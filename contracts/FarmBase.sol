// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RepositoryBase.sol";

contract FarmBase {
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
    enum Specie {A, B, C, D, E, F, G, H, I, J, K, L}

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
}
