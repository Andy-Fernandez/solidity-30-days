// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/// @title PollStation v2 – Dynamic list of candidates with simple voting
contract PollStation {
    /* --------------------------------------------------------------------- */
    /* Storage                                                               */
    /* --------------------------------------------------------------------- */
    address public immutable owner;               // admin of the poll

    string[] private candidateNames;              // candidate list
    mapping(string => uint256) private voteCount; // name → votes
    mapping(address => bool)  public hasVoted;    // 1-addr-1-vote

    /* --------------------------------------------------------------------- */
    /* Events                                                                */
    /* --------------------------------------------------------------------- */
    event CandidateAdded(string name);
    event Voted(address indexed voter, string indexed candidate);

    /* --------------------------------------------------------------------- */
    /* Constructor                                                           */
    /* --------------------------------------------------------------------- */
    constructor() { owner = msg.sender; }

    /* --------------------------------------------------------------------- */
    /* Owner-only: add a new candidate                                       */
    /* --------------------------------------------------------------------- */
    function addCandidate(string calldata name) external onlyOwner {
        require(bytes(name).length > 0, "Empty name");
        require(!_exists(name),        "Already added");

        candidateNames.push(name);
        emit CandidateAdded(name);
    }

    /* --------------------------------------------------------------------- */
    /* Public: vote for a candidate                                          */
    /* --------------------------------------------------------------------- */
    function vote(string calldata name) external {
        require(!hasVoted[msg.sender], "Already voted");
        require(_exists(name),         "Candidate not found");

        voteCount[name] += 1;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, name);
    }

    /* --------------------------------------------------------------------- */
    /* View helpers                                                          */
    /* --------------------------------------------------------------------- */
    /// @notice Get vote total for a name
    function getVotes(string calldata name) external view returns (uint256) {
        require(_exists(name), "Candidate not found");
        return voteCount[name];
    }

    /// @notice How many candidates exist?
    function candidateCount() external view returns (uint256) {
        return candidateNames.length;
    }

    /// @notice Get candidate name at index
    function candidateAt(uint256 index) external view returns (string memory) {
        require(index < candidateNames.length, "Out of range");
        return candidateNames[index];
    }

    /* --------------------------------------------------------------------- */
    /* Internal utils                                                        */
    /* --------------------------------------------------------------------- */
    function _exists(string memory name) internal view returns (bool) {
        // O(n) scan – fine for small lists; hash-based map is overkill here
        for (uint256 i; i < candidateNames.length; ++i) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(name)))
                return true;
        }
        return false;
    }

    /* --------------------------------------------------------------------- */
    /* Modifier                                                              */
    /* --------------------------------------------------------------------- */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
