// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Campaign is ERC721, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable {
    
    uint256 private _nextTokenId;

    struct CompetitionSettings {
        string name;
        string symbol;
        string title;
        uint256 startDate;
        uint256 endDate;
        uint256 maxParticipants;
        string judgingType;
        uint256 totalPrizeAmount;
        uint256 totalWinners;
    }

     struct Submission {
        string imageUrlOrHash;
        address userId;
        string description;
    }

    enum JudgingType { Admin, Public }

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

    CompetitionSettings  public campaign;
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        string  memory _judgingType,
        uint256 _totalPrizeAmount,
        uint256 _totalWinners,
        address initOwner
    )
        ERC721(_name, _symbol)
        Ownable(initOwner)
    {
        // Initialize the struct
        campaign = CompetitionSettings({
            name: _name,
            symbol: _symbol,
            title: _title,
            startDate: _startDate,
            endDate: _endDate,
            maxParticipants: _maxParticipants,
            judgingType: _judgingType,
            totalPrizeAmount: _totalPrizeAmount,
            totalWinners: _totalWinners
        });
    
    }

    function createSubmission(
        string memory _imageUrlOrHash,
        string memory _description
    ) external {
        require(block.timestamp >= startDate && block.timestamp <= endDate, "Competition not active");
        require(submissions.length < maxParticipants || maxParticipants == 0, "Maximum participants reached");
        require(!hasSubmitted[msg.sender], "User has already submitted");

        submissions.push(Submission({
            imageUrlOrHash: _imageUrlOrHash,
            userId: msg.sender,
            description: _description
        }));

        hasSubmitted[msg.sender] = true;

       // safeMint(msg.sender, newItemId); // Mint a new NFT for the user

        emit SubmissionCreated(msg.sender, _imageUrlOrHash, _description);
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

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
