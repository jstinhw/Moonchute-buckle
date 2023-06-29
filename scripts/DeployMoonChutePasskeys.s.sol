pragma solidity ^0.8.0;

import {KernelFactoryPasskeys} from "src/KernelFactoryPasskeys.sol";
import {SampleNFT} from "samples/SampleNFT.sol";
import {VerifyingPaymaster} from "src/paymaster/VerifyingPaymaster.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 

contract DeployMoonChute is Script {
    function run() public {
        uint256 key = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        EntryPoint entryPoint = new EntryPoint();
        KernelFactoryPasskeys factory = new KernelFactoryPasskeys(IEntryPoint(address(entryPoint)));
        SampleNFT sampleNFT = new SampleNFT();
        VerifyingPaymaster paymaster = new VerifyingPaymaster(entryPoint, vm.addr(key));
        entryPoint.depositTo{value: 1000000000000000000}(address(paymaster));
        vm.stopBroadcast();
    }
}

