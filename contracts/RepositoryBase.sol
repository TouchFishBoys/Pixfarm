// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Money.sol";

contract RepositoryBase is Ownable, Money {
    // 定义了物品的类型
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    /// @dev 所有玩家名字
    address[] playersAddress;
    mapping(string => address) nameToAddress;
    mapping(address => string) public addressToName;

    /// @dev 玩家的仓库
    //mapping(ItemType => mapping(address => Item[])) internal _repository;
    mapping(address => mapping(ItemType => mapping(uint256 => Item)))
        internal _backpack;
    mapping(address => uint256) internal maxIndex;

    /// @dev 好友
    struct friend {
        string friendName;
        address friendAddress;
    }
    mapping(address => friend[]) public friendList;

    struct Item {
        bool usable;
        uint32 tag;
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
        returns (Item[] memory)
    {
        Item[] memory items;
        uint8 p = 0;
        for (uint8 i = 0; i < maxIndex[_player]; i++) {
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
        for (uint256 i = 0; i < maxIndex[_player]; i++) {
            if (_backpack[_player][_itemType][i].tag == _item.tag) {
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
        return true;
    }

    /// @dev 找到对应仓库的第一个空位
    function _findFirstPlace(address _player, ItemType _itemType)
        internal
        returns (uint256)
    {
        uint256 index;
        for (uint256 i = 0; i < maxIndex[_player]; i++) {
            if (_backpack[_player][_itemType][i].stack == 0) {
                index = i;
            }
        }
        if (index == 0 && maxIndex[_player] <= 49) {
            maxIndex[_player] += 1;
            index = maxIndex[_player];
        }
        return index;
        return 50; //full
    }

    /// @dev 删除指定 tag 的物品 _amount 个
    function removeItem(
        address _player,
        ItemType _itemType,
        uint256 _tag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < 50; i++) {
            if (_backpack[_player][_itemType][i].tag == _tag) {
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

    function addFriendByName(string memory _name) public returns (bool) {
        if (!isNameExist(_name)) {
            return false;
        } else {
            request memory newRequest;
            newRequest.senderAddress = msg.sender;
            newRequest.senderName = addressToName[msg.sender];
            requestList[nameToAddress[_name]].push(newRequest);
            return true;
        }
    }

    function addFriendByAddress(address _address) public returns (bool) {
        if (!isNameExist(addressToName[_address])) {
            return false;
        } else {
            request memory newRequest;
            newRequest.senderAddress = msg.sender;
            newRequest.senderName = addressToName[msg.sender];
            requestList[_address].push(newRequest);
            return true;
        }
    }

    function acceptFriend(uint256 _index) public {
        friend memory newFriend;
        newFriend.friendName = requestList[msg.sender][_index].senderName;
        newFriend.friendAddress = requestList[msg.sender][_index].senderAddress;
        friendList[msg.sender].push(newFriend);

        friend memory receiver;
        receiver.friendName = addressToName[msg.sender];
        receiver.friendAddress = msg.sender;
        friendList[requestList[msg.sender][_index].senderAddress].push(
            receiver
        );

        for (uint256 i = _index; i < requestList[msg.sender].length; i++) {
            requestList[msg.sender][i] = requestList[msg.sender][i + 1];
        }
        delete requestList[msg.sender][requestList[msg.sender].length - 1];
    }

    function refuseFriend(uint256 _index) public {
        for (uint256 i = _index; i < requestList[msg.sender].length; i++) {
            requestList[msg.sender][i] = requestList[msg.sender][i + 1];
        }
        delete requestList[msg.sender][requestList[msg.sender].length - 1];
    }

    function getItemList(
        uint8 itemType,
        address user,
        address target
    ) public view returns (Item[] memory) {
        require(
            user == target || storageAllowence[target][user],
            "permission denied"
        );
        return _getAll(ItemType(itemType), target);
    }

    function changePermission(address user, address target) public {
        storageAllowence[user][target] = !storageAllowence[user][target];
    }

    function friendCheck(address p1, address p2) public view returns (bool) {
        for (uint256 i = 0; i < friendList[p1].length; i++) {
            if (friendList[p1][i].friendAddress == p2) {
                return true;
            }
        }
        return false;
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

    function getUsername(address _person) public view returns (string memory) {
        string memory name = addressToName[_person];
        require(!hashCompare(name, ""), "USER_NOTREGISTERED");
        return name;
    }

    function getFriendList() public view returns (friend[] memory) {
        return friendList[msg.sender];
    }

    /// @dev 添加种子
    function addSeed(
        uint256 _tag,
        address _player,
        uint256 _amount
    ) public {
        Item memory newItem;
        newItem.tag = uint32(_tag);
        newItem.usable = true;
        newItem.stack = uint32(_amount);
        quieckAddItem(ItemType(ItemType.Seed), _player, newItem);
    }

    /// @dev 添加果实
    function addFruit(
        uint256 _tag,
        address _player,
        uint256 _amount
    ) public {
        Item memory newItem;
        newItem.tag = uint32(_tag);
        newItem.usable = true;
        newItem.stack = uint32(_amount);
        quieckAddItem(ItemType(ItemType.Fruit), _player, newItem);
    }
}
