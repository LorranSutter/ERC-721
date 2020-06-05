// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";


contract Liken is IERC721, IERC721Metadata, IERC721Enumerable {
    address private owner;
    string private _name;
    string private _symbol;
    uint256 private currentToken; // FIXME Do I need this?

    uint256[] internal allTokens;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownerToTokens; // FIXME DO I need this?
    mapping(uint256 => address) private tokenToOwner;

    // Mapping from token ID to index of the owner tokens list
    // mapping(uint256 => uint256) internal ownerToTokensIndex;
    //Mapping from token id to position in the allTokens array
    // mapping(uint256 => uint256) internal allTokensIndex;

    mapping(address => uint256) private ownerToTokensCount;
    mapping(uint256 => address) internal tokenToApproval;

    //Global variable
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Not current owner");
        }
        _;
    }

    modifier validToken(uint256 _tokenId) {
        require(tokenToOwner[_tokenId] != address(0), "Liken token not valid");
        _;
    }

    constructor(string memory name, string memory symbol) public {
        owner = msg.sender;
        _name = name;
        _symbol = symbol;
        currentToken = 0;
    }

    // ------ Metadata ------ //
    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    // ------ Enumerable ------ //
    function totalSupply() public override view returns (uint256) {
        return allTokens.length;
    }

    function tokenByIndex(uint256 _index)
        public
        override
        view
        returns (uint256)
    {
        require(_index < allTokens.length, "Invalid index");
        return allTokens[_index];
    }

    // ------ ERC-721 ------ //
    function balanceOf(address _owner) public override view returns (uint256) {
        return ownerToTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns (address) {
        address _owner = tokenToOwner[_tokenId];
        require(_owner != address(0), "Invalid Liken token");
        return _owner;
    }

    function approve(address _approved, uint256 _tokenId)
        public
        override
        payable
        // canOperate(_tokenId)
        validToken(_tokenId)
    {
        // allowed[msg.sender][_approved] = _value;

        address tokenOwnerAddress = tokenToOwner[_tokenId];
        require(_approved != tokenOwnerAddress, "Approval to current owner");

        tokenToApproval[_tokenId] = _approved;
        emit Approval(tokenOwnerAddress, _approved, _tokenId);
    }

    // ------ Functions not in the interfaces ------ //
    function mint(address _to) public onlyOwner {
        require(_to != address(0), "Invalid address");

        uint256 tokenId = _generateNextToken();
        _addLikenToken(_to, tokenId);

        emit Transfer(address(0), _to, tokenId);
    }

    function _generateNextToken() internal view returns (uint256) {
        require(currentToken + 1 > 0, "Max number of tokens reached");
        return currentToken + 1;
    }

    function _addLikenToken(address _to, uint256 _tokenId) internal {
        require(
            tokenToOwner[_tokenId] == address(0),
            "Liken token already exists"
        );
        require(
            ownerToTokensCount[_to] + 1 > ownerToTokensCount[_to],
            "Overflow"
        );

        allTokens.push(_tokenId);
        currentToken++;
        tokenToOwner[_tokenId] = _to;
        ownerToTokensCount[_to]++;
    }
}
