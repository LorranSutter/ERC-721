// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";


contract Liken is IERC721, IERC721Metadata, IERC721Enumerable {
    address private owner;
    string private _name;
    string private _symbol;
    uint256 private _currentToken;

    mapping(uint256 => address) private _idToOwner;
    mapping(address => uint256) private _ownerToLikenTokenCount;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not current owner");
        _;
    }

    constructor(string memory name, string memory symbol) public {
        owner = msg.sender;
        _name = name;
        _symbol = symbol;
        _currentToken = 0;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public override view returns (uint256) {
        return _currentToken;
    }

    function balanceOf(address _owner) public override view returns (uint256) {
        return _ownerToLikenTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns (address) {
        address _owner = _idToOwner[_tokenId];
        require(_owner != address(0), "Invalid Liken token");
        return _owner;
    }

    function mint(address _to) public onlyOwner {
        require(_to != address(0), "Invalid address");

        uint256 tokenId = _generateNextToken();
        _addLikenToken(_to, tokenId);
        _currentToken++;

        emit Transfer(address(0), _to, _currentToken);
    }

    function _generateNextToken() internal view returns (uint256) {
        require(_currentToken + 1 > 0, "Max number of tokens reached");
        return _currentToken + 1;
    }

    function _addLikenToken(address _to, uint256 _tokenId) internal {
        require(
            _idToOwner[_tokenId] == address(0),
            "Liken token already exists"
        );
        require(
            _ownerToLikenTokenCount[_to] + 1 > _ownerToLikenTokenCount[_to],
            "Overflow"
        );

        _idToOwner[_tokenId] = _to;
        _ownerToLikenTokenCount[_to]++;
    }
}
