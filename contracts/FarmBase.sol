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
}
