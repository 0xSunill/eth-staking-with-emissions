// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/StakingContract.sol";

contract TestStakingContract is Test {
    StakingContract c;

    function setUp() public {
        c = new StakingContract();
    }

    function testStake() public {
        address user = address(0x123);
        vm.deal(user, 10 ether);

        uint value = 10 ether;

        vm.prank(user);
        c.stake{value: value}(value);
        assert(c.totalStaked() == value);
    }

    function testUnStake() public {
        address user = address(0x123);
        vm.deal(user, 10 ether);

        uint value = 10 ether;
        uint unStake = 5 ether;

        vm.prank(user);
        c.stake{value: value}(value);

        vm.prank(user);
        c.unStake(unStake);

        assertEq(c.totalStaked(), value - unStake);
        assertEq(c.stakedBalances(user), value - unStake);
    }
}
