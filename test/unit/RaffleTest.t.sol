//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import{Test, console} from "forge-std/Test.sol";

contract RaffleTest is Test{
    Raffle raffle;

    address public PLAYER=makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE= 10 ether;

    function setUp() external{
        DeployRaffle deployRaffle= new DeployRaffle();
        raffle=deployRaffle.run();
    }
}