// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AuctionBase.sol";
import "./ShopBase.sol";
import "./RepositoryBase.sol";

abstract contract MarketBase is AuctionBase, ShopBase, RepositoryBase {
    IERC20 internal bank;

    function _setBankAddress(address bankAddress) public onlyOwner {
        bank = IERC20(bankAddress);
    }

    /// @dev 仅用于付费，获取（生成）商品信息在调用的函数中生成
    function _buy(
        uint256 _tag,
        uint256 _amount,
        uint256 _price
    ) internal {
        require(bank.allowance(msg.sender, address(this)) > _amount);
        transferToShop(_amount * _price);
        Item memory newItem;
        newItem.tag = _tag;
        newItem.stack = _amount;
        newItem.usable = true;
        _repository[ItemType[_tag % 8]][msg.sender].push(newItem);
    }

    function _sell(
        ItemType _type,
        uint256 _index,
        uint256 _amount
    ) internal {
        //bank.transfer(msg.sender, _amount);
        _repository[_type][msg.sender][_index].stack =
            _repository[_type][msg.sender][_index].stack -
            _amount;
        uint256 _price;
        _price = _repository[_type][msg.sender][_index].tag >> 17; //收购价 = 作物种类（x%）* 总属性对应价
        getMoneyFromShop(_amount);
    }

    function _upgrade() internal {}
}
