// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarketBase.sol";
import "./FarmBase.sol";
import "./FarmFactory.sol";

contract FarmMarket is MarketBase, FarmBase {
    FarmFactory fc;

    constructor(FarmFactory _fc, Repository _repo)
        FarmBase(_repo)
        MarketBase(_repo)
    {
        fc = _fc;
    }

    event SeedSoldFromShop(
        address buyer,
        uint256 tag,
        uint256 _amount,
        uint256 cost
    );

    function buySeed(Specie _specie, uint256 _amount) public {
        repo.addSeed(_specie, msg.sender, _amount);
        repo.transferToShop(msg.sender, PriceForSpecie[_specie] * _amount);
        //emit SeedSoldFromShop(msg.sender, seedTag, _amount, _price);
    }

    function sellFruit(Specie _specie, uint256 _amount) public returns (bool) {
        sell(Repository.ItemType.Fruit, _specie, uint32(_amount));
        return true;
    }
}
