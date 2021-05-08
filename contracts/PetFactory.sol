// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PetBase.sol";

interface IPetFactory {
    // ///@dev 计算属性
    // function getPetProperties(uint256 _dna)
    //     external
    //     view
    //     returns (PetBase.PetPropertiesPacked calldata);
    // ///@dev 计算DNA
    // function calDna(PetBase.PetPropertiesPacked memory _pack)
    //     external
    //     view
    //     returns (uint256 dna);
}

contract PetFactory is Ownable, PetBase, IPetFactory {
    // function getPetProperties(uint256 _dna)
    //     public
    //     pure
    //     override
    //     returns (PetPropertiesPacked memory)
    // {
    //     PetPropertiesPacked memory pack;
    //     //TODO
    //     return pack;
    // }
    // function calDna(PetPropertiesPacked memory _pack)
    //     public
    //     pure
    //     override
    //     returns (uint256)
    // {
    //     uint256 dna;
    //     //TODO
    //     return dna;
    // }
    // //全局随机调整属性
    // //参数：PlantPropertiesPacked
    // //返回：PlantPropertiesPacked
    // function followRandom(PetPropertiesPacked memory _pack)
    //     internal
    //     view
    //     returns (PetPropertiesPacked memory)
    // {
    //     //TODO
    //     return _pack;
    // }
}
