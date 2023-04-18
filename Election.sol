pragma solidity ^0.4.2;

import "./Ownable.sol";
import "./Whitelist.sol";

contract Election is Ownable, Whitelist {
    struct Resolution {
        uint256 id;
        string description;
        uint256 voteCountFor;
        uint256 voteCountAgainst;
        uint256 voteCountNeutral;
        bool finished;
    }

    mapping(uint256 => Resolution) public resolutions;

    Whitelist private _whitelist;

    event ResolutionAdded(uint256 id, string description);
    event ResolutionFinished(uint256 id, uint256 voteCountFor, uint256 voteCountAgainst, uint256 voteCountNeutral);
    event Voted(uint256 indexed resolutionId, address indexed voter, string voteType);

    constructor() {
        _whitelist = new Whitelist();
    }

    function addResolution(uint256 _id, string memory _description) public onlyOwner {
        require(!resolutions[_id].finished, "Resolution already finished");
        resolutions[_id] = Resolution(_id, _description, 0, 0, 0, false);
        emit ResolutionAdded(_id, _description);
    }

    function finishResolution(uint256 _id) public onlyOwner {
        Resolution storage resolution = resolutions[_id];
        require(!resolution.finished, "Resolution already finished");
        resolution.finished = true;
        emit ResolutionFinished(_id, resolution.voteCountFor, resolution.voteCountAgainst, resolution.voteCountNeutral);
    }

    function vote(uint256 _resolutionId, string memory _voteType) public {
        require(!resolutions[_resolutionId].finished, "Resolution already finished");

        Resolution storage resolution = resolutions[_resolutionId];
        if (keccak256(abi.encodePacked(_voteType)) == keccak256("FOR")) {
            resolution.voteCountFor++;
        } else if (keccak256(abi.encodePacked(_voteType)) == keccak256("AGAINST")) {
            resolution.voteCountAgainst++;
        } else {
            resolution.voteCountNeutral++;
        }
        emit Voted(_resolutionId, msg.sender, _voteType);
    }

    function addToWhitelist(address[] memory _beneficiaries) public onlyOwner {
        Whitelist(_whitelist).addToWhitelist(_beneficiaries);
    }


    function removeFromWhitelist(address[] memory _beneficiaries) public onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _whitelist.removeFromWhitelist(_beneficiaries[i]);
        }
    }

}
