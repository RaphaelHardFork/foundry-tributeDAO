// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library Slot {
    bytes4 internal constant EMPTY = 0x00000000;

    // ADAPTERS
    bytes4 internal constant MANAGING = bytes4(keccak256("managing"));
    bytes4 internal constant ONBOARDING = bytes4(keccak256("onboarding"));
    bytes4 internal constant VOTING = bytes4(keccak256("voting"));

    // EXTENSIONS
    bytes4 internal constant BANK = bytes4(keccak256("bank"));
}
