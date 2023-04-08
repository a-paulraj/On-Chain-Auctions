// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    uint public highestBid;
    address payable public highestBidder;
    bool public auctionEnded;

    mapping(address => uint) public bids;
    mapping(address => bool) public hasPaid;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint biddingTime) {
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() public payable {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "There is already a higher bid");

        highestBid = msg.value;
        highestBidder = payable(msg.sender);

        if (highestBid != 0) {
            // refund previous highest bidder
            bids[highestBidder] += highestBid;
        }

        bids[msg.sender] += msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function endAuction() public {
        require(msg.sender == auctionOwner, "You are not the auction owner");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Auction has already ended");

        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);
    }

    function pay() public {
        require(auctionEnded, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(!hasPaid[msg.sender], "Payment already made");

        hasPaid[msg.sender] = true;
        payable(msg.sender).transfer(highestBid);
    }

    function withdraw() public {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(bids[msg.sender] > 0, "You have no funds to withdraw");

        uint amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
