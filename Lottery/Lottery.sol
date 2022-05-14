// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// We can use 'receive()' only once in contract
// used to receive ether or amount send by external user

    contract Lottery {
        address public manager;
        address payable[] participents;

        constructor(){
            manager = msg.sender;
        }
        receive() external payable{
            require(msg.value == 1 ether, "You are not allowed to enter");
            participents.push(payable(msg.sender));
        }
        function getBalance() public view returns(uint){
            require(msg.sender == manager, "Only manager can do this");
            return address(this).balance;
        }
        function random() public view returns(uint){
            return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,participents.length)));
        }
        function selectWinner() public {
            require(msg.sender == manager, "Only mananger can select winner");
            require(participents.length >= 3);
            uint r = random();
            uint winnerIndex = r % participents.length; 
            address payable winner = participents[winnerIndex];
            winner.transfer(getBalance());
            participents = new address payable[](0);
        }
    }