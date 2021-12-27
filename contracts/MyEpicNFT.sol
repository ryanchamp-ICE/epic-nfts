// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // We split the SVG at the part where it asks for the background color.
  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // I create three arrays, each with their own theme of random words.
  // Pick some random funny words, names of anime characters, foods you like, whatever! 
  string[] firstWords = ["Ice", "Luke", "Hot", "Dead", "Meaty", "Flawless", "Flimsy", "Early", "Spooky", "Trashy", "Fragile", "Bouncy", "Funny", "Cagey", "Stimulating", "Diligent", "Filthy", "Nostalgic", "Wet", "Huge" ];
  string[] secondWords = ["Cold", "Warm", "Orthodox", "Dreary", "Volatile", "Tested", "Dusty", "Cheerful", "Jaded", "Glorious", "Untidy", "Kaput", "Wise", "Barbarous", "Glistening", "Soft", "Scary", "Earthy", "Poised", "Spicy"];
  string[] thirdWords = ["Edge", "Middle", "Guy", "Gal", "Baby", "Wifey", "Mars", "File", "Freight", "Maid", "Sweat", "Stick", "Hole", "Rebel", "Pie", "Outcome", "Ratio", "Actor", "Tradition", "Balance", "Sexual" ];

  // Get fancy with it! Declare a bunch of colors.
  string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
      console.log("IceColdNFT");
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

    rand = rand % firstWords.length;

    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));

    rand = rand % secondWords.length;

    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));

    rand = rand % thirdWords.length;

    return thirdWords[rand];
  }

  // Same old stuff, pick a random color.
  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory firstWord = pickRandomFirstWord(newItemId);
    string memory secondWord = pickRandomSecondWord(newItemId);
    string memory thirdWord = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(firstWord, secondWord, thirdWord));
    
    string memory randomColor = pickRandomColor(newItemId);

    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            combinedWord,
            '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n-----------------------");
    console.log(
      string(
        abi.encodePacked("https://nftpreview.0xdev.codes/?code=", finalTokenUri)
      )
    );
    console.log("-----------------------\n");

    _safeMint(msg.sender, newItemId);

    _setTokenURI(newItemId, finalTokenUri);
    //_setTokenURI(newItemId, "data:application/json;base64,eyJuYW1lIjoiSWNlQ29sZEVkZ2UiLCJkZXNjcmlwdGlvbiI6IlRoZSBJY2VDb2xkRWRnZSBORlQiLCJpbWFnZSI6ImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajRLSUNBZ0lEeHpkSGxzWlQ0dVltRnpaU0I3SUdacGJHdzZJSGRvYVhSbE95Qm1iMjUwTFdaaGJXbHNlVG9nYzJWeWFXWTdJR1p2Ym5RdGMybDZaVG9nTVRSd2VEc2dmVHd2YzNSNWJHVStDaUFnSUNBOGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSmliR0ZqYXlJZ0x6NEtJQ0FnSUR4MFpYaDBJSGc5SWpVd0pTSWdlVDBpTlRBbElpQmpiR0Z6Y3owaVltRnpaU0lnWkc5dGFXNWhiblF0WW1GelpXeHBibVU5SW0xcFpHUnNaU0lnZEdWNGRDMWhibU5vYjNJOUltMXBaR1JzWlNJK1NXTmxRMjlzWkVWa1oyVThMM1JsZUhRK0Nqd3ZjM1puUGc9PSJ9");
    
    _tokenIds.increment();
    console.log("An NFT w/ id %s has been minted to %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}
