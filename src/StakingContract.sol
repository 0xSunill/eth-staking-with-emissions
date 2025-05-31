// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingContract {
    mapping(address => uint256) public stakedBalances;
    uint256 public totalStaked;
    constructor() {}


    function stake(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value == amount, "Amount must match the value sent");
        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
    }

    function unStake(uint256 amount) external {
        require(stakedBalances[msg.sender] >= amount, "Insufficient balance");
        stakedBalances[msg.sender] -= amount;
        totalStaked -= amount;
        payable(msg.sender).transfer(amount);
    }
    function getBalance() external view returns (uint256) {
        return stakedBalances[msg.sender];
    }
}
