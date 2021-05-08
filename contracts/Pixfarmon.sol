// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PixPet.sol";
import "./PixFarm.sol";

contract Pixfarmon is PixPet, PixFarm {
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
