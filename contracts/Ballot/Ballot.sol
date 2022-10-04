// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyBallot {

    struct Voter {
        bool canVote;
        bool hasVoted;
    }

    struct Candidate {
        string name;
        string party;
        uint votesCount;
    }

    address public contractOwner;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;

    uint private totalVotesCounter;

    uint private maxVotes;

    // CONSTRUCTOR

    constructor(Candidate[] memory _candidates, uint _maxVotes) {
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
        require(
            areYouContractOwner(),
            "Only the contract owner can give right to vote."
        );
        getVoterVotedRequire(voterAddress);
        _;
    }

    modifier voteModifier(address voterAddress) {
        require(
            totalVotesCounter < maxVotes, 
            "Max account votes is reached"
        );
        require(
            areYouHaveRigthToVote(), 
            "You have not right to vote"
        );
        getVoterVotedRequire(voterAddress);
        _;        
    }


    // REQUIRES

    function setCandidatesIntoStorage(Candidate[] memory _candidates) private {
        for (uint index = 0; index < _candidates.length; index++) {
            candidates.push(Candidate({
                name: _candidates[index].name,
                party: _candidates[index].party,
                votesCount: 0
            }));
        }
    }

    function getVoterVotedRequire(address voterAddress) private view {
        return require(
            !getVoterVoted(voterAddress),
            "Voter already voted."
        );
    }


    // FUNCTIONS
    
    function giveRightToVote(address voterAddress) public giveRightToVoteModifier(voterAddress) {
        voters[voterAddress].canVote = true;
    }

    function vote(string memory name) public voteModifier(msg.sender) {
        Voter storage sender = voters[msg.sender]; // this is to show the usage of storage | I could use directly voters[msg.sender].hasVoted
        
        for (uint index = 0; index < candidates.length; index++) {
            if (stringEqualTo(candidates[index].name,name)) {
                candidates[index].votesCount++;
                sender.hasVoted = true;
                totalVotesCounter++;
            }
        }
    }

    function getWinnerName() public view returns (string memory winnerName) {
        (uint winningProposal, bool isTie) = getWinningCandidate();
        require(
            !isTie,
            "There is a tie on Ballot"
        );
        winnerName = candidates[winningProposal].name;
    }

    function getWinningCandidate() public view returns (uint winningProposal, bool isTie) {        
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

    function getCandidatesList() public view returns (Candidate[] memory) {
        return candidates;
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function areYouContractOwner() public view returns (bool) {
        return msg.sender == contractOwner;
    }

    function areYouHaveRigthToVote() public view returns (bool) {
        return getVoterRigthToVote(msg.sender);
    }

    function getVoterRigthToVote(address voterAddress) public view returns (bool) {
        return voters[voterAddress].canVote;
    }

    function areYouVoted() public view returns (bool) {
        return getVoterVoted(msg.sender);
    }

    function getVoterVoted(address voterAddress) public view returns (bool) {
        return voters[voterAddress].hasVoted;
    }


    // OTHER FUNCTIONS

    function stringEqualTo(string memory s1, string memory s2) internal pure returns (bool) {
        return keccak256(abi.encode(s1)) == keccak256(abi.encode(s2));
    }
}