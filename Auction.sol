pragma solidity >= 0.8.4;

contract Auction {
    address public owner;
    uint public startDate;
    uint public endDate;
    mapping(address => uint) private bids;
    address private highestBidder;
    address private secondHighestBidder;


    constructor(){
        owner = msg.sender;
    }

    enum Status {Cancelled, Complete, Started}
    Status public status;

    modifier checkOwner {
        _;
        require(msg.sender == owner, "sender is not owner");
    }

    function startAuction(uint endTime) external checkOwner {
        startDate = block.timestamp;
        endDate = endTime;
        status = Status.Started;

    }

    function cancelAuction() external {
        status = Status.Cancelled;


    }

    function finalizeAuction() external checkOwner{
        require(block.timestamp >= endDate, "end date has not yet reached");
        status = Status.Complete;
        uint increment = 1;
        uint highestBindingBid = bids[secondHighestBidder] + increment;
        payable(msg.sender).transfer(highestBindingBid);

    }


    
    function placeBid() payable external {
        bids[msg.sender] = msg.value;
		if (highestBidder == address(0)) {
			highestBidder = msg.sender;
			secondHighestBidder = msg.sender;
		} else if (msg.value > bids[highestBidder]) {
			secondHighestBidder = highestBidder;
			highestBidder = msg.sender;
		} else if (msg.value > bids[secondHighestBidder]) {
			secondHighestBidder = msg.sender;
		}

    }

    //withdrawing bids after end of auction
    function withdrawBid() external {
        if (status == Status.Complete && msg.sender == highestBidder) {
			uint increment = 1;

            //bid that the highest bidder must pay
			uint highestBindingBid = bids[secondHighestBidder] + increment;

            //extra amount paid by highest bidder
			uint refund = bids[msg.sender] - highestBindingBid;
			payable(msg.sender).transfer(refund);
		} else {
            //if msg.sender is not highest bidder they get their entire amount back
			payable(msg.sender).transfer(bids[msg.sender]);
		}
       
    }

    function winner() external view returns (address){
        require(status == Status.Complete,"Auctions has not yet been finalized");
        return highestBidder;
    }



}