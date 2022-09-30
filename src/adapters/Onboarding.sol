// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "../helpers/Slot.sol";
import "../core/IDaoCore.sol";
import "./Adapters.sol";

contract Onboarding is Adapters {
    constructor(address core) Adapters(core, Slot.ONBOARDING) {}

    function processProposal(bytes32) external pure override {
        // TO IMPLEMENT
    }
}
