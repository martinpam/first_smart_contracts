// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract SmartContractWallet {
    address public owner;
    struct User {
        uint payed;
        uint allowance;
        bool isGuardian;
        uint8 newOwnerCount;
        bool usedVote;
    }
    uint8 numberOfGuardians;
    address[] addressesWithVotes;
    mapping(address => User) public userMapping;

    constructor(address _initialOwner) {
        owner = _initialOwner;
    }

    function receiveFunds() payable public {
        userMapping[msg.sender].payed += msg.value;
    }

    receive() external payable {
        receiveFunds();
    }


    function transfer(address payable _to, uint _amount) payable public {
        if (msg.sender == owner) {
             _to.transfer(_amount);
        } else {
            require(userMapping[msg.sender].allowance >= _amount, "Too little allowance");
            userMapping[msg.sender].allowance -= _amount;
            _to.transfer(_amount);
        }
    }

    function setAllowance(address payable _userAddress, uint _amount) public {
        require(msg.sender == owner, "You are not the owner");
         userMapping[_userAddress].allowance = _amount;
    }

    function setGuardianState(address _userAddress, bool _isGuardian) public {
        require(msg.sender == owner, "You are not the owner");
        if (numberOfGuardians < 5 && _isGuardian) {
            userMapping[_userAddress].isGuardian = true;
            numberOfGuardians++;
        } else if(!_isGuardian) {
            userMapping[_userAddress].isGuardian = false;
            numberOfGuardians--;
        }
    }

    function voteNewOwner(address _userAddress, bool _revokeVote) public {
        require(userMapping[msg.sender].isGuardian, "You are not a guardian");
        if (!_revokeVote && !userMapping[msg.sender].usedVote) {
            addressesWithVotes.push(_userAddress);
            userMapping[msg.sender].usedVote = true;
            userMapping[_userAddress].newOwnerCount += 1;
            if (userMapping[_userAddress].newOwnerCount == 3) {
                owner = _userAddress;
                for (uint i = 0; i < addressesWithVotes.length; i++) {
                    userMapping[addressesWithVotes[i]].newOwnerCount = 0;
                }
            }
        } else if (_revokeVote) {
            userMapping[msg.sender].usedVote = false;
            userMapping[_userAddress].newOwnerCount -= 1;
        }
    }
}


