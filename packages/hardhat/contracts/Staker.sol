// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint) public balances;

  uint public constant threshold = 1 ether;

  uint public deadline = block.timestamp +  96 hours;

  event Stake(address staker, uint amountStaked);

  bool public openForWithdraw;

  modifier notCompleted() {
    require(exampleExternalContract.completed() == false, "You cannot call this method after deadline");
    _;
  }

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable notCompleted returns(bool) {
      require(block.timestamp < deadline, "You can only stake before the deadline");
      uint currentBalance = balances[msg.sender];
      balances[msg.sender] = currentBalance + msg.value;
      emit Stake(msg.sender, msg.value);
      return true;
    }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public returns(bool) {
    require(block.timestamp >= deadline, "You can only call this function after the deadline");
    uint currentEthBalance = address(this).balance;
    if(currentEthBalance >= threshold){
      exampleExternalContract.complete{value:currentEthBalance}();
    }
    if(currentEthBalance < threshold){
      openForWithdraw = true;
    }
    return true;
    
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public notCompleted returns(bool) {
    require(openForWithdraw == true, "Cannot withdraw");
    uint currentBalance = balances[msg.sender];
    balances[msg.sender] = balances[msg.sender] - currentBalance;
    payable(msg.sender).transfer(currentBalance);
    return true;
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint) {
    uint timeRemaining;
    if(deadline > block.timestamp){
      timeRemaining =  deadline - block.timestamp;
    }
    if(deadline < block.timestamp){
      timeRemaining = 0;
    }

    return timeRemaining;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }

}
