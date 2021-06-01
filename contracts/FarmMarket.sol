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
    event CalculatedTag(uint256 seedTag);

    function buySeed(
        uint256 specie,
        uint256 level,
        uint256 _amount
    ) public {
        require(level <= 4, "ERR_ARG_LEVEL");
        require(getFarmLevel(msg.sender) >= level, "ERR_LVL");
        PlantPropertiesPacked memory pack;
        pack.specie = Specie(specie);
        pack.hp = 0;
        pack.atk = 0;
        pack.def = 0;
        pack.spd = 0;
        // 随机分配点数
        for (uint256 i = 0; i < level; i++) {
            uint256 rnd = repo.getRandom(4);
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
        // 计算种子价格
        uint256 _price = getSeedValue(specie, level);
        uint256 seedTag = fc.getSeedTag(pack);
        emit CalculatedTag(seedTag);
        // Item memory item;
        // item.tag = uint32(seedTag);
        // item.stack = uint32(_amount);
        // item.usable = true;
        repo.addSeed(seedTag, msg.sender, _amount);
        repo.transferToShop(msg.sender, getSeedValue(specie, level));
        emit SeedSoldFromShop(msg.sender, seedTag, _amount, _price);
    }

    /// @dev 计算种子价格
    function getSeedValue(uint256 specie, uint256 level)
        internal
        view
        returns (uint256)
    {
        return
            MarketBase.PirceForSpecie[specie] + MarketBase.PirceForLevel[level];
    }

    /// @dev 计算果实价格
    function getFruitValue(uint256 specie, uint256 level)
        public
        view
        returns (uint256)
    {
        require(specie < 8);
        return
            (MarketBase.PirceForSpecie[specie] +
                MarketBase.PirceForLevel[level]) *
            (100 + MarketBase.RateForBenefit[specie] / 100);
    }

    /// @dev 利用Tag计算果实价格
    function getFruitValueByTag(uint256 _tag) public view returns (uint256) {
        PlantPropertiesPacked memory pack = fc.getPropertiesByTag(_tag);
        uint8 specie = uint8(pack.specie);
        uint8 level = pack.atk + pack.hp + pack.def + pack.spd;
        require(specie < 8);
        return
            (MarketBase.PirceForSpecie[specie] +
                MarketBase.PirceForLevel[level]) *
            (100 + MarketBase.RateForBenefit[specie] / 100);
    }

    function sellFruit(uint256 _tag, uint256 _amount) public returns (bool) {
        sell(
            Repository.ItemType.Fruit,
            _tag,
            uint32(_amount),
            getFruitValueByTag(_tag)
        );
        return true;
    }
}
