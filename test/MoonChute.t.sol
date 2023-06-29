// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "account-abstraction/core/EntryPoint.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {SampleNFT} from "samples/SampleNFT.sol";
import {Kernel, KernelStorage} from "src/Kernel.sol";
import {KernelFactory} from "src/KernelFactory.sol";
import {VerifyingPaymaster} from "src/paymaster/VerifyingPaymaster.sol";

using ECDSA for bytes32;

contract MoonChuteTest is Test {
  EntryPoint entryPoint;
  KernelFactory kernelFactory;
  SampleNFT sampleNFT;
  VerifyingPaymaster paymaster;

  address bundler;
  uint256 bundlerPrivKey;
  address user1;
  uint256 user1PrivKey;
  address user2;
  uint256 user2PrivKey;

  constructor() {}

  function setUp() public {
    entryPoint = new EntryPoint();
    kernelFactory = new KernelFactory(entryPoint);
    (user1, user1PrivKey) = makeAddrAndKey("user1");
    (user2, user2PrivKey) = makeAddrAndKey("user2");
    (bundler, bundlerPrivKey) = makeAddrAndKey("bundler");
    paymaster = new VerifyingPaymaster(entryPoint, bundler);
    sampleNFT = new SampleNFT();
  }

  function signUserOp(UserOperation memory op, address addr, uint256 key)
      public
      view
      returns (bytes memory signature)
  {
      bytes32 hash = entryPoint.getUserOpHash(op);
      (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, hash.toEthSignedMessageHash());
      require(addr == ECDSA.recover(hash.toEthSignedMessageHash(), v, r, s));
      signature = abi.encodePacked(r, s, v);
      require(addr == ECDSA.recover(hash.toEthSignedMessageHash(), signature));
  }

  function signPaymasterOp(UserOperation memory op, address addr, uint256 key, uint48 validUntil, uint48 validAfter)
      public
      view
      returns (bytes memory signature)
  {
      bytes32 hash = paymaster.getHash(op, validUntil, validAfter);
       (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, hash.toEthSignedMessageHash());
      require(addr == ECDSA.recover(hash.toEthSignedMessageHash(), v, r, s));
      signature = abi.encodePacked(r, s, v);
      require(addr == ECDSA.recover(hash.toEthSignedMessageHash(), signature));
  }

  function testCallAA() public {
    address payable account = payable(kernelFactory.getAccountAddress(user1, 0, user2));
    entryPoint.depositTo{value: 1000000000000000000}(account);
    UserOperation[] memory ops = new UserOperation[](1);
    ops[0] = UserOperation({
        sender: account,
        nonce: 0,
        initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", account, 0, abi.encodeCall(KernelStorage.getOwner, ()), 0
          // hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    ops[0].signature = signUserOp(ops[0], user1, user1PrivKey);

    entryPoint.handleOps(ops, payable(bundler));
  }

  function testCallOutside () public {
    address payable account = payable(kernelFactory.getAccountAddress(user1, 0, user2));
    entryPoint.depositTo{value: 1000000000000000000}(account);
    
    // mint
    UserOperation[] memory ops = new UserOperation[](1);
    ops[0] = UserOperation({
        sender: account,
        nonce: 0,
        initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    bytes memory sigSigner = signUserOp(ops[0], user1, user1PrivKey);
    bytes memory sigTwoFactor = signUserOp(ops[0], user2, user2PrivKey);
    ops[0].signature = abi.encodePacked(sigSigner, sigTwoFactor);
    entryPoint.handleOps(ops, payable(bundler));
    assert(sampleNFT.balanceOf(account) == 1);
    assert(sampleNFT.ownerOf(1) == account);
    
    // transfer
    UserOperation[] memory opsTransfer = new UserOperation[](1);
    opsTransfer[0] = UserOperation({
        sender: account,
        nonce: 1,
        initCode: "", // abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(IERC721.transferFrom, (account, user1, 1)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    bytes memory sigSignerTransfer = signUserOp(opsTransfer[0], user1, user1PrivKey);
    bytes memory sigTwoFactorTransfer = signUserOp(opsTransfer[0], user2, user2PrivKey);

    console2.logBytes(opsTransfer[0].callData);
    opsTransfer[0].signature = abi.encodePacked(sigSignerTransfer, sigTwoFactorTransfer);
    entryPoint.handleOps(opsTransfer, payable(bundler));
    assert(sampleNFT.balanceOf(account) == 0);
    assert(sampleNFT.balanceOf(user1) == 1);

    assert(sampleNFT.ownerOf(1) == user1);
  }

  function testCallWithPaymaster () public {
    address payable account = payable(kernelFactory.getAccountAddress(user1, 0, user2));
    entryPoint.depositTo{value: 1000000000000000000}(address(paymaster));

    // mint
    UserOperation[] memory ops = new UserOperation[](1);
    ops[0] = UserOperation({
        sender: account,
        nonce: 0,
        initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    // paymaster Data
    uint48 validUntil = uint48(0);
    uint48 validAfter = uint48(0);
    bytes memory sigMock = signPaymasterOp(ops[0], bundler, bundlerPrivKey, validUntil, validAfter);

    ops[0].paymasterAndData = abi.encodePacked(
        paymaster,
        abi.encodePacked(
            uint256(validUntil),
            uint256(validAfter),
            sigMock
        )
    );
    bytes memory sigPaymaster = signPaymasterOp(ops[0], bundler, bundlerPrivKey, validUntil, validAfter);
    bytes memory paymasterData = abi.encodePacked(
        uint256(validUntil),
        uint256(validAfter),
        sigPaymaster
    );
    ops[0].paymasterAndData = abi.encodePacked(
        paymaster,
        paymasterData
    );
    bytes memory sigSigner = signUserOp(ops[0], user1, user1PrivKey);
    bytes memory sigTwoFactor = signUserOp(ops[0], user2, user2PrivKey);
    ops[0].signature = abi.encodePacked(sigSigner, sigTwoFactor);
    

    entryPoint.handleOps(ops, payable(bundler));
    assert(sampleNFT.balanceOf(account) == 1);
    assert(sampleNFT.ownerOf(1) == account);
  }

  function testInvalidSignature() public {
     address payable account = payable(kernelFactory.getAccountAddress(user1, 0, user2));
    entryPoint.depositTo{value: 1000000000000000000}(account);
    UserOperation[] memory ops = new UserOperation[](1);
    ops[0] = UserOperation({
        sender: account,
        nonce: 0,
        initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", account, 0, abi.encodeCall(KernelStorage.getOwner, ()), 0
          // hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    ops[0].signature = signUserOp(ops[0], user1, user1PrivKey);

    entryPoint.handleOps(ops, payable(bundler));

    // sign message
    string memory message = "Hello World!";
    bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", bytes(message).length, message));
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivKey, messageHash.toEthSignedMessageHash());
    bytes memory signature = abi.encodePacked(r, s, v);
    bytes memory magic_value = abi.encodeWithSelector(0xffffffff);
    bytes memory isValid = abi.encodeWithSelector(Kernel(account).isValidSignature(messageHash, signature));
    assertEq(isValid, magic_value);
  }

  function testValidSignature() public {
     address payable account = payable(kernelFactory.getAccountAddress(user1, 0, user2));
    entryPoint.depositTo{value: 1000000000000000000}(account);
    UserOperation[] memory ops = new UserOperation[](1);
    ops[0] = UserOperation({
        sender: account,
        nonce: 0,
        initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (user1, 0, user2))),
        callData: abi.encodeWithSelector(
          hex"940d3c60", account, 0, abi.encodeCall(KernelStorage.getOwner, ()), 0
          // hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
        ),
        callGasLimit: 100000,
        verificationGasLimit: 300000,
        preVerificationGas: 200000,
        maxFeePerGas: 100000,
        maxPriorityFeePerGas: 100000,
        paymasterAndData: hex"",
        signature: hex""
    });
    ops[0].signature = signUserOp(ops[0], user1, user1PrivKey);

    entryPoint.handleOps(ops, payable(bundler));

    // sign message
    string memory message = "Hello World!";
    bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", bytes(message).length, message));
    (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(user1PrivKey, messageHash.toEthSignedMessageHash());
    (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(user2PrivKey, messageHash.toEthSignedMessageHash());

    bytes memory signatureOwner = abi.encodePacked(r1, s1, v1);
    bytes memory signatureTwoFactor = abi.encodePacked(r2, s2, v2);

    bytes memory magic_value = abi.encodeWithSelector(0x1626ba7e);
    bytes memory isValid = abi.encodeWithSelector(Kernel(account).isValidSignature(messageHash, abi.encodePacked(signatureOwner, signatureTwoFactor)));
    assertEq(isValid, magic_value);
  }
}
