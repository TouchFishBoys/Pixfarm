// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RepositoryBase.sol";

contract FarmBase is RepositoryBase {
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
    mapping(address => uint256) farmExperience;
    mapping(address => address[]) public owners;
    mapping(address => Field[6][6]) fields;
    /// @dev 品质
    enum Quality {N, R, SR, SSR}
    /// @dev 物种
    enum Specie {
        spirel,
        zebrot,
        branut,
        moonbean,
        malener,
        sunberry,
        barner,
        thorner,
        quernom,
        demute,
        charis,
        peento
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

    /// @dev 物种偏向
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
    /// @dev 作物成熟时间
    uint256[] specieTime = [
        uint256(300),
        600,
        1800,
        3600,
        7200,
        18000,
        28800,
        43200,
        86400,
        86400,
        86400,
        86400
    ];
    /// @dev 果实饱食度
    uint256[] specieFull = [10, 10, 10, 10, 20, 20, 15, 15, 15, 15, 10, 15];

    /// @dev 地价
    uint256[] landPrice = [12000, 300000, 6000000, 8000000];

    /// @dev 经验值
    uint256[] landExp = [500, 8000, 120000, 500000];

    function getFarmLevel(address _owner) public view returns (uint8) {
        uint8 level = 1;
        for (uint8 i = 0; i < landExp.length; i++) {
            if (farmExperience[_owner] > landExp[i]) {
                level = i + 2;
            }
        }
        return level;
    }

    function upgradeLand(uint8 level) public {
        require(getFarmLevel(msg.sender) >= level);
        if (level != 1) {
            require(transferToShop(msg.sender, landPrice[level - 2]));
        }
        for (uint8 i = 0; i < level + 1; i++) {
            for (uint8 j = 0; j < level + 1; j++) {
                fields[msg.sender][i][j].unlocked = true;
            }
        }
    }

    /// @dev 初始化土地
    function _initField(Field storage _field) internal {
        if (_field.used == false) {
            _field.seedTag = 0;
            _field.sowingTime = 0;
            _field.maturityTime = 0;
            _field.stolen = false;
            _field.firstThief = address(0);
            _field.secondThief = address(0);
        }
    }

    /// @dev 注册
    function register(string memory _name) public {
        _registration(_name);
        upgradeLand(1);
        getMoneyFromShop(msg.sender, 1000);
    }
}
