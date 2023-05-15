// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DescendingAuction {
    address payable public auctionOwner;
    uint public currentPrice;
    address payable public winner;
    uint public decrement;
    IERC721 public nft;
    uint public nftId;

    event AuctionStarted(uint ceilingPrice);
    event PriceLowered(uint newPrice);
    event AuctionEnded(address winner, uint amount);

    constructor(uint ceilingPrice, uint decrementValue, address thenft, uint thenftid) {
        require(IERC721(thenft).ownerOf(thenftid) == msg.sender, "Auctioneer does not own NFT");
        auctionOwner = payable(msg.sender);
        currentPrice = ceilingPrice;
        decrement = decrementValue;
        nft = IERC721(thenft);
        nftId = thenftid;
        emit AuctionStarted(currentPrice);
    }

    function bid() public payable {
        require(msg.value == currentPrice, "You must bid the current price");
        winner = payable(msg.sender);
        auctionOwner.transfer(msg.value);
        nft.safeTransferFrom(auctionOwner, winner, nftId);
        emit AuctionEnded(winner, msg.value);
    }

    function lowerPrice() public {
        require(msg.sender == auctionOwner, "Only auction owner can lower price");

        currentPrice = currentPrice - decrement;
        emit PriceLowered(currentPrice);

        if (currentPrice == 0) { // auction ends with no buyers
            emit AuctionEnded(address(0), 0);
        }
    }
}
