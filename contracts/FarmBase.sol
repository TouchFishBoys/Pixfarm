// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Repository.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FarmBase is Ownable {
    //TODO to interface IRepository
    Repository repo;
    // /// @dev 属性封包
    // struct PlantPropertiesPacked {
    //     Specie specie;
    //     uint8 hp;
    //     uint8 atk;
    //     uint8 def;
    //     uint8 spd;
    // }

    struct Field {
        Specie specie;
        uint256 sowingTime;
        address owner; //土地拥有者
        address farmer; //种植者
    }
    //mapping(address => uint256) farmExperience;
    //mapping(address => address[]) public owners;
    //mapping(address => ) fields;
    uint8 fieldSize = 6;
    Field[6][6] fields;

    /// @dev 物种
    enum Specie {empty, branut, moonbean, sunberry, charis}

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

    constructor(Repository _repo) {
        repo = _repo;

        specieTime[Specie.empty] = uint256(0) - 1;
        specieTime[Specie.branut] = 300;
        specieTime[Specie.moonbean] = 3600;
        specieTime[Specie.sunberry] = 21600;
        specieTime[Specie.charis] = 43200;

        successRate[Specie.branut] = 10;
        successRate[Specie.moonbean] = 15;
        successRate[Specie.sunberry] = 25;
        successRate[Specie.charis] = 35;
    }

    /// @dev 作物成熟时间
    //uint256[] specieTime = [uint256(300), 3600, 21600, 43200];
    mapping(Specie => uint256) specieTime;

    /// @dev 作物收获成功率
    mapping(Specie => uint256) successRate;

    /// @dev 果实饱食度
    //uint256[] specieFull = [10, 10, 10, 10, 20, 20, 15, 15, 15, 15, 10, 15];

    /// @dev 地价
    //uint256[] landPrice = [12000, 300000, 6000000, 8000000];

    /// @dev 经验值
    //uint256[] landExp = [500, 8000, 120000, 500000];

    // function getFarmLevel(address _owner) public view returns (uint8) {
    //     uint8 level;
    //     uint256 Exp = farmExperience[_owner];
    //     // for (uint8 i = 0; i < landExp.length; i++) {
    //     //     if (farmExperience[_owner] > landExp[i]) {
    //     //         level = i + 2;
    //     //     }
    //     // }
    //     if (Exp < 500) {
    //         level = 1;
    //     } else if (Exp < 8000) {
    //         level = 2;
    //     } else if (Exp < 120000) {
    //         level = 3;
    //     } else if (Exp < 500000) {
    //         level = 4;
    //     } else {
    //         level = 5;
    //     }

    //     return level;
    // }

    // function upgradeLand(uint8 level) public {
    //     require(getFarmLevel(msg.sender) >= level);
    //     if (level != 1) {
    //         repo.transferToShop(msg.sender, landPrice[level - 2]);
    //     }
    //     for (uint8 i = 0; i < level + 1; i++) {
    //         for (uint8 j = 0; j < level + 1; j++) {
    //             fields[msg.sender][i][j].unlocked = true;
    //         }
    //     }
    // }

    /// @dev 初始化土地
    function _initField(Field storage _field) internal {
        if (_field.specie == Specie.empty) {
            _field.sowingTime = 0;
            _field.farmer = address(0);
        }
    }

    /// @dev 注册
    function register(string memory _name) public {
        repo._registration(_name);
        //upgradeLand(1);
        repo.getMoneyFromShop(msg.sender, 1000);
        repo.updateMaxIndex();
    }

    function startInit() internal {
        for (uint8 i = 0; i < fieldSize * fieldSize; i++) {
            fields[i / 6][i % 6].specie = Specie.empty;
            fields[i / 6][i % 6].sowingTime = 0;
            fields[i / 6][i % 6].owner = address(this);
            fields[i / 6][i % 6].farmer = address(0);
        }
    }
}
