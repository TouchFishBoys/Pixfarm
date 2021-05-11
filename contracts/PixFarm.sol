// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FarmFactory.sol";
import "./FarmBase.sol";
import "./FarmMarket.sol";

interface IPixFarm {
    ///@dev 播种
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external returns (bool);

    ///@dev 收获
    function harvest(uint256 _x, uint256 _y) external;

    ///@dev 铲除
    function eradicate(uint256 _x, uint256 _y) external returns (bool getSeed);

    ///@dev 偷菜
    // function stealPlant(
    //     address _owner,
    //     uint256 _x,
    //     uint256 _y
    // ) external returns (bool);

    ///@dev 分解果实
    function disassembling(uint256 _fruitTag) external returns (bool);
}

contract PixFarm is Ownable, IPixFarm, FarmBase {
    event SeedPlanted(address owner, uint8 x, uint8 y);
    FarmMarket fm;
    FarmFactory fc;

    constructor(FarmMarket _fm, FarmFactory _fc) {
        fm = _fm;
        fc = _fc;
    }

    /// @notice 播种
    /// @param _x uint x坐标
    /// @param _y uint y坐标
    /// @param _seedTag uint256 种子标签
    //返回：bool
    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) external override returns (bool) {
        require(fields[msg.sender][_x][_y].unlocked == true);
        require(fields[msg.sender][_x][_y].used == false);
        if (!removeItem(msg.sender, ItemType.Seed, _seedTag, 1)) {
            return false;
        }
        fields[msg.sender][_x][_y].seedTag = _seedTag;
        fields[msg.sender][_x][_y].sowingTime = block.timestamp;
        fields[msg.sender][_x][_y].maturityTime =
            block.timestamp +
            specieTime[uint8(fc.getPropertiesByTag(_seedTag).specie)];
        fields[msg.sender][_x][_y].used = true;
        return true;
    }

    event PlantHarvested(address owner, uint8 x, uint8 y);

    /// @notice 收获
    /// @param _x x坐标
    /// @param _y y坐标
    function harvest(uint256 _x, uint256 _y) public override {
        require(fields[msg.sender][_x][_y].unlocked == true);
        require(block.timestamp >= fields[msg.sender][_x][_y].maturityTime);
        fields[msg.sender][_x][_y].used = false;
        uint32 num = 1;
        if (probabilityCheck(5, 1000)) {
            num = 3;
        } else if (probabilityCheck(10, 995)) {
            num = 2;
        }
        uint256 x = _x;
        uint256 y = _y;
        uint256 fruitTag;
        uint8 sign = fc.randomHybridize(msg.sender, uint8(_x), uint8(_y));
        if (sign == 1) {
            //up
            y += 1;
        } else if (sign == 2) {
            //down
            y -= 1;
        } else if (sign == 3) {
            //left
            x -= 1;
        } else {
            //right
            x += 1;
        }
        fruitTag = fc.getHarvestFruitTag(
            fields[msg.sender][_x][_y].seedTag,
            fields[msg.sender][x][y].seedTag
        );
        if (sign == 0) {
            fruitTag = fc.getFruitTag(fields[msg.sender][_x][_y].seedTag);
        }

        // if (giveItem(ItemType.Fruit,msg.sender, fruitTag, num)) {
        //     _initField(fields[msg.sender][_x][_y]);
        //     return (true, uint8(num));
        // } else {
        //     fields[msg.sender][_x][_y].used = true;
        //     return (false, uint8(num));
        // }
        Item memory item;
        item.usable = true;
        item.tag = uint32(fruitTag);
        item.stack = num;
        addItem(ItemType.Fruit, msg.sender, item);
        farmExperience[msg.sender] += fm.getFruitValueByTag(fruitTag) / 10;
        //return uint8(num);
    }

    event PlantEradicated(address owner, uint8 x, uint8 y);

    /// @notice 铲除某地的植物
    /// @param _x 被铲除的x坐标
    /// @param _y 被铲除的y坐标
    function eradicate(uint256 _x, uint256 _y)
        external
        override
        returns (bool)
    {
        require(fields[msg.sender][_x][_y].unlocked == true);
        require(fields[msg.sender][_x][_y].used == true);

        if (
            ((block.timestamp - fields[msg.sender][_x][_y].sowingTime) * 100) /
                specieTime[
                    uint8(
                        fc
                            .getPropertiesByTag(
                            fields[msg.sender][_x][_y]
                                .seedTag
                        )
                            .specie
                    )
                ] <
            10
        ) {
            fields[msg.sender][_x][_y].used = false;
            // if (giveItem(msg.sender, fields[msg.sender][_x][_y].seedTag, 1)) {
            //     _initField(fields[msg.sender][_x][_y]);
            //     return true;
            // } else {
            //     fields[msg.sender][_x][_y].used = true;
            //     revert("Repository is full");
            // }
            Item memory item;
            item.stack = 1;
            item.usable = true;
            item.tag = uint32(fields[msg.sender][_x][_y].seedTag);
            addItem(ItemType.Seed, msg.sender, item);
            return true;
        } else {
            _initField(fields[msg.sender][_x][_y]);
            return true;
        }
    }

    // event PlantStolen(address owner, address thief, uint8 x, uint8 y);

    // /// @notice 偷菜
    // /// @dev 返回false则为背包满
    // /// @param _owner 被偷的人
    // /// @param _x 菜地的x坐标
    // /// @param _y 菜地的y坐标
    // function stealPlant(
    //     address _owner,
    //     uint256 _x,
    //     uint256 _y
    // ) public override returns (bool) {
    //     require(fields[msg.sender][_x][_y].unlocked == true);
    //     require(
    //         fields[msg.sender][_x][_y].used == true &&
    //             block.timestamp >= fields[_owner][_x][_y].maturityTime
    //     );
    //     require(friendCheck(msg.sender, _owner));
    //     //过宠物判定
    //     if (!fields[_owner][_x][_y].stolen) {
    //         //没被偷过
    //         fields[_owner][_x][_y].stolen = true;
    //         // if (
    //         //     giveItem(
    //         //         msg.sender,
    //         //         getFruitTag(fields[_owner][_x][_y].seedTag),
    //         //         1
    //         //     )
    //         // ) {
    //         //偷成功
    //         Item memory item;
    //         item.stack = 1;
    //         item.usable = true;
    //         item.tag = uint32(fc.getFruitTag(fields[_owner][_x][_y].seedTag));
    //         addItem(ItemType.Fruit, msg.sender, item);
    //         fields[_owner][_x][_y].maturityTime = block.timestamp + 1800;
    //         fields[_owner][_x][_y].firstThief = msg.sender;
    //         return true;
    //         // } else {
    //         //     //偷失败
    //         //     fields[_owner][_x][_y].stolen = false;
    //         //     return false;
    //         // }
    //     }
    //     //被偷过
    //     else {
    //         //Field memory _field = fields[_owner][_x][_y];
    //         fields[_owner][_x][_y].used = false;
    //         _initField(fields[_owner][_x][_y]);
    //         // if (
    //         //     giveItem(
    //         //         msg.sender,
    //         //         getFruitTag(fields[_owner][_x][_y].seedTag),
    //         //         1
    //         //     )
    //         // ) {
    //         //偷成功
    //         Item memory item;
    //         item.stack = 1;
    //         item.usable = true;
    //         item.tag = uint32(fc.getFruitTag(fields[_owner][_x][_y].seedTag));
    //         addItem(ItemType.Fruit, msg.sender, item);
    //         fields[_owner][_x][_y].secondThief = msg.sender;
    //         return true;
    //         // } else {
    //         //     //偷失败
    //         //     fields[_owner][_x][_y] = _field;
    //         //     return false;
    //         // }
    //     }
    // }

    /// @notice 分解果实
    /// @dev 返回false则为背包满
    /// @param _fruitTag果实Tag
    function disassembling(uint256 _fruitTag) public override returns (bool) {
        bool check;
        uint256 seedTag;
        (seedTag, check) = fc.disassembleFruit(_fruitTag);
        uint256 value = fm.getFruitValueByTag(_fruitTag) / 10;
        require(transferToShop(msg.sender, value));
        Item memory seed;
        seed.usable = true;
        seed.stack = 1;
        seed.tag = uint32(seedTag);
        addItem(ItemType.Seed, msg.sender, seed);
        if (check) {
            Item memory dreamy;
            dreamy.usable = true;
            dreamy.stack = 1;
            dreamy.tag = uint32(fc.getDreamySeedTag());
            addItem(ItemType.Seed, msg.sender, dreamy);
        }
        farmExperience[msg.sender] += value;
        return check;
    }

    function getFields(address player)
        public
        view
        returns (Field[6][6] memory)
    {
        return fields[player];
    }

    function getAge(uint256 sowingTime, uint256 maturityTime)
        public
        view
        returns (uint8)
    {
        uint256 timePass = block.timestamp - sowingTime;
        uint256 rate = timePass / (maturityTime - sowingTime);
        if (rate <= 50) {
            return 0;
        }
        if (rate <= 99) {
            return 1;
        }
        return 2;
    }
}
