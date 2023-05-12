pragma solidity ^0.8.0;

import {KernelFactory} from "src/KernelFactory.sol";
import {SampleNFT} from "samples/SampleNFT.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 

contract DeployMoonChute is Script {
    function run() public {
        uint256 key = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        EntryPoint entryPoint = new EntryPoint();
        KernelFactory factory = new KernelFactory(IEntryPoint(address(entryPoint)));
        SampleNFT sampleNFT = new SampleNFT();
        vm.stopBroadcast();
    }
}

