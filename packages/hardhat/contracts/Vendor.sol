pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  error NotEnoughETH();

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns(bool) {
    uint amountOfTokens = (msg.value*100);
    if(msg.value < 0) revert NotEnoughETH();
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    return true;
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner returns(bool){
    uint EthBalance = address(this).balance;
    payable(msg.sender).transfer(EthBalance);
    return true;
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint amountToSell) public returns(bool) {
    require(amountToSell > 0, "amount to sell is less than 0");
    yourToken.transferFrom(msg.sender, address(this), amountToSell);
    uint ethValue = amountToSell/100;
    payable(msg.sender).transfer(ethValue);
    return true;
  }

}
