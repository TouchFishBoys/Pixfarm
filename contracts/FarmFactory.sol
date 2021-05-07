// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./FarmBase.sol";

interface IFarmFactory {
    ///@dev 计算属性
    function getPlantProperties(uint256 _dna)
        external
        view
        returns (PlantPropertiesPacked memory);

    ///@dev 计算DNA
    function calDna(PlantPropertiesPacked memory _pack)
        external
        view
        returns (uint256 dna);

    ///@dev 计算Tag
    function calTag(
        PlantPropertiesPacked memory _pack,
        Quality quality,
        PixfarmonBase.ItemType itemType
    ) external pure returns (uint256 tag);

    ///@dev 生成果实
    function getFruitTag(uint256 _seedTag)
        external
        view
        returns (uint256 fruitTag);

    ///@dev 生成种子
    function getSeedTag(PlantPropertiesPacked memory _pack)
        external
        pure
        returns (uint256 seedTag);

    ///@dev 分解果实
    function disassembleFruit(uint256 _fruitTag)
        external
        returns (uint256 seedTag, bool getSpecialSeed);

    ///@dev 根据Tag获得属性
    function getPropertiesByTag(uint256 tag)
        external
        view
        returns (PlantPropertiesPacked memory);

    ///@dev 获得梦幻种子tag
    function getDreamySeedTag() external view returns (uint256);

    ///@dev 获得杂交种子tag
    function getHybridizedSeedTag(uint256 parent1, uint256 parent2)
        external
        view
        returns (uint256);

    ///@dev 获得收获果实tag
    function getHarvestFruitTag(uint256 parent1, uint256 parent2)
        external
        view
        returns (uint256);

    ///@dev 杂交检查
    function HybridizationCheck(
        address _owner,
        uint8 _x,
        uint8 _y
    ) external view returns (uint256);

    ///@dev 随机杂交
    function randomHybridize(
        address _owner,
        uint8 _x,
        uint8 _y
    ) external view returns (uint8);
}

contract FarmFactory is IPixFarmFactory, FarmBase {
    function _generateDna(uint256 Dna1, uint256 Dna2)
        private
        pure
        returns (uint256)
    {
        uint256 child;
        child = (Dna1 + Dna2) / 2;
        return child;
    }

    function getFruitTag(uint256 _seedTag)
        public
        view
        override
        returns (uint256 fruitTag)
    {
        PlantPropertiesPacked memory pack = getPropertiesByTag(_seedTag);
        Quality quality;
        if (probabilityCheck(1, 100)) {
            quality = Quality(3);
        } else if (probabilityCheck(5, 99)) {
            quality = Quality(2);
        } else if (probabilityCheck(10, 94)) {
            quality = Quality(1);
        }
        return calTag(pack, quality, ItemType.Fruit);
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
        override
        returns (PlantPropertiesPacked memory)
    {
        uint256 dna = _dna;
        if (dna > (1 << 12)) {
            dna <<= 5;
        }
        PlantPropertiesPacked memory pack;
        pack.spd = uint8(dna % 8);
        dna >> 3;
        pack.def = uint8(dna % 8);
        dna >> 3;
        pack.atk = uint8(dna % 8);
        pack.hp >> 3;
        pack.specie = Specie(uint8(dna % 16));
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
        PixfarmonBase.ItemType itemType
    ) public pure override returns (uint256 tag) {
        uint256 _tag =
            (calDna(_pack) << 5) + (uint256(quality) << 3) + uint256(itemType);
        return _tag;
    }

    //分解果实
    //参数：FruitTag
    //返回：SeedTag、bool(是否获得梦幻种子)
    function disassembleFruit(uint256 _fruitTag)
        public
        view
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

    //调整果实属性
    //参数：PlantPropertiesPacked、Quality
    //返回：PlantPropertiesPacked
    function generateRandomAttribute(
        PlantPropertiesPacked memory _pack,
        uint256 quality
    ) public view returns (PlantPropertiesPacked memory) {
        if (probabilityCheck(2, 10)) {
            _pack = followRandom(_pack);
        }
        PropertiesLegelCheck(_pack);
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

    //根据植物偏向调整属性
    //参数：PlantPropertiesPacked
    //返回：PlantPropertiesPacked
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
        PropertiesLegelCheck(_pack);
        return _pack;
    }

    //全局随机调整属性
    //参数：PlantPropertiesPacked
    //返回：PlantPropertiesPacked
    function followRandom(PlantPropertiesPacked memory _pack)
        internal
        view
        returns (PlantPropertiesPacked memory)
    {
        _pack.hp = uint8(int8(_pack.hp) + getFollowRandom());
        _pack.atk = uint8(int8(_pack.atk) + getFollowRandom());
        _pack.def = uint8(int8(_pack.def) + getFollowRandom());
        _pack.spd = uint8(int8(_pack.spd) + getFollowRandom());
        PropertiesLegelCheck(_pack);
        return _pack;
    }

    //获取随机调整值
    //返回：int8
    function getFollowRandom() internal view returns (int8) {
        if (probabilityCheck(5, 100)) {
            return 1;
        } else if (probabilityCheck(5, 95)) {
            return -1;
        }
        return 0;
    }

    //属性合法性检查
    //参数：PlantPropertiesPacked
    //返回：PlantPropertiesPacked
    function PropertiesLegelCheck(PlantPropertiesPacked memory _pack)
        internal
        view
        returns (PlantPropertiesPacked memory pack)
    {
        //处理uint超界导致的极大数
        if (_pack.hp > 6) {
            _pack.hp = 0;
        }
        if (_pack.atk > 6) {
            _pack.atk = 0;
        }
        if (_pack.def > 6) {
            _pack.def = 0;
        }
        if (_pack.spd > 6) {
            _pack.spd = 0;
        }
        //处理单属性超界
        if (_pack.hp == 6) {
            _pack.hp--;
        }
        if (_pack.atk == 6) {
            _pack.atk--;
        }
        if (_pack.def == 6) {
            _pack.def--;
        }
        if (_pack.spd == 6) {
            _pack.spd--;
        }
        //处理总属性和>8
        uint256 rnd;
        while (_pack.hp + _pack.atk + _pack.def + _pack.spd > 8) {
            rnd = getRandom(4);
            if (rnd == 0) {
                if (_pack.hp > 0) {
                    _pack.hp--;
                }
            } else if (rnd == 1) {
                if (_pack.atk > 0) {
                    _pack.atk--;
                }
            } else if (rnd == 2) {
                if (_pack.def > 0) {
                    _pack.def--;
                }
            } else {
                if (_pack.spd > 0) {
                    _pack.spd--;
                }
            }
            return _pack;
        }
    }

    //根据Tag获得属性
    //参数：uint256
    //返回：PlantPropertiesPacked
    function getPropertiesByTag(uint256 _tag)
        public
        view
        override
        returns (PlantPropertiesPacked memory)
    {
        require(_tag % 8 <= 2);
        return getPlantProperties(_tag >> 5);
    }

    //获得梦幻种子tag
    //返回：uint256
    function getDreamySeedTag() public view override returns (uint256) {
        PlantPropertiesPacked memory pack;
        uint256 rnd = getRandom(4);
        if (rnd == 0) {
            pack.specie = 8;
            pack.hp = 5;
        } else if (rnd == 1) {
            pack.specie = 9;
            pack.atk = 5;
        } else if (rnd == 2) {
            pack.specie = 10;
            pack.def = 5;
        } else {
            pack.specie = 11;
            pack.spd = 5;
        }
        return getSeedTag(pack);
    }

    //获得杂交种子tag
    //参数：uint256 p1, uint256 p2
    //返回：uint256
    function getHybridizedSeedTag(uint256 parent1, uint256 parent2)
        public
        view
        override
        returns (uint256)
    {
        return (parent1 + parent2) / 2;
    }

    //获得收获果实tag
    //参数：uint256 p1, uint256 p2
    //返回：uint256
    function getHarvestFruitTag(uint256 parent1, uint256 parent2)
        public
        view
        override
        returns (uint256)
    {
        if (probabilityCheck(10, 20)) {
            return getFruitTag(parent1);
        } else {
            return getFruitTag(getHybridizedSeedTag(parent1, parent2));
        }
    }

    //杂交检查
    //参数：address _owner, uint8 _x,uint8 _y
    //返回：uint8 count,uint256
    function HybridizationCheck(
        address _owner,
        uint8 _x,
        uint8 _y
    ) public view override returns (uint8, uint256) {
        uint256 specie = frields[_owner][_x][_y].seedTag >> 17;
        uint256 sign;
        uint8 count;
        //up
        if (
            y < 5 &&
            frields[_owner][_x][_y + 1].seedTag >> 17 == specie &&
            block.timestamp >= frields[_owner][_x][_y + 1].maturityTime
        ) {
            sign = (sign << 1) + 1;
            count++;
        }
        //down
        if (
            y > 0 &&
            frields[_owner][_x][_y - 1].seedTag >> 17 == specie &&
            block.timestamp >= frields[_owner][_x][_y - 1].maturityTime
        ) {
            sign = (sign << 1) + 1;
            count++;
        }
        //left
        if (
            x > 0 &&
            frields[_owner][_x - 1][_y].seedTag >> 17 == specie &&
            block.timestamp >= frields[_owner][_x - 1][_y].maturityTime
        ) {
            sign = (sign << 1) + 1;
            count++;
        }
        //right
        if (
            x < 5 &&
            frields[_owner][_x + 1][_y].seedTag >> 17 == specie &&
            block.timestamp >= frields[_owner][_x + 1][_y].maturityTime
        ) {
            sign = (sign << 1) + 1;
            count++;
        }
        return (count, sign);
    }

    //随机杂交
    //参数：address _owner, uint8 _x,uint8 _y
    //返回：uint8
    function randomHybridize(
        address _owner,
        uint8 _x,
        uint8 _y
    ) external view returns (uint8) {
        uint8 count;
        uint256 sign;
        (count, sign) = HybridizationCheck(_owner, _x, _y);
        if (count == 0) {
            return 0;
        }
        uint256 rnd = getRandom(count);
        uint8[] temp;
        if (sign % 2 == 1) {
            temp.push(4);
        }
        sign /= 2;
        if (sign % 2 == 1) {
            temp.push(3);
        }
        sign /= 2;
        if (sign % 2 == 1) {
            temp.push(2);
        }
        sign /= 2;
        if (sign % 2 == 1) {
            temp.push(1);
        }
        return temp[rnd];
    }
}
