// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

    contract Ecommerce{

        struct Product{
            string title;
            string desc;
            address payable seller;
            uint productId;
            uint price;
            address buyer;
            bool delivered;
        }
        bool destroyed = false;
        modifier isDestroyed{
            require(!destroyed,"Contract does not exists");
            _;
        }
        address payable public manager;
        constructor(){
            manager = payable(msg.sender);
        }
        uint count = 1;
        Product[] public products;
        event registered(string title,string desc,address seller);
        event bought(uint productId,address buyer);
        event delivered(uint productId);

        function registeredProduct(string memory _title,string memory _desc,uint _price) public isDestroyed{
            require(_price > 0,"Price should be greater than zero");
            Product memory teampProducts;
            teampProducts.title = _title;
            teampProducts.desc = _desc;
            teampProducts.price = _price *10**18;
            teampProducts.seller = payable(msg.sender);
            teampProducts.productId = count;
            products.push(teampProducts);
            count++;
            emit registered(_title,_desc,msg.sender);
        }
        function buy(uint _productId) public payable isDestroyed{
            // msg.value == number of wei sent with the message
            require(products[_productId-1].price == msg.value,"Please pay exact price");
            require(products[_productId-1].seller != msg.sender,"Seller cannot be the buyer");
            products[_productId-1].buyer = msg.sender;
            emit bought(_productId,msg.sender);
        }
        function delivery(uint _productId) public isDestroyed{ 
            require(products[_productId-1].buyer == msg.sender,"Only buyer can confirm");
            products[_productId-1].delivered = true;
            products[_productId-1].seller.transfer(products[_productId-1].price);
            emit delivered(_productId);
        }
        /* function destroy() public{
            require(msg.sender == manager,"Only manager can destroy");
            // this function will transfer contract balance to the manager address
            selfdestruct(manager);
        } */
        function destroy() public isDestroyed{
            require(msg.sender == manager,"Only manager can destroy");
            manager.transfer(address(this).balance);
            destroyed = true;
        }
        fallback() payable external{
            payable(msg.sender).transfer(msg.value);
        }
        receive() external payable {
        }
    }  