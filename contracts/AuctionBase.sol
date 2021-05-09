// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Money.sol";

contract AuctionBase is Ownable, Money {
    enum AuctionStatus {
        PENDING, // 还未创建
        RUNNING, // 可以出价或者时间到了
        FINISHED, // 可以提钱
        CANCELED // 拍卖被卖家取消
    }

    struct Auction {
        address seller; //卖家
        uint64 startingPrice; //起拍价
        uint64 highestBid; //最高价
        address highestBidder; //最高出价者
        uint256 startTime; // 拍卖开始的时间
        uint256 duration; // 结束时间
    }

    uint256[] public tokens; //商品列表
    /// @dev Token 对应的拍卖
    mapping(uint256 => Auction) public tokenToAuction;

    /// @dev 出价者地址 => (token => 出价)
    mapping(address => mapping(uint256 => uint64)) public bidderBids;

    /// @dev 拍卖上剩余的待取的钱
    mapping(uint256 => uint64) public tokenToMoneyRemain;

    /// @dev 拍卖的状态
    mapping(uint256 => AuctionStatus) public status;

    event AuctionEnded(address seller, address winner, uint64 dealPrice);
    modifier ownerOf(uint256 _token) {
        require(
            tokenToAuction[_token].seller == msg.sender,
            "You are not the owner of this auction"
        );
        _;
    }

    modifier notOwnerOf(uint256 _token) {
        require(
            tokenToAuction[_token].seller != msg.sender,
            "You are not the owner of this auction"
        );
        _;
    }

    function getTokensList() public view returns (uint256[] memory) {
        return tokens;
    }
}
