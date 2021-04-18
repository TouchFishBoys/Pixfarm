// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pixfarmon {
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    struct Item {
        ItemType itemType;
        bool usable;
        uint32 id;
        uint32 stack;
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
