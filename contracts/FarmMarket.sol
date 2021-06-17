// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketBase.sol";
import "./FarmBase.sol";

contract FarmMarket is MarketBase, FarmBase {
    constructor(Repository _repo) FarmBase(_repo) MarketBase(_repo) {}

    event SeedSoldFromShop(
        address buyer,
        uint256 tag,
        uint256 _amount,
        uint256 cost
    );

    function buySeed(uint8 _specie, uint256 _amount) public {
        repo.addSeed(Specie(_specie), msg.sender, _amount);
        repo.transferToShop(
            msg.sender,
            PriceForSpecie[Specie(_specie)] * _amount
        );
        //emit SeedSoldFromShop(msg.sender, seedTag, _amount, _price);
    }

    function sellFruit(Specie _specie, uint256 _amount) public returns (bool) {
        _sell(Repository.ItemType.Fruit, _specie, uint32(_amount));
        return true;
    }
}
