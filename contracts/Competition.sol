// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Competition {
    struct Submission {
        string imageUrlOrHash;
        address userId;
        string description;
    }

    enum JudgingType { Admin, Public }

    address public owner;
    string public title;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public maxParticipants;
    JudgingType public judgingType;
    uint256 public totalPrizeAmount;
    uint256 public totalWinners;
    Submission[] public submissions;
    mapping(address => bool) public hasSubmitted;

    event SubmissionCreated(address indexed userId, string imageUrlOrHash, string description);

    constructor(
        address _owner,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        string memory _judgingType,
        uint256 _totalPrizeAmount,
        uint256 _totalWinners
    ) {
        owner = _owner;
        title = _title;
        startDate = _startDate;
        endDate = _endDate;
        maxParticipants = _maxParticipants;
        
        if (keccak256(abi.encodePacked(_judgingType)) == keccak256(abi.encodePacked("admin"))) {
            judgingType = JudgingType.Admin;
        } else {
            judgingType = JudgingType.Public;
        }
        
        totalPrizeAmount = _totalPrizeAmount;
        totalWinners = _totalWinners;
    }

    function createSubmission(
        string memory _imageUrlOrHash,
        string memory _description
    ) external {
        require(block.timestamp >= startDate && block.timestamp <= endDate, "Competition not active");
        require(submissions.length < maxParticipants || maxParticipants == 0, "Maximum participants reached");
        // require(hasSubmitted[msg.sender] == false, "User has already submitted");

        Submission memory newSubmission = Submission({
            imageUrlOrHash: _imageUrlOrHash,
            userId: msg.sender,
            description: _description
        });

        submissions.push(newSubmission);
        // hasSubmitted[msg.sender] = true;

        emit SubmissionCreated(msg.sender, _imageUrlOrHash, _description);
    }
}
