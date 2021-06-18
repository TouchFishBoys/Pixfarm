// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PixFarm.sol";
import "./Money.sol";
import "./Repository.sol";
import "./Auction.sol";
import "./FarmMarket.sol";

contract Pixfarmon {
    Auction auction;
    Money mon;
    Repository public rb;
    FarmMarket fm;
    FarmBase fb;

    constructor(
        address _auction,
        address _money,
        address _repository,
        address _farmMarket,
        address _farmBase
    ) {
        auction = Auction(_auction);
        mon = Money(_money);
        rb = Repository(_repository);
        fm = FarmMarket(_farmMarket);
        fb = FarmBase(_farmBase);
    }

    /// @dev 添加好友
    // function AddFriendByName(string memory _name) public {
    //     rb.addFriendByName(_name);
    // }

    // function AddFriendByAddress(address _address) public {
    //     rb.addFriendByAddress(_address);
    // }

    /// @dev 氪金
    function RechargeMoney(uint256 _money) public {
        mon.rechargeMoney(_money);
    }

    // /// @dev 买种子
    // function BuySeedFromShop(
    //     uint8 specie,
    //     //uint256 level,
    //     uint256 _amount
    // ) public {
    //     fm.buySeed(specie, _amount);
    // }

    // /// @dev 播种
    // function Sowing(
    //     uint256 _x,
    //     uint256 _y,
    //     uint256 _tag
    // ) public {
    //     sowing(_x, _y, _tag);
    // }

    // /// @dev 收获
    // function Harvest(uint256 _x, uint256 _y) public returns (uint256) {
    //     return harvest(_x, _y);
    // }

    // /// @dev 铲除
    // function Eradicate(uint256 _x, uint256 _y) public {
    //     eradicate(_x, _y);
    // }

    // /// @dev 偷菜
    // function Steal(
    //     address _owner,
    //     uint256 _x,
    //     uint256 _y
    // ) public {
    //     stealPlant(_owner, _x, _y);
    // }

    // /// @dev 分解
    // function Disassembling(uint256 _tag) public returns (bool) {
    //     return disassembling(_tag);
    // }

    // /// @dev 拍卖
    // function deployAnAuction() public view returns (uint256[] memory) {
    //     return auction.getTokensList();
    // }

    // /// @dev 注册
    // function register(string memory _name) public {
    //     rb._registration(_name);
    //     mon.getMoneyFromShop(msg.sender, 1000);
    // }

    // /// @dev 检查是否已注册
    // function isregister(address _person) public view returns (bool) {
    //     return rb._isregister(_person);
    // }

    // function getUsername(address player) public view returns (string memory) {
    //     // return rb.getUsername(player);
    // }
}
