// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

abstract contract Guards {
    modifier onlyAdapter() {
        //
        _;
    }
}
