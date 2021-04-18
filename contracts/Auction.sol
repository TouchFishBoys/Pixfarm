// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Auction {
    ERC20 private Erc20;
    struct Good {
        address owner; //卖家
        uint256 lowestPrice; //底价
        string name; //商品名
        uint32 dna; //商品dna
        uint256 finalPrice; //一口价
        uint256 total; //该货物上的总钱数，总钱数为 0 时，表示所有出价者已取回出价
        bool isEnd; //结束标志
        uint256 highestPrice; //最高价
        address highestBuyer; //最高出价者
    }

    Good[] public goods; //商品列表
    mapping(address => mapping(uint256 => uint256)) internal buyerBids; //出价者地址 => (商品索引号 => 出价)

    constructor(ERC20 token) {
        Erc20 = token;
    }

    function addGood(
        uint256 _lowestPrice,
        string memory _name,
        uint32 _dna,
        uint256 _finalPrice
    ) public {
        //添加商品
        Good memory good;

        good.owner = msg.sender;
        good.lowestPrice = _lowestPrice;
        good.name = _name;
        good.dna = _dna;
        good.finalPrice = _finalPrice;
        good.highestPrice = good.lowestPrice;
        good.total = 0;
        good.highestBuyer = address(0);
        good.isEnd = false;

        //goods.push(good);
        goods[findFirstSpace()] = good;
    }

    function findFirstSpace() internal view returns (uint256) {
        //寻找商品列表中的第一个空缺
        for (uint256 i = 0; i <= goods.length; i++) {
            if (goods[i].total == 0) {
                return i;
            }
        }
        return goods.length;
    }

    function bid(uint256 _money, uint256 _index) public {
        //出价竞拍
        require(goods[_index].isEnd == false, "The Auction is over");

        require(
            _money + buyerBids[msg.sender][_index] >= goods[_index].lowestPrice,
            "Your price is lower than lowestprice"
        );
        require(
            _money + buyerBids[msg.sender][_index] >=
                goods[_index].highestPrice,
            "Your price is lower than highestPrice"
        );

        Erc20.transferFrom(msg.sender, address(this), _money);

        goods[_index].total += _money;
        buyerBids[msg.sender][_index] += _money;

        if (
            goods[_index].highestPrice == goods[_index].lowestPrice &&
            _money + buyerBids[msg.sender][_index] >= goods[_index].finalPrice
        ) {
            goods[_index].highestPrice = buyerBids[msg.sender][_index];
            goods[_index].highestBuyer = msg.sender;
            auctionEnd(_index); //以一口价结束竞拍
            return;
        } else if (goods[_index].highestPrice != goods[_index].lowestPrice) {
            goods[_index].highestPrice = buyerBids[msg.sender][_index];
            goods[_index].highestBuyer = msg.sender;
        }
    }

    function stopAuction(uint256 _index) public {
        //卖家主动结束拍卖
        require(
            msg.sender == goods[_index].owner,
            "You are not the seller of this item"
        );
        //goods[_index].isEnd=true;
        auctionEnd(_index);
    }

    function auctionEnd(uint256 _index) internal {
        //拍卖结束，卖家获得收益
        goods[_index].isEnd = true;
        if (goods[_index].highestPrice != goods[_index].lowestPrice) {
            Erc20.transfer(
                goods[_index].owner,
                (goods[_index].highestPrice * 95) / 100
            ); //收取5%的手续费
            goods[_index].total -= goods[_index].highestPrice;
            buyerBids[goods[_index].highestBuyer][_index] = 0;
        }
        //delete goods[_index];
    }

    function drawBack(uint256 _index) public {
        //出价者取回出价
        require(goods[_index].isEnd == true);
        require(buyerBids[msg.sender][_index] > 0);
        Erc20.transfer(msg.sender, buyerBids[msg.sender][_index]);
        goods[_index].total -= buyerBids[msg.sender][_index];
        buyerBids[msg.sender][_index] = 0;
    }
}
