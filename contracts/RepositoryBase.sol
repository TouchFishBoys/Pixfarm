// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RepositoryBase is Ownable {
    // 定义了物品的类型
    enum ItemType {Seed, Fruit, Feed} // 3bits for futher development

    /// @dev 所有玩家名字
    string[] playersName;
    mapping(string => address) nameToAddress;
    mapping(address => string) addressToName;
    /// @dev 玩家的仓库
    mapping(ItemType => mapping(address => Item[])) internal _repository;

    /// @dev 好友
    struct friend {
        string friendName;
        address friendAddress;
    }
    mapping(address => friend[]) friendList;

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
    mapping(address => mapping(address => bool)) internal _storageAllowence;

    /// @dev 删除某人的某个格子的道具
    function _remove(
        ItemType _type,
        address _player,
        uint256 _slot
    ) internal {
        delete _repository[_type][_player][_slot];
    }

    ///@dev 获取玩家在某个槽的物品
    function _get(
        ItemType _type,
        address _player,
        uint256 _slot
    ) internal returns (Item memory) {
        return _repository[_type][_player][_slot];
    }

    /// @dev 获取玩家拥有的物品列表
    function _getAll(ItemType _type, address _player)
        internal
        returns (Item[] memory)
    {
        return _repository[_type][_player];
    }

    ///@dev 添加指定数量的道具
    function _add(
        ItemType _itemType,
        address _player,
        Item memory _item
    ) public returns (bool) {
        // TODO 溢出处理
        for (uint256 i = 0; i < _repository[_itemType][_player].length; i++) {
            if (_repository[_itemType][_player][i].tag == _item.tag) {
                _repository[_itemType][_player][i].stack += _item.stack;
                return true;
            }
        }
        _repository[_itemType][_player][_findFirstPlace(_player, _itemType)]
            .tag == _item.tag;
        _repository[_itemType][_player][_findFirstPlace(_player, _itemType)]
            .stack == _item.stack;
        return true;
    }

    /// @dev 找到对应仓库的第一个空位
    function _findFirstPlace(address _receiver, ItemType _itemType)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < _repository[_itemType][_receiver].length; i++) {
            if (_repository[_itemType][_receiver][i].stack == 0) {
                return i;
            }
        }
        return _repository[_itemType][_receiver].length;
    }

    /// @dev 删除指定 tag 的物品 _amount 个
    function removeItem(
        address _player,
        ItemType _itemType,
        uint256 _tag,
        uint32 _amount
    ) public returns (bool) {
        for (uint256 i = 0; i < _repository[_itemType][_player].length; i++) {
            if (_repository[_itemType][_player][i].tag == _tag) {
                if (_amount > _repository[_itemType][_player][i].stack) {
                    return false;
                } else {
                    _repository[_itemType][_player][i].stack -= _amount;
                    return true;
                }
            }
        }
        return false;
    }

    modifier requireVisibility(address host, address visitor) {
        require(
            _storageAllowence[host][visitor],
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
            playersName.push(_name);
            addressToName[msg.sender] = _name;
            nameToAddress[_name] = msg.sender;
            return true;
        } else {
            return false;
        }
    }

    function isNameExist(string memory _name) internal view returns (bool) {
        for (uint256 i = 0; i < playersName.length; i++) {
            if (hashCompare(_name, playersName[i])) {
                return true;
            }
        }
        return false;
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
}
