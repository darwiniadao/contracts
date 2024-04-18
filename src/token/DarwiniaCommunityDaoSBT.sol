// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts@4.9.6/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.9.6/token/ERC721/extensions/ERC721Votes.sol";
import "@openzeppelin/contracts@4.9.6/access/Ownable2Step.sol";
import "@openzeppelin/contracts@4.9.6/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts@4.9.6/utils/Counters.sol";
import "@openzeppelin/contracts@4.9.6/governance/utils/IVotes.sol";
import "./IERC5192.sol";

/// @dev Implementation of https://eips.ethereum.org/EIPS/eip-5192[ERC5192] Minimal Soulbound NFTs
/// and https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard including the Metadata extension
/// Specification:
/// 1. SBT tokens are non-transferable.
/// 2. Assume at extreme condition (lost private key), community multisig (contract owner) can transfer the token to the new wallet.
/// 3. SBT Tokens are sequentially minted starting at 0 (e.g. 0, 1, 2, 3..).
/// 4. The maximum token id cannot exceed 2**256 - 1 (max value of uint256).
/// 5. Metadata and image are pinned to ipfs.
/// 6. Token uri metadata are changeable by contract owner.
/// @custom:security-contact security@darwinia.network
contract DarwiniaCommunityDaoSBT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable2Step,
    EIP712,
    ERC721Votes,
    IERC5192
{
    using Counters for Counters.Counter;

    error ErrLocked();

    Counters.Counter private _tokenIdCounter;
    string private _contractURI;
    string private _base_uri;

    bool private constant LOCKED = true;

    // --- Auth ---
    mapping(address => uint256) public wards;

    function rely(address guy) external onlyOwner {
        wards[guy] = 1;
    }

    function deny(address guy) external onlyOwner {
        wards[guy] = 0;
    }

    modifier auth() {
        require(wards[_msgSender()] == 1, "gDCDP/not-authorized");
        _;
    }

    constructor(address dao)
        ERC721("Darwinia Community DAO Profile", "gDCDP")
        EIP712("Darwinia Community DAO Profile", "1")
    {
        wards[dao] = 1;
        _transferOwnership(dao);
    }

    function setBaseURI(string calldata newBaseURI) external auth {
        _base_uri = newBaseURI;
        uint256 toTokenId = totalSupply() - 1;
        emit BatchMetadataUpdate(0, toTokenId);
    }

    // uid: bytes32
    // ipfs://dir_cid/{uri=uid}
    function safeMint(address to, string memory uri) public auth {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit Locked(tokenId);
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function setContractURI(string calldata newContractURI) external onlyOwner {
        _contractURI = newContractURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    // Only contract owner could transfer/burn SBT
    function _isApprovedOrOwner(address spender, uint256) internal view override returns (bool) {
        if (spender != owner()) revert ErrLocked();
        return true;
    }

    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        revert ErrLocked();
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override(IERC721, ERC721) {
        revert ErrLocked();
        super.setApprovalForAll(operator, approved);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _base_uri;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function locked(uint256 tokenId) external view returns (bool) {
        _requireMinted(tokenId);
        return LOCKED;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return interfaceId == type(IERC5192).interfaceId || interfaceId == type(IVotes).interfaceId
            || super.supportsInterface(interfaceId);
    }
}
