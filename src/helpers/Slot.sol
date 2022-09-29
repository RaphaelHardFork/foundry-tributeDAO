// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library Slot {
    bytes4 internal constant EMPTY = 0x00000000;
    bytes4 internal constant MANAGING = bytes4(keccak256("managing"));
    bytes4 internal constant ONBOARDING = bytes4(keccak256("onboarding"));
}
