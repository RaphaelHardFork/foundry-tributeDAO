// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/core/DaoCore.sol";

contract DaoCore_test is Test {
    address public ADMIN = address(501);

    DaoCore public core;

    function setUp() public {
        core = new DaoCore(ADMIN, address(0));
    }
}
