// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FarmFactory.sol";
import "./FarmMarket.sol";
import "./Repository.sol"

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

    ///@dev 分解果实
    function disassembling(uint256 _fruitTag) external returns (bool);
}

contract PixFarm is Ownable, IPixFarm, FarmFactory, FarmMarket {
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
        uint256 fruitTag;
        uint8 sign = randomHybridize(msg.sender, _x, _y);
        if (sign == 0) {
            fruitTag = getFruitTag(fields[msg.sender][_x][_y].seedTag);
        } else if (sign == 1) {
            //up
            fruitTag = getHarvestFruitTag(
                fields[msg.sender][_x][_y].seedTag,
                fields[msg.sender][_x][_y + 1].seedTag
            );
        } else if (sign == 2) {
            //down
            fruitTag = getHarvestFruitTag(
                fields[msg.sender][_x][_y].seedTag,
                fields[msg.sender][_x][_y - 1].seedTag
            );
        } else if (sign == 3) {
            //left
            fruitTag = getHarvestFruitTag(
                fields[msg.sender][_x][_y].seedTag,
                fields[msg.sender][_x - 1][_y].seedTag
            );
        } else {
            //right
            fruitTag = getHarvestFruitTag(
                fields[msg.sender][_x][_y].seedTag,
                fields[msg.sender][_x + 1][_y].seedTag
            );
        }

        if (giveItem(msg.sender, fruitTag, num)) {
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

    /// @notice 分解果实
    /// @dev 返回false则为背包满
    /// @param _fruitTag果实Tag
    function disassembling(uint256 _fruitTag) public returns (bool) {
        bool check;
        uint256 seedTag;
        Money[msg.sender] -= getFruitValue(_fruitTag);
        (seedTag, check) = disassembleFruit(_fruitTag);
        PlantPropertiesPacked memory pack = getPropertiesByTag(_fruitTag);
        uint256 level = pack.hp + pack.atk + pack.def + pack.spd;
        uint256 value = getFruitValue(pack.specie, level);
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

    /// @dev 添加好友
    function addFriendByName(string memory _name) public {
        _addFriendByName(_name);
    }

    function addFriendByAddress(address _address) public {
        _addFriendByAddress(_address);
    }

    /// @dev 氪金
    function rechargeMoney(uint256 _money) public {
        _rechargeMoney(_value);
    }

    /// @dev 买种子
    function buySeedFromShop(
        uint256 specie,
        uint256 level,
        uint256 _amount
    ) public {
        buySeed(specie, level, _amount);
    }

    /// @dev 卖果实
    function sellSeedToShop(
        ItemType _type,
        uint256 _index,
        uint256 _amount
    ) public {
        _sellSeed(_type, _index, _amount);
    }

    /// @dev 拍卖
    function auction() public {}
}
