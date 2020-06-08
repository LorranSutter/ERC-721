// SPDX-License-Identifier: MIT

pragma solidity >=0.5.8 <0.7.0;

import "./Interfaces/IERC721.sol";
import "./Interfaces/IERC721Metadata.sol";
import "./Interfaces/IERC721Enumerable.sol";

// Based on https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/utils/address-utils.sol
library Address {
    /**
     * @dev Returns whether the target address is a contract.
     * @param _addr Address to check.
     * @return addressCheck True if _addr is a contract, false if not.
     */
    function isContract(address _addr)
        internal
        view
        returns (bool addressCheck)
    {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;


        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_addr) } // solhint-disable-line
        addressCheck = (codehash != 0x0 && codehash != accountHash);
    }
}


contract ERC721 is IERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    address private owner;
    string private _name;
    string private _symbol;
    uint256 private currentToken;

    uint256[] internal allTokens;

    mapping(uint256 => address) private tokenToOwner;

    mapping(address => uint256) private ownerToTokensCount;
    mapping(uint256 => address) internal tokenToApproval;
    mapping(address => mapping(address => bool)) internal ownerToOperators;

    //Global variable
    mapping(address => mapping(address => uint256)) internal allowed;

    // Mapping for stroing interface ids of supported interfaces
    mapping(bytes4 => bool) private _supportedInterfaces;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

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

    modifier validToken(uint256 _tokenId) {
        require(
            tokenToOwner[_tokenId] != address(0),
            "ERC721: token not valid"
        );
        _;
    }

    modifier canOperate(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            "ERC721: not owner or operator"
        );
        _;
    }

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender ||
                tokenToApproval[_tokenId] == msg.sender ||
                ownerToOperators[tokenOwner][msg.sender],
            "ERC721: not owner, approved or operator"
        );
        _;
    }

    constructor(string memory name, string memory symbol) public {
        owner = msg.sender;
        _name = name;
        _symbol = symbol;
        currentToken = 0;
        _registerInterface(0x01ffc9a7); //ERC-165
        _registerInterface(0x80ac58cd); //ERC-721
        _registerInterface(0x5b5e139f); //ERC-721-metadata
        _registerInterface(0x780e9d63); //ERC-721-enumerable
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
        require(_index < allTokens.length, "ERC721: invalid index");
        return allTokens[_index];
    }

    // ------ ERC-721 ------ //
    function balanceOf(address _owner) public override view returns (uint256) {
        return ownerToTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns (address) {
        address _owner = tokenToOwner[_tokenId];
        require(_owner != address(0), "ERC721: invalid ERC721 token");
        return _owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public override payable {
        _safeTransfer(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override payable {
        _safeTransfer(_from, _to, _tokenId, "");
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
        address tokenOwnerAddress = tokenToOwner[_tokenId];
        require(
            _approved != tokenOwnerAddress,
            "ERC721: approval to current owner"
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

    function supportsInterface(bytes4 interfaceId)
        public
        override
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    // ------ Functions not in the interfaces ------ //
    function mint(address _to) public returns (uint256) {
        require(_to != address(0), "ERC721: invalid address");

        uint256 tokenId = _generateNextToken();
        _addToken(_to, tokenId);
        currentToken++;

        emit Transfer(msg.sender, _to, tokenId);

        return tokenId;
    }

    // ------ Internal functions ------ //
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC721: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    function _generateNextToken() internal view returns (uint256) {
        require(currentToken + 1 > 0, "ERC721: max number of tokens reached");
        return currentToken + 1;
    }

    function _addToken(address _to, uint256 _tokenId) internal {
        require(
            tokenToOwner[_tokenId] == address(0),
            "ERC721: token already exists"
        );
        require(
            ownerToTokensCount[_to] + 1 > ownerToTokensCount[_to],
            "ERC721: overflow"
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

    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 retval = IERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _to,
                _tokenId,
                data
            );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                "ERC721: recipient SC cannot handle ERC721 tokens"
            );
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal validToken(_tokenId) {
        require(
            ownerOf(_tokenId) == _from,
            "ERC721: transfer of token that is not own"
        );
        require(_to != address(0), "ERC721: Transfer to the zero address");

        _clearApproval(_tokenId);

        _removeToken(_from, _tokenId);
        _addToken(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _removeToken(address _from, uint256 _tokenId) internal {
        require(tokenToOwner[_tokenId] == _from, "ERC721: not owner");
        ownerToTokensCount[_from] = ownerToTokensCount[_from] - 1;
        delete tokenToOwner[_tokenId];
    }

    function _clearApproval(uint256 _tokenId) internal {
        if (tokenToApproval[_tokenId] != address(0)) {
            delete tokenToApproval[_tokenId];
        }
    }
}
