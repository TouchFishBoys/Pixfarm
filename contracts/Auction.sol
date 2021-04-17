// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    struct Good {
        bool finished;
        address owner;
        uint256 price;
        uint256 money;
        string name;
    }

    mapping(address => mapping(uint256 => uint256)) private money;

    Good[] public goods;

    function addGood(uint256 _price) public {
        Good memory good;

        good.owner = msg.sender;
        good.price = _price;

        goods.push(good);
    }
}
