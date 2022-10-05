// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyBallot {

    // STORAGE VARIABLES

    struct Voter {
        string nameVoter;
        bool canVote;
        bool hasVoted;
    }

    struct Candidate {
        string nameProject;
        uint votesCount;
    }

    address private contractOwner;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;

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
        require(
            !voters[voterAddress].canVote,
            "Voter have already has right to vote."
        );
        getVoterVotedRequire(voterAddress);
        _;
    }

    modifier voteModifierBefore(address voterAddress) {
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

    function isCandidateExistRequire(bool isExist) private pure {
        return require(
            isExist,
            "Candidate you sent does not exist"
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
    
    function giveRightToVote(address voterAddress, string memory _nameVoter) public giveRightToVoteModifier(voterAddress) {
        voters[voterAddress].nameVoter = _nameVoter;
        voters[voterAddress].canVote = true;
    }

    function vote(string memory _nameProject) public voteModifierBefore(msg.sender) {
        Voter storage sender = voters[msg.sender]; // this is to show the usage of storage | I could use directly voters[msg.sender].hasVoted
        bool isCandidateExist;
        
        for (uint index = 0; index < candidates.length; index++) {
            if (stringEqualTo(candidates[index].nameProject, _nameProject)) {
                candidates[index].votesCount++;
                sender.hasVoted = true;
                totalVotesCounter++;
                isCandidateExist = true;
            }
        }

        isCandidateExistRequire(isCandidateExist);
    }

    function getWinnerName() public view returns (string memory winnerName, address) {
        (Candidate memory winningCandidate) = getWinningCandidate();
        winnerName = winningCandidate.nameProject;
        return (winnerName, getContractAddress());
    }

    function getWinningCandidate() public view returns (Candidate memory winningCandidate) {        
        uint winningVoteCount;
        uint winningCandidateIndex;

        uint candidatesLength = candidates.length;
        
        string[] memory tieCandidatesList = new string[](candidatesLength);
        uint tieCandidatesListIndex;
        bool isTie = true;
        string memory tieCandidatesListNames;

        for (uint indexCandidate = 0; indexCandidate < candidatesLength; indexCandidate++) {
            if (candidates[indexCandidate].votesCount > winningVoteCount) {
                winningVoteCount = candidates[indexCandidate].votesCount;
                winningCandidateIndex = indexCandidate;
                if (isTie) {
                    isTie = false;
                    tieCandidatesListIndex = 0;
                    tieCandidatesList = new string[](candidatesLength);
                    tieCandidatesList[tieCandidatesListIndex] = candidates[indexCandidate].nameProject;
                    tieCandidatesListIndex++;
                }
            } else if (candidates[indexCandidate].votesCount == winningVoteCount) {
                isTie = true;
                tieCandidatesList[tieCandidatesListIndex] = candidates[indexCandidate].nameProject;
                tieCandidatesListIndex++;
            }            
        }


        if (isTie) {
            for (uint indexCandidate = 0; indexCandidate < tieCandidatesList.length; indexCandidate++) {
                tieCandidatesListNames = concatenateStrings(tieCandidatesListNames,tieCandidatesList[indexCandidate]);
            }
            
            string memory tieMessage = concatenateStrings("There is a tie on Ballot. You should start a new ballot with tie candidates:", tieCandidatesListNames);
        
            require(
                false,
                tieMessage
            );
        } else {
            winningCandidate = candidates[winningCandidateIndex];
        }
    }

    function getCandidatesListName() public view returns (string[] memory) {
        uint candidatesLength = candidates.length;
        string[] memory candidatesListName = new string[](candidatesLength);
        
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

    function concatenateStrings(string memory s1, string memory s2) public pure returns (string memory) {
        return string(abi.encodePacked(s1, " " , s2));
    }
}