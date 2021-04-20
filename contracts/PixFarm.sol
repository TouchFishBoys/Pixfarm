// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PixFarmFactory.sol";
import "./Shop.sol";

contract PixFarm is Ownable, PixFarmFactory, Shop {
    /// @dev contract of factory
    IPixFarmFactory private factory;
    mapping(address => Item[]) internal accountStorage;

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    constructor(IPixFarmFactory _factory) {
        factory = _factory;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
            "You have no permission to see this guy's storage"
        );
        _;
    }

    function updateFactory(IPixFarmFactory _factory) public onlyOwner {
        factory = _factory;
    }
}
