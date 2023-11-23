//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
contract RaffleTest is Test{
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator; 
    bytes32 keyHash;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER=makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE= 10 ether;

    function setUp() external{
        DeployRaffle deployRaffle= new DeployRaffle();
        (raffle, helperConfig)=deployRaffle.run();
        (entranceFee,
         interval,
         vrfCoordinator, 
         keyHash,
         subscriptionId,
         callbackGasLimit)=helperConfig.activeNetworkConfig();
    }
    function testRaffleInitalizesInOpenState() public view{
        assert(raffle.getRaffleState()==Raffle.RaffleState.OPEN);
    }
    //////////////////////////////////////////
    ////// enterRaffle            //////////
    ////////////////////////////////////////
    function testRaffleWhenYouDontPayEnough() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        //Assert
        raffle.enterRaffle();

    }
    function testRaffleRecordsPLayersWhenTheyEnter() public{
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER); 
    }
}