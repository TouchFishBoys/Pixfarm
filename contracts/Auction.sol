// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AuctionBase.sol";

contract Auction is AuctionBase {
    /// @dev 添加一个拍卖
    /// @notice token
    function _addAuction(uint256 _token, Auction calldata _auction) internal {
        //添加商品
        tokenToAuction[_token] = _auction;
        emit AuctionCreated(
            _token,
            _auction.startingPrice,
            _auction.startTime,
            _auction.duration
        );
    }

    function _findFirstAuctionSlot() internal pure returns (uint256) {
        // 条件：状态不为RUNNING，
        return 0;
    }

    function _canBid(uint256 _token) internal view returns (bool) {
        return status[_token] == AuctionStatus.RUNNING && _isTimeEnd(_token);
    }

    /// @dev 仅判断是否超时
    function _isTimeEnd(uint256 _token) internal view returns (bool) {
        Auction storage auction = tokenToAuction[_token];
        return auction.startTime + auction.duration < block.timestamp;
    }

    event AuctionCreated(
        uint256 token,
        uint256 startBid,
        uint256 startTime,
        uint256 duration
    );

    /// @notice 创建拍卖
    /// @return token 返回创建的拍卖的token
    function createAuction(uint64 _startPrice, uint256 _endTime)
        public
        returns (uint256 token)
    {
        Auction memory _auction =
            Auction({
                seller: msg.sender,
                startingPrice: _startPrice,
                highestBid: 0,
                highestBidder: address(0),
                startTime: block.timestamp,
                duration: _endTime
            });
        token = _findFirstAuctionSlot();
        tokenToAuction[token] = _auction;
        status[token] = AuctionStatus.RUNNING;
        emit AuctionCreated(token, _startPrice, block.timestamp, _endTime);
        return token;
    }

    event AuctionCanceled(uint256 token);

    /// @notice 取消拍卖
    function cancelAuction(uint256 _token) public ownerOf(_token) {
        require(
            status[_token] == AuctionStatus.RUNNING,
            "This Auction is running or has already cancled"
        );
        status[_token] = AuctionStatus.CANCELED;
        emit AuctionCanceled(_token);
    }

    event AuctionBidded(address bidder, uint256 amount, uint256 blockNumber);

    /// @notice 参与出价
    /// @param _token 拍卖号
    /// @param _money 出价
    function bid(uint256 _token, uint64 _money) public notOwnerOf(_token) {
        Auction storage _auction = tokenToAuction[_token];
        if (
            status[_token] == AuctionStatus.RUNNING &&
            block.timestamp < _auction.startTime + _auction.duration
        ) {
            status[_token] = AuctionStatus.FINISHED;
        }

        require(
            _money > _auction.highestBid,
            "You cannot bid less than current highest bid"
        );
        //uint64 previousBid = _auction.highestBid;
        //address previousBidder = _auction.highestBidder;

        _auction.highestBid = _money;
        _auction.highestBidder = msg.sender;
        // bool isSuccess =
        //     ercToken.transferFrom(msg.sender, address(this), _money);
        // if (!isSuccess) {
        //     _auction.highestBid = previousBid;
        //     _auction.highestBidder = previousBidder;
        //     revert("Transfer erc token failed");
        // }
        transferTo(msg.sender, address(this), _money);

        tokenToMoneyRemain[_token] += _money;
        bidderBids[msg.sender][_token] += _money;
        emit AuctionBidded(msg.sender, _money, block.number);
    }

    event BidWithdrew(
        uint256 token,
        address withdrawer,
        uint256 amount,
        uint256 index
    );

    /// @notice 参加拍卖的人取回在这个拍卖里面的钱
    /// @param _token 拍卖的token
    function withdraw(uint256 _token) public {
        require(!_canBid(_token), "Auction has not ended");
        require(
            bidderBids[msg.sender][_token] > 0, // sender在拍卖 _index 剩余的票票
            "You have no money in this auction"
        );

        uint64 amount = bidderBids[msg.sender][_token];

        //uint64 previousRemain = bidderBids[msg.sender][_token];
        bidderBids[msg.sender][_token] = 0;
        // 先把在这个拍卖剩余的钱置 0
        // bool isSuccess = ercToken.transfer(msg.sender, amount);
        // if (!isSuccess) {
        //     bidderBids[msg.sender][_token] = previousRemain;
        //     revert("Transfer failed");
        // }
        transferTo(address(this), msg.sender, amount);
        tokenToMoneyRemain[_token] -= amount;
        emit BidWithdrew(_token, msg.sender, amount, _token);
        if (tokenToMoneyRemain[_token] == 0) {
            // 如果剩余的钱全部撤回完了，就更新状态
            status[_token] = AuctionStatus.PENDING;
        }
    }
}
