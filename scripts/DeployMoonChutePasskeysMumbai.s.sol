pragma solidity ^0.8.0;

import {KernelFactoryPasskeys} from "src/KernelFactoryPasskeys.sol";
import {SampleNFT} from "samples/SampleNFT.sol";
import {VerifyingPaymaster} from "src/paymaster/VerifyingPaymaster.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 

contract DeployMoonChute is Script {
    function run() public {
        uint256 key = vm.envUint("MUMBAI_DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        address payable entryPoint = payable(vm.envAddress("MUMBAI_ENTRYPOINT_ADDRESS"));
        KernelFactoryPasskeys factory = new KernelFactoryPasskeys(IEntryPoint(entryPoint));

        vm.stopBroadcast();
    }
}

