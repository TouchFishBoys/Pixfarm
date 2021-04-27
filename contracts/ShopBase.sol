// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FarmBase.sol";

interface ShopBase {
    function _buy() external returns (uint256);

    function _sell() external;

    function _upgrade() external;

    ///@dev buy a seed from shop
    function buySeed(uint256 specie, uint256 level) external returns (bool);

    function buyPet() external view returns (uint256 _dna);
}
