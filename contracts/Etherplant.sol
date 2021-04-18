// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EtherplantFactory.sol";

contract Etherplant is Ownable, Pixfarmon {
    /// @dev contract of factory
    IEtherplantFactory private factory;
    mapping(address => Item[]) internal accountStorage;

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    constructor(IEtherplantFactory _factory) {
        factory = _factory;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
            "You have no permission to see this guy's storage"
        );
        _;
    }

    function updateFactory(IEtherplantFactory _factory) public onlyOwner {
        factory = _factory;
    }
}
