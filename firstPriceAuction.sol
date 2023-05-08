// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract firstPriceAuction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    uint public highestBid; // should this and below be changed to something not public? idk
    address payable public highestBidder;
    bool public hasPaid; // default value is false
    IERC721 public nft;
    uint public nftId;

    //mapping(address => uint) public bids;
    mapping(address => bool) public hasBid; //might not need this, gas prices incentivize not spamming too hard

    constructor(uint biddingTime, address thenft, uint thenftid) {
        // need to verify that msg.sender owns thenft
        // make sure nftid and nft check out
        require(IERC721(thenft).ownerOf(thenftid) == msg.sender, "Auctioneer does not own NFT");
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
        nft = IERC721(thenft);
        nftId = thenftid;
    }

    function bid(uint thebid) public {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        require(thebid > 0, "Only Positive Bids Allowed");
        require(!hasBid[msg.sender], "Already Bid");
        hasBid[msg.sender] = true;
        if (thebid > highestBid) {
            highestBid = thebid;
            highestBidder = payable(msg.sender);
        }
    }

    function pay() public payable {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(msg.value == highestBid, "Insufficient Eth Transferred");
        require(!hasPaid, "Payment already made");
        hasPaid = true;
        auctionOwner.transfer(highestBid);
        nft.safeTransferFrom(auctionOwner, msg.sender, nftId);
    }
}