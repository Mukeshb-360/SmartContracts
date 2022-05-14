// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.5;

contract mappingAndStructs{

    struct Payment {
        uint amount;
        uint timeStamps;
    }

    struct Balance {
        uint totaolBalance;
        uint numOfPayments;
        mapping(uint => Payment) payments;
    }
    event moneySent(address,uint);
    mapping(address => Balance) moneyReceived;

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function sendMoney() public payable{
        moneyReceived[msg.sender].totaolBalance += msg.value;
        // Payment memory payment = Payment(msg.value, block.timestamp);
        // moneyReceived[msg.sender].payments[moneyReceived[msg.sender].numOfPayments] = payment;
        moneyReceived[msg.sender].numOfPayments++;
        //emit moneySent(msg.sender,msg.value);
    }

    function withdrawAllMoney(address payable _to) public {
        //uint moneyToWithdraw = moneyReceived[msg.sender];
        moneyReceived[msg.sender].totaolBalance = 0;
        //_to.transfer(moneyToWithdraw);
        _to.transfer(moneyReceived[msg.sender].totaolBalance);
    }

    function withdrawRequestedAmt(address payable _to, uint _amount) public {
        require(moneyReceived[msg.sender].totaolBalance >= _amount, "Insuffient funds");
        moneyReceived[msg.sender].totaolBalance -= _amount;
        _to.transfer(_amount);
    }

    fallback() external payable{}
    receive() external payable {}
}