// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SunToken} from "./SunToken.sol";

contract StakingContract {
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public unclaimedRewards;
    mapping(address => uint256) public lastUpdateTime;
    uint256 public totalStaked;

    SunToken public rewardToken;

    constructor(address _sunTokenAddress) {
        rewardToken = SunToken(_sunTokenAddress);
    }

    function getReward(address _user) public view returns (uint256) {
        uint256 currentReward = unclaimedRewards[_user];
        uint256 lastTime = lastUpdateTime[_user];
        if (lastTime == 0) return currentReward;

        uint256 timeElapsed = block.timestamp - lastTime;

        // 1 SUN per 1 ETH per day
        uint256 newReward = (stakedBalances[_user] * timeElapsed) / 1 days;

        return currentReward + newReward;
    }

    function updateRewards(address _user) internal {
        unclaimedRewards[_user] = getReward(_user);
        lastUpdateTime[_user] = block.timestamp;
    }

    function stake(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value == amount, "Sent ETH must match stake amount");

        if (stakedBalances[msg.sender] > 0) {
            updateRewards(msg.sender);
        } else {
            lastUpdateTime[msg.sender] = block.timestamp;
        }

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

    function claimReward() public {
        updateRewards(msg.sender);

        uint256 reward = unclaimedRewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        unclaimedRewards[msg.sender] = 0;
        lastUpdateTime[msg.sender] = block.timestamp;

        rewardToken.mint(msg.sender, reward * 1e18); // mint SUN with 18 decimals
    }

    function getBalance() external view returns (uint256) {
        return stakedBalances[msg.sender];
    }
}
