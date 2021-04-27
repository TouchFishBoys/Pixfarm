// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketBase.sol";

contract FarmMarket is MarketBase {
    event SeedSoldFromShop(
        address buyer,
        uint256 tag,
        uint256 _amount,
        uint256 cost
    );

    function _buySeed(
        uint256 _tag,
        uint256 _amount,
        uint256 _price
    ) internal {
        // Something
        _buy(_price);
        emit SeedSoldFromShop(msg.sender, _tag, _amount, _price);
    }
}
