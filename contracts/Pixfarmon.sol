// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pixfarmon {
    function getRandom(uint256 seed) public view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(seed, msg.sender, block.timestamp))
            );
    }
}
