// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

import "../helpers/Slot.sol";
import "../core/IDaoCore.sol";
import "../guards/SlotGuard.sol";
import "../extensions/IBank.sol";

contract Onboarding is SlotGuard {
    address public immutable bank;

    constructor(address core, address bank_) SlotGuard(core, Slot.ONBOARDING) {
        bank = bank_;
    }

    function joinDao(uint256 deposit) external {
        require(
            !IDaoCore(_core).hasRole(msg.sender, Slot.USER_EXISTS),
            "Onboarding: already a member"
        );
        IBank(bank).joiningDeposit(msg.sender, deposit);
        IDaoCore(_core).changeMemberStatus(msg.sender, Slot.USER_EXISTS, true);
    }

    function quitDao() external {
        require(
            IDaoCore(_core).hasRole(msg.sender, Slot.USER_EXISTS),
            "Onboarding: not a member"
        );
        IBank(bank).refundJoinDeposit(msg.sender);
        IDaoCore(_core).changeMemberStatus(msg.sender, Slot.USER_EXISTS, false);
    }
}
