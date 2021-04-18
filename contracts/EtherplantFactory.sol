// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Pixfarmon.sol";

abstract contract IEtherplantFactory is Pixfarmon {
    enum Quality {N, R, SR, SSR}
    enum Specie {RESERVED}

    struct PlantPropertiesPacked {
        Specie specie;
        uint8 hp;
        uint8 atk;
        uint8 def;
        uint8 spd;
        ItemType plantType;
        Quality quality;
    }

    struct Plant {
        string name;
        uint32 dna; //1 bit to classfy seed and fruit 4 bits for species 2 bits for quality and 3 bits for each properties
    }

    //total:19 bits
    //  example:
    //  specie (4bits)
    //  |   hp (3bits)
    //  |   |  atk (3bits)
    //  |   |  |  def (3bits)
    //  |   |  |  |  spd (3bits)
    //  |   |  |  |  |  DNA  quality (2bits)
    //  |   |  |  |  |       | itemType (3bits)
    //  |   |  |  |  |       | |
    //  0011001010011100     01010

    function getPlantProperties(uint64 _dna)
        external
        view
        virtual
        returns (PlantPropertiesPacked calldata);

    ///@dev 计算DNA
    function calDna(PlantPropertiesPacked calldata _pack)
        public
        view
        virtual
        returns (uint256 dna);

    ///@dev 计算Tag
    function calTag(
        PlantPropertiesPacked calldata _pack,
        Quality quality,
        ItemType itemType
    ) public pure virtual returns (uint256 tag);
}

contract EtherplantFactory is Ownable, IEtherplantFactory {
    function _generateDna(uint32 parent1, uint32 parent2)
        private
        view
        returns (uint32)
    {
        uint32 child;
        uint32 propertiesData;
        child = (parent1 + parent2) / 2;
        propertiesData = child % 4096;
        child /= 4096;
        child = child - (child % 4); //clear quality
        //random give 0,1,2,3
        if (probabilityCheck(1, 100)) {
            child += 3;
        } else if (probabilityCheck(5, 99)) {
            child += 2;
        } else if (probabilityCheck(10, 94)) {
            child += 1;
        }
        child = child * 4096 + propertiesData;
        return child;
    }

    function getPlantProperties(uint64 _dna)
        external
        view
        virtual
        override
        returns (PlantPropertiesPacked memory)
    {
        PlantPropertiesPacked memory pack;
        pack.spd = uint8(_dna % 8);
        _dna /= 8;
        pack.def = uint8(_dna % 8);
        _dna /= 8;
        pack.atk = uint8(_dna % 8);
        _dna /= 8;
        pack.hp = uint8(_dna % 8);
        _dna /= 8;
        pack.quality = Quality(_dna % 4);
        _dna /= 4;
        pack.specie = Specie(_dna % 16);
        _dna /= 16;
        pack.plantType = ItemType(_dna);
        return pack;
    }

    function calDna(PlantPropertiesPacked calldata _pack)
        public
        pure
        override
        returns (uint256 dna)
    {
        uint256 _dna =
            _pack.spd +
                (_pack.def << 3) +
                (_pack.atk << 6) +
                (_pack.hp << 9) +
                (uint8(_pack.specie) << 13);
        return _dna;
    }

    function calTag(
        PlantPropertiesPacked calldata _pack,
        Quality quality,
        ItemType itemType
    ) public pure override returns (uint256 tag) {
        uint256 _tag =
            (calDna(_pack) << 5) + (uint256(quality) << 3) + uint256(itemType);
        return _tag;
    }

    function check(uint256 probability, uint256 decimal)
        public
        view
        returns (bool)
    {
        if (
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                decimal <
            probability
        ) {
            return true;
        }
        return false;
    }
}
