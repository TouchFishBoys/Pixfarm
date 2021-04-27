// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./RespositoryBase.sol"
contract FarmBase {
    /// @dev 属性封包
    struct PlantPropertiesPacked {
        Specie specie;
        uint8 hp;
        uint8 atk;
        uint8 def;
        uint8 spd;
    }

    struct Field {
        bool unlocked;
        bool used;
        uint256 seedTag;
        uint256 sowingTime;
        uint256 maturityTime;
        bool stolen;
        address firstThief;
        address secondThief;
    }
}
