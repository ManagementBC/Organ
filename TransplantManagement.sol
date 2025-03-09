// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransplantManagement {
    address public regulator;
    
    mapping(address => bool) public registeredHospitals;
    mapping(address => bool) public registeredMedicalTeams;
    mapping(address => bool) public authorizedLLMs;
    mapping(address => bool) public registeredEthicalCommittee;

    mapping(uint256 => Donor) public donors;
    mapping(uint256 => Recipient) public recipients;
    mapping(uint256 => Match) public matches;

    mapping(address => uint256) public registeredDonorAddresses;
    mapping(address => uint256) public registeredRecipientAddresses;

    uint256 public donorCounter;
    uint256 public recipientCounter;
    uint256 public matchCounter;

    struct Donor {
        uint256 donorId;
        address donorAddress;
        string bloodType;
        string hlaTyping;
        string organType;
        string ipfsHash;
        bool registered;
        bool ethicalApproved;
    }

    struct Recipient {
        uint256 recipientId;
        address recipientAddress;
        string bloodType;
        string hlaTyping;
        string organType;
        string ipfsHash;
        bool registered;
        bool matched;
        bool ethicalApproved;
    }

    struct Match {
        uint256 matchId;
        uint256 donorId;
        uint256 recipientId;
        address matchedByLLM;
        bool medicalApproved;
        bool hospitalApproved;
        bool donorApproved;
        bool recipientApproved;
        bool ethicalCommitteeApproved;
    }

    event DonorAddressRegistered(address indexed donorAddress);
    event RecipientAddressRegistered(address indexed recipientAddress);
    event DonorRegistered(uint256 indexed donorId, address indexed donorAddress, string organType);
    event RecipientRegistered(uint256 indexed recipientId, address indexed recipientAddress, string organType);
    event LLMRegistered(address indexed llmAddress);
    event MatchRecorded(uint256 indexed matchId, uint256 indexed donorId, uint256 indexed recipientId, address llm);
    event ApprovalGranted(uint256 indexed matchId, string approvedBy);
    event EthicalCommitteeMemberRegistered(address indexed committeeMember);
    event EthicalApprovalGranted(uint256 indexed id, string entityType);

    modifier onlyRegulator() {
        require(msg.sender == regulator, "Only regulator can perform this action");
        _;
    }

    modifier onlyLLM() {
        require(authorizedLLMs[msg.sender], "Only authorized LLMs can perform this action");
        _;
    }

    modifier onlyMedicalTeam() {
        require(registeredMedicalTeams[msg.sender], "Only a registered Medical Team can approve");
        _;
    }

    modifier onlyHospital() {
        require(registeredHospitals[msg.sender], "Only a registered Hospital can approve");
        _;
    }

    modifier onlyEthicalCommittee() {
        require(registeredEthicalCommittee[msg.sender], "Only the Ethical Committee can perform this action");
        _;
    }

    constructor(address _regulator) {
        require(_regulator != address(0), "Invalid regulator address"); // Zero address check
        regulator = _regulator;
    }

    // Registration Functions
    function registerHospital(address hospital) public onlyRegulator {
        registeredHospitals[hospital] = true;
    }

    function registerMedicalTeam(address medicalTeam) public onlyRegulator {
        registeredMedicalTeams[medicalTeam] = true;
    }

    function registerLLM(address llm) public onlyRegulator {
        authorizedLLMs[llm] = true;
        emit LLMRegistered(llm);
    }

    function registerEthicalCommittee(address committeeMember) public onlyRegulator {
        registeredEthicalCommittee[committeeMember] = true;
        emit EthicalCommitteeMemberRegistered(committeeMember);
    }

    function registerDonorAddress(address donorAddress) public onlyRegulator {
        require(registeredDonorAddresses[donorAddress] == 0, "Donor already registered");
        donorCounter++;
        registeredDonorAddresses[donorAddress] = donorCounter;
        emit DonorAddressRegistered(donorAddress);
    }

    function registerRecipientAddress(address recipientAddress) public onlyRegulator {
        require(registeredRecipientAddresses[recipientAddress] == 0, "Recipient already registered");
        recipientCounter++;
        registeredRecipientAddresses[recipientAddress] = recipientCounter;
        emit RecipientAddressRegistered(recipientAddress);
    }

   function registerDonor(
    address donorAddress, 
    string memory bloodType, 
    string memory hlaTyping, 
    string memory organType, 
    string memory ipfsHash
) public onlyHospital {
    uint256 donorId = registeredDonorAddresses[donorAddress];  
    require(donorId != 0, "Donor address not pre-registered by regulator"); 

    
    donors[donorId] = Donor(donorId, donorAddress, bloodType, hlaTyping, organType, ipfsHash, true, false);

   
    emit DonorRegistered(donorId, donorAddress, organType);
}


function registerRecipient(
    address recipientAddress, 
    string memory bloodType, 
    string memory hlaTyping, 
    string memory organType, 
    string memory ipfsHash
) public onlyHospital {
    uint256 recipientId = registeredRecipientAddresses[recipientAddress];  
    require(recipientId != 0, "Recipient address not pre-registered by regulator");  

    
    recipients[recipientId] = Recipient(recipientId, recipientAddress, bloodType, hlaTyping, organType, ipfsHash, true, false, false);

   
    emit RecipientRegistered(recipientId, recipientAddress, organType);
}



function approveDonorEthicalCommittee(uint256 donorId) public onlyEthicalCommittee {
    require(donors[donorId].donorId != 0, "Donor does not exist");
    require(!donors[donorId].ethicalApproved, "Donor already ethically approved");

    donors[donorId].ethicalApproved = true;
    emit EthicalApprovalGranted(donorId, "Donor");
}

function approveRecipientEthicalCommittee(uint256 recipientId) public onlyEthicalCommittee {
    require(recipients[recipientId].recipientId != 0, "Recipient does not exist");
    require(!recipients[recipientId].ethicalApproved, "Recipient already ethically approved");

    recipients[recipientId].ethicalApproved = true;
    emit EthicalApprovalGranted(recipientId, "Recipient");
}
function createMatch(uint256 donorId, uint256 recipientId1, uint256 recipientId2) public onlyLLM {
    require(donors[donorId].ethicalApproved, "Donor must be ethically approved");
    require(recipients[recipientId1].ethicalApproved, "Recipient 1 must be ethically approved");
    require(recipients[recipientId2].ethicalApproved, "Recipient 2 must be ethically approved");

    matchCounter++;
    matches[matchCounter] = Match(
        matchCounter, 
        donorId, 
        recipientId1, 
        msg.sender, 
        false, 
        false, 
        false, 
        false, 
        false
    );

    matchCounter++;
    matches[matchCounter] = Match(
        matchCounter, 
        donorId, 
        recipientId2, 
        msg.sender, 
        false, 
        false, 
        false, 
        false, 
        false
    );

    emit MatchRecorded(matchCounter - 1, donorId, recipientId1, msg.sender);
    emit MatchRecorded(matchCounter, donorId, recipientId2, msg.sender);
}


    // Approval Functions
    function approveMedicalTeam(uint256 matchId) public onlyMedicalTeam {
        require(matches[matchId].matchId != 0, "Match does not exist");
        matches[matchId].medicalApproved = true;
        emit ApprovalGranted(matchId, "Medical Team");
    }

    function approveHospital(uint256 matchId) public onlyHospital {
        require(matches[matchId].matchId != 0, "Match does not exist");
        matches[matchId].hospitalApproved = true;
        emit ApprovalGranted(matchId, "Hospital");
    }

    function approveDonor(uint256 matchId) public {
        require(matches[matchId].matchId != 0, "Match does not exist");
        require(msg.sender == donors[matches[matchId].donorId].donorAddress, "Only donor can approve");
        matches[matchId].donorApproved = true;
        emit ApprovalGranted(matchId, "Donor");
    }

    function approveRecipient(uint256 matchId) public {
        require(matches[matchId].matchId != 0, "Match does not exist");
        require(msg.sender == recipients[matches[matchId].recipientId].recipientAddress, "Only recipient can approve");
        matches[matchId].recipientApproved = true;
        emit ApprovalGranted(matchId, "Recipient");
    }

    function approveFinalTransplant(uint256 matchId) public onlyEthicalCommittee {
        require(matches[matchId].matchId != 0, "Match does not exist");
        matches[matchId].ethicalCommitteeApproved = true;
        emit ApprovalGranted(matchId, "Ethical Committee");
    }

    function isTransplantApproved(uint256 matchId) public view returns (bool) {
        Match memory m = matches[matchId];
        return (m.medicalApproved && m.hospitalApproved && m.donorApproved && m.recipientApproved && m.ethicalCommitteeApproved);
    }
}
