// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SealedBidAuction {
    address payable public auctionOwner;
    uint public auctionEndTime;
    uint public highestBid;
    address payable public highestBidder;
    bool public hasPaid;
    IERC721 public nft;
    uint public nftId;

    mapping(address => bytes32) public hashedBids;

    constructor(uint biddingTime, address thenft, uint thenftid) {
        require(IERC721(thenft).ownerOf(thenftid) == msg.sender, "Auctioneer does not own NFT");
        auctionOwner = payable(msg.sender);
        auctionEndTime = block.timestamp + biddingTime;
        nft = IERC721(thenft);
        nftId = thenftid;
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

        if (actualBid > highestBid) {
            highestBid = actualBid;
            highestBidder = payable(msg.sender);
        }
    }

    function pay() public payable {
        require(block.timestamp > auctionEndTime, "Auction has not ended yet");
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(msg.value == highestBid, "Insufficient Eth Transferred");
        require(!hasPaid, "Payment already made");
        hasPaid = true;
        auctionOwner.transfer(highestBid);
        nft.safeTransferFrom(auctionOwner, msg.sender, nftId);
    }
}
