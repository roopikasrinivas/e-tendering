/* This is the smart contract for the Procurement Tender. It consists of two contracts - 
   Tender and TenderFactory - which is used to declare instances of the 'tender'
   contract, Bid for Tender and Approve the Tender
*/
pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

contract TenderFactory {

    // deployedTenders stores the addresses of the deployed tenders
    address[] public deployedTenders;

    /* createTender is used to deploy a new instance of the 'tender' contract - 
       it accepts the requirements of the tender as argument and deploys an
       instance with the msg.sender as manager
    */  
    function createTender(string description) public {
      address newTender = new Tender(description, msg.sender);
      deployedTenders.push(newTender);
    }

    /* getDeployedTenders is a function that returns the array of deployed tenders' 
       addresses.
    */
    function getDeployedTenders() public view returns(address[]){
        return deployedTenders;
    }   
}

contract Tender{
    /* manager => address of the manager/creator of the tender
       data => requirements of the tender 
       complete => status of whether the tender has BEEN AWARDED
    */
    bool public complete;
    string private data;
    address private manager;
    
    /* struct Bid is a type to hold the details of a bid made - containing
       the address of the bidder, the amount that the bid is made at, and the
       proposal of the bidder (bid).
    */
    struct Bid {
        address  bidder;
        uint bidAmount;
        string bid;
    }
    
    /* struct hiddenBid contains the bidAmount and bid members, but does not contain the 
       address of the bidder, to ensure that the awarding of a tender is an unbiased process
    */
    struct hiddenBid {
        uint ID;
        uint bidAmount;
        string bid;
    }
    
    /* 1.bids consists of all the bids and is made private to ensure no bias.
       2.hiddenBids is the array of structures that contain bids without their addresses, for 
         the purpose of the govt choosing a bid
       3.winner consists of the address of the winning bidder 
       4.winIndex contains the winner index
    */
    Bid[] private bids;
    hiddenBid[] private hiddenBids;
    Bid public winner;
    uint public winIndex;
    
    /* 
        Constructor function of the tender contract.
    */
    constructor (string description, address creator) public {
        manager = creator;
        data = description;
    }

    /* 
        This function returns the details of the bidder, bidAmount and bid(proposal)
        only after the tender has been awarded, to ensure transparency in the system.
    */
    function getBidSummary(uint index) public view returns (uint, uint, string) {
        return (
            hiddenBids[index].ID,
            hiddenBids[index].bidAmount,
            hiddenBids[index].bid
        );
    }
     
    /* 
        This function is used to let a bidder make a bid, it creates a temporary instance
        of Bid and hiddenBid and initialised them and pushes them into the respective arrays.
    */
    function makeBid(uint bidAmount, string desc) public payable {
        require(!complete);
        Bid memory newBid = Bid({
            bidder : msg.sender,
            bidAmount : bidAmount,
            bid : desc
        });
        bids.push(newBid);
        hiddenBid memory newhiddenBid = hiddenBid({
            ID : bids.length-1,
            bidAmount : bidAmount,
            bid : desc
        });
        hiddenBids.push(newhiddenBid);
    }

    /* 
        finalizeBid is used to award the bid by passing an argument of the index of the bid.
    */
    function finalizeBid(uint index) public payable {
        require(!complete);
        winner = bids[index];
        winIndex = index;
        //send bid amount to winner and balance to manager
        complete = true;   
    }

    /* 
        getTenderSummary is used to get tender details
    */
    function getTenderSummary() public view returns (address, string, uint) {
        return(manager,
        data,
        bids.length);
    }

    /* 
        getBidCount is used to get the number of bids for Tender
    */
    function getBidCount() public view returns (uint) {
        return bids.length;
    }

    /* 
        getAllBids returns all the bids without bidder address
    */
    function getAllBids() public view returns (hiddenBid[] memory){
      hiddenBid[] memory bidss = new hiddenBid[](hiddenBids.length);
      for (uint i = 0; i < hiddenBids.length; i++) {
          hiddenBid storage bid = hiddenBids[i];
          bidss[i] = bid;
      }
      return bidss;
    }

}
