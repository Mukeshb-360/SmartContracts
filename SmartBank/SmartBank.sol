// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract SmartBank is Ownable {

    uint private bankBalance = 0;
    mapping(address => uint) public accountVsBalance;
    mapping(address => timeStamp) timeStamps;
    using SafeMath for uint;

    struct timeStamp {
        uint[] deepositeTime;
        uint[] withdrawTime;
    }

    function getBankBalance() public view onlyOwner returns(uint){
        return bankBalance;
    }

    function depositMoney(address payable _accNumber, uint _amount) public payable {
        accountVsBalance[_accNumber] = _amount;
        bankBalance =bankBalance.add(_amount);
        timeStamp storage ts = timeStamps[_accNumber];
        ts.deepositeTime.push(block.timestamp);
    }

    function getAddressBalance(address _accNumber) internal view returns(uint){
        uint principalAmount = accountVsBalance[_accNumber];
        timeStamp storage ts = timeStamps[_accNumber];
        uint timeLapsed = block.timestamp - ts.deepositeTime[0];
        uint interestAmount = uint((principalAmount * 7 * timeLapsed) / (100 * 365 * 24 * 60 * 60)) + 1;
        return principalAmount + interestAmount;
    }

    function withdrawMoney(uint _amount) public payable{
       // check - weather caller did any deposits or not 
       require(accountVsBalance[msg.sender] != 0, "You havent made any deposits yet");
       uint amountAvailableToWithdraw = getAddressBalance(msg.sender);
       console.log("amountAvailableToWithdraw : ", amountAvailableToWithdraw);
       // check - requested amount should be less than withdrawable amount
       require(amountAvailableToWithdraw >= _amount, "Insufficent Funds");
       // deducting the funds from the callers account
       accountVsBalance[msg.sender] -=_amount;
       // transfer requested funds to the caller 
       (bool success, ) = msg.sender.call{value: _amount}("");
       require(success, "Transfer failed.");
       //payable(msg.sender).transfer(_amount);
       timeStamp storage ts = timeStamps[msg.sender];
       // add withdraw time to array 
       ts.withdrawTime.push(block.timestamp);
    }
}