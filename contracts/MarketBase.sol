// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./AuctionBase.sol";
import "./ShopBase.sol";

contract MarketBase is AuctionBase, ShopBase {
    IERC20 internal bank;

    function _setBankAddress(address bankAddress) public onlyOwner {
        this.bank = IERC20(bankAddress);
    }

    /// @dev 仅用于付费，获取（生成）商品信息在调用的函数中生成
    function _buy(uint256 _amount) internal {
        require(bank.allowance(msg.sender, address(this)) > _amount);
    }

    function _sell(uint256 _amount) internal {
        bank.transfer(msg.sender, _amount);
    }

    function _upgrade() internal {}
}
