// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ICampaignFactory {
    function logSubmissionCreated(
        address user,
        address campaignAddress,
        string calldata imageUrlOrHash,
        string calldata description,
        uint256 submissionId
    ) external;

    function logUpvoted(
        address voter,
        address campaignAddress,
        uint256 submissionId
    ) external;

    // function logWinnersCalculated(
    //     CampaignFactory.Submission[] calldata winningSubmissions,
    //     address campaignAddress
    // ) external;
}