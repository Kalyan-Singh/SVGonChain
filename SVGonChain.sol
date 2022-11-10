// SPDX-License-Identifier: MIT


pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract SVGonChain is ERC721Enumerable, Ownable {
  using Strings for uint256;

  // string[] public wordValues=["Here","Loki","Thor","Karatos","Odin","Zues"];
  // above array was use for testing


  struct Word{
    string name;
    string bgHue;
    string description;
    string textHue;
    string value;
  }

  mapping (uint => Word) public words;



  uint256 public cost = 0.005 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 1;

  constructor() ERC721("On Chain SVG NFT","OCSN") {}

  // internal
  function randomNum(uint _mod,uint _seed,uint _salt) public view returns(uint){
    uint num= uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,_seed,_salt)))%_mod;
    return num;
  }

  // public
  function mint(string memory _des,string memory _value) public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= maxSupply);

    if (msg.sender != owner()) {
      require(msg.value >= cost);
    }

      _safeMint(msg.sender, supply + 1);

    Word memory newWrd= Word(
      string(abi.encodePacked("OCSN #",uint256(supply).toString())),
      randomNum(361, 3, 3).toString(),
      _des,
      randomNum(361, 3, 3).toString(),
      _value
    );

    words[supply]=newWrd;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override 
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    return string(abi.encodePacked('data:application/json;base64,',Base64.encode(bytes(abi.encodePacked(
      '{"name":"',
      "",words[tokenId-1].name,"",
      '","description":"',
      "",words[tokenId-1].description,"",
      '","image":"',
      'data:image/svg+xml;base64,',
      buildImage(tokenId-1),
      '"}'
    )))));
  }
  

  function buildImage(uint _index) public view returns(string memory){
    return Base64.encode(bytes(abi.encodePacked(
      '<?xml version="1.0"?>'
      '<svg width="100%" height="500" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg">'
      '<rect fill="hsl(',words[_index].bgHue,', 50%, 25%)" height="500" width="100%"/>'
      '<text fill="hsl(',words[_index].textHue,', 100%, 80%)" font-family="serif" font-size="18"  text-anchor="start" x="10" xml:space="preserve" y="40">',words[_index].value,'</text>'
      '</svg>'
    )));
  }

  //only owner

  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  


 
  function withdraw() public payable onlyOwner {

    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}
