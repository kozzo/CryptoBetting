// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract CryptoBetting {
  AggregatorV3Interface internal constant priceFeed =
    AggregatorV3Interface(0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f);

  address public owner;
  uint256 public commissionRate = 5; // 5% commission

  enum Prediction {
    Rise,
    Fall
  }

  struct Bet {
    uint256 amount;
    Prediction prediction;
    bool claimed;
    int256 entryPrice;
  }

  address[] public bettors;
  mapping(address => Bet) public bets;

  uint256 public totalBetAmount;
  uint256 public totalRiseBets;
  uint256 public totalFallBets;

  constructor() {
    owner = msg.sender;
  }

  function placeBet(Prediction _prediction) external payable {
    require(msg.value > 0, "Bet amount must be greater than 0");
    require(bets[msg.sender].amount == 0, "Already placed a bet");

    int256 currentPrice = getLatestPrice();
    bets[msg.sender] = Bet(msg.value, _prediction, false, currentPrice);
    bettors.push(msg.sender);
    totalBetAmount += msg.value;

    if (_prediction == Prediction.Rise) {
      totalRiseBets += msg.value;
    } else {
      totalFallBets += msg.value;
    }
  }

  function getLatestPrice() public view returns (int256) {
    (, int256 price,,,) = priceFeed.latestRoundData();
    return price;
  }

  function resolveBet() external {
    require(bets[msg.sender].amount > 0, "No bet placed");
    require(!bets[msg.sender].claimed, "Already claimed");

    int256 latestPrice = getLatestPrice();
    Prediction winningPrediction =
      (latestPrice > bets[msg.sender].entryPrice) ? Prediction.Rise : Prediction.Fall;

    uint256 totalWinnersPool =
      (winningPrediction == Prediction.Rise) ? totalRiseBets : totalFallBets;

    uint256 totalLosersPool = totalBetAmount - totalWinnersPool;

    require(totalWinnersPool > 0, "No winners, no payout");

    if (bets[msg.sender].prediction == winningPrediction) {
      uint256 userBet = bets[msg.sender].amount;

      // Calculate proportional winnings (minus commission)
      uint256 userWinnings = (userBet * totalLosersPool) / totalWinnersPool;
      uint256 payout = userBet + (userWinnings * (100 - commissionRate)) / 100;

      (bool success,) = payable(msg.sender).call{ value: payout }("");
      require(success, "Transfer failed");
    }

    bets[msg.sender].claimed = true;
  }

  function withdrawCommission() external {
    require(msg.sender == owner, "Only owner can withdraw");
    uint256 commission = (totalBetAmount * commissionRate) / 100;
    totalBetAmount -= commission;

    (bool success,) = payable(owner).call{ value: commission }("");
    require(success, "Transfer failed");
  }
}
