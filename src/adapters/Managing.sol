// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "../helpers/Slot.sol";
import "../core/IDaoCore.sol";
import "./Adapters.sol";

/**
 * @notice MOST important contract in the DAO, as it allow to add/remove adapters & extensions
 * if this contract deprecaced this fonction the DAO cannot evolve anymore
 */

contract Managing is Adapters {
    struct Proposal {
        bytes4 slot;
        address adapterAddr;
        address votingContract;
    }

    mapping(bytes28 => Proposal) public proposals;

    constructor(address core) Adapters(core, Slot.MANAGING) {}

    function submitProposal(bytes4 slot, address adapterAddr, address votingContract) external {
        // check member
        // check votingContract

        Proposal memory proposal = Proposal(slot, adapterAddr, votingContract);
        bytes28 proposalId = bytes28(keccak256(abi.encode(proposal)));

        // store in the core
        IDaoCore(_core).submitProposal(bytes32(bytes.concat(_slot, proposalId)), msg.sender, votingContract);
    }

    function processProposal(bytes32 proposalId) external override onlyCore {
        Proposal memory p = proposals[bytes28(proposalId << 32)];
        IDaoCore(_core).replaceAdapter(p.slot, p.adapterAddr);
        delete proposals[bytes28(proposalId << 32)];
    }
}
