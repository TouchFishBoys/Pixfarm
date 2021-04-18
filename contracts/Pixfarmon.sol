// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pixfarmon {
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    struct Item {
        ItemType itemType;
        uint32 id;
        uint32 stack;
    }

    mapping(address => Item[]) private _farmRepository;
    mapping(address => mapping(address => bool)) public visibility;

    function getRepository(address _owner) public view returns (Item[] memory) {
        require(visibility[msg.sender][_owner], "Can't see it");
        Item[] memory _repository = _farmRepository[_owner];
        return _repository;
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
