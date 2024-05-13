// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import {ICampaign} from "./Interface/ICampaign.sol";
import {LogContract} from "./LogContract.sol";

contract CampaignFactory is LogContract {
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

    address public immutable campaignImplementation;


    constructor(address _campaignImplementation) {
        campaignImplementation = _campaignImplementation;
    }

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
        address clone = ClonesUpgradeable.clone(campaignImplementation);
        ICampaign(clone).initialize(
            imageUrl,
            title,
            description,
            startDate,
            endDate,
            maxParticipants,
            judgingType,
            totalPrizeAmount,
            totalWinners,
            msg.sender, // Set the creator as the initial owner of the Campaign contract
            address(this)
        );

        campaigns[campaignCount] = clone;
        emit CampaignCreated(
            campaignCount,
            msg.sender,
            clone,
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

        campaignCount++;
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }
}
