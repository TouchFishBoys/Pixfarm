// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PixFarmFactory.sol";
import "./Shop.sol";

abstract contract IPixFarm is IPixFarmFactory, Shop {
    mapping(address => uint256) farmExperience;
    mapping(address => address[]) public friends;

    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) public virtual returns (bool);

    function harvest(uint256 _x, uint256 _y)
        public
        virtual
        returns (uint256 fruitTag, uint8 number);

    function eradicating(uint256 _x, uint256 _y)
        public
        virtual
        returns (bool getSeed);

    function stealing(
        address _friend,
        uint256 _x,
        uint256 _y
    ) public virtual returns (bool);
}

abstract contract PixFarm is Ownable, IPixFarm {
    /// @dev contract of factory
    IPixFarmFactory private factory;
    mapping(address => Item[]) internal accountStorage;

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    mapping(address => field[][]) fields;
    struct field {
        bool unlocked;
        bool used;
        uint256 seedTag;
        uint256 sowingTime;
        uint256 maturityTime;
    }

    constructor(IPixFarmFactory _factory) {
        factory = _factory;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
            "You have no permission to see this guy's storage"
        );
        _;
    }

    function updateFactory(IPixFarmFactory _factory) public onlyOwner {
        factory = _factory;
    }

    function sowing(
        uint256 _x,
        uint256 _y,
        uint256 _seedTag
    ) public override returns (bool) {
        require(
            fields[msg.sender][_x][_y].unlocked == true,
            "The field is locked!"
        );
        //移除背包种子，成功返回true，失败返回false
        fields[msg.sender][_x][_y].seedTag = _seedTag;
        fields[msg.sender][_x][_y].sowingTime = block.timestamp;
        fields[msg.sender][_x][_y].maturityTime =
            block.timestamp +
            specieTime[getSpecieBySeed(_seedTag)];
        fields[msg.sender][_x][_y].used = true;
    }

    function harvest(uint256 _x, uint256 _y)
        public
        override
        returns (uint256 fruitTag, uint8 number)
    {}

    function eradicating(uint256 _x, uint256 _y)
        public
        override
        returns (bool getSeed)
    {
        if(block.timestamp-fields[msg.sender][_x][_y])
    }

    function stealing(
        address _friend,
        uint256 _x,
        uint256 _y
    ) public override returns (bool) {}
}
