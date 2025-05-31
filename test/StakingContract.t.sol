// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StakingContract.sol";
import "../src/SunToken.sol";

contract StakingContractTest is Test {
    SunToken token;
    StakingContract staking;

    address user = vm.addr(1);

    function setUp() public {
        token = new SunToken(address(this));
        staking = new StakingContract(address(token));
        token.updateStakingContract(address(staking));
    }

    function testStakeAndUnstake() public {
        vm.deal(user, 2 ether);

        vm.prank(user);
        staking.stake{value: 1 ether}(1 ether);
        assertEq(staking.stakedBalances(user), 1 ether);

        vm.warp(block.timestamp + 1 days);

        vm.prank(user);
        staking.unStake(1 ether);
        assertEq(staking.stakedBalances(user), 0);
    }

    function testRewardAccrualAfterOneDay() public {
        vm.deal(user, 1 ether);

        vm.prank(user);
        staking.stake{value: 1 ether}(1 ether);

        vm.warp(block.timestamp + 1 days);

        vm.prank(user);
        staking.claimReward();

        assertEq(token.balanceOf(user), 1 ether);
    }

    function testMultipleStakesWithCorrectReward() public {
        vm.deal(user, 3 ether);

        // Stake 1 ETH
        vm.prank(user);
        staking.stake{value: 1 ether}(1 ether);
        vm.warp(block.timestamp + 1 days);

        // Stake 2 more ETH
        vm.prank(user);
        staking.stake{value: 2 ether}(2 ether);
        vm.warp(block.timestamp + 1 days);

        // Claim reward
        vm.prank(user);
        staking.claimReward();

        // Day 1: 1 ETH * 1 day = 1 token
        // Day 2: 3 ETH * 1 day = 3 tokens
        uint256 expectedReward = 4 ether;
        assertEq(token.balanceOf(user), expectedReward);
    }

    function testUnstakeReducesBalance() public {
        vm.deal(user, 2 ether);
        vm.prank(user);
        staking.stake{value: 2 ether}(2 ether);

        vm.warp(block.timestamp + 1 days);

        vm.prank(user);
        staking.unStake(1 ether);
        assertEq(staking.stakedBalances(user), 1 ether);
    }

    function testClaimRewardFailsIfZero() public {
        vm.expectRevert("No rewards to claim");
        vm.prank(user);
        staking.claimReward();
    }

    function testStakeZeroFails() public {
        vm.expectRevert("Amount must be greater than 0");
        vm.prank(user);
        staking.stake{value: 0}(0);
    }

    function testStakeMismatchFails() public {
        vm.expectRevert("Sent ETH must match stake amount");
        vm.prank(user);
        staking.stake{value: 0.5 ether}(1 ether);
    }

    function testUnstakeMoreThanStakedFails() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        staking.stake{value: 1 ether}(1 ether);

        vm.expectRevert("Insufficient balance");
        vm.prank(user);
        staking.unStake(2 ether);
    }

    function testGetRewardViewFunction() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        staking.stake{value: 1 ether}(1 ether);

        vm.warp(block.timestamp + 1 days);

        uint256 reward = staking.getReward(user);
        assertEq(reward, 1 ether);
    }
}
