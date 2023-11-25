//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VM} from "forge-vm/VM.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test{

    /**---EVENTS-------------- */
    event EnteredRaffle(address indexed player);




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
         vm.deal(PLAYER, STARTING_USER_BALANCE);
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
    function testEmitsOnEntrace() public{
        vm.prank(PLAYER);
        vm.expectEmit(true,false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
    function testCantEnterWhenRaffleIsCalculating()public  {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp+interval+1);
        vm.roll(block.number+1);
        raffle.performUpKeep("");
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();   
    }


    //////////////////////////////
    // checkUpKeep              //
    /////////////////////////////

    function testCheckUpKeepReturnsFalseIfItHasNoBalance() public{
        //Arrange
        vm.warp(block.timestamp+interval+1);
        vm.roll(block.number+1);

        //Act
        (bool upkeepNeeded, )=raffle.checkUpkeep("");
        //Assert
        assert(!upkeepNeeded);
        }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() public{
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp+interval+1);
        vm.roll(block.number+1);
        raffle.performUpKeep("");
        //ACT
        (bool upkeepNeeded, )=raffle.checkUpKeep("");
        //Assert
        assert(!upkeepNeeded==false);
        
        function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public{
            //arrange
            vm.prank(PLAYER);
            raffle.enterRaffle{value: entranceFee}();
            vm.warp(block.timestamp+interval+1);
            vm.roll(block.number+1);

            //act 
            //assert
            raffle.performUpKeep("");   
        }
        function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public{
            //arrange
            uint256 currentBalance=0;
            uint256 numPlayers=0;
            uint256 raffleState=0;
            //act/assert
            vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, currentBalance, numPlayers) );
            raffle.performUpKeep("");

        }

        modifier raffleEnteredTimePassed() {
            vm.prank(PLAYER);
            raffle.enterRaffle{value: entranceFee}();
            vm.warp(block.timestamp+interval+1);
            vm.roll(block.number+1);
        }
        //what if i need to test using the output of an event generally its not possible but coz we are using chainlink it is
        //we can use the chainlink events to test the output of the performUpkeep function
        function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public{
            //arrange
            raffleEnteredTimePassed{
                //act
                //using cheatcode recordLogs to record the logs of all events
                vm.recordLogs();
                raffle.performUpKeep("");//will emit request id
                Vm.Log[] memory entries=vm.getRecordedLogs();
                bytes32 requestId=entries[1].topics[1];//all logs are in bytes32 in foundry
                //assert
                Raffle.RaffleState raffleState=raffle.getRaffleState();
                assert(uint256(requestId)>0);
                assert(uint256(rState)==1);
            }
        }
        function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) public raffleEnteredAndTimePassed{
            //arrange
            vm.expectRevert("nonexistent req");
            VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId,address(raffle));
        }
        function testFulfillRandomWordsPickAWinnerResetsAndSendsMoney() public raffledEnteredAndTimePassed{
            //arrange
            uint256 additionalEntrants=5;
            uint256 startingIndex=1;
            for(uint256 i= startingIndex; i<startingIndex+additionalEntrants; i++)
            {
                address player= address(uint160(i));//address(1,2,3......)
                hoax(player,1 ether);//hoax is a prank which gives ether 
                raffle.enterRaffle{value: entranceFee}();
            }

            uint256 prize =entranceFee*(additionalEntrants+1);

            vm.recordLogs();
            raffle.performUpKeep("");//will emit request id
            Vm.Log[] memory entries=vm.getRecordedLogs();
            bytes32 requestId=entries[1].topics[1];
            
            uint256 previousTimeStamp=raffle.getLastTimeStamp();
            //pretend to be chainlink vrf coordinator
            VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId,address(raffle));
            //assert
            assert(uint256(raffle.getRaffleState())==0);
            assert(raffle.getRecentWinner()!= address(0));
            assert(raffle.getLengthOfPlayers()==0);
            assert(previousTimeStamp<raffle.getLastTimeStamp());
            assert(raffle.getRecentWinnerBalance()==STARTING_USER_BALANCE+ prize-entranceFee);

        }
}