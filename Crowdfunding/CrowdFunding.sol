//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

    contract CrowdFunding {
            mapping(address => uint) public contributors;
            address public manager;
            uint public minContribution;
            uint public target;
            uint public deadline;
            uint public raisedAmount;
            uint public noOfContributors;
        struct Request{
            string description;
            address payable receiptant;
            bool completed;
            uint value;
            uint noOfVoters;
            mapping(address => bool) voters;
        }
        mapping(uint => Request) public requests;
        uint public noOfRequests;

        constructor(uint _target, uint _deadline){
            manager = msg.sender;
            target = _target;
            deadline = block.timestamp + _deadline;
            minContribution = 100 wei;
        }
        function sendEther() public payable {
            require(block.timestamp < deadline, "Deadline is passed");
            require(msg.value >= minContribution, "Minimun contribution is 100wei*");

            if(contributors[msg.sender] == 0){
                noOfContributors++;
            }
            contributors[msg.sender] += msg.value;
            raisedAmount += msg.value; 
        }
        function refund() public{
            require(block.timestamp > deadline && raisedAmount < target);
            require(contributors[msg.sender] > 0);
            address payable user = payable(msg.sender);
            user.transfer(contributors[msg.sender]);
            contributors[msg.sender] = 0;
        }
        function createRequest(string memory _description, address payable _receiptant,uint _value) public {
            require(msg.sender == manager, "Only Mnager can create request");
            // If you want to use mapping from struct then use storage
            Request storage newRequest = requests[noOfRequests];
            noOfRequests++;
            newRequest.description = _description;
            newRequest.receiptant = _receiptant;
            newRequest.value = _value;
            newRequest.completed =false;
            newRequest.noOfVoters =0;
        }
        function voteRequest(uint _reqNo) public {
            require(contributors[msg.sender] >0,"You must be contributor");
            Request storage thsiVoteRequest = requests[_reqNo];
            require(thsiVoteRequest.voters[msg.sender] == false,"You have already voted");
            thsiVoteRequest.voters[msg.sender] = true;
            thsiVoteRequest.noOfVoters++;
        } 
        function makePayment(uint _reqqNumber) public {
            require(msg.sender == manager,"Only manager can make payments");
            require(raisedAmount >= target);
            Request storage thatReq = requests[_reqqNumber];
            require(thatReq.completed == false,"Request is alredy completed");
            require(thatReq.noOfVoters > noOfContributors/2,"Majority is against the request");
            thatReq.receiptant.transfer(thatReq.value);
            thatReq.completed = true;
        }
    } 