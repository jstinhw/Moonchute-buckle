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

using ECDSA for bytes32;

contract MoonChuteTest is Test {
  EntryPoint entryPoint;
  KernelFactory kernelFactory;
  SampleNFT sampleNFT;

  address payable bundler;
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
    bundler = payable(makeAddr("bundler"));
    sampleNFT = new SampleNFT();
    
    // vm.prank(user1);
    // sampleNFT.mint(user1);
    // assert(sampleNFT.balanceOf(user1) == 1);
    // assert(sampleNFT.ownerOf(1) == user1);
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

    entryPoint.handleOps(ops, bundler);
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
    entryPoint.handleOps(ops, bundler);
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
    entryPoint.handleOps(opsTransfer, bundler);
    assert(sampleNFT.balanceOf(account) == 0);
    assert(sampleNFT.balanceOf(user1) == 1);

    assert(sampleNFT.ownerOf(1) == user1);
  }
}