//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//Internal Imporrs for the smart contract
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract NFTMarket is ERC721URIStorage{
    uint private TokenId;
    uint private tokenSold;
    address payable owner;
    uint listingPrice = 0.025 ether;
    mapping(uint => MarketItem) private idMarketItem;
    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() ERC721("NFT Metaverse Token", "MYNFT"){
        owner = payable(msg.sender);
    }
    //This si the funtion updating the listing price of the nft token
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner{
       listingPrice = _listingPrice;
    }
    // This is the function to fetch the listing price of the particular token
    function getListingPrice() public view returns(uint256){
        return listingPrice;
    }
    // This is the function to create the NFT token
    function createToken(string memory tokenUri, uint256 price) public payable returns(uint){
       TokenId++;
       uint256 newTokenId =  TokenId;
      _safeMint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenUri);
      createMarketItem(newTokenId, price);

      return newTokenId; 
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price>0 , "Price must be at least 1");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, true);
    }
    // This is the funtion for the user to resell the nft and sell it in the higher price
    function resellToken(uint256 tokenId, uint256 price) public payable{
        require(idMarketItem[tokenId].owner == msg.sender, "Only owner of the person can resell the token");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));
        tokenSold--;
        _transfer(msg.sender, address(this), tokenId);
    }
    // This is the function to create the sale of the token
    function createMarketSale(uint256 tokenId) public payable{
        uint256 price = idMarketItem[tokenId].price;
        require(msg.value == price, "Please complete the asking price in order to complete the order");
        idMarketItem[TokenId].owner = payable(msg.sender);
        idMarketItem[TokenId].sold = true;
        idMarketItem[TokenId].owner = payable(address(0));

        tokenSold++;
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }   
    // This is the funtion which displays the nft which is available for the sale in the contract
    function fetchMarketItem() public view returns(MarketItem[] memory) {
        uint256 itemCount = TokenId;
        uint256 unSoldItemCount = TokenId - tokenSold;
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unSoldItemCount);

        for(uint256 i = 0; i<items.length; i++){
            if(idMarketItem[i + 1].owner == address(this)){
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items; 
    }
    // This is the function to display the all nfts of the person
    function fetchMyNFT() public view returns(MarketItem[] memory) {
        uint256 totalCount = TokenId;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i = 0; i<totalCount ;i++){
            if(idMarketItem[i+1].owner == msg.sender){
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint256 i = 0; i<itemCount ; i++){
            if(idMarketItem[i+1].owner == msg.sender){
                uint currentId = i + 1;
                MarketItem memory currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }

        return items;
        
    }

   function fetchSelledNFT() public view returns(MarketItem[] memory) {
        uint256 totalCount = TokenId;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i = 0; i < totalCount; i++){
            if(idMarketItem[i+1].seller == msg.sender){
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint256 i = 0; i<itemCount ; i++){
            if(idMarketItem[i+1].seller == msg.sender){
                uint currentId = i+1;
                MarketItem memory item = idMarketItem[currentId];
                items[currentIndex] = item;
                currentIndex++;
            }
        }

        return items;
   }
    
}

