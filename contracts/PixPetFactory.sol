// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PixFarm.sol";

abstract contract IPixPetFactory {
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

    ///@dev 计算属性
    function getPetProperties(uint256 _dna)
        public
        view
        virtual
        returns (PetPropertiesPacked calldata);

    ///@dev 计算DNA
    function calDna(PetPropertiesPacked memory _pack)
        public
        view
        virtual
        returns (uint256 dna);
}

contract PixPetFactory is Ownable, IPixPetFactory {
    function getPetProperties(uint256 _dna)
        public
        view
        override
        returns (PetPropertiesPacked memory)
    {
        PetPropertiesPacked memory pack;
        //TODO
        return pack;
    }

    function calDna(PetPropertiesPacked memory _pack)
        public
        view
        override
        returns (uint256)
    {
        uint256 dna;
        //TODO
        return dna;
    }

    //全局随机调整属性
    //参数：PlantPropertiesPacked
    //返回：PlantPropertiesPacked
    function followRandom(PetPropertiesPacked memory _pack)
        internal
        view
        returns (PetPropertiesPacked memory)
    {
        //TODO
        return _pack;
    }
}
