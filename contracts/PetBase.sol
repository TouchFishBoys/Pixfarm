// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./RespositoryBase.sol"
contract PetBase {
    IERC20 private erc20;

    /// @dev  宠物列表
    mapping(address => PetPropertiesPacked[]) internal petList;

    constructor(IERC20 _erc20) {
        erc20 = _erc20;
        uint8[] propertiesTrough = [0, 2, 4, 5, 7, 8, 9, 10, 10];
    }

    //成长值和各部位样式、颜色
    //hp(6bits)
    //atk(6bits)
    //def(6bits)
    //spd(6bits)
    //shape(4bits)each
    //color(4bits)each
    //-------------------DNA
    //吃到的属性值和等级
    //hp(11bits)
    //atk(11bits)
    //def(11bits)
    //spd(11bits)
    //Level(5bits)
    struct PetPropertiesPacked {
        uint8 hp;
        uint8 atk;
        uint8 def;
        uint8 spd;
        uint32 petExperience;
        uint16 maxPropertiesTrough;
        uint8 fullDegree;
    }
}
