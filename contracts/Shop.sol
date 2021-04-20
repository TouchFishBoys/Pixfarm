// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./PixFarmFactory.sol";

interface IShop {
    ///@dev buy a seed from shop
    function buySeed(uint256 specie, uint256 level)
        external
        view
        returns (uint256 _dna);

    function buyPet() external view returns (uint256 _dna);
}

contract Shop is PixFarmFactory, IShop {
    mapping(address => uint256) public experience;

    function buySeed(uint256 specie, uint256 level)
        external
        view
        override
        returns (uint256 _dna)
    {
        require(level <= 4, "illegal level");
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
        return getSeedTag(pack);
    }

    function buyPet() external view override returns (uint256 _dna) {
        return 0;
    }
}
