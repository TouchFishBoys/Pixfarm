// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Pixfarmon.sol";
import "./EtherplantFactory.sol";

contract PlantShop {
    Pixfarmon pixfarmon;
    IEtherplantFactory plantFactory;

    function buySeed(uint256 specie, uint256 level)
        external
        view
        returns (uint256 _dna)
    {
        uint256 hp = 0;
        uint256 atk = 0;
        uint256 def = 0;
        uint256 spd = 0;
        if (level >= 4) {
            return 0;
        }
        for (uint256 i = 0; i < level; i++) {
            uint256 rnd = pixfarmon.getRandom(4);
            if (rnd == 0) {
                hp++;
            } else if (rnd == 1) {
                atk++;
            } else if (rnd == 2) {
                def++;
            } else if (rnd == 3) {
                spd++;
            }
        }
        return plantFactory.getDNA(specie, hp, atk, def, spd);
    }
}
