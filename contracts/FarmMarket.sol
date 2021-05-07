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
        _buy(_tag, _amount, _price);
        emit SeedSoldFromShop(msg.sender, _tag, _amount, _price);
    }

    function buySeed(
        uint256 specie,
        uint256 level,
        uint256 _amount
    ) external {
        require(level <= 4, "Illegal level");
        PlantPropertiesPacked memory pack;
        pack.specie = Specie(specie);
        pack.hp = 0;
        pack.atk = 0;
        pack.def = 0;
        pack.spd = 0;
        for (uint256 i = 0; i < level; i++) {
            uint256 rnd = getRandom(4);
            if (rnd == 0) {
                pack.hp++;
            } else if (rnd == 1) {
                pack.atk++;
            } else if (rnd == 2) {
                pack.def++;
            } else if (rnd == 3) {
                pack.spd++;
            }
        }
        uint256 _price = getSeedValue(specie, level);
        uint256 seedTag = getSeedTag(pack);
        _buySeed(seedTag, _amount, _price);
        giveItem(msg.sender, seedTag, 1);
    }

    /// @dev 计算种子价格
    function getSeedValue(uint256 specie, uint256 level)
        internal
        returns (uint256)
    {
        return PirceForSpecie[specie] + PirceForLevel[level];
    }

    /// @dev 计算果实价格
    function getFruitValue(uint256 specie, uint256 level)
        internal
        returns (uint256)
    {
        require(specie < 8, "Dreamy Fruit can't be saled");
        return
            (PirceForSpecie[specie] + PirceForLevel[level]) *
            (100 + RateForBenefit[specie] / 100);
    }

    function _sellSeed(
        ItemType _type,
        uint256 _index,
        uint256 _amount
    ) {
        _sell(_type, _index, _amount);
    }
}
