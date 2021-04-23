// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FarmFactory.sol";
import "./FarmMarket.sol"


interface IPixFarm {
    ///@dev 播种
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external returns (bool);

    ///@dev 收获
    function harvest(uint256 _x, uint256 _y)
        public
        virtual
        returns (bool, uint8 number);

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
        bool stolen;
        address firstThief;
        address secondThief;
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
        require(
            fields[msg.sender][_x][_y].used == false,
            "THe field has been used!"
        );
        if (!removeItem(msg.sender, _seedTag, 1)) {
            return false;
        }
        fields[msg.sender][_x][_y].seedTag = _seedTag;
        fields[msg.sender][_x][_y].sowingTime = block.timestamp;
        fields[msg.sender][_x][_y].maturityTime =
            block.timestamp +
            specieTime[getPropertiesByTag(_seedTag).specie];
        fields[msg.sender][_x][_y].used = true;
        return true;
    }

    //收获
    //参数：uing256，uing256
    //返回：bool,uint256,uint8
    function harvest(uint256 _x, uint256 _y)
        external
        override
        returns (bool, uint8 number)
    {
        require(
            block.timestamp >= fields[msg.sender][_x][_y].maturityTime,
            "can't be harvested"
        );
        fields[msg.sender][_x][_y].used = false;
        uint32 num = 1;
        if (probabilityCheck(5, 1000)) {
            num = 3;
        } else if (probabilityCheck(10, 995)) {
            num = 2;
        }
        if (
            giveItem(
                msg.sender,
                getFruitTag(fields[msg.sender][_x][_y].seedTag),
                num
            )
        ) {
            initField(fields[msg.sender][_x][_y]);
            return (true, uint8(num));
        } else {
            fields[msg.sender][_x][_y].used = true;
            return (false, uint8(num));
        }
    }

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
                    getPropertiesByTag(fields[msg.sender][_x][_y].specie)
                ] <
            10
        ) {
            fields[msg.sender][_x][_y].used = false;
            if (giveItem(msg.sender, fields[msg.sender][_x][_y].seedTag, 1)) {
                initField(fields[msg.sender][_x][_y]);
                return true;
            } else {
                fields[msg.sender][_x][_y].used = true;
                revert("Repository is full");
            }
        } else {
            initField(fields[msg.sender][_x][_y]);
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
    ) public override returns (bool) {
        require(
            block.timestamp >= fields[_friend][_x][_y].maturityTime,
            "can't be stolen"
        );
        //过宠物判定
        if (!fields[_friend][_x][_y].stolen) {
            //没被偷过
            fields[_friend][_x][_y].stolen = true;
            if (
                giveItem(
                    msg.sender,
                    getFruitTag(fields[_friend][_x][_y].seedTag),
                    1
                )
            ) {
                //偷成功
                fields[_friend][_x][_y].maturityTime =
                    block.timestamp +
                    punishTime;
                fields[_friend][_x][_y].firstThief = msg.sender;
                return true;
            } else {
                //偷失败
                fields[_friend][_x][_y].stolen = false;
                return false;
            }
        }
        //被偷过
        else {
            Field memory _field = fields[_friend][_x][_y];
            fields[_friend][_x][_y].used = false;
            initField(fields[_friend][_x][_y]);
            if (
                giveItem(
                    msg.sender,
                    getFruitTag(fields[_friend][_x][_y].seedTag),
                    1
                )
            ) {
                //偷成功
                fields[_friend][_x][_y].secondThief = msg.sender;
                return true;
            } else {
                //偷失败
                fields[_friend][_x][_y] = _field;
                return false;
            }
        }
    }

    //初始化土地
    //参数：(传址)field
    function initField(Field storage _field) internal {
        if (_field.used == false) {
            _field.seedTag = 0;
            _field.sowingTime = 0;
            _field.maturityTime = 0;
            _field.stolen = false;
            _field.firstThief = address(0);
            _field.secondThief = address(0);
        }
    }
}
