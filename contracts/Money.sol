// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Money {
    mapping(address => uint256) money;

    IERC20 internal contrac;

    /// @dev 向商店给钱
    function transferToShop(uint256 _value) public {
        money[msg.sender] = money[msg.sender] - _value;
    }

    /// @dev 收钱
    function getMoneyFromShop(uint256 _value) public {
        money[msg.sender] = money[msg.sender] + _value;
    }

    /// @dev 玩家间交易
    function transferTo(address _receiver, uint256 _value) public {
        money[msg.sender] = money[msg.sender] - _value;
        money[_receiver] = money[_receiver] + _value;
    }

    ///充值
    function _rechargeMoney(uint256 _value) public {
        bool isSuccess =
            contrac.transferFrom(msg.sender, address(this), _value);
        if (!isSuccess) {
            revert("Recharge failed");
        }
        money[msg.sender] = money[msg.sender] + _value;
    }
}
