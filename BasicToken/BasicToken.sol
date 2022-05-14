//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

    interface ERC20Interface {
        function totalSupply() external view returns (uint);
        function balanceOf(address tokenOwner) external view returns (uint balance);
        function transfer(address to, uint tokens) external returns (bool success);

        function allowance(address tokenOwner, address spender) external view returns (uint remaining);
        function approve(address spender, uint tokens) external returns (bool success);
        function transferFrom(address from, address to, uint tokens) external returns (bool success);

        event Transfer(address indexed from, address indexed to, uint tokens);
        event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    }

    contract IndianNationArmy is ERC20Interface {
        string public name = "Indian National Army";
        string public symbol= "INA";

        uint public decimal = 0;
        address public founder;
        uint public override totalSupply;
        mapping(address=>uint) public balances;
        mapping(address=>mapping(address => uint)) public allowed;

        constructor(){
            founder = msg.sender;
            totalSupply =10000000;
            balances[founder] = totalSupply;
        }
        // starting balance of tokens / total supply of tokens
        function balanceOf(address tokenOwner) public view override returns(uint balance){
            return balances[tokenOwner];
        }
        // transfer tokens to address
        function transfer(address to, uint tokens) public override virtual returns (bool success){
            require(balances[msg.sender] >= tokens,"You don't have sufficient balance");
            balances[to] = balances[to] + tokens;
            balances[msg.sender] = balances[msg.sender] - tokens;
            emit Transfer(msg.sender,to,tokens);
            return true;
        }
        // approval from owner to spend the token
        function approve(address spender, uint tokens) public override returns (bool success){
            require(balances[msg.sender] >= tokens);
            require(tokens > 0 );
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender,spender,tokens);
            return true;
        }
        // no of tokens allowed by owner to spender
        function allowance(address tokenOwner, address spender) public view override returns (uint noOfToken){
            return allowed[tokenOwner][spender];
        }

        function transferFrom(address from, address to, uint tokens) public override virtual returns (bool success){
            require(allowed[from][to] >= tokens);
            require(balances[from] >= tokens);
            balances[from] -= tokens; // balances[from] - tokens
            balances[to] += tokens; // balances[to] + tokens
            return true;
        }

    }

    contract ICO is IndianNationArmy {
        address public manager;
        address payable public deposit;
        // price of 1 token
        uint tokenPrice=0.1 ether;
        // circulating supply of INA
        uint public cap= 300 ether;

        uint public raisedAmount;

        uint public icoStart = block.timestamp;
        uint public icoEnd = block.timestamp + 3600;

        uint public tokenTradeTime= icoEnd+3600;

        uint public maxInvest= 10 ether;
        uint public minInvest = 0.1 ether;

        enum state{beforeStart,afterEnd,running,halted}

        state public icoState;

        event Invests(address investor,uint value,uint tokens);

        constructor(address payable _deposit){
            deposit = _deposit;
            manager = msg.sender;
            icoState = state.beforeStart;
        }
        modifier onlyManager(){
            require(msg.sender == manager);
            _;
        }
        function halt() public onlyManager{
            icoState = state.halted;
        }
        function resume() public onlyManager{
            icoState = state.running;
        }
        function changeDepositeAddress(address payable _newDeposite) public onlyManager{
            deposit = _newDeposite;
        }
        function getState() public view returns(state){
            if(icoState == state.halted){
                return state.halted;
            }else if(block.timestamp < icoStart ){
                return state.beforeStart;
            }else if(block.timestamp >= icoStart && block.timestamp <= icoEnd){
                return state.running;
            }else{
                return state.afterEnd;
            }
        }
        function Invest() public payable returns(bool){
            icoState=getState();
            require(icoState == state.running);
            require(msg.value >= minInvest && msg.value <= maxInvest);
            
            raisedAmount += msg.value;
            require(raisedAmount <= cap);

            uint tokens = msg.value / tokenPrice;

            balances[msg.sender] += tokens;
            balances[founder] -= tokens;
            deposit.transfer(msg.value);

            emit Invests(msg.sender,msg.value,tokens);
            return true;
        }
        function burn() public returns(bool){
            icoState = getState();
            require(icoState == state.afterEnd);
            balances[founder] = 0;
            return true;
        }
        function transfer(address to, uint tokens) public override returns (bool success){
            require(block.timestamp > tokenTradeTime);
            super.transfer(to,tokens);
            return true;
        }
        function transferFrom(address from, address to, uint tokens) public override returns (bool success){
            require(block.timestamp > tokenTradeTime);
            super.transferFrom(from,to,tokens);
            return true;
        }
        // receive function should be external and payable
        receive() external payable{
            Invest();
        }
    }
