// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RepositoryBase is Ownable {
    // 定义了物品的类型
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    /// @dev 玩家的仓库
    mapping(ItemType => mapping(address => Item[])) internal repository;

    struct Item {
        ItemType itemType;
        bool usable;
        uint32 tag;
        uint32 stack;
    }

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    function giveItem(
        address _receiver,
        ItemType _itemType,
        uint256 _itemTag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < repository[_itemType][_receiver].length; i++) {
            if (repository[_itemType][_receiver][i].tag == _itemTag) {
                repository[_itemType][_receiver][i].stack += _amount;
                return true;
            }
        }
        repository[_itemType][_receiver][findFirstPlace(_receiver, _itemType)]
            .tag == _itemTag;
        repository[_itemType][_receiver][findFirstPlace(_receiver, _itemType)]
            .stack == _amount;
        return true;
    }

    function findFirstPlace(address _receiver, ItemType _itemType)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < repository[_itemType][_receiver].length; i++) {
            if (repository[_itemType][_receiver][i].stack == 0) {
                return i;
            }
        }
        return repository[_itemType][_receiver].length;
    }

    function removeItem(
        address _receiver,
        uint256 _ItemTag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < repository[_itemType][_receiver].length; i++) {
            if (repository[_itemType][_receiver][i].tag == _ItemTag) {
                if (_amount > repository[_itemType][_receiver][i].stack) {
                    return false;
                } else {
                    repository[_itemType][_receiver][i].stack -= _amount;
                    return true;
                }
            }
        }
        return false;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
            "You have no permission to see this receiver's storage"
        );
        _;
    }

    function probabilityCheck(uint256 numerator, uint256 denominator)
        public
        view
        returns (bool)
    {
        if (getRandom(denominator) < numerator) {
            return true;
        }
        return false;
    }

    function getRandom(uint256 decimal) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        gasleft(),
                        block.difficulty,
                        block.number,
                        keccak256(abi.encode(block.gaslimit))
                    )
                )
            ) % decimal;
    }
}
