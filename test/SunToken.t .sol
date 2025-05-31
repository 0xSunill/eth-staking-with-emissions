// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/SunToken.sol";

contract TestSunToken is Test {
    SunToken c;

    function setUp() public {
        c = new SunToken(address(this));
    }

    function testInitialBalance() public {
        assertEq(
            c.balanceOf(address(this)),
            0,
            "Initial balance should be zero"
        );
    }

    function testMint() public {
        c.mint(address(this), 100);
        assertEq(c.balanceOf(address(this)), 100, "Mint failed");
    }
}
