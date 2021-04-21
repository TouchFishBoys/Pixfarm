// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PixFarmFactory.sol";
import "./Shop.sol";

interface IPixFarm {
    ///@dev 播种
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external returns (bool);

    ///@dev 收获
    function harvest(uint256 _x, uint256 _y)
        external
        returns (
            bool,
            uint256 fruitTag,
            uint8 number
        );

    ///@dev 铲除
    function eradicating(uint256 _x, uint256 _y)
        external
        returns (bool getSeed);

    ///@dev 偷菜
    function stealing(
        address _friend,
        uint256 _x,
        uint256 _y
    ) external returns (bool);
}

contract PixFarm is Ownable, IPixFarm, PixFarmFactory {
    mapping(address => uint256) farmExperience;
    mapping(address => address[]) public friends;
    mapping(address => field[6][6]) fields;
    struct field {
        bool unlocked;
        bool used;
        uint256 seedTag;
        uint256 sowingTime;
        uint256 maturityTime;
    }

    //播种
    //参数：uing256，uing256，uing256
    //返回：bool
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external override returns (bool) {
        require(
            fields[msg.sender][_x][_y].unlocked == true,
            "The field is locked!"
        );
        if (!removeItem(msg.sender, _seedTag, 1)) {
            return false;
        }
        fields[msg.sender][_x][_y].seedTag = _seedTag;
        fields[msg.sender][_x][_y].sowingTime = block.timestamp;
        fields[msg.sender][_x][_y].maturityTime =
            block.timestamp +
            specieTime[getSpecieBySeed(_seedTag)];
        fields[msg.sender][_x][_y].used = true;
        return true;
    }

    //收获
    //参数：uing256，uing256
    //返回：bool,uint256,uint8
    function harvest(uint256 _x, uint256 _y)
        external
        override
        returns (
            bool,
            uint256 fruitTag,
            uint8 number
        )
    {}

    //铲除
    //参数：uing256，uing256
    //返回：bool 为false为背包满
    function eradicating(uint256 _x, uint256 _y)
        external
        override
        returns (bool)
    {
        if (
            ((block.timestamp - fields[msg.sender][_x][_y].sowingTime) * 100) /
                specieTime[
                    getSpecieBySeed(fields[msg.sender][_x][_y].seedTag)
                ] <
            10
        ) {
            fields[msg.sender][_x][_y].used = false;
            if (giveItem(msg.sender, fields[msg.sender][_x][_y].seedTag, 1)) {
                return true;
            } else {
                fields[msg.sender][_x][_y].used = true;
                revert("Repository is full");
            }
        } else {
            return true;
        }
    }

    //偷菜
    //参数：uing256，uing256
    //返回：bool 为false为背包满
    function stealing(
        address _friend,
        uint256 _x,
        uint256 _y
    ) external view override returns (bool) {
        //TODO
        return false;
    }
}
