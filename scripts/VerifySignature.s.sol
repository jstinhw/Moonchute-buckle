import {Kernel, KernelStorage} from "src/Kernel.sol";
import {KernelFactory} from "src/KernelFactory.sol";
import {SampleNFT} from "samples/SampleNFT.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

using ECDSA for bytes32;

contract VerifyMoonChuteOps is Script {
    EntryPoint public entryPoint = EntryPoint(payable(0x5FbDB2315678afecb367f032d93F642f64180aa3));
    KernelFactory public kernelFactory = KernelFactory(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
    SampleNFT public sampleNFT = SampleNFT(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);
    
    uint256 bundlerPrivKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address payable bundler = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address user1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 user1PrivKey = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address user2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 user2PrivKey = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

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

    function run() public {
      vm.startBroadcast(user1PrivKey);

      address account = kernelFactory.getAccountAddress(bundler, 0, bundler);
      entryPoint.depositTo{value: 1000000000000000000}(account);
      UserOperation[] memory ops = new UserOperation[](1);
      
      ops[0] = UserOperation({
          sender: account,
          nonce: 0,
          initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (bundler, 0, bundler))),
          callData: abi.encodeWithSelector(
            // hex"940d3c60", account, 0, abi.encodeCall(KernelStorage.getOwner, ()), 0
            hex"940d3c60", address(sampleNFT), 0, abi.encodeCall(SampleNFT.mint, (account)), 0
          ),
          callGasLimit: 100000,
          verificationGasLimit: 200000,
          preVerificationGas: 100000,
          maxFeePerGas: 100000,
          maxPriorityFeePerGas: 100000,
          paymasterAndData: hex"",
          signature: hex""
      });
      ops[0].signature = bytes.concat(signUserOp(ops[0], bundler, bundlerPrivKey), signUserOp(ops[0], bundler, bundlerPrivKey));
      entryPoint.handleOps(ops, bundler);
      vm.stopBroadcast();
    }

    // function run() public {
    //     uint256 key = vm.envUint("DEPLOYER_PRIVATE_KEY");
    //     // ops start
    //     vm.startBroadcast(bundlerPrivKey);

    //     // op
    //     address payable account = payable(kernelFactory.getAccountAddress(bundler, 0, bundler));
    //     entryPoint.depositTo{value: 1000000000000000000}(account);

    //     UserOperation[] memory ops = new UserOperation[](1);
    //     ops[0] = UserOperation({
    //         sender: account,
    //         nonce: 0,
    //         initCode: abi.encodePacked(kernelFactory, abi.encodeCall(KernelFactory.createAccount, (bundler, 0, bundler))),
    //         callData: abi.encodeWithSelector(
    //           hex"940d3c60", address(account), 0, abi.encodeCall(Kernel.lock, ()), 0
    //         ),
    //         callGasLimit: 10000000000,
    //         verificationGasLimit: 3000000000,
    //         preVerificationGas: 200000,
    //         maxFeePerGas: 1000000,
    //         maxPriorityFeePerGas: 1000000,
    //         paymasterAndData: hex"",
    //         signature: hex""
    //     });
    //     ops[0].signature = signUserOp(ops[0], bundler, bundlerPrivKey);

    //     entryPoint.handleOps(ops, account);
    //     vm.stopBroadcast();
    // }
}
