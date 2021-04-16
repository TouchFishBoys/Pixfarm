// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    struct Good {
        address owner;
        uint256 price;
        string name;
    }
    Good[] public goods;

    function addGood(uint256 _price) public {
        Good memory good;

        good.owner = msg.sender;
        good.price = _price;

        goods.push(good);
    }
}
