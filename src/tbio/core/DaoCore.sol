// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "../helpers/Slot.sol";

/**
 * @notice Main contract, keep states of the DAO
 */

contract DaoCore {
    event AdapterChanged(
        bytes4 indexed slot,
        address oldAdapter,
        address newAdapter
    );

    struct Member {
        uint256 flags;
    }

    struct Adapter {
        bytes4 slot;
        address adapterAddr;
    }

    /// @notice The map to track all members of the DAO with their existing flags
    mapping(address => Member) public members;

    /// @notice The map that keeps track of all adapters registered in the DAO: sha3(adapterId) => adapterAddress
    mapping(bytes4 => Adapter) public adapters;

    modifier onlyAdapter(bytes4 slot) {
        require(
            adapters[slot].adapterAddr == msg.sender,
            "Core: not the right adapter"
        );
        _;
    }

    function replaceAdapter(bytes4 slot, address adapterAddr)
        external
        onlyAdapter(Slot.MANAGING)
    {
        require(slot != Slot.EMPTY, "Core: empty slot");
        address oldAdapter = adapters[slot].adapterAddr;

        if (adapterAddr != address(0)) {
            adapters[slot] = Adapter(slot, adapterAddr);
        } else {
            // remove adapter
        }

        emit AdapterChanged(slot, oldAdapter, adapterAddr);
    }
}
