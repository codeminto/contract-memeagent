// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CompetitionContract {
    address public owner;
    string public title;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public maxParticipants;
    uint8 public judgingType;
    uint256 public totalPrize;
    uint256 public totalWinners;
    uint256 public competitionCreationFee;
    bool public isCompetitionActive;

    struct Submission {
        address user;
        string imageUrl;
        string description;
    }

    Submission[] public submissions;
    mapping(address => bool) public hasSubmitted;
    mapping(address => bool) public winners;
    mapping(address => uint256) public prizeAmounts; // Amount each winner should receive

    event SubmissionPosted(uint256 submissionId, address user);
    event WinnersAnnounced(address[] winners);
    event PrizeClaimed(address winner, uint256 amount);

    constructor(
        address _owner,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        uint8 _judgingType,
        uint256 _totalPrize,
        uint256 _totalWinners,
        uint256 _competitionCreationFee
    ) {
        owner = _owner;
        title = _title;
        startDate = _startDate;
        endDate = _endDate;
        maxParticipants = _maxParticipants;
        judgingType = _judgingType;
        totalPrize = _totalPrize;
        totalWinners = _totalWinners;
        competitionCreationFee = _competitionCreationFee;
        isCompetitionActive = true;
    }

    function submitMeme(string memory _imageUrl, string memory _description) external {
        require(isCompetitionActive, "Competition is not active");
        require(block.timestamp >= startDate && block.timestamp <= endDate, "Submission not allowed at this time");
        require(submissions.length < maxParticipants || maxParticipants == 0, "Max participants reached");

        submissions.push(Submission(msg.sender, _imageUrl, _description));
        hasSubmitted[msg.sender] = true;
        emit SubmissionPosted(submissions.length - 1, msg.sender);
    }

    function announceWinners(address[] memory _winners) external {
        require(msg.sender == owner, "Only competition owner can announce winners");
        require(_winners.length == totalWinners, "Invalid number of winners");

        for (uint256 i = 0; i < _winners.length; i++) {
            winners[_winners[i]] = true;
            // Calculate prize amount for each winner
            prizeAmounts[_winners[i]] = totalPrize / totalWinners;
        }

        emit WinnersAnnounced(_winners);
    }

    function claimPrize() external {
        require(winners[msg.sender], "You are not a winner");
        require(isCompetitionActive == false, "Competition is still active");

        uint256 amount = prizeAmounts[msg.sender];
        require(amount > 0, "No prize to claim");

        // Reset the prize amount to prevent re-entrancy attacks
        prizeAmounts[msg.sender] = 0;

        // Transfer prize amount to winner
        payable(msg.sender).transfer(amount);
        emit PrizeClaimed(msg.sender, amount);
    }

    // Other functions for contract management can be added as needed
}
