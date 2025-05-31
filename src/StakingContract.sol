// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingContract {
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public unclaimedRewards;
    mapping(address => uint256) public lastUpdateTime;
    uint256 public totalStaked;

    constructor() {}

    function getReward(address _address) public view returns (uint256) {
        uint currentReward = unclaimedRewards[_address];
        uint updatedTime = lastUpdateTime[_address];
        if (updatedTime == 0 || totalStaked == 0) return currentReward;
        uint newReward = ((block.timestamp - updatedTime) * stakedBalances[_address]) / totalStaked;
        return currentReward + newReward;
    }

    function updateRewards(address _user) internal {
        unclaimedRewards[_user] = getReward(_user);
        lastUpdateTime[_user] = block.timestamp;
    }

    function stake(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value == amount, "Amount must match the value sent");

        updateRewards(msg.sender);

        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
    }

    function unStake(uint256 amount) external {
        require(stakedBalances[msg.sender] >= amount, "Insufficient balance");

        updateRewards(msg.sender);

        stakedBalances[msg.sender] -= amount;
        totalStaked -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return stakedBalances[msg.sender];
    }

    function claimReward() public {
        uint reward = getReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        unclaimedRewards[msg.sender] = 0;
        lastUpdateTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(reward);
    }
}
