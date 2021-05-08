// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MarketBase.sol";
import "./PixPet.sol";

abstract contract IPetMarket is PixPet {
    /// @dev 向商店出售宠物
    function sellPetToShop(uint256 _index)
        external
        virtual
        returns (bool isSuccess);

    /// @dev 拍卖宠物
    function sellPetOnAuction(uint256 _index)
        external
        virtual
        returns (bool isSuccess);

    /// @dev 商店购买宠物
    function buyPetFromShop(uint256 _money, PetPropertiesPacked memory _pet)
        external
        virtual
        returns (bool isSuccess);
}

abstract contract PetMarket is IPetMarket {
    function sellPetToShop(uint256 _index)
        public
        override
        returns (bool isSuccess)
    {
        uint256 value = getPetValue(petList[msg.sender][_index]);
        // bool flag = (erc20.transfer(msg.sender, value));
        // if (!flag) {
        //     revert("Failed to sell pet");
        // }
        getMoneyFromShop(msg.sender, value);
        for (uint256 i = _index; i < petList[msg.sender].length - 1; i++) {
            petList[msg.sender][i] = petList[msg.sender][i + 1];
        }
    }

    function sellPetOnAuction(uint256 _index)
        public
        override
        returns (bool isSuccess)
    {}

    function buyPetFromShop(uint256 _money, PetPropertiesPacked memory _pet)
        public
        override
        returns (bool isSuccess)
    {
        // bool flag = (erc20.transferFrom(msg.sender, address(this), _money));
        // if (!flag) {
        //     revert("An error occurred during payment");
        // }
        transferToShop(msg.sender, _money);
        petList[msg.sender].push(_pet);
    }

    function getPetValue(PetPropertiesPacked memory _pet)
        internal
        returns (uint256 _value)
    {}
}
