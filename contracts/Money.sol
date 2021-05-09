// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Money {
    mapping(address => uint256) money;

    IERC20 internal contrac;

    /// @dev 向商店给钱
    function transferToShop(address _person, uint256 _value)
        public
        returns (bool)
    {
        if (_value > money[_person]) {
            return false;
        }
        money[_person] = money[_person] - _value;
        return true;
    }

    /// @dev 收钱
    function getMoneyFromShop(address _person, uint256 _value) public {
        money[_person] = money[_person] + _value;
    }

    /// @dev 玩家间交易
    function transferTo(
        address p1,
        address p2,
        uint256 _value
    ) public {
        money[p1] = money[p1] - _value;
        money[p2] = money[p2] + _value;
    }

    ///充值
    function _rechargeMoney(uint256 _value) public {
        bool isSuccess =
            contrac.transferFrom(msg.sender, address(this), _value);
        if (!isSuccess) {
            revert("Recharge failed");
        }
        money[msg.sender] = money[msg.sender] + (_value / 400000000000);
    }
}
