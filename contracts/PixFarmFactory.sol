// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PixfarmonBase.sol";

abstract contract IPixFarmFactory is PixfarmonBase {
    enum Quality {N, R, SR, SSR}
    enum Specie {A, B, C, D, E, F, G, H, I, J, K, L}

    int256[][] specieData = [
        [int256(1), -1, -1, 1],
        [int256(1), -1, -1, 1],
        [int256(1), -1, 1, -1],
        [int256(-1), 1, 1, -1],
        [int256(-1), 1, -1, 1],
        [int256(-1), -1, 1, 1],
        [int256(1), 0, 0, 0],
        [int256(0), 0, 0, 1]
    ];
    struct PlantPropertiesPacked {
        Specie specie;
        uint8 hp;
        uint8 atk;
        uint8 def;
        uint8 spd;
    }

    struct Plant {
        string name;
        uint32 dna; //4 bits for species and 3 bits for each properties
    }

    //total:21 bits
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

    function getPlantProperties(uint256 _dna)
        public
        view
        virtual
        returns (PlantPropertiesPacked calldata);

    ///@dev 计算DNA
    function calDna(PlantPropertiesPacked memory _pack)
        public
        view
        virtual
        returns (uint256 dna);

    ///@dev 计算Tag
    function calTag(
        PlantPropertiesPacked memory _pack,
        Quality quality,
        ItemType itemType
    ) public pure virtual returns (uint256 tag);

    ///@dev 生成果实
    function getFruitTag(PlantPropertiesPacked memory _pack)
        public
        view
        virtual
        returns (uint256 fruitTag);

    ///@dev 生成种子
    function getSeedTag(PlantPropertiesPacked memory _pack)
        public
        pure
        virtual
        returns (uint256 seedTag);

    ///@dev 分解果实
    function disassembleFruit(uint256 _fruitTag)
        public
        virtual
        returns (uint256 seedTag, bool getSpecialSeed);
}

abstract contract PixFarmFactory is Ownable, IPixFarmFactory {
    function _generateDna(uint256 Dna1, uint256 Dna2)
        private
        pure
        returns (uint256)
    {
        uint256 child;
        child = (Dna1 + Dna2) / 2;
        return child;
    }

    function getFruitTag(PlantPropertiesPacked memory _pack)
        public
        view
        override
        returns (uint256 fruitTat)
    {
        uint256 tag = calDna(_pack);
        tag << 2;
        if (probabilityCheck(1, 100)) {
            tag += 3;
        } else if (probabilityCheck(5, 99)) {
            tag += 2;
        } else if (probabilityCheck(10, 94)) {
            tag += 1;
        }
        tag << 3;
        tag += 1;
        return tag;
    }

    function getSeedTag(PlantPropertiesPacked memory _pack)
        public
        pure
        override
        returns (uint256 SeedTag)
    {
        uint256 tag = calDna(_pack);
        tag << 5;
        return tag;
    }

    function getPlantProperties(uint256 _dna)
        public
        view
        virtual
        override
        returns (PlantPropertiesPacked memory)
    {
        if (_dna > (1 << 12)) {
            _dna <<= 5;
        }
        PlantPropertiesPacked memory pack;
        pack.spd = uint8(_dna % 8);
        _dna >> 3;
        pack.def = uint8(_dna % 8);
        _dna >> 3;
        pack.atk = uint8(_dna % 8);
        pack.hp >> 3;
        pack.specie = Specie(uint8(_dna % 16));
        return pack;
    }

    function calDna(PlantPropertiesPacked memory _pack)
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
        PlantPropertiesPacked memory _pack,
        Quality quality,
        ItemType itemType
    ) public pure override returns (uint256 tag) {
        uint256 _tag =
            (calDna(_pack) << 5) + (uint256(quality) << 3) + uint256(itemType);
        return _tag;
    }

    function disassembleFruit(uint256 _fruitTag)
        public
        override
        returns (uint256 seedTag, bool getSpecialSeed)
    {
        uint256 specie = _fruitTag >> 17;
        require(specie < 8, "");
        uint256 dna = _fruitTag >> 3;
        uint256 quality = dna % 4;
        dna >> 2;
        PlantPropertiesPacked memory pack = getPlantProperties(dna);
        pack = generateRandomAttribute(pack, quality);
        bool check;
        if (quality == 3) {
            check = probabilityCheck(5, 100);
        } else if (quality == 2) {
            check = probabilityCheck(1, 95);
        } else if (quality == 1) {
            check = probabilityCheck(5, 940);
        } else {
            check = probabilityCheck(1, 935);
        }
        return (getSeedTag(pack), check);
    }

    function generateRandomAttribute(
        PlantPropertiesPacked memory _pack,
        uint256 quality
    ) public view returns (PlantPropertiesPacked memory) {
        if (quality == 3) {
            return followSpecie(_pack);
        } else if (quality == 2) {
            if (probabilityCheck(50, 100)) {
                return followSpecie(_pack);
            }
            return _pack;
        } else if (quality == 1) {
            if (probabilityCheck(30, 100)) {
                return followSpecie(_pack);
            }
            return _pack;
        } else {
            if (probabilityCheck(10, 100)) {
                return followSpecie(_pack);
            }
            return _pack;
        }
    }

    function followSpecie(PlantPropertiesPacked memory _pack)
        internal
        view
        returns (PlantPropertiesPacked memory)
    {
        uint256 rnd = getRandom(4);
        if (rnd == 0) {
            _pack.hp = uint8(
                int8(_pack.hp) + int8(specieData[uint256(_pack.specie)][0])
            );
        } else if (rnd == 1) {
            _pack.atk = uint8(
                int8(_pack.atk) + int8(specieData[uint256(_pack.specie)][1])
            );
        } else if (rnd == 2) {
            _pack.def = uint8(
                int8(_pack.def) + int8(specieData[uint256(_pack.specie)][2])
            );
        } else {
            _pack.spd = uint8(
                int8(_pack.spd) + int8(specieData[uint256(_pack.specie)][3])
            );
        }
        return _pack;
    }
}
