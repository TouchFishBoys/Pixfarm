// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Repository.sol";
import "./FarmBase.sol";
import "./FarmMarket.sol";
import "./MarketBase.sol";

interface IPixFarm {
    ///@dev 播种
    function sowing(
        uint256 _x,
        uint256 _y,
        FarmBase.Specie _specie
    ) external returns (bool);

    ///@dev 收获
    function harvest(uint256 _x, uint256 _y) external returns (bool);

    // ///@dev 铲除
    // function eradicate(uint256 _x, uint256 _y) external returns (bool getSeed);

    ///@dev 偷菜
    // function stealPlant(
    //     address _owner,
    //     uint256 _x,
    //     uint256 _y
    // ) external returns (bool);

    ///@dev 分解果实
    // function disassembling(uint256 _fruitTag) external returns (bool);
}

contract PixFarm is Ownable, IPixFarm, FarmBase, Money, MarketBase {
    event SeedPlanted(address owner, uint8 x, uint8 y);
    Money mon;

    constructor(Repository _repo, Money _mon)
        FarmBase(_repo)
        MarketBase(_repo)
    {
        mon = _mon;
    }

    /// @notice 播种
    /// @param _x uint x坐标
    /// @param _y uint y坐标
    /// @param _specie uint256 种子标签
    //返回：bool
    function sowing(
        uint256 _x,
        uint256 _y,
        Specie _specie
    ) external override returns (bool) {
        //require(fields[msg.sender][_x][_y].unlocked == true);
        require(fields[_x][_y].specie == Specie.empty);

        //Need Change
        if (fields[_x][_y].owner != msg.sender) {
            require(
                money[msg.sender] > (PriceForSpecie[_specie] * 8) / 100,
                "You don't have enough money to pay your rent"
            );
        }

        if (
            !mon.transferTo(
                msg.sender,
                fields[_x][_y].owner,
                (PriceForSpecie[_specie] * 8) / 100
            )
        ) {
            return false;
        }

        if (
            !repo.removeItem(msg.sender, Repository.ItemType.Seed, _specie, 1)
        ) {
            return false;
        }
        fields[_x][_y].farmer = msg.sender;
        fields[_x][_y].specie = _specie;
        fields[_x][_y].sowingTime = block.timestamp;
        return true;
    }

    event PlantHarvested(address owner, uint8 x, uint8 y);

    /// @notice 收获
    /// @param _x x坐标
    /// @param _y y坐标
    function harvest(uint256 _x, uint256 _y) public override returns (bool) {
        require(fields[_x][_y].specie != Specie.empty);
        require(
            block.timestamp >=
                (fields[_x][_y].sowingTime + specieTime[fields[_x][_y].specie])
        );

        //uint32 num = 1;
        if (msg.sender != fields[_x][_y].farmer) {
            require(
                block.timestamp >=
                    (fields[_x][_y].sowingTime +
                        specieTime[fields[_x][_y].specie] +
                        1800),
                "This crop is under protection"
            );
            return PlantStole(_x, _y);
        }
        if (!repo.probabilityCheck(successRate[fields[_x][_y].specie], 100)) {
            return false;
        }
        // uint256 x = _x;
        // uint256 y = _y;
        Repository.Item memory item;
        item.usable = true;
        item.specie = fields[_x][_y].specie;
        item.stack = 1;
        repo.addItem(Repository.ItemType.Fruit, msg.sender, item);
        _initField(fields[_x][_y]);
        return true;
    }

    function PlantStole(uint256 _x, uint256 _y) internal returns (bool) {
        //------------TODO
        if (!repo.probabilityCheck(successRate[fields[_x][_y].specie], 100)) {
            return false;
        }
        Repository.Item memory item;
        item.usable = true;
        item.specie = fields[_x][_y].specie;
        item.stack = 1;
        repo.addItem(Repository.ItemType.Fruit, msg.sender, item);
        _initField(fields[_x][_y]);
        return true;
    }

    event PlantEradicated(address owner, uint8 x, uint8 y);

    // /// @notice 铲除某地的植物
    // /// @param _x 被铲除的x坐标
    // /// @param _y 被铲除的y坐标
    // function eradicate(uint256 _x, uint256 _y)
    //     external
    //     override
    //     returns (bool)
    // {
    //     require(
    //         fields[_x][_y].owner == msg.sender,
    //         "You have no right to do this"
    //     );
    //     require(
    //         fields[_x][_y].specie != Specie.empty,
    //         "Thers is no plant to remove"
    //     );

    //     if (
    //         ((block.timestamp - fields[_x][_y].sowingTime) * 100) /
    //             specieTime[fields[_x][_y].specie] <
    //         10
    //     ) {
    //         Repository.Item memory item;
    //         item.stack = 1;
    //         item.usable = true;
    //         item.specie = fields[_x][_y].specie;
    //         repo.addItem(Repository.ItemType.Seed, msg.sender, item);
    //     }
    //     fields[_x][_y].specie = Specie.empty;
    //     _initField(fields[_x][_y]);
    //     return true;
    // }

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

    function getFields() public view returns (uint256, Field[6][6] memory) {
        return (block.timestamp, fields);
    }

    ///@dev 获取土地信息
    function getFieldsMessage(uint256 _x, uint256 _y)
        public
        view
        returns (
            Specie,
            uint256,
            address,
            address
        )
    {
        return (
            fields[_x][_y].specie,
            fields[_x][_y].sowingTime,
            fields[_x][_y].farmer,
            fields[_x][_y].owner
        );
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

    ///@dev 购买土地
    function buyLand(uint256 _x, uint256 _y) public returns (bool) {
        require(
            fields[_x][_y].owner == address(this),
            "This land has been unlocked"
        );
        if (!mon.transferTo(msg.sender, address(this), 999)) {
            return false;
        }
        fields[_x][_y].owner = msg.sender;
        return true;
    }

    // ///@dev 出售土地
    // function sellLandToShop(uint256 _x, uint256 _y) public returns (bool) {
    //     require(fields[_x][_y].owner == msg.sender);
    //     if (!mon.getMoneyFromShop(msg.sender, 999)) {
    //         return false;
    //     }
    //     fields[_x][_y].specie = Specie.empty;
    //     fields[_x][_y].sowingTime = 0;
    //     fields[_x][_y].owner = address(this);
    //     fields[_x][_y].farmer = address(0);
    //     return true;
    // }
}
