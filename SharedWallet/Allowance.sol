//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {
    // using openZeppelin safeMath library
    using SafeMath for uint;
    event allowdAllowance(address indexed __toWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);
    mapping(address => uint) public allowance;
    address isOwner = owner();

    // function will check is address of caller is in the allowance mapping or not 
    function checkIsAllower(address _add) internal view returns(bool){
        if(allowance[_add] >0){
            return true;
        }
        else{
            return false;
        }
    }

    function giveAllowance(address _to, uint _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Not enough funds");
        emit allowdAllowance(_to,msg.sender,allowance[_to],_amount);
        allowance[_to] = _amount;
    }
    
    // function will deduct allowance from allowers account once withdrawal is done
    function deductAllowance(address _who, uint _amount) internal{
        emit allowdAllowance(_who,msg.sender,allowance[_who],allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}