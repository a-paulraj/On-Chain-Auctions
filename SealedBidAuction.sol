// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SealedBidAuction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    bytes32 public highestBid;
    address payable public highestBidder;
    bool public hasPaid;
    mapping(address => bytes32) public hashedBids;

    constructor(uint biddingTime) {
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
    }

    function submitBid(bytes32 bid) public {
        require(block.timestamp <= auctionEndTime, "Auction has ended");
        require(hashedBids[msg.sender] == 0, "Already submitted a bid");
        hashedBids[msg.sender] = bid;
    }

    function revealBid(uint actualBid) public {
        require(block.timestamp > auctionEndTime, "Auction has not ended yet");
        require(hashedBids[msg.sender] != 0, "No bid submitted");
        require(keccak256(abi.encodePacked(actualBid)) == hashedBids[msg.sender], "Actual bid does not match hashed bid");

        if (actualBid > uint(highestBid)) {
            highestBid = bytes32(actualBid);
            highestBidder = payable(msg.sender);
        }
    }

    function pay() public {
        require(block.timestamp > auctionEndTime, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(!hasPaid, "Payment already made");
        hasPaid = true;
        payable(msg.sender).transfer(uint(highestBid));
    }
}
