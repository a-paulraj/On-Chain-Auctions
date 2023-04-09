// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    uint public highestBid; // should this and below be changed to something not public? idk
    address payable public highestBidder;
    bool public hasPaid; // default value is false

    //mapping(address => uint) public bids;
    mapping(address => bool) public hasBid; //might not need this, gas prices incentivize not spamming too hard

    event AuctionEnded(address winner, uint amount);

    constructor(uint biddingTime) {
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() public payable {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        //require(msg.value > highestBid, "There is already a higher bid");
        require(!hasBid[msg.sender], "Already Bid");
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
        }
    }

    function pay() public {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(!hasPaid, "Payment already made");
        hasPaid = true;
        payable(msg.sender).transfer(highestBid);
    }
}