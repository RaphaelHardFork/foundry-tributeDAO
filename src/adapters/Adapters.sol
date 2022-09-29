// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "../helpers/Slot.sol";
import "../core/IDaoCore.sol";

interface IAdapters {
    function processProposal(bytes32 proposalId) external;

    function deleteAdapter() external;
}

abstract contract Adapters is IAdapters {
    address internal immutable _core;
    bytes4 internal immutable _slot;

    modifier onlyCore() {
        require(msg.sender == _core, "Adapters: only callable by Core");
        _;
    }

    modifier onlyMember() {
        require(IDaoCore(_core).isMember(msg.sender), "Adapters: not a member");
        _;
    }

    constructor(address core, bytes4 slot) {
        require(slot != Slot.EMPTY, "Adapters: empty slot");
        _core = core;
        _slot = slot;
    }

    function deleteAdapter() external override onlyCore {
        selfdestruct(payable(_core));
    }
}
