// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyBallot {

    // STORAGE VARIABLES

    struct Voter {
        bool canVote;
        bool hasVoted;
    }

    struct Candidate {
        string nameProject;
        uint votesCount;
    }

    address private contractOwner;

    mapping(address => Voter) private voters;

    Candidate[] private candidates;

    uint private totalVotesCounter;

    uint private maxVotes;


    // CONSTRUCTOR

    constructor(string[] memory _candidates, uint _maxVotes) {
        contractOwner = msg.sender;
        setCandidatesIntoStorage(_candidates);        
        maxVotes = _maxVotes;
    }


    // MODIFIERS

    modifier isContractOwnerAddCandidate() {
        require(
            areYouContractOwner(),
            "Only the contract owner can add candidates."
        );
        _;
    }

    modifier giveRightToVoteModifier(address voterAddress) {
        getTotalVotesCounterReachedRequire();
        require(
            areYouContractOwner(),
            "Only the contract owner can give right to vote."
        );
        getVoterVotedRequire(voterAddress);
        _;
    }

    modifier voteModifier(address voterAddress) {
        getTotalVotesCounterReachedRequire();
        require(
            areYouHaveRigthToVote(), 
            "You have not right to vote"
        );
        getVoterVotedRequire(voterAddress);
        _;        
    }


    // REQUIRES

    function getVoterVotedRequire(address voterAddress) private view {
        return require(
            !getVoterVoted(voterAddress),
            "Voter already voted."
        );
    }

    function getTotalVotesCounterReachedRequire() private view {
        return require(
            totalVotesCounter < maxVotes, 
            "Max account votes is reached. Ballot is CLOSED."
        );
    }


    // FUNCTIONS

    function setCandidatesIntoStorage(string[] memory _candidates) private {
        for (uint index = 0; index < _candidates.length; index++) {
            candidates.push(Candidate({
                nameProject: _candidates[index],
                votesCount: 0
            }));
        }
    }
    
    function giveRightToVote(address voterAddress) public giveRightToVoteModifier(voterAddress) {
        voters[voterAddress].canVote = true;
    }

    function vote(string memory _nameProject) public voteModifier(msg.sender) {
        Voter storage sender = voters[msg.sender]; // this is to show the usage of storage | I could use directly voters[msg.sender].hasVoted
        
        for (uint index = 0; index < candidates.length; index++) {
            if (stringEqualTo(candidates[index].nameProject, _nameProject)) {
                candidates[index].votesCount++;
                sender.hasVoted = true;
                totalVotesCounter++;
            }
        }
    }

    function getWinnerName() public view returns (string memory winnerName, address) {
        (uint winningProposal, bool isTie) = getWinningCandidate();
        require(
            !isTie,
            "There is a tie on Ballot. You should start a new ballot with tie candidates."
        );
        winnerName = candidates[winningProposal].nameProject;
        return (winnerName, getContractAddress());
    }

    function getWinningCandidate() private view returns (uint winningProposal, bool isTie) {        
        uint winningVoteCount;

        for (uint indexCandidate = 0; indexCandidate < candidates.length; indexCandidate++) {
            if (candidates[indexCandidate].votesCount > winningVoteCount) {
                winningVoteCount = candidates[indexCandidate].votesCount;
                winningProposal = indexCandidate;
                isTie = false;
            } else if (candidates[indexCandidate].votesCount == winningVoteCount) {
                isTie = true;
            }
        }
    }

    function getCandidatesListName() public view returns (string[] memory) {
        uint candidatesLength = candidates.length;
        string[]  memory candidatesListName = new string[](candidatesLength);
        
        for (uint index = 0; index < candidatesLength; index++) {
            candidatesListName[index] = candidates[index].nameProject;
        }

        return candidatesListName;
    }

    function getContractAddress() private view returns (address) {
        return address(this);
    }

    function areYouContractOwner() private view returns (bool) {
        return msg.sender == contractOwner;
    }

    function areYouHaveRigthToVote() private view returns (bool) {
        return getVoterRigthToVote(msg.sender);
    }

    function getVoterRigthToVote(address voterAddress) private view returns (bool) {
        return voters[voterAddress].canVote;
    }

    function areYouVoted() private view returns (bool) {
        return getVoterVoted(msg.sender);
    }

    function getVoterVoted(address voterAddress) private view returns (bool) {
        return voters[voterAddress].hasVoted;
    }


    // OTHER FUNCTIONS

    function stringEqualTo(string memory s1, string memory s2) private pure returns (bool) {
        return keccak256(abi.encode(s1)) == keccak256(abi.encode(s2));
    }
}