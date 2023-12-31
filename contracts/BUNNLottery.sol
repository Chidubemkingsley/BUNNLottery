// SPDX-License-identifier:MIT
pragma solidity ^0.8.7;

import "@chainlink\contracts\src\v0.8\interfaces\VRFCoordinatorV2Interface.sol";
import "@chainlink\contracts\src\v0.8\vrf\VRFConsumerBaseV2.sol";
import "@chainlink\contracts\src\v0.8\shared\access\ConfirmedOwner.sol";

contract BUNNLottery is VRFConsumerBaseV2, ConfirmedOwner {

event RequestSent (uint256 requestId, uint32 numWords);
event RequestFulfilled (uint256 requestId, uint256[] randomwords);
event lotteryCreated (uint256 lotteryId);

     VRFCoordinatorV2Interface COORDINATOR;
     uint64 s_subscriptionId;

     uint256 lastRequestId;
     bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomwords;
    }

    mapping(uint256 => RequestStatus ) public s_requests;
    uint 256[] public requestIds;

    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;

    uint32 numWords = 1;

    struct lotteryData_ {
        uint256 numberOfParticipants;
        address winner;
        addresss[] contenders;
        bool completed;
        bool exists;
    }

    mapping(uint256 => lotteryData_) public LotteryData;

    constructor (uint64 subscriptionID) VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625 ) ConfirmedOwner(msg.sender){
      COORDINATOR = VRFCoordinatorV2Interface(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625);
      s_subscriptionId = subscriptionID;

}


  function requestRandomWords() internal returns (uint256 requestID) {
    requestID = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
    );
    s_requests[requestID] = RequestStatus ({
        randomwords: new uint256[](0),
        exists: true,
        fulfilled: false
    });
    requestIds.push(requestID);
    lastRequestId = requestID;
    emit RequestSent(requestID, numWords);

  }

 function fulfillRandomWords9(uint256 _requestID, uint256[] memory _randomWords) internal override{
 require(s_requests[_requestID].exists, "request not found");
 s_requests[_requestID].fulfilled = true;
 s_requests[_requestID].randomWords = _randomWords;
 emit RequestFulfilled(_requestID, _randomWords); 
 }

 function getRequestStatus(uint256 _requestID) public view returns (bool fulfilled, uint256[] memory randomWords) {
 require(s_requests[_requestID].exists, "request not found");
 RequestStatus memory request = s_requests[_requestID];

 return (request.fulfilled, request.randomWords);
 }

 function createLottery (uint256 _lotteryId, uint256 numberOfParticipants) external onlyOwner {
    address[] memory contenders;
    lotteryData_ memory newLottery = lotteryData_ (numberOfParticipants, address(0), contenders, false, true);
    LotteryData[_lotteryId] = newLottery;
    emit lotteryCreated(_lotteryId);
 }

 function participate (uint256 _lotteryId) external returns (bool) {
    require(LotteryData[_lotteryId].exists == true, "INVALID LOTTERY");
    require(LotteryData[_lotteryId].contenders.length < LotteryData[_lotteryId].numberOfParticipants, "LOTTERY FULL");
    LotteryData[_lotteryId].contenders.push(msg.sender);
    if (LotteryData[_lotteryId].numberOfParticipants == LotteryData[_lotteryId].contenders.length) {
        spinTheWheel(_lotteryId);

    }
    return true;
 }
  function spinTheWheel(uint lotteryId) public {
    require(LotteryData[_lotteryId].exists == true, "INVALID LOTTERY ID");
    if(msg.sender != Owner()) {
    require(LotteryData[_lotteryId].numberOfParticipants == LotteryData[_lotteryId].contenders.length, "LOTTERY STILL IN PROGRESS");        
    }
    LotteryData[_lotteryId].completed = true;
    requestRandomWords();
  }

  function AwardWinner(uint _lotteryId) external returns(uint256){
    require(LotteryData[_lotteryId].completed == true, "WHEEL NOT SPINNED");
    require(LotteryData[_lotteryId],winner == address(0), "WINNER ALREADY ANNOUNCED");
    ( ,uint[] memorywinners) = getRequestStatus(lastRequestId);
    uint noOfContenders = LotteryData[_lotteryId].contenders.length;
    uint winner = winners[0] % noOfContenders;
    address[]memory contenders_ = LotteryData[_lotteryId].contenders;
    LotteryData[_lotteryId].winner = contenders_[winner];
    return winner;
    }

    function viewwinner(uint _lotteryId) external view returns (address) {
        require(LotteryData[_lotteryId].exists == true, "INVALID LOTTERY ID");
        return LotteryData[_lotteryId].winner;
    } 




    
}


