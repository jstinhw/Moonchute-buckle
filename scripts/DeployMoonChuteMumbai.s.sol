pragma solidity ^0.8.0;

import {KernelFactory} from "src/KernelFactory.sol";
import {SampleNFT} from "samples/SampleNFT.sol";
import {VerifyingPaymaster} from "src/paymaster/VerifyingPaymaster.sol";

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol"; 

contract DeployMoonChute is Script {
    function run() public {
        uint256 key = vm.envUint("MUMBAI_DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        // existing entry point
        address payable entryPoint = payable(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
        // 1. deploy kernel factory
        KernelFactory factory = new KernelFactory(IEntryPoint(address(entryPoint)));
        // 2. deploy paymaster
        // VerifyingPaymaster paymaster = new VerifyingPaymaster(EntryPoint(entryPoint), vm.addr(key));
        // 3. deposit to paymaster
        // paymaster.addStake{value: 100000000000000000}(1);
        vm.stopBroadcast();
    }
}

