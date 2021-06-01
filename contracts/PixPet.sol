// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PetFactory.sol";
import "./FarmFactory.sol";

contract PixPet is PetFactory, FarmFactory {
    constructor(Repository _repo) FarmFactory(_repo) {}

    /// @dev  宠物繁殖
    // function breed(
    //     address _petOwner,
    //     uint256 _fatherIndex,
    //     address _getMoneyPerson,
    //     uint256 _motherIndex,
    //     uint256 _money
    // ) public {
    //     // bool isSuccess = erc20.transferFrom(_petOwner, address(this), _money);
    //     // if (isSuccess == false) {
    //     //     revert("Transfer failed");
    //     // }
    //     transferToShop(msg.sender, _money);
    //     PetPropertiesPacked memory descendant;
    //     // descendant = _getDescendant(
    //     //     petList[_petOwner][_fatherIndex],
    //     //     petList[_getMoneyPerson][_motherIndex]
    //     // );
    //     petList[_petOwner].push(descendant);

    //     // isSuccess = erc20.transfer(_getMoneyPerson, (_money * 95) / 100);
    //     // if (isSuccess == false) {
    //     //     revert("Transfer failed");
    //     // }
    //     getMoneyFromShop(_getMoneyPerson, (_money * 95) / 100);
    // }

    /// @dev  获得后代
    // function _getDescendant(
    //     PetPropertiesPacked memory _fatherPet,
    //     PetPropertiesPacked memory _motherPet
    // ) internal pure returns (PetPropertiesPacked memory _descendant) {
    //     PetPropertiesPacked memory descendant;

    //     //function

    //     return descendant;
    // }

    /// @dev  检查宠物是否处于饥饿状态，饥饿状态下全属性-30%
    function _isHungry(PetPropertiesPacked memory _pet)
        internal
        pure
        returns (PetPropertiesPacked memory _petChecked)
    {
        if (_pet.fullDegree < 40) {
            _pet.atk = (_pet.atk * 70) / 100;
            _pet.def = (_pet.def * 70) / 100;
            _pet.hp = (_pet.hp * 70) / 100;
            _pet.spd = (_pet.spd * 70) / 100;
            return (_pet);
        } else {
            return _pet;
        }
    }

    /// @dev  战斗轮
    function fight(
        address _challenger,
        uint256 _challengerIndex,
        address _defender,
        uint256 _defenderIndex
    ) public returns (PetPropertiesPacked memory _winner) {
        PetPropertiesPacked memory challengerPet =
            _isHungry(petList[_challenger][_challengerIndex]);
        PetPropertiesPacked memory defenderPet =
            _isHungry(petList[_defender][_defenderIndex]);

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

    /// @dev  宠物喂养
    function feed(uint256 _tag, uint256 _petIndex) public {
        if (_tag % 8 == 2) {
            petList[msg.sender][_petIndex].fullDegree += 25;
            petList[msg.sender][_petIndex].fullDegree = correctHunger(
                petList[msg.sender][_petIndex].fullDegree
            );
        } else {
            PlantPropertiesPacked memory pac = getPropertiesByTag(_tag);
            if (uint8(pac.specie) < 8) {
                petList[msg.sender][_petIndex].hp += pac.hp;
                petList[msg.sender][_petIndex].atk += pac.atk;
                petList[msg.sender][_petIndex].def += pac.def;
                petList[msg.sender][_petIndex].spd += pac.spd;
                petList[msg.sender][_petIndex]
                    .maxPropertiesTrough -= propertiesTrough[
                    pac.hp + pac.atk + pac.def + pac.spd
                ];
                petList[msg.sender][_petIndex].fullDegree += uint8(
                    specieFull[uint8(pac.specie)]
                );
                petList[msg.sender][_petIndex].fullDegree = correctHunger(
                    petList[msg.sender][_petIndex].fullDegree
                );
            } else {
                petList[msg.sender][_petIndex].hp += pac.hp;
                petList[msg.sender][_petIndex].atk += pac.atk;
                petList[msg.sender][_petIndex].def += pac.def;
                petList[msg.sender][_petIndex].spd += pac.spd;
                petList[msg.sender][_petIndex].maxPropertiesTrough -= 1;
                petList[msg.sender][_petIndex].fullDegree += uint8(
                    specieFull[uint8(pac.specie)]
                );
                petList[msg.sender][_petIndex].fullDegree = correctHunger(
                    petList[msg.sender][_petIndex].fullDegree
                );
            }
        }
    }

    /// @dev  饱食度修正
    function correctHunger(uint8 _hunger)
        internal
        pure
        returns (uint8 _correctDegree)
    {
        if (_hunger > 100) {
            return (_hunger - (_hunger - 100));
        } else if (_hunger < 0) {
            return 0;
        } else {
            return _hunger;
        }
    }

    /// @dev  饱食度减少    1点饱食度 = 360秒   100点 = 10小时
    function decreaseHunger(uint256 _petIndex) public returns (uint8 _hunger) {
        if (
            petList[msg.sender][_petIndex].fullDegree > 0 &&
            petList[msg.sender][_petIndex].zeroTime >= block.timestamp
        ) {
            petList[msg.sender][_petIndex].fullDegree -= uint8(
                (petList[msg.sender][_petIndex].zeroTime - block.timestamp) /
                    360
            );
            petList[msg.sender][_petIndex].fullDegree = correctHunger(
                petList[msg.sender][_petIndex].fullDegree
            );
        } else {
            petList[msg.sender][_petIndex].fullDegree = 0;
        }
        return petList[msg.sender][_petIndex].fullDegree;
    }

    /// @dev  得到饱食度归零时间
    function getZerTime(uint256 _petIndex) public returns (uint256 _zeroTime) {
        petList[msg.sender][_petIndex].zeroTime =
            block.timestamp +
            petList[msg.sender][_petIndex].fullDegree *
            360;
        return petList[msg.sender][_petIndex].zeroTime;
    }
}
