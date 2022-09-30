// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Bank {
    /// @notice tokens managed by the Bank
    mapping(address => bool) public tokens;

    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => mapping(bytes4 => uint256)) public internalBalances;

    modifier tokenExists(address tokenAddr) {
        require(tokens[tokenAddr], "Bank: inexistant token");
        _;
    }

    function addToken(address tokenAddr) external {
        // ONLY ADATPERS
    }

    function removeToken(address tokenAddr) external tokenExists(tokenAddr) {}

    function _deposit(
        address tokenAddr,
        address account,
        uint256 amount
    ) internal tokenExists(tokenAddr) {
        IERC20(tokenAddr).transferFrom(account, address(this), amount);
        balances[account][tokenAddr] += amount;
    }
}
