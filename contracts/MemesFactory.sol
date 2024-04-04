// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import './Interface/ICompetition.sol';

contract MemesFactory {
    address[] public deployedCompetitions;
    uint256 public competitionCreationFee;
    ICompetition public competitionInterface;

    event CompetitionCreated(address competitionAddress, address creator);

    constructor(uint256 _competitionCreationFee, address _competitionInterface) {
        competitionCreationFee = _competitionCreationFee;
        competitionInterface = ICompetition(_competitionInterface);
    }

    function createCompetition(
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _maxParticipants,
        string memory _judgingType,
        uint256 _totalPrizeAmount,
        uint256 _totalWinners
    ) external payable {
        require(msg.value >= competitionCreationFee, "Insufficient fee");
        
        address newCompetition = address(
            new CompetitionContract(
                msg.sender,
                _title,
                _startDate,
                _endDate,
                _maxParticipants,
                _judgingType,
                _totalPrizeAmount,
                _totalWinners
            )
        );
        
        deployedCompetitions.push(newCompetition);

        emit CompetitionCreated(newCompetition, msg.sender);
    }
}
