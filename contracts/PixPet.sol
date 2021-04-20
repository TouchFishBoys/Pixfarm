// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./PixPetFactory.sol";

abstract contract PixPet is PixPetFactory {
    IERC20 private ERC20;

    mapping(address => PetAttribute[]) internal petList;

    constructor(IERC20 _ERC20) {
        ERC20 = _ERC20;
    }

    function addPet(address _owner, PetAttribute memory _newPet) internal {
        //add pet into list
        petList[_owner].push(_newPet);
    }

    //pet trade
    function petBreed(
        address _getPetPerson,
        uint256 _fatherIndex,
        address _getMoneyPerson,
        uint256 _motherIndex,
        uint256 _money
    ) public {
        ERC20.transferFrom(_getPetPerson, address(this), _money);
        PetAttribute memory descendant;
        descendant = getDescendant(
            petList[_getPetPerson][_fatherIndex],
            petList[_getMoneyPerson][_motherIndex]
        );
        petList[_getPetPerson].push(descendant);
        ERC20.transfer(_getMoneyPerson, (_money * 95) / 100);
    }

    function getDescendant(
        PetAttribute memory _fatherPet,
        PetAttribute memory _motherPet
    ) internal pure returns (PetAttribute memory _descendant) {
        PetAttribute memory descendant;

        //function

        return descendant;
    }

    function petFight(
        address _challenger,
        uint256 _challengerIndex,
        address _defender,
        uint256 _defenderIndex
    ) public {
        PetAttribute memory challengerPet =
            petList[_challenger][_challengerIndex];
        PetAttribute memory defenderPet = petList[_defender][_defenderIndex];
    }
}
