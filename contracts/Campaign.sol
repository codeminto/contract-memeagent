// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interface/ICampaignFactory.sol";  // Import the interface

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Campaign is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable,
    VRFConsumerBaseV2
    UUPSUpgradeable
{
    uint256 private _nextTokenId;
    enum JudgingType {
        Admin,
        Public
    }

    struct CompetitionSettings {
        string imageUrl;
        string title;
        string description;
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

    string public imageUrlContest;
    string public title;
    string public description;
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
    // IHeroPoolFactory public factory;

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
    ICampaignFactory public factory;  // Use the interface type

    function initialize(
        string memory _imageUrl,
        string memory _title,
        string memory _description,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        string memory _judgingType,
        uint256 _totalPrizeAmount,
        uint256 _totalWinners,
        address initOwner,
        address _factoryContractAddress
    ) public initializer {
        __ERC721_init(_title, _imageUrl);
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __Ownable_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        // Initialize the struct
        campaign = CompetitionSettings({
            imageUrl: _imageUrl,
            title: _title,
            description: _description,
            startDate: _startDate,
            endDate: _endDate,
            maxParticipants: _maxParticipants,
            judgingType: parseJudgingType(_judgingType),
            totalPrizeAmount: _totalPrizeAmount,
            totalWinners: _totalWinners
        });
        imageUrlContest = _imageUrl;
        title = _title;
        description = _description;
        startDate = _startDate;
        endDate = _endDate;
        maxParticipants = _maxParticipants;
        judgingType = parseJudgingType(_judgingType);
        totalPrizeAmount = _totalPrizeAmount;
        totalWinners = _totalWinners;
        factory = ICampaignFactory(_factoryContractAddress);
        transferOwnership(initOwner);
    }
    function createSubmission(
        string memory _imageUrlOrHash,
        string memory _description
    ) external {
        // require(
        //     block.timestamp >= startDate && block.timestamp <= endDate,
        //     "Competition not active"
        // );
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
            submissions.length - 1
        );
        factory.logSubmissionCreated(
            msg.sender,
            address(this),
            _imageUrlOrHash,
            _description,
            submissions.length - 1
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
    ) internal override(ERC721Upgradeable, ERC721PausableUpgradeable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (bool) {
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
        factory.logUpvoted(voter, address(this), _submissionId);
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
        // factory.logWinnersCalculated(
        //     convertToLogSubmission(winningSubmissions),
        //     address(this)
        // );
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

    // // Function to request random number from Chainlink VRF
    // function requestRandomNumber(
    //     uint256 userProvidedSeed
    // ) internal returns (bytes32 requestId) {
    //     require(
    //         LINK.balanceOf(address(this)) >= fee,
    //         "Not enough LINK to pay fee"
    //     );
    //     return requestRandomness(keyHash, fee, userProvidedSeed);
    // }

    // // Callback function called by Chainlink VRF with the random number
    // function fulfillRandomness(
    //     bytes32 requestId,
    //     uint256 randomness
    // ) internal override {
    //     randomResult = randomness;
    //     // Call your function to select winners using the random number here...
    // }

    // Function to announce winners using the random number
    function announceWinners() external onlyOwner {
        // Request a random number from Chainlink VRF
        uint256 userProvidedSeed = uint256(
            keccak256(abi.encodePacked(blockhash(block.number)))
        );
       // requestRandomNumber(userProvidedSeed);
    }

    // Function to select winners using the random number
    function selectWinners() internal {
        // Use the random number to select winners from the submissions
        // For example, select the winners based on the random number modulus total submissions
        uint256 numWinners = totalWinners > submissions.length
            ? submissions.length
            : totalWinners;
        address[] memory winnersArray = new address[](numWinners);
        for (uint256 i = 0; i < numWinners; i++) {
            uint256 winnerIndex = (randomResult + i) % submissions.length;
            winnersArray[i] = submissions[winnerIndex].userId;
        }
        emit WinnersAnnounced(winnersArray);
    }
}
