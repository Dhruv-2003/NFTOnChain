//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract CricNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /// mapping for the token ID => t levels
    mapping(uint256 => uint256) public tokenIdLevels;

    /// intializing the NFT ERC721
    constructor() ERC721("Cric NFT", "Cric") {}

    //  to generate the main SVG part
    function generateCharacter(uint256 tokenId) public returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Cricket",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    /// to get the final level in the proper format
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdLevels[tokenId];
        return levels.toString();
    }

    // to get the final tokenURI for a tokenId with metadata and svg together
    function getTokenURI(uint256 tokenId) public returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Cric NFT #',
            tokenId.toString(),
            '",',
            '"description": "Cricket on Chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /// to mint a on chain NFT using mint and setting a token URI for the svg
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /// train wil just increase the level and update the new token URI with new SVG
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an Exsisting token");
        require(ownerOf(tokenId) == msg.sender, "YOu are not the owner");
        uint256 currentLevel = tokenIdLevels[tokenId];
        tokenIdLevels[tokenId] = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
