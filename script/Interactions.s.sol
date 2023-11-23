//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";  
import {HelperConfig} from "./HelperConfig.s.sol";  
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";


contract CreateSubscription is Script{
    function createSubscriptionUsingConfig() public returns(uint64){
        HelperConfig helperConfig= new HelperConfig();
        (,,
         address vrfCoordinator
         ,,, 
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator);

    }

    function createSubscription(
        address vrfCoordinator
        ) public returns(uint64)
    {
        console.log("creating subscription on Chain-id",block.chainid);    
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub id", subId);
        console.log("Pls update subscroption id in HelperConfig.sol");
        return subId;
    
    }

    function run() external returns(uint64) {
        return createSubscriptionUsingConfig();
    }
}


contract FundSubscription is Script{
    uint96 public constant LINK_AMOUNT= 3 ether;

    function fundSubscriptionUsingConfig() public{
        HelperConfig helperConfig= new HelperConfig();
        (,,
         address vrfCoordinator
         ,,uint64 subId,address link 
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator,subId, link);

    }
    function fundSubscription(address vrfCoordinator,uint64 subId, address link) public{
        console.log("funding subscription:",subId);
        console.log("using vrfCoordinator",vrfCoordinator);
        console.log("on ChainId",block.chainid);
    }
    function run() external{
        fundSubscriptionUsingConfig();  
    }
}