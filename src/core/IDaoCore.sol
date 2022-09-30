// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IDaoCore {
    function replaceAdapter(bytes4 slot, address adapterAddr) external;

    function changeMemberStatus(
        address account,
        bytes4 role,
        bool value
    ) external;

    function submitProposal(
        bytes32 proposalId,
        address initiater,
        address votingContract
    ) external;

    function processProposal(bytes32 proposalId) external;

    function hasRole(address account, bytes4 role) external returns (bool);
}
