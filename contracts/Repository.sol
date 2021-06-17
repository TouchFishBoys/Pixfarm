// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Money.sol";
import "./FarmBase.sol";

/// @dev 游戏的仓库的合约
contract Repository is Money {
    // 定义了物品的类型
    enum ItemType {Seed, Fruit, Tool} // 3bits for futher development

    /// @dev 所有玩家
    address[] playersAddress;
    mapping(string => address) nameToAddress;
    mapping(address => string) public addressToName;

    /// @dev 玩家的仓库
    //mapping(ItemType => mapping(address => Item[])) internal _repository;
    mapping(address => mapping(ItemType => mapping(uint256 => Item)))
        internal _backpack;
    mapping(address => uint256[8]) internal maxIndex;

    /// @dev 好友
    struct friend {
        string friendName;
        address friendAddress;
    }
    mapping(address => friend[]) public friendList;

    struct Item {
        bool usable;
        //uint32 tag;
        FarmBase.Specie specie;
        uint32 stack;
    }

    struct request {
        string senderName;
        address senderAddress;
    }

    mapping(address => request[]) requestList;

    /// @dev is value has permission to see key's storage
    mapping(address => mapping(address => bool)) public storageAllowence;

    /// @dev 删除某人的某个格子的道具
    function _remove(
        ItemType _type,
        address _player,
        uint256 _index,
        uint32 _amount
    ) internal {
        _backpack[_player][_type][_index].stack -= _amount;
    }

    ///@dev 获取玩家在某个槽的物品
    function _get(
        ItemType _type,
        address _player,
        uint256 _index
    ) internal view returns (Item memory) {
        return _backpack[_player][_type][_index];
    }

    /// @dev 获取玩家拥有的物品列表
    function _getAll(ItemType _type, address _player)
        internal
        view
        returns (Item[50] memory)
    {
        Item[50] memory items;
        uint8 p = 0;
        for (uint8 i = 0; i < maxIndex[_player][uint8(_type)]; i++) {
            if (_backpack[_player][_type][i].stack != 0) {
                items[p] = _backpack[_player][_type][i];
                p += 1;
            }
        }
        return items;
    }

    function quieckAddItem(
        ItemType _itemType,
        address _player,
        Item memory _item
    ) public returns (bool) {
        // _repository[_itemType][_player][1].tag == _item.tag;
        // _repository[_itemType][_player][1].stack == _item.stack;
        _backpack[_player][_itemType][1] = _item;
        return true;
    }

    ///@dev 添加指定数量的道具
    function addItem(
        ItemType _itemType,
        address _player,
        Item memory _item
    ) public returns (bool) {
        // TODO 溢出处理
        for (uint256 i = 0; i < maxIndex[_player][uint8(_itemType)]; i++) {
            if (_backpack[_player][_itemType][i].specie == _item.specie) {
                _backpack[_player][_itemType][i].stack += _item.stack;
                return true;
            }
        }
        if (_findFirstPlace(_player, _itemType) == 50) {
            return false;
        }
        _backpack[_player][_itemType][
            _findFirstPlace(_player, _itemType)
        ] = _item;
        if (
            _findFirstPlace(_player, _itemType) ==
            maxIndex[_player][uint8(_itemType)]
        ) {
            maxIndex[_player][uint8(_itemType)] += 1;
        }
        return true;
    }

    /// @dev 找到对应仓库的第一个空位
    function _findFirstPlace(address _player, ItemType _itemType)
        public
        view
        returns (uint256)
    {
        uint256 index;
        for (uint256 i = 0; i < maxIndex[_player][uint8(_itemType)]; i++) {
            if (_backpack[_player][_itemType][i].stack == 0) {
                index = i;
            }
        }
        if (index == 0 && maxIndex[_player][uint8(_itemType)] <= 49) {
            return maxIndex[_player][uint8(_itemType)];
        }
        return 50;
    }

    /// @dev 删除指定 tag 的物品 _amount 个
    function removeItem(
        address _player,
        ItemType _itemType,
        FarmBase.Specie _specie,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < 50; i++) {
            if (_backpack[_player][_itemType][i].specie == _specie) {
                if (_amount > _backpack[_player][_itemType][i].stack) {
                    return false;
                } else {
                    _backpack[_player][_itemType][i].stack -= _amount;
                    return true;
                }
            }
        }
        return false;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            storageAllowence[host][visitor],
            "You have no permission to see this receiver's storage"
        );
        _;
    }

    //TODO seprate
    function probabilityCheck(uint256 numerator, uint256 denominator)
        public
        view
        returns (bool)
    {
        if (getRandom(denominator) < numerator) {
            return true;
        }
        return false;
    }

    // TODO seprate
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

    function playerCreate(string memory _name) public returns (bool) {
        if (!isNameExist(_name)) {
            playersAddress.push(msg.sender);
            addressToName[msg.sender] = _name;
            nameToAddress[_name] = msg.sender;
            return true;
        } else {
            return false;
        }
    }

    function isNameExist(string memory _name) internal view returns (bool) {
        if (nameToAddress[_name] != address(0)) {
            return true;
        } else {
            return false;
        }
    }

    /// @dev 比较两个字符串
    function hashCompare(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function getItemList(
        uint8 itemType,
        address user,
        address target
    ) public view returns (Item[50] memory) {
        require(
            user == target || storageAllowence[target][user],
            "permission denied"
        );
        return _getAll(ItemType(itemType), target);
    }

    function changePermission(address user, address target) public {
        storageAllowence[user][target] = !storageAllowence[user][target];
    }

    /// @dev 注册
    function _registration(string memory _name) public {
        playersAddress.push(msg.sender);
        nameToAddress[_name] = msg.sender;
        addressToName[msg.sender] = _name;
    }

    /// @dev 是否已注册
    function _isregister(address _person) public view returns (bool) {
        bool flag = false;
        //TODO
        for (uint256 i = 0; i < playersAddress.length; i++) {
            if (playersAddress[i] == _person) {
                flag = true;
            }
        }
        return flag;
    }

    /// @dev 添加种子
    function addSeed(
        FarmBase.Specie _specie,
        address _player,
        uint256 _amount
    ) public {
        Item memory newItem;
        newItem.specie = _specie;
        newItem.usable = true;
        newItem.stack = uint32(_amount);
        addItem(ItemType(ItemType.Seed), _player, newItem);
    }

    /// @dev 添加果实
    function addFruit(
        FarmBase.Specie _specie,
        address _player,
        uint256 _amount
    ) public {
        Item memory newItem;
        newItem.specie = _specie;
        newItem.usable = true;
        newItem.stack = uint32(_amount);
        addItem(ItemType(ItemType.Fruit), _player, newItem);
    }

    function updateMaxIndex() external {
        maxIndex[msg.sender][0] = 0;
        maxIndex[msg.sender][1] = 0;
        maxIndex[msg.sender][2] = 0;
        maxIndex[msg.sender][3] = 0;
        maxIndex[msg.sender][4] = 0;
        maxIndex[msg.sender][5] = 0;
        maxIndex[msg.sender][6] = 0;
        maxIndex[msg.sender][7] = 0;
    }
}
