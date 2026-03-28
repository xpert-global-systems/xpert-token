// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PayToUnlockToken is ERC20, Ownable {
    uint256 public unlockFee;
    mapping(address => bool) public unlocked;

    event Unlocked(address indexed user);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        uint256 unlockFee_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply_ * 10 ** decimals());
        unlockFee = unlockFee_;
    }

    function unlock() external payable {
        require(!unlocked[msg.sender], "Already unlocked");
        require(msg.value >= unlockFee, "Insufficient unlock fee");

        unlocked[msg.sender] = true;
        emit Unlocked(msg.sender);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0)) {
            require(unlocked[from], "You must unlock first");
        }
        super._update(from, to, value);
    }
}
