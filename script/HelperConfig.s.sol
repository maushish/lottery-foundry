//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";


contract HelperConfig is Script{
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator; 
        bytes32 keyHash;
        uint64 subscriptionId; 
        uint32 callbackGasLimit;
        address link;
        uint256 key;
    }
    NetworkConfig public activeNetworkConfig;

    constructor(){
        if(block.chainid== 11155111){
            activeNetworkConfig=getSepoliaEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee:0.001 ether,
            interval: 30 seconds,
            vrfCoordinator:0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            keyHash:0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 7050,
            callbackGasLimit: 200000,
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789,
            key:vm.envUint("PRIVATE_KEY")
        });
    }
    

}