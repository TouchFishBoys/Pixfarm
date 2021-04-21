// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PixPetFactory.sol";
import "./PixFarmFactory.sol";

contract PixPet is PixPetFactory {
    IERC20 private erc20;

    mapping(address => PetPropertiesPacked[]) internal petList;

    constructor(IERC20 _erc20) {
        erc20 = _erc20;
        uint8[] propertiesTrough = [0, 2, 4, 5, 7, 8, 9, 10, 10];
    }

    //pet trade
    function petBreed(
        address _getPetPerson,
        uint256 _fatherIndex,
        address _getMoneyPerson,
        uint256 _motherIndex,
        uint256 _money
    ) public {
        erc20.transferFrom(_getPetPerson, address(this), _money);
        PetPropertiesPacked memory descendant;
        descendant = getDescendant(
            petList[_getPetPerson][_fatherIndex],
            petList[_getMoneyPerson][_motherIndex]
        );
        petList[_getPetPerson].push(descendant);
        erc20.transfer(_getMoneyPerson, (_money * 95) / 100);
    }

    function getDescendant(
        PetPropertiesPacked memory _fatherPet,
        PetPropertiesPacked memory _motherPet
    ) internal pure returns (PetPropertiesPacked memory _descendant) {
        PetPropertiesPacked memory descendant;

        //function

        return descendant;
    }

    function fullDegreeCheck(PetPropertiesPacked memory _pet)
        internal
        returns (PetPropertiesPacked memory _petChecked)
    {
        if (_pet.fullDegree < 40) {
            _pet.atk *= 70 / 100;
            _pet.def *= 70 / 100;
            _pet.hp *= 70 / 100;
            _pet.spd *= 70 / 100;
            return (_pet);
        } else {
            return _pet;
        }
    }

    function petFight(
        address _challenger,
        uint256 _challengerIndex,
        address _defender,
        uint256 _defenderIndex
    ) public view returns (PetPropertiesPacked memory _winner) {
        PetPropertiesPacked memory challengerPet =
            fullDegreeCheck(petList[_challenger][_challengerIndex]);
        PetPropertiesPacked memory defenderPet =
            fullDegreeCheck(petList[_defender][_defenderIndex]);

        uint8 round;

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
        if (_tag % 8 == 2) {
            petList[msg.sender][_petIndex].fullDegree += 25;
            correctFullDegree(petList[msg.sender][_petIndex].fullDegree);
        } else {
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
                petList[msg.sender][_petIndex].fullDegree += specieFull[
                    pac.specie
                ];
                correctFullDegree(petList[msg.sender][_petIndex].fullDegree);
            } else {
                petList[msg.sender][_petIndex].hp += pac.hp;
                petList[msg.sender][_petIndex].atk += pac.atk;
                petList[msg.sender][_petIndex].def += pac.def;
                petList[msg.sender][_petIndex].spd += pac.spd;
                petList[msg.sender][_petIndex].maxPropertiesTrough -= 1;
                petList[msg.sender][_petIndex].fullDegree += specieFull[
                    pac.specie
                ];
                correctFullDegree(petList[msg.sender][_petIndex].fullDegree);
            }
        }
    }

    function correctFullDegree(uint7 _fullDegree)
        internal
        returns (uint7 _correctDegree)
    {
        if (_fullDegree > 100) {
            return (_fullDegree - (_fullDegree - 100));
        }
    }
}
