// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/core/DaoRegistry.sol";

contract DeployProcess is Test {
    DaoRegistry public dao;

    address public DEPLOYER = address(401);
    address public DAO_OWNER = address(501);
    address public PAYER = address(601);
    address public ADAPTER = address(11);

    function setUp() public {
        //
    }

    function testDeployment() public {
        dao = new DaoRegistry();
        // check address
        emit log_address(DEPLOYER);
        emit log_address(DAO_OWNER);
        emit log_address(PAYER);

        // deployment
        vm.prank(DAO_OWNER);
        dao.initialize(DAO_OWNER, DAO_OWNER);

        // add extensions & adapters?

        vm.prank(DAO_OWNER);
        dao.finalizeDao();

        // use the DAO
        vm.prank(DAO_OWNER);
        // dao.potentialNewMember(PAYER);

        // checks
        // assertTrue(dao.isMember(DEPLOYER));
        assertTrue(dao.isMember(DAO_OWNER));
        // assertTrue(dao.isMember(PAYER));

        // view
        emit log_address(address(dao));

        emit log_bytes32(bytes4(keccak256("life")));
    }
}
