// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/StakingContract.sol";
import "src/SunToken.sol";

contract StakingContractTest is Test {
    StakingContract staking;
    SunToken token;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);

    function setUp() public {
        // Deploy with dummy staking address
        token = new SunToken(address(this)); // Set self temporarily as staking contract

        // Deploy staking contract
        staking = new StakingContract(address(token));

        // Override restriction using prank
        vm.prank(address(this));
        token.updateStakingContract(address(staking));
    }

    function testStake() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        staking.stake{value: 1 ether}(1 ether);

        assertEq(staking.stakedBalances(user1), 1 ether);
        assertEq(staking.totalStaked(), 1 ether);
    }

    function testStakeZeroReverts() public {
        vm.expectRevert("Amount must be greater than 0");
        staking.stake{value: 0}(0);
    }

    function testStakeMismatchedValueReverts() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert("Amount must match the value sent");
        staking.stake{value: 0.5 ether}(1 ether);
    }

    function testUnstake() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        staking.stake{value: 2 ether}(2 ether);

        vm.prank(user1);
        staking.unStake(1 ether);

        assertEq(staking.stakedBalances(user1), 1 ether);
        assertEq(staking.totalStaked(), 1 ether);
    }

    function testUnstakeTooMuchReverts() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        staking.stake{value: 1 ether}(1 ether);

        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        staking.unStake(2 ether);
    }

    function testGetBalance() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        staking.stake{value: 1 ether}(1 ether);

        vm.prank(user1);
        uint256 balance = staking.getBalance();
        assertEq(balance, 1 ether);
    }

    function testClaimRewardMintsToken() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        staking.stake{value: 1 ether}(1 ether);

        skip(60); // simulate time passing

        vm.prank(user1);
        staking.claimReward();

        // token test will verify reward amount and mint logic
        uint256 reward = token.balanceOf(user1);
        assertGt(reward, 0);
    }

    function testNoRewardsToClaimReverts() public {
        vm.prank(user1);
        vm.expectRevert("No rewards to claim");
        staking.claimReward();
    }
}
