// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Campaign is
    ERC721,
    ERC721URIStorage,
    ERC721Pausable,
    Ownable,
    ERC721Burnable
{
    uint256 private _nextTokenId;
    enum JudgingType {
        Admin,
        Public
    }

    struct CompetitionSettings {
        string name;
        string symbol;
        string title;
        uint256 startDate;
        uint256 endDate;
        uint256 maxParticipants;
        JudgingType judgingType;
        uint256 totalPrizeAmount;
        uint256 totalWinners;
    }

    struct Submission {
        string imageUrlOrHash;
        address userId;
        string description;
        uint256 submissionId;
        uint256 submissionUpvotes;
    }

    string public title;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public maxParticipants;
    JudgingType public judgingType;
    uint256 public totalPrizeAmount;
    uint256 public totalWinners;
    Submission[] public submissions;
    Submission[] public winners;
    mapping(address => bool) public hasSubmitted;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => bool) public hasClaimed;

    event SubmissionCreated(
        address indexed userId,
        string imageUrlOrHash,
        string description,
        uint256 submissionId
    );
    event Upvoted(address indexed voter, uint256 submissionId);
    event WinnersCalculated(Submission[] winningSubmissions);
    event PrizeClaimed(address indexed winner, uint256 amount);

    CompetitionSettings public campaign;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        string memory _judgingType,
        uint256 _totalPrizeAmount,
        uint256 _totalWinners,
        address initOwner
    ) ERC721(_name, _symbol) Ownable(initOwner) {
        // Initialize the struct
        campaign = CompetitionSettings({
            name: _name,
            symbol: _symbol,
            title: _title,
            startDate: _startDate,
            endDate: _endDate,
            maxParticipants: _maxParticipants,
            judgingType: parseJudgingType(_judgingType),
            totalPrizeAmount: _totalPrizeAmount,
            totalWinners: _totalWinners
        });
        title = _title;
        startDate = _startDate;
        endDate = _endDate;
        maxParticipants = _maxParticipants;
        judgingType = parseJudgingType(_judgingType);
        totalPrizeAmount = _totalPrizeAmount;
        totalWinners = _totalWinners;
    }

    function createSubmission(
        string memory _imageUrlOrHash,
        string memory _description
    ) external {
        require(
            block.timestamp >= startDate && block.timestamp <= endDate,
            "Competition not active"
        );
        require(
            submissions.length <= maxParticipants || maxParticipants == 0,
            "Maximum participants reached"
        );
        require(!hasSubmitted[msg.sender], "User has already submitted");

        submissions.push(
            Submission({
                imageUrlOrHash: _imageUrlOrHash,
                userId: msg.sender,
                description: _description,
                submissionId: submissions.length,
                submissionUpvotes: 0
            })
        );

        hasSubmitted[msg.sender] = true;

        // safeMint(msg.sender, newItemId); // Mint a new NFT for the user

        emit SubmissionCreated(
            msg.sender,
            _imageUrlOrHash,
            _description,
            submissions.length
        );
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function parseJudgingType(
        string memory _judgingType
    ) internal pure returns (JudgingType) {
        if (
            keccak256(abi.encodePacked(_judgingType)) ==
            keccak256(abi.encodePacked("Admin"))
        ) {
            return JudgingType.Admin;
        } else if (
            keccak256(abi.encodePacked(_judgingType)) ==
            keccak256(abi.encodePacked("Public"))
        ) {
            return JudgingType.Public;
        } else {
            revert("Invalid JudgingType");
        }
    }

    function upvoteSubmission(address voter, uint256 _submissionId) external {
        require(_submissionId < submissions.length, "Invalid submission ID");
        require(
            !hasVoted[_submissionId][voter],
            "User has already upvoted this submission"
        );

        submissions[_submissionId].submissionUpvotes++;
        hasVoted[_submissionId][voter] = true;

        emit Upvoted(voter, _submissionId);
    }

    function calculateWinners() external {
        require(block.timestamp > endDate, "End date not reached yet");
        require(submissions.length > 0, "No submissions available");

        Submission[] memory winningSubmissions;
        uint256 maxWinners = totalWinners;

        if (totalWinners > submissions.length) {
            maxWinners = submissions.length;
        }

        uint256[] memory highestVotesIndices = new uint256[](maxWinners);

        for (uint256 i = 0; i < maxWinners; i++) {
            uint256 maxVotes = 0;
            uint256 winningSubmissionIndex;

            for (uint256 j = 0; j < submissions.length; j++) {
                if (submissions[j].submissionUpvotes > maxVotes) {
                    bool alreadySelected = false;
                    for (uint256 k = 0; k < i; k++) {
                        if (j == highestVotesIndices[k]) {
                            alreadySelected = true;
                            break;
                        }
                    }
                    if (!alreadySelected) {
                        maxVotes = submissions[j].submissionUpvotes;
                        winningSubmissionIndex = j;
                    }
                }
            }
            winningSubmissions[i] = submissions[winningSubmissionIndex];
            winners[i] = submissions[winningSubmissionIndex];
            highestVotesIndices[i] = winningSubmissionIndex;
        }

        emit WinnersCalculated(winningSubmissions);
    }

    function claim() external {
        require(block.timestamp > endDate, "End date not reached yet");
        require(submissions.length > 0, "No submissions available");
        require(!hasClaimed[msg.sender], "User has already claimed");

        uint256 maxWinners = winners.length;

        for (uint256 i = 0; i < maxWinners; i++) {
            if (winners[i].userId == msg.sender) {
                uint256 prizeAmount = totalPrizeAmount / totalWinners;
                hasClaimed[msg.sender] = true;
                payable(msg.sender).transfer(prizeAmount);
                emit PrizeClaimed(msg.sender, prizeAmount);
                break;
            }
        }
    }
}
