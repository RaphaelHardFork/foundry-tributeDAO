// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IDaoCore {
    struct Member {
        MemberStatus status;
    }

    enum MemberStatus {
        UNKNOWN,
        IN_PROCESS,
        EXISTS,
        EXITED,
        JAILED
    }

    function replaceAdapter(bytes4 slot, address adapterAddr) external;

    function changeMemberStatus(address account, MemberStatus status) external;

    function submitProposal(
        bytes32 proposalId,
        address initiater,
        address votingContract
    ) external;

    function processProposal(bytes32 proposalId) external;

    function isMember(address account) external returns (bool);
}
