// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract IEtherplantFactory {
    enum Quality {N, R, SR, SSR}
    enum Type {Seed,Fruit}

    struct Plant { 
        string name;
        uint32 dna;         //1 bit to classfy seed and fruit 4 bits for species 2 bits for quality and 3 bits for each properties
    }                       //total:19 bits
                            //  example:
                            //  seed or fruit
                            //  |
                            //  |species
                            //  ||   quality
                            //  ||   | hp
                            //  ||   | |  atk
                            //  ||   | |  |  def             
                            //  ||   | |  |  |  spd
                            //  ||   | |  |  |  |
                            //  1110010001011100010


    function getPlantProperties(uint64 _dna)
        external
        view
        virtual
        returns (
            Type type,
            uint256 hp,
            uint256 atk,
            uint256 def,
            uint256 spd,
            Quality quality
        );
}

contract EtherplantFactory is Ownable, IEtherplantFactory {
    function _generateDna(uint32 parent1, uint32 parent2)
        private
        pure
        returns (uint32)
    {
        //TODO
        return uint32(parent1 + parent2);
    }

    function getPlantProperties(uint64 _dna)
        external
        view
        virtual
        override
        returns (
            Type type,
            uint256 hp,
            uint256 atk,
            uint256 def,
            uint256 spd,
            Quality quality
        )
    {
        
    }

    function check(uint256 probability, uint256 decimal)
        public
        view
        returns (bool)
    {
        if (
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                decimal <
            probability
        ) {
            return true;
        }
        return false;
    }
}
