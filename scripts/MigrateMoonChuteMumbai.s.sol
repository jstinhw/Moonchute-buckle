pragma solidity ^0.8.0;

import {KernelFactory} from "src/KernelFactory.sol";
import {SampleNFT} from "samples/SampleNFT.sol";
import {VerifyingPaymaster} from "src/paymaster/VerifyingPaymaster.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 

struct Kernelv1 {
    address userAddress;
    address twoFactorAddress;
}

contract DeployMoonChute is Script {
    function run() public {
        uint256 key = vm.envUint("MUMBAI_DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        KernelFactory factory = KernelFactory(0xdDA927cC691811929a40D3CF9bD154e10aE45b73);
        Kernelv1[] memory kernels = new Kernelv1[](7);
        kernels[0] = 
            Kernelv1(0x27FB75d177E01103827068357cbaBEDa12ed7e1C, 0xe3918d6e35272FA5849bc0E27f41505CD37C3Da0);
        
        kernels[1] = 
            Kernelv1(0xCa8296fca4FCc9D0eEb6b4919A8D944E9cfdd0cb, 0xDeCaA71170fffA4661d66846Cb3094043BBDCF77);

        kernels[2] = 
            Kernelv1(0x9cf5DD981fadC6F97aDBD56e315Ea16299B57a38, 0x51d58087ca4D2E998090CD4ef5F8D34e858A5622);
        
        kernels[3] = 
            Kernelv1(0x533F5E1b722DcC12FeE6c1418Ac7241Fb20E4d25, 0x39801ceF88357e20a42af7aB63B22171D71A65e1);
        
       kernels[4] = 
            Kernelv1(0x0eD0C862678B9532D109a625fD03c8D25A906430, 0xDC904F21D3246C58ba5cF99A013A73cBBcBC1aa5);
        
        kernels[5] = 
            Kernelv1(0xCa073B72aeb5459E7FF462a5269730AC5531A510, 0x45f97B26e9D836dB74d3e1BAD8B9028AC105993A);

        kernels[6] = 
            Kernelv1(0x4422fb6cc641E2485a4f7f8fe23e93797bd4EaA4, 0x92E766815ed3943138758BD6736253D521782c59);


        for (uint i = 0; i < kernels.length; i++) {
            factory.createAccount(kernels[i].userAddress, 0, kernels[i].twoFactorAddress);
            address kernelAddress = factory.getAccountAddress(kernels[i].userAddress, 0, kernels[i].twoFactorAddress);
            console2.log("user:", kernels[i].userAddress ,"Kernel address: ", kernelAddress);
        }
        vm.stopBroadcast();
    }
}

