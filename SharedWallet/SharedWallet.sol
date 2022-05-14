//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import './Allowance.sol'; 

contract SharedWallet is Allowance {

    event TransferMoney(address _beneficiery, uint _amount);
    event MoneyReceived(address _from, uint _amount);
    event WithdrawAllowance(address _add, uint _amount); 

    // withdraw money uisng address and amount to withdraw
    function withdrawMoney(address payable _to, uint _amount) public payable onlyOwner {
        require(_amount <= address(this).balance, "Not enough funds ");
        // owner can also transfer allowance to the allower
        if(checkIsAllower(_to) == true){
            deductAllowance(_to,_amount);
        }
        emit TransferMoney(_to,_amount);
        _to.transfer(_amount);
    }

    // allower can withdraw the allowance
    function withdrawAllowance(uint _amt) public payable returns(bool) {
        require(checkIsAllower(msg.sender) == true, "You are not allower" );
        require(allowance[msg.sender] >= _amt,"You dont have enough allowance which you trying to withdraw");
        deductAllowance(msg.sender,_amt);
        payable(msg.sender).transfer(_amt);
        emit WithdrawAllowance(msg.sender,_amt);
        return true;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    receive() external payable {}

    function renounceOwnership() public override virtual onlyOwner {
        revert();
    }
    function transferOwnership() public virtual onlyOwner {
        revert();
    }
}