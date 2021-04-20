// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PixfarmonBase {
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    struct Item {
        ItemType itemType;
        bool usable;
        uint32 tag;
        uint32 stack;
    }
    mapping(address => Item[]) internal accountStorage;

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    function giveItem(
        address _guy,
        uint256 _ItemTag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < accountStorage[_guy].length; i++) {
            if (accountStorage[_guy][i].tag == _ItemTag) {
                accountStorage[_guy][i].stack += _amount;
                return true;
            }
        }
        accountStorage[_guy][findFirstPlace(_guy)].tag == _ItemTag;
        accountStorage[_guy][findFirstPlace(_guy)].stack == _amount;
        return true;
    }

    function findFirstPlace(address _guy) internal view returns (uint256) {
        for (uint256 i = 0; i < accountStorage[_guy].length; i++) {
            if (accountStorage[_guy][i].stack == 0) {
                return i;
            }
        }
        return accountStorage[_guy].length;
    }

    function removeItem(
        address _guy,
        uint256 _ItemTag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < accountStorage[_guy].length; i++) {
            if (accountStorage[_guy][i].tag == _ItemTag) {
                if (_amount > accountStorage[_guy][i].stack) {
                    return false;
                } else {
                    accountStorage[_guy][i].stack -= _amount;
                    return true;
                }
            }
        }
        return false;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
            "You have no permission to see this guy's storage"
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
