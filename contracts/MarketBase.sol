// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AuctionBase.sol";
import "./Repository.sol";
import "./FarmBase.sol";

contract MarketBase {
    Repository private repo;

    constructor(Repository _repo) {
        repo = _repo;

        PriceForSpecie[FarmBase.Specie.empty] = 0;
        PriceForSpecie[FarmBase.Specie.branut] = 150;
        PriceForSpecie[FarmBase.Specie.moonbean] = 300;
        PriceForSpecie[FarmBase.Specie.sunberry] = 500;
        PriceForSpecie[FarmBase.Specie.charis] = 800;

        RateForBenefit[FarmBase.Specie.empty] = 0;
        RateForBenefit[FarmBase.Specie.branut] = 10;
        RateForBenefit[FarmBase.Specie.moonbean] = 15;
        RateForBenefit[FarmBase.Specie.sunberry] = 30;
        RateForBenefit[FarmBase.Specie.charis] = 50;
    }

    /// @dev 等级附加售价
    // uint256[] PirceForLevel = [
    //     uint256(100),
    //     200,
    //     400,
    //     800,
    //     1200,
    //     1800,
    //     2500,
    //     3500
    // ];
    /// @dev 作物本身价格
    //uint256[] PirceForSpecie = [uint256(150), 300, 500, 800];
    mapping(FarmBase.Specie => uint256) PriceForSpecie;
    /// @dev 作物收益
    //uint256[] RateForBenefit = [uint256(10), 15, 30, 50];
    mapping(FarmBase.Specie => uint256) RateForBenefit;

    // function _setBankAddress(address bankAddress) public onlyOwner {
    //     bank = IERC20(bankAddress);
    // }

    /// @dev 仅用于付费，获取（生成）商品信息在调用的函数中生成
    function _buy(
        FarmBase.Specie _specie,
        uint256 _amount,
        uint256 _price
    ) internal {
        //require(bank.allowance(msg.sender, address(this)) > _amount);
        require(repo.transferToShop(msg.sender, _amount * _price));
        Repository.Item memory newItem;
        newItem.specie = _specie;
        newItem.stack = uint32(_amount);
        newItem.usable = true;
        //_repository[ItemType(_tag % 8)][msg.sender].push(newItem);
        repo.addItem(Repository.ItemType.Seed, msg.sender, newItem);
    }

    function sell(
        Repository.ItemType _type,
        FarmBase.Specie _specie,
        uint32 _amount,
        uint256 _value
    ) internal {
        //bank.transfer(msg.sender, _amount);
        // _repository[_type][msg.sender][_index].stack =
        //     _repository[_type][msg.sender][_index].stack -
        //     _amount;
        // uint256 _price;
        // _price = _repository[_type][msg.sender][_index].tag >> 17; //收购价 = 作物种类（x%）* 总属性对应价
        // getMoneyFromShop(msg.sender, _amount);
        require(repo.removeItem(msg.sender, _type, _specie, _amount));
        repo.getMoneyFromShop(msg.sender, _value);
    }

    //function _upgrade() internal override {}
}
