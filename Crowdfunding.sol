// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // Campaign structure
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;  // Goal amount in wei
        uint deadline;  // Deadline in Unix timestamp
        uint amountRaised;  // Amount raised in wei
        bool ended;  // Boolean to check if campaign has ended
    }

    // State variables
    address public owner;
    mapping(uint => Campaign) public campaigns;

    // Events
    event CampaignCreated(
        uint campaignId,
        string title,
        address benefactor,
        uint goal,
        uint deadline
    );

    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, uint amountRaised);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier campaignExists(uint _campaignId) {
        require(campaigns[_campaignId].goal > 0, "Campaign does not exist");
        _;
    }

    modifier campaignNotEnded(uint _campaignId) {
        require(!campaigns[_campaignId].ended, "Campaign has already ended");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address payable _benefactor,
        uint _goal,  // Goal amount in wei
        uint _duration  // Duration in seconds
    ) public {
        require(_goal > 0, "Goal must be greater than zero");
        require(_benefactor != address(0), "Benefactor address must be valid");

        uint _deadline = block.timestamp + _duration;  // Calculate deadline as current time + duration

        uint campaignId = block.timestamp;  // Generate campaign ID based on current block timestamp
        require(campaigns[campaignId].goal == 0, "Campaign ID already exists");  // Ensure unique campaign ID

        campaigns[campaignId] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: _deadline,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(campaignId, _title, _benefactor, _goal, _deadline);
    }

    // Function to donate to a campaign
    function donateToCampaign(uint _campaignId) public payable campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp <= campaign.deadline, "Campaign has already ended");
        require(msg.value > 0, "Donation must be greater than zero");

        // Update the amount raised
        campaign.amountRaised += msg.value;

        // Directly transfer the donation to the benefactor
        campaign.benefactor.transfer(msg.value);

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to end a campaign
    function endCampaign(uint _campaignId) public campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");

        campaign.ended = true;

        emit CampaignEnded(_campaignId, campaign.amountRaised);
    }

    // Function to withdraw leftover funds (if any) by the owner
    function withdrawLeftoverFunds() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available for withdrawal");
        payable(owner).transfer(contractBalance);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
