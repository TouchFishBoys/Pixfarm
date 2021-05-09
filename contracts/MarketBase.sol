// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AuctionBase.sol";
import "./RepositoryBase.sol";

contract MarketBase is AuctionBase, RepositoryBase {
    /// @dev 等级附加售价
    uint256[] PirceForLevel = [
        uint256(100),
        200,
        400,
        800,
        1200,
        1800,
        2500,
        3500
    ];
    /// @dev 作物本身价格
    uint256[] PirceForSpecie = [
        uint256(150),
        100,
        150,
        200,
        250,
        250,
        300,
        400
    ];

    /// @dev 作物收益
    uint256[] RateForBenefit = [uint256(1), 1, 2, 3, 5, 10, 15, 20];

    // function _setBankAddress(address bankAddress) public onlyOwner {
    //     bank = IERC20(bankAddress);
    // }

    /// @dev 仅用于付费，获取（生成）商品信息在调用的函数中生成
    function _buy(
        uint256 _tag,
        uint256 _amount,
        uint256 _price
    ) internal {
        //require(bank.allowance(msg.sender, address(this)) > _amount);
        require(transferToShop(msg.sender, _amount * _price));
        Item memory newItem;
        newItem.tag = uint32(_tag);
        newItem.stack = uint32(_amount);
        newItem.usable = true;
        //_repository[ItemType(_tag % 8)][msg.sender].push(newItem);
        addItem(ItemType(_tag >> 17), msg.sender, newItem);
    }

    function sell(
        ItemType _type,
        uint256 _tag,
        uint32 _amount,
        uint256 _value
    ) internal {
        //bank.transfer(msg.sender, _amount);
        // _repository[_type][msg.sender][_index].stack =
        //     _repository[_type][msg.sender][_index].stack -
        //     _amount;
        // uint256 _price;
        // _price = _repository[_type][msg.sender][_index].tag >> 17; //收购价 = 作物种类（x%）* 总属性对应价
        // getMoneyFromShop(msg.sender, _amount);
        require(removeItem(msg.sender, _type, _tag, _amount));
        money[msg.sender] += _value;
    }

    //function _upgrade() internal override {}
}
