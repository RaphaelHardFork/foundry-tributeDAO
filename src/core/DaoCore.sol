// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "../helpers/Slot.sol";
import "../adapters/Adapters.sol";

/**
 * @notice Main contract, keep states of the DAO
 */

contract DaoCore {
    event AdapterChanged(
        bytes4 indexed slot,
        address oldAdapter,
        address newAdapter
    );

    event MemberStatusChanged(
        address indexed member,
        MemberStatus indexed oldStatus,
        MemberStatus indexed newStatus
    );

    event ProposalSubmitted(
        bytes4 indexed slot,
        address indexed initiater,
        address indexed votingContract,
        bytes32 proposalId
    );

    enum MemberStatus {
        UNKNOWN,
        IN_PROCESS,
        EXISTS,
        EXITED,
        JAILED
    }

    enum ProposalStatus {
        EXISTS,
        SUSPENDED,
        ACCEPTED,
        REJECTED
    }

    struct Member {
        MemberStatus status;
    }

    struct Adapter {
        bytes4 slot;
        address adapterAddr;
    }

    struct Proposal {
        bytes4 slot;
        bytes28 proposalId;
        address fromMember;
        address votingContract;
        ProposalStatus status;
    }

    /// @notice The map to track all members of the DAO with their existing flags
    mapping(address => Member) public members;
    uint256 public membersCount;

    /// @notice The map that keeps track of all adapters registered in the DAO: sha3(adapterId) => adapterAddress
    mapping(bytes4 => Adapter) public adapters;

    /// @notice The map that keeps track of all proposasls submitted to the DAO
    mapping(bytes32 => Proposal) public proposals;

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
            delete adapters[slot];

            IAdapters(oldAdapter).deleteAdapter();
        }

        emit AdapterChanged(slot, oldAdapter, adapterAddr);
    }

    function changeMemberStatus(address account, MemberStatus status)
        external
        onlyAdapter(Slot.ONBOARDING)
    {
        require(account != address(0), "Core: zero address used");
        MemberStatus oldStatus = members[account].status;

        // update members count
        if (oldStatus == MemberStatus.IN_PROCESS) {
            unchecked {
                membersCount++;
            }
        } else if (status == MemberStatus.EXITED) {
            unchecked {
                membersCount--;
            }
        }

        members[account].status = status;
        emit MemberStatusChanged(account, oldStatus, status);
    }

    function submitProposal(
        bytes32 proposalId,
        address initiater,
        address votingContract
    ) external onlyAdapter(bytes4(proposalId)) {
        require(
            initiater != address(0) && votingContract != address(0),
            "Core: zero address used"
        );

        bytes4 slot = bytes4(proposalId);

        proposals[proposalId] = Proposal(
            slot,
            bytes28(proposalId << 32),
            initiater,
            votingContract,
            ProposalStatus.EXISTS
        );
        emit ProposalSubmitted(slot, initiater, votingContract, proposalId);
    }

    function processProposal(bytes32 proposalId)
        external
        onlyAdapter(bytes4(proposalId))
    {
        // require => vote ok => get result

        address adapterAddr = adapters[bytes4(proposalId)].adapterAddr;
        IAdapters(adapterAddr).processProposal(proposalId);
    }

    function isMember(address account) external view returns (bool) {
        return members[account].status == MemberStatus.EXISTS;
    }
}
