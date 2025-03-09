// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TransplantManagement.sol";

/**
 * @title TransplantManagementTest
 * @dev Comprehensive test suite for the TransplantManagement contract, covering both positive and negative cases.
 */
contract TransplantManagementTest is Test {
    TransplantManagement transplant;

    // Define key actors
    address regulator = address(0x1);
    address hospital = address(0x2);
    address medicalTeam = address(0x3);
    address llm = address(0x4);
    address ethicalCommittee = address(0x5);
    address donor = address(0x6);
    address recipient1 = address(0x7);
    address recipient2 = address(0x8);
    address unauthorized = address(0x9);

    function setUp() public {
        // Deploy the contract with the regulator address
        vm.prank(regulator);
        transplant = new TransplantManagement(regulator);

        // Register key entities
        vm.prank(regulator);
        transplant.registerHospital(hospital);

        vm.prank(regulator);
        transplant.registerMedicalTeam(medicalTeam);

        vm.prank(regulator);
        transplant.registerLLM(llm);

        vm.prank(regulator);
        transplant.registerEthicalCommittee(ethicalCommittee);

        vm.prank(regulator);
        transplant.registerDonorAddress(donor);

        vm.prank(regulator);
        transplant.registerRecipientAddress(recipient1);

        vm.prank(regulator);
        transplant.registerRecipientAddress(recipient2);
    }

    /// @dev Tests successful donor and recipient registration.
    function testDonorAndRecipientRegistration_Success() public {
        vm.prank(hospital);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");

        (uint256 donorId, , string memory bloodType, , string memory organType, , bool registered, ) = transplant.donors(1);

        assertEq(donorId, 1);
        assertEq(bloodType, "A+");
        assertEq(organType, "Kidney");
        assertTrue(registered);

        vm.prank(hospital);
        transplant.registerRecipient(recipient1, "A+", "HLA-A2", "Kidney", "ipfs://recipient1");

        (uint256 recipientId, , string memory recipientBloodType, , string memory recipientOrganType, , bool recipientRegistered, , ) = transplant.recipients(1);

        assertEq(recipientId, 1);
        assertEq(recipientBloodType, "A+");
        assertEq(recipientOrganType, "Kidney");
        assertTrue(recipientRegistered);
    }

    /// @dev Tests failure when an unauthorized entity tries to register a donor.
    function testDonorRegistration_FailsForUnauthorizedCaller() public {
        vm.expectRevert("Only a registered Hospital can approve");
        vm.prank(unauthorized);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");
    }

    /// @dev Tests ethical approval process.
    function testEthicalApproval_Success() public {
        vm.prank(hospital);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");

        vm.prank(hospital);
        transplant.registerRecipient(recipient1, "A+", "HLA-A2", "Kidney", "ipfs://recipient1");

        vm.prank(ethicalCommittee);
        transplant.approveDonorEthicalCommittee(1);

        (, , , , , , , bool ethicalApproved) = transplant.donors(1);
        assertTrue(ethicalApproved);
    }

    /// @dev Tests failure when an unauthorized entity tries to approve a donor.
    function testEthicalApproval_FailsForUnauthorizedCaller() public {
        vm.expectRevert("Only the Ethical Committee can perform this action");
        vm.prank(unauthorized);
        transplant.approveDonorEthicalCommittee(1);
    }

    /// @dev Tests match creation by an authorized LLM.
    function testMatchCreation_Success() public {
        vm.prank(hospital);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");

        vm.prank(hospital);
        transplant.registerRecipient(recipient1, "A+", "HLA-A2", "Kidney", "ipfs://recipient1");

        vm.prank(ethicalCommittee);
        transplant.approveDonorEthicalCommittee(1);
        vm.prank(ethicalCommittee);
        transplant.approveRecipientEthicalCommittee(1);

        vm.prank(llm);
        transplant.createMatch(1, 1, 1);

        (uint256 matchId, uint256 donorId, uint256 recipientId, , , , , , ) = transplant.matches(1);

        assertEq(matchId, 1);
        assertEq(donorId, 1);
        assertEq(recipientId, 1);
    }

    /// @dev Tests failure when an unauthorized entity tries to create a match.
    function testMatchCreation_FailsForUnauthorizedCaller() public {
        vm.expectRevert("Only authorized LLMs can perform this action");
        vm.prank(unauthorized);
        transplant.createMatch(1, 1, 1);
    }

    /// @dev Tests the entire approval process.
    function testFullApprovalProcess_Success() public {
        vm.prank(hospital);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");

        vm.prank(hospital);
        transplant.registerRecipient(recipient1, "A+", "HLA-A2", "Kidney", "ipfs://recipient1");

        vm.prank(ethicalCommittee);
        transplant.approveDonorEthicalCommittee(1);
        vm.prank(ethicalCommittee);
        transplant.approveRecipientEthicalCommittee(1);

        vm.prank(llm);
        transplant.createMatch(1, 1, 1);

        vm.prank(medicalTeam);
        transplant.approveMedicalTeam(1);

        vm.prank(hospital);
        transplant.approveHospital(1);

        vm.prank(donor);
        transplant.approveDonor(1);

        vm.prank(recipient1);
        transplant.approveRecipient(1);

        vm.prank(ethicalCommittee);
        transplant.approveFinalTransplant(1);

        assertTrue(transplant.isTransplantApproved(1));
    }

    /// @dev Tests failure when a match is not fully approved.
    function testTransplantApproval_FailsIfNotFullyApproved() public {
        vm.prank(hospital);
        transplant.registerDonor(donor, "A+", "HLA-A2", "Kidney", "ipfs://donor1");

        vm.prank(hospital);
        transplant.registerRecipient(recipient1, "A+", "HLA-A2", "Kidney", "ipfs://recipient1");

        vm.prank(ethicalCommittee);
        transplant.approveDonorEthicalCommittee(1);
        vm.prank(ethicalCommittee);
        transplant.approveRecipientEthicalCommittee(1);

        vm.prank(llm);
        transplant.createMatch(1, 1, 1);

        vm.prank(medicalTeam);
        transplant.approveMedicalTeam(1);

        // Missing hospital, donor, and recipient approvals
        assertFalse(transplant.isTransplantApproved(1));
    }
}
