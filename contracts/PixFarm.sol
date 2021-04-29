// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FarmFactory.sol";
import "./FarmMarket.sol";

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
    function eradicate(uint256 _x, uint256 _y) external returns (bool getSeed);

    ///@dev 偷菜
    function stealPlant(
        address _owner,
        uint256 _x,
        uint256 _y
    ) external returns (bool);
}

contract PixFarm is Ownable, IPixFarm, FarmFactory {
    mapping(address => uint256) farmExperience;
    mapping(address => address[]) public owners;
    mapping(address => field[6][6]) fields;

    event SeedPlanted(address owner, uint8 x, uint8 y);

    /// @notice 播种
    /// @param _x uint x坐标
    /// @param _y uint y坐标
    /// @param _seedTag uint256 种子标签
    //返回：bool
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external override {
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

    event PlantHarvested(address owner, uint8 x, uint8 y);

    /// @notice 收获
    /// @param _x x坐标
    /// @param _y y坐标
    function harvest(uint256 _x, uint256 _y)
        external
        override
        returns (uint8 number)
    {
        require(
            block.timestamp >= fields[msg.sender][_x][_y].maturityTime,
            "Can't be harvested"
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
            _initField(fields[msg.sender][_x][_y]);
            return (true, uint8(num));
        } else {
            fields[msg.sender][_x][_y].used = true;
            return (false, uint8(num));
        }
    }

    event PlantEradicated(address owner, uint8 x, uint8 y);

    /// @notice 铲除某地的植物
    /// @param _x 被铲除的x坐标
    /// @param _y 被铲除的y坐标
    function eradicate(uint256 _x, uint256 _y) external override {
        if (
            ((block.timestamp - fields[msg.sender][_x][_y].sowingTime) * 100) /
                specieTime[
                    getPropertiesByTag(fields[msg.sender][_x][_y].specie)
                ] <
            10
        ) {
            fields[msg.sender][_x][_y].used = false;
            if (giveItem(msg.sender, fields[msg.sender][_x][_y].seedTag, 1)) {
                _initField(fields[msg.sender][_x][_y]);
                return true;
            } else {
                fields[msg.sender][_x][_y].used = true;
                revert("Repository is full");
            }
        } else {
            _initField(fields[msg.sender][_x][_y]);
            return true;
        }
    }

    event PlantStolen(address owner, address thief, uint8 x, uint8 y);

    /// @notice 偷菜
    /// @dev 返回false则为背包满
    /// @param _owner 被偷的人
    /// @param _x 菜地的x坐标
    /// @param _y 菜地的y坐标
    function stealPlant(
        address _owner,
        uint256 _x,
        uint256 _y
    ) public override {
        require(
            block.timestamp >= fields[_owner][_x][_y].maturityTime,
            "can't be stolen"
        );
        //过宠物判定
        if (!fields[_owner][_x][_y].stolen) {
            //没被偷过
            fields[_owner][_x][_y].stolen = true;
            if (
                giveItem(
                    msg.sender,
                    getFruitTag(fields[_owner][_x][_y].seedTag),
                    1
                )
            ) {
                //偷成功
                fields[_owner][_x][_y].maturityTime =
                    block.timestamp +
                    punishTime;
                fields[_owner][_x][_y].firstThief = msg.sender;
                return true;
            } else {
                //偷失败
                fields[_owner][_x][_y].stolen = false;
                return false;
            }
        }
        //被偷过
        else {
            Field memory _field = fields[_owner][_x][_y];
            fields[_owner][_x][_y].used = false;
            _initField(fields[_owner][_x][_y]);
            if (
                giveItem(
                    msg.sender,
                    getFruitTag(fields[_owner][_x][_y].seedTag),
                    1
                )
            ) {
                //偷成功
                fields[_owner][_x][_y].secondThief = msg.sender;
                return true;
            } else {
                //偷失败
                fields[_owner][_x][_y] = _field;
                return false;
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

    function buySeed(uint256 specie, uint256 level) external {
        require(level <= 4, "Illegal level");
        PlantPropertiesPacked memory pack;
        pack.specie = Specie(specie);
        pack.hp = 0;
        pack.atk = 0;
        pack.def = 0;
        pack.spd = 0;
        for (uint256 i = 0; i < level; i++) {
            uint256 rnd = getRandom(4);
            if (rnd == 0) {
                pack.hp++;
            } else if (rnd == 1) {
                pack.atk++;
            } else if (rnd == 2) {
                pack.def++;
            } else if (rnd == 3) {
                pack.spd++;
            }
        }
        uint256 seedTag = getSeedTag(pack);
        giveItem(msg.sender, seedTag, 1);
    }
}
