// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PetBase.sol";

abstract contract IPetFactory {
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

contract PetFactory is Ownable, IPixPetFactory {
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
