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
            uint256 specie,
            uint256 hp,
            uint256 atk,
            uint256 def,
            uint256 spd,
            Quality quality
        );
    function getQuality(uint256 code)
        internal
        view
        virtual
    returns(Quality q);
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
            uint256 specie,
            uint256 hp,
            uint256 atk,
            uint256 def,
            uint256 spd,
            Quality quality
        )
    {
        uint256 _spd = _dna % 8;
        _dna/=8;
        uint256 _def = _dna % 8;
        _dna/=8;
        uint256 _atk = _dna % 8;
        _dna/=8;
        uint256 _hp = _dna % 8;
        _dna/=8;
        Quality _quality = getQuality(_dna % 4);
        _dna/=4;
        uint256 _specie = _dna % 16;
        _dna/=16;
        //get type
        return (_specie,_hp,_atk,_def,_spd,_quality); 
    }

    function getQuality(uint256 code)
        internal
        view
        virtual
        override
        returns(Quality q){
        if(code==0){
            return Quality.N;
        }else if(code==1){
            return Quality.R;
        }else if(code==2){
            return Quality.SR;
        }else if(code==3){
            return Quality.SSR;
        }
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
