// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./PixPetFactory.sol";
import "./PixFarmFactory.sol";

abstract contract PixPet is PixPetFactory {
    IERC20 private ERC20;

    mapping(address => PetPropertiesPacked[]) internal petList;

    uint8[] internal propertiesTrough = [0, 2, 4, 5, 7, 8, 9, 10, 10];

    constructor(IERC20 _ERC20) {
        ERC20 = _ERC20;
    }

    function addPet(address _owner, PetPropertiesPacked memory _newPet)
        internal
    {
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
        PetPropertiesPacked memory descendant;
        descendant = getDescendant(
            petList[_getPetPerson][_fatherIndex],
            petList[_getMoneyPerson][_motherIndex]
        );
        petList[_getPetPerson].push(descendant);
        ERC20.transfer(_getMoneyPerson, (_money * 95) / 100);
    }

    function getDescendant(
        PetPropertiesPacked memory _fatherPet,
        PetPropertiesPacked memory _motherPet
    ) internal pure returns (PetPropertiesPacked memory _descendant) {
        PetPropertiesPacked memory descendant;

        //function

        return descendant;
    }

    function petFight(
        address _challenger,
        uint256 _challengerIndex,
        address _defender,
        uint256 _defenderIndex
    ) public view returns (PetPropertiesPacked memory _winner) {
        PetPropertiesPacked memory challengerPet =
            petList[_challenger][_challengerIndex];
        PetPropertiesPacked memory defenderPet =
            petList[_defender][_defenderIndex];

        uint8 round;
        uint8 challengerOriginalHp = challengerPet.hp;
        uint8 defenderOriginalHp = defenderPet.hp;

        if (challengerPet.spd > defenderPet.spd) {
            round = challengerPet.spd / defenderPet.spd;
        } else {
            round = defenderPet.spd / challengerPet.spd;
        }

        while (challengerPet.hp >= 0 && defenderPet.hp >= 0) {
            if (challengerPet.spd >= defenderPet.spd) {
                for (uint256 i = 1; i <= round; i++) {
                    defenderPet.hp -=
                        challengerPet.atk *
                        (1 - (defenderPet.def / (100 + defenderPet.def)));
                }
                challengerPet.hp -=
                    defenderPet.atk *
                    (1 - (challengerPet.def / (100 + challengerPet.def)));
            } else {
                for (uint256 i = 1; i <= round; i++) {
                    challengerPet.hp -=
                        defenderPet.atk *
                        (1 - (challengerPet.def / (100 + challengerPet.def)));
                }
                defenderPet.hp -=
                    challengerPet.atk *
                    (1 - (defenderPet.def / (100 + defenderPet.def)));
            }
        }

        // challengerPet.hp = challengerOriginalHp;
        // defenderPet.hp = defenderOriginalHp;

        if (challengerPet.hp == 0) {
            if (challengerPet.petExperience >= defenderPet.petExperience) {
                petList[_defender][_defenderIndex].petExperience +=
                    (challengerPet.petExperience * 1) /
                    100 +
                    100;
            } else {
                petList[_defender][_defenderIndex].petExperience +=
                    (defenderPet.petExperience * 1) /
                    100 +
                    100;
            }
            return (defenderPet);
        } else {
            if (challengerPet.petExperience >= defenderPet.petExperience) {
                petList[_challenger][_challengerIndex].petExperience +=
                    (challengerPet.petExperience * 1) /
                    100 +
                    100;
            } else {
                petList[_challenger][_challengerIndex].petExperience +=
                    (defenderPet.petExperience * 1) /
                    100 +
                    100;
            }
            return (challengerPet);
        }
    }

    function feedPet(uint256 _tag, uint256 _petIndex) public {
        PlantPropertiesPacked memory pac = getPropertiesByFruitTag(_tag);
        if (pac.specie < 8) {
            petList[msg.sender][_petIndex].hp += pac.hp;
            petList[msg.sender][_petIndex].atk += pac.atk;
            petList[msg.sender][_petIndex].def += pac.def;
            petList[msg.sender][_petIndex].spd += pac.spd;
            petList[msg.sender][_petIndex]
                .maxPropertiesTrough -= propertiesTrough[
                pac.hp + pac.atk + pac.def + pac.spd
            ];
        } else {
            petList[msg.sender][_petIndex].hp += pac.hp;
            petList[msg.sender][_petIndex].atk += pac.atk;
            petList[msg.sender][_petIndex].def += pac.def;
            petList[msg.sender][_petIndex].spd += pac.spd;
            petList[msg.sender][_petIndex].maxPropertiesTrough -= 1;
        }
    }
}
