// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ICampaign {
     function initialize(
        string calldata imageUrl,
        string calldata title,
        string calldata description,
        uint256 startDate,
        uint256 endDate,
        uint256 maxParticipants,
        string calldata judgingType,
        uint256 totalPrizeAmount,
        uint256 totalWinners,
        address initOwner,
        address factoryContractAddress
    ) external;
    struct Submission {
        string imageUrlOrHash;
        address userId;
        string description;
    }

    enum JudgingType { Admin, Public }

    function owner() external view returns (address);
    function title() external view returns (string memory);
    function startDate() external view returns (uint256);
    function endDate() external view returns (uint256);
    function maxParticipants() external view returns (uint256);
    function judgingType() external view returns (JudgingType);
    function totalPrizeAmount() external view returns (uint256);
    function totalWinners() external view returns (uint256);
    function submissions(uint256 index) external view returns (Submission memory);
    function hasSubmitted(address _user) external view returns (bool);

    function createSubmission(
        string memory _imageUrlOrHash,
        string memory _description
    ) external;
}