// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract SmartBank is Ownable {

    address public owner;
    uint private bankBalance = 0;
    mapping(address => uint) public accountVsBalance;
    mapping(address => timeStamp) timeStamps;
    using SafeMath for uint;

    constructor() {
        owner == msg.sender;
    }

    modifier OnlyDepositors{
        require(accountVsBalance[msg.sender] != 0, "You havent made any deposits yet");
        _;
    }
    struct timeStamp {
        uint[] deepositeTime;
        uint[] withdrawTime;
    }

    function getBankBalance() public view onlyOwner returns(uint){
        return bankBalance;
    }

    function depositMoney(uint _amount) public payable {
        accountVsBalance[msg.sender] = _amount;
        bankBalance =bankBalance.add(_amount);
        timeStamp storage ts = timeStamps[msg.sender];
        ts.deepositeTime.push(block.timestamp);
    }

    function getAddressBalance(address _accNumber) internal view OnlyDepositors returns(uint){
        uint principalAmount = accountVsBalance[_accNumber];
        timeStamp storage ts = timeStamps[_accNumber];
        uint timeLapsed = block.timestamp - ts.deepositeTime[0];
        uint interestAmount = uint((principalAmount * 7 * timeLapsed) / (100 * 365 * 24 * 60 * 60)) + 1;
        return principalAmount + interestAmount;
    }

    function selfTransfer(uint _amount) public OnlyDepositors {
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

    function transferMoney(address _to, uint _amount) public OnlyDepositors {
        uint amountAvailableToWithdraw = getAddressBalance(msg.sender);
        require(amountAvailableToWithdraw >= _amount, "Insufficent Funds");
        accountVsBalance[msg.sender] -=_amount;
       // transfer funds to the requested account 
       (bool success, ) = _to.call{value: _amount}("");
       require(success, "Transfer failed.");
       timeStamp storage ts = timeStamps[msg.sender];
       ts.withdrawTime.push(block.timestamp);
    }

    function shutTheBank(address _add) public onlyOwner { 
        selfdestruct(owner); 
    }
}