// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Campaign.sol";

contract CampaignFactory {
    // Event to log the creation of a new Campaign contract
    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed owner,
        address campaignAddress,
        string imageUrl,
        string title,
        string description,
        uint256 startDate,
        uint256 endDate,
        uint256 maxParticipants,
        string judgingType,
        uint256 totalPrizeAmount,
        uint256 totalWinners
    );

    // Event to log received payments
    event PaymentReceived(address indexed sender, uint256 amount);

    // State variable to keep track of the number of campaigns
    uint256 public campaignCount;

    // Mapping from campaign ID to Campaign contract addresses
    mapping(uint256 => address) public campaigns;

    // Function to create a new Campaign contract
    function createCampaign(
        string memory imageUrl,
        string memory title,
        string memory description,
        uint256 startDate,
        uint256 endDate,
        uint256 maxParticipants,
        string memory judgingType,
        uint256 totalPrizeAmount,
        uint256 totalWinners
    ) external {
        Campaign newCampaign = new Campaign(
            imageUrl,
            title,
            description,
            startDate,
            endDate,
            maxParticipants,
            judgingType,
            totalPrizeAmount,
            totalWinners,
            msg.sender // Set the creator as the initial owner of the Campaign contract
        );

        // Increment the campaign count and set the new Campaign address in the mapping
        campaigns[campaignCount] = address(newCampaign);
        // Emit an event with the new Campaign contract's ID and address
        emit CampaignCreated(
            campaignCount,
            msg.sender,
            address(newCampaign),
            imageUrl,
            title,
            description,
            startDate,
            endDate,
            maxParticipants,
            judgingType,
            totalPrizeAmount,
            totalWinners
        );

        // Increment the campaign counter
        campaignCount++;
    }
}
