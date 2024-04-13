// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

abstract contract LogContract {
    // mapping(address => bool) internal authorizedLogger;

    // modifier onlyAuthorizedLogger() {
    //     require(
    //         authorizedLogger[msg.sender],
    //         "Not Authorized To Log Event Data!"
    //     );
    //     _;
    // }

    struct Submission {
        string imageUrlOrHash;
        address userId;
        string description;
        uint256 submissionId;
        uint256 submissionUpvotes;
    }

    // Events
    event SubmissionCreated(
        address indexed userId,
        address indexed contractAddress,
        string imageUrlOrHash,
        string description,
        uint256 submissionId
    );
    event Upvoted(
        address indexed voter,
        address indexed contractAddress,
        uint256 submissionId
    );
    event WinnersCalculated(
        Submission[] winningSubmissions,
        address indexed contractAddress
    );
    event PrizeClaimed(
        address indexed winner,
        address indexed contractAddress,
        uint256 amount
    );

    function logSubmissionCreated(
        address userId,
        address contractAddress,
        string memory imageUrlOrHash,
        string memory description,
        uint256 submissionId
    ) external {
        emit SubmissionCreated(
            userId,
            contractAddress,
            imageUrlOrHash,
            description,
            submissionId
        );
    }

    function logUpvoted(
        address voter,
        address contractAddress,
        uint256 submissionId
    ) external {
        emit Upvoted(voter, contractAddress, submissionId);
    }

    function logWinnersCalculated(
        Submission[] memory winningSubmissions,
        address contractAddress
    ) external {
        emit WinnersCalculated(winningSubmissions, contractAddress);
    }

    function logPrizeClaimed(
        address winner,
        address contractAddress,
        uint256 amount
    ) external {
        emit PrizeClaimed(winner, contractAddress, amount);
    }
}
