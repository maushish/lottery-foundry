//SPDX-License-Identifier: MIT
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

pragma solidity ^0.8.18;

contract DeployRaffle is Script{
    function run () external returns(Raffle){
        HelperConfig helperConfig= new HelperConfig();
        (uint256 entranceFee,
         uint256 interval,
         address vrfCoordinator, 
         bytes32 keyHash,
         uint64 subscriptionId, 
         uint32 callbackGasLimit)=helperConfig.activeNetworkConfig();
    }
    vm.startBroadcast();
    Raffle raffle= new Raffle(
        entranceFee,
        interval,
        vrfCoordinator,
        keyHash,
        subscriptionId,
        callbackGasLimit
    );
    vm.stopBroadcast();
    return raffle;

}