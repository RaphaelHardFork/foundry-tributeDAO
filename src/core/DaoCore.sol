// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "openzeppelin-contracts/access/AccessControl.sol";

import "../helpers/Slot.sol";
import "../adapters/Adapters.sol";
import "./IDaoCore.sol";

/**
 * @notice Main contract, keep states of the DAO
 */

contract DaoCore is IDaoCore {
    event AdapterChanged(
        bytes4 indexed slot,
        address oldAdapter,
        address newAdapter
    );

    event ExtensionChanged(bytes4 indexed slot, address extensionAddr);

    event MemberStatusChanged(
        address indexed member,
        bytes4 indexed roles,
        bool indexed actualValue
    );

    event ProposalSubmitted(
        bytes4 indexed slot,
        address indexed initiater,
        address indexed votingContract,
        bytes32 proposalId
    );

    enum ProposalStatus {
        EXISTS,
        SUSPENDED,
        ACCEPTED,
        REJECTED
    }

    struct Adapter {
        bytes4 slot;
        address adapterAddr;
    }

    struct Extension {
        bytes4 slot;
        bool active;
        address extensionAddr;
    }

    struct Proposal {
        bytes4 slot;
        bytes28 proposalId;
        address fromMember;
        address votingContract;
        ProposalStatus status;
    }

    /// @notice The map to track all members of the DAO with their roles or credits
    mapping(address => mapping(bytes4 => uint256)) public members;
    uint256 public membersCount;

    /// @notice The map that keeps track of all adapters registered in the DAO: sha3(adapterId) => adapterAddress
    mapping(bytes4 => Adapter) public adapters;

    mapping(bytes4 => Extension) public extensions; // + adapters = JUST ENTRIES ??

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

    function addExtension(bytes4 slot, address extensionAddr)
        external
        onlyAdapter(Slot.MANAGING)
    {
        require(slot != Slot.EMPTY, "Core: empty slot");
        Extension memory e = extensions[slot];
        require(!e.active, "Core: cannot replace extension");

        e.slot = slot;
        e.extensionAddr = extensionAddr;
        e.active = true;
        extensions[slot] = e;

        emit ExtensionChanged(slot, extensionAddr);
    }

    function removeExtension(bytes4 slot) external onlyAdapter(Slot.MANAGING) {
        Extension memory e = extensions[slot];
        require(e.active, "Core: inactive extension");

        delete extensions[slot];
        emit ExtensionChanged(slot, e.extensionAddr);
    }

    function changeMemberStatus(
        address account,
        bytes4 roles,
        bool value
    ) external onlyAdapter(Slot.ONBOARDING) {
        require(account != address(0), "Core: zero address used");
        require(members[account][roles] != value, "Core: role not changing");

        if (roles == Slot.USER_EXISTS) {
            unchecked {
                value ? ++membersCount : --membersCount;
            }
        }

        members[account][roles] = value;
        emit MemberStatusChanged(account, roles, value);
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

    function hasRole(address account, bytes4 role)
        external
        view
        returns (bool)
    {
        return members[account][role];
    }
}
