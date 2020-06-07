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
    // mapping(address => uint256[]) internal ownerToTokens; // FIXME DO I need this?
    mapping(uint256 => address) private tokenToOwner;

    // Mapping from token ID to index of the owner tokens list
    // mapping(uint256 => uint256) internal ownerToTokensIndex;
    //Mapping from token id to position in the allTokens array
    // mapping(uint256 => uint256) internal allTokensIndex;

    mapping(address => uint256) private ownerToTokensCount;
    mapping(uint256 => address) internal tokenToApproval;
    mapping(address => mapping(address => bool)) internal ownerToOperators;

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

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Liken: not current owner");
        }
        _;
    }

    modifier validToken(uint256 _tokenId) {
        require(tokenToOwner[_tokenId] != address(0), "Liken: token not valid");
        _;
    }

    modifier canOperate(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            "Liken: not owner or operator"
        );
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender ||
                tokenToApproval[_tokenId] == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            "Liken: not owner, approved or operator"
        );
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
        require(_index < allTokens.length, "Liken: invalid index");
        return allTokens[_index];
    }

    // ------ ERC-721 ------ //
    function balanceOf(address _owner) public override view returns (uint256) {
        return ownerToTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns (address) {
        address _owner = tokenToOwner[_tokenId];
        require(_owner != address(0), "Liken: invalid Liken token");
        return _owner;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override payable canTransfer(_tokenId) validToken(_tokenId) {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        public
        override
        payable
        canOperate(_tokenId)
        validToken(_tokenId)
    {
        // allowed[msg.sender][_approved] = _value;

        address tokenOwnerAddress = tokenToOwner[_tokenId];
        require(
            _approved != tokenOwnerAddress,
            "Liken: approval to current owner"
        );

        _approve(tokenOwnerAddress, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        public
        override
    {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        public
        override
        view
        validToken(_tokenId)
        returns (address)
    {
        return tokenToApproval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        override
        view
        returns (bool)
    {
        return ownerToOperators[_owner][_operator];
    }

    // ------ Functions not in the interfaces ------ //
    function mint(address _to) public onlyOwner {
        require(_to != address(0), "Liken: invalid address");

        uint256 tokenId = _generateNextToken();
        _addToken(_to, tokenId);
        currentToken++;

        emit Transfer(address(0), _to, tokenId);
    }

    // ------ Internal functions ------ //
    function _generateNextToken() internal view returns (uint256) {
        require(currentToken + 1 > 0, "Liken: max number of tokens reached");
        return currentToken + 1;
    }

    function _addToken(address _to, uint256 _tokenId) internal {
        require(
            tokenToOwner[_tokenId] == address(0),
            "Liken: token already exists"
        );
        require(
            ownerToTokensCount[_to] + 1 > ownerToTokensCount[_to],
            "Liken: overflow"
        );

        allTokens.push(_tokenId);
        tokenToOwner[_tokenId] = _to;
        ownerToTokensCount[_to]++;
    }

    function _approve(
        address _owner,
        address _to,
        uint256 _tokenId
    ) internal {
        tokenToApproval[_tokenId] = _to;
        emit Approval(_owner, _to, _tokenId);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal validToken(_tokenId) {
        require(
            ownerOf(_tokenId) == _from,
            "Liken: transfer of token that is not own"
        );
        require(_to != address(0), "Liken: Transfer to the zero address");

        _clearApproval(_tokenId);

        _removeToken(_from, _tokenId);
        _addToken(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _removeToken(address _from, uint256 _tokenId) internal {
        require(tokenToOwner[_tokenId] == _from, "Liken: not owner");
        ownerToTokensCount[_from] = ownerToTokensCount[_from] - 1;
        delete tokenToOwner[_tokenId];
    }

    function _clearApproval(uint256 _tokenId) internal {
        if (tokenToApproval[_tokenId] != address(0)) {
            delete tokenToApproval[_tokenId];
        }
    }
}
