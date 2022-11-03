// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTBuilder is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 10000;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NFTBuilder", "NFTB") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeid4qh5r3tcjix2jumgcby3r7qhtfedq36h5mz5ahxew4jvfnpqjwq/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Update the mint status, edit the publicMintOpen and allowListMintOpen variables
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    // Use for Allowlist Mint NFTs. Only the people in allowList allow to mint
    // First, check the mint status, then check the payment amount.
    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist Mint is closed now");
        require(allowList[msg.sender], "Sorry, you are not on the list");
        require(msg.value == 1 ether, "The funds are not enough");
        internalMint();
    }

    // Use for Public Mint NFTs. 
    // First, check the mint status, then check the payment amount.
    function publicMint() public payable {
        require(publicMintOpen, "Public Mint is closed now");
        require(msg.value == 2 ether, "The funds are not enough");
        internalMint();
    }

    // The mint function, first check the supply limitation
    function internalMint() internal {
        require(totalSupply() < maxSupply, "Sold Out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    // Withdraw the money from the contract
    function withdraw(address _addr) external onlyOwner {
        uint256 balalnce = address(this).balance;
        payable(_addr).transfer(balalnce);
    }

    // Update the allowlist
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Override the function
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}