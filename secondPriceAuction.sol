// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract secondPriceAuction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    uint public highestBid; // should this and below be changed to something not public? idk
    uint public secondhighestBid;
    address payable public highestBidder;
    bool public hasPaid; // default value is false

    //mapping(address => uint) public bids;
    mapping(address => bool) public hasBid; //might not need this, gas prices incentivize not spamming too hard

    constructor(uint biddingTime) {
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid(uint thebid) public {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        require(thebid > 0, "Only Positive Bids Allowed");
        require(!hasBid[msg.sender], "Already Bid");
        hasBid(msg.sender) = true;
        if (thebid > highestBid) {
            secondhighestBid = highestBid;
            highestBid = thebid;
            highestBidder = payable(msg.sender);
        } else if (thebid > secondhighestBid) {
            secondhighestBid = thebid;
        }
    }

    function pay() public payable {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(!hasPaid, "Payment already made");
        hasPaid = true;
        payable(msg.sender).transfer(secondhighestBid);
    }
}