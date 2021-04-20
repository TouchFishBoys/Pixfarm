// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PixPet.sol";

contract AuctionBase {
    IERC20 private ercToken;

    struct Auction {
        address seller; //卖家
        uint256 startingPrice; //起拍价
        uint256 fixedPrice; //一口价
        uint256 highestBid; //最高价
        address highestBidder; //最高出价者
        uint256 startTime; // 拍卖开始的时间
        uint256 duration; // 结束时间
    }

    uint256[] public tokens; //商品列表
    /// @dev Token 对应的拍卖
    mapping(uint256 => Auction) internal tokenToAuction;

    /// @dev 出价者地址 => (商品索引号 => 出价)
    mapping(address => mapping(uint256 => uint256)) internal bidderBids;

    /// @dev 拍卖上剩余的待取的钱
    mapping(uint256 => uint128) private tokenToMoneyRemain;

    event AuctionBided(address bidder, uint256 amount, uint256 blockNumber);
    event BidWithdrew(address withdrawer, uint256 amount, uint256 index);
    event AuctionCanceled(uint256 token);
    event AuctionEnded(uint256 seller, uint256);

    constructor(IERC20 _token) {
        ercToken = _token;
    }

    event AuctionCreated(
        uint256 token,
        uint256 startBid,
        uint256 startTime,
        uint256 duration
    );

    modifier ownerOf(uint256 _token) {
        require(
            tokens[_token].seller == msg.sender,
            "You are not the owner of this auction"
        );
        _;
    }

    modifier notOwnerOf(uint256 _token) {
        require(
            tokens[_token].seller != msg.sender,
            "You are not the owner of this auction"
        );
        _;
    }

    /// @dev 添加一个拍卖
    /// @notice token
    function _addAuction(uint256 _token, Auction calldata _auction) internal {
        //添加商品
        tokenToAuction[_token] = _auction;
        emit AuctionCreated(
            _token,
            _auction.startingPrice,
            _auction.sta,
            _auction.duration
        );
    }

    function _isOnAuction(uint256 _token) internal view returns (bool) {
        Auction storage auction = tokenToAuction[_token];
        return
            now > auction.startTime + auction.duration &&
            tokenToMoneyRemain[_token] == 0;
    }

    /// @dev 直接删除拍卖
    function _removeAuction(uint256 _token) internal {
        delete tokenToMoneyRemain[_token];
    }

    /// @dev 取消拍卖
    function _cancleAuction(uint256 _token) internal {
        _removeAuction(_token);
    }

    /// @dev Cancle an auction by its owner
    function cancleAuction(uint256 _token) public ownerOf(_token) {
        _cancleAuction(_token);
    }

    function bid(uint256 _money, uint256 _token) public notOwnerOf(_token) {
        //出价竞拍
        require(_isOnAuction(_token), "The Auction is over");

        Auction storage _auction = tokenToAuction[_token];
        require(_money > _auction.highestBid, "You cannot bid lower");
        uint256 previousBid = _auction.highestBid;
        address previousBidder = _auction.highestBidder;

        _auction.highestBid = _money;
        _auction.highestBidder = msg.sender;
        bool isSuccess =
            ercToken.transferFrom(msg.sender, address(this), _money);

        if (!isSuccess) {
            _auction.highestBid = previousBid;
            _auction.highestBidder = previousBidder;
            revert("Transfer erc token failed");
        }

        tokenToMoneyRemain[_token] += _money;
        bidderBids[msg.sender][_token] += _money;
        emit AuctionBided(msg.sender, _money, block.number);
    }

    function withdraw(uint256 _token) public {
        //出价者取回出价
        require(!_isOnAuction(_token), "Auction has not ended");
        require(
            bidderBids[msg.sender][_token] > 0, // sender在拍卖 _index 剩余的票票
            "You have no money in this auction"
        );

        uint256 amount = bidderBids[msg.sender][_token];

        uint256 previousRemain = bidderBids[msg.sender][_token];
        bidderBids[msg.sender][_token] = 0; // 先把在这个拍卖剩余的钱置 0
        bool isSuccess = ercToken.transfer(msg.sender, amount);
        if (!isSuccess) {
            bidderBids[msg.sender][_token] = previousRemain;
            revert("Transfer failed");
        }
        tokens[_token].total -= bidderBids[msg.sender][_token];
        emit BidWithdrew(msg.sender, amount, _token);
    }
}
