// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

import "../helpers/Slot.sol";
import "../core/IDaoCore.sol";
import "./Adapters.sol";

contract Onboarding is Adapters {
    constructor(address core) Adapters(core, Slot.ONBOARDING) {}

    function joinDao(uint256 deposit) external {}

    function processProposal(bytes32) external pure override {
        // TO IMPLEMENT
    }
}
