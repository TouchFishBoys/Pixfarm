// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PixPet.sol";
import "./PixFarm.sol";

contract Pixfarmon is PixPet, PixFarm {
    /// @dev 添加好友
    function AddFriendByName(string memory _name) public {
        _addFriendByName(_name);
    }

    function AddFriendByAddress(address _address) public {
        _addFriendByAddress(_address);
    }

    /// @dev 氪金
    function RechargeMoney(uint256 _money) public {
        _rechargeMoney(_value);
    }

    /// @dev 买种子
    function BuySeedFromShop(
        uint256 specie,
        uint256 level,
        uint256 _amount
    ) public {
        buySeed(specie, level, _amount);
    }

    /// @dev 卖果实
    function SellSeedToShop(
        ItemType _type,
        uint256 _index,
        uint256 _amount
    ) public {
        _sellSeed(_type, _index, _amount);
    }

    /// @dev 播种
    function Sowing(
        uint256 _x,
        uint256 _y,
        uint256 _tag
    ) public {
        sowing(_x, _y, _tag);
    }

    /// @dev 收获
    function Harvest(uint256 _x, uint256 _y) public returns (uint256) {
        return harvest(_x, _y);
    }

    /// @dev 铲除
    function Eradicate(uint256 _x, uint256 _y) public {
        eradicate(_x, _y);
    }

    /// @dev 偷菜
    function Steal(
        address _owner,
        uint256 _x,
        uint256 _y
    ) public {
        stealPlant(_owner, _x, _y);
    }

    /// @dev 分解
    function Disassembling(uint256 _tag) public returns (bool) {
        return disassembling(_tag);
    }

    /// @dev 拍卖
    function auction() public {}
}
