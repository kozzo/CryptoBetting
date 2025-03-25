// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract CryptoBetting {
  AggregatorV3Interface internal constant priceFeed =
    AggregatorV3Interface(0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f);

  address public owner;
  uint256 public commissionRate = 5; // Commission rate: 5%

  enum Prediction {
    Rise,
    Fall
  }

  struct Bet {
    uint256 amount;
    Prediction prediction;
    bool claimed;
    int256 entryPrice; // Store initial price
  }

  mapping(address => Bet) public bets;
  uint256 public totalBetAmount;

  constructor() {
    owner = msg.sender;
  }

  function placeBet(Prediction _prediction) external payable {
    require(msg.value > 0, "Bet amount must be greater than 0");
    require(bets[msg.sender].amount == 0, "User has already placed a bet");

    int256 currentPrice = getLatestPrice(); // Store price at bet time
    bets[msg.sender] = Bet(msg.value, _prediction, false, currentPrice);
    totalBetAmount += msg.value;
  }

  function getLatestPrice() public view returns (int256) {
    (, int256 price,,,) = priceFeed.latestRoundData();
    return price;
  }

  function resolveBet() external {
    require(bets[msg.sender].amount > 0, "No bet placed");
    require(!bets[msg.sender].claimed, "Already claimed");

    int256 latestPrice = getLatestPrice();
    int256 entryPrice = bets[msg.sender].entryPrice;
    Prediction userPrediction = bets[msg.sender].prediction;

    bool winner = false;
    if (
      (userPrediction == Prediction.Rise && latestPrice > entryPrice)
        || (userPrediction == Prediction.Fall && latestPrice < entryPrice)
    ) {
      winner = true;
    }

    if (winner) {
      uint256 payout = (totalBetAmount * (100 - commissionRate)) / 100;

      // payable(msg.sender).transfer(payout);

      (bool success,) = payable(msg.sender).call{ value: payout }("");
      require(success, "Transfer failed");
    }

    bets[msg.sender].claimed = true;
  }
}
