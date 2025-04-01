// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MultiCryptoBetting {
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

  struct CryptoPool {
    address priceFeed;
    uint256 totalBetAmount;
    uint256 totalRiseBets;
    uint256 totalFallBets;
  }

  mapping(string => CryptoPool) public cryptoPools;
  mapping(string => mapping(address => Bet)) public bets;
  mapping(string => address[]) public bettors;

  constructor() {
    owner = msg.sender;
  }

  function addCrypto(string memory symbol, address priceFeed) external {
    require(msg.sender == owner, "Only owner can add cryptos");
    require(cryptoPools[symbol].priceFeed == address(0), "Crypto already exists");
    cryptoPools[symbol] = CryptoPool(priceFeed, 0, 0, 0);
  }

  function placeBet(string memory symbol, Prediction _prediction) external payable {
    require(msg.value > 0, "Bet amount must be greater than 0");
    require(cryptoPools[symbol].priceFeed != address(0), "Invalid crypto");
    require(bets[symbol][msg.sender].amount == 0, "Already placed a bet");

    int256 currentPrice = getLatestPrice(symbol);
    bets[symbol][msg.sender] = Bet(msg.value, _prediction, false, currentPrice);
    bettors[symbol].push(msg.sender);
    cryptoPools[symbol].totalBetAmount += msg.value;

    if (_prediction == Prediction.Rise) {
      cryptoPools[symbol].totalRiseBets += msg.value;
    } else {
      cryptoPools[symbol].totalFallBets += msg.value;
    }
  }

  function getLatestPrice(string memory symbol) public view returns (int256) {
    require(cryptoPools[symbol].priceFeed != address(0), "Invalid crypto");
    (, int256 price,,,) = AggregatorV3Interface(cryptoPools[symbol].priceFeed).latestRoundData();
    return price;
  }

  function resolveBet(string memory symbol) external {
    require(bets[symbol][msg.sender].amount > 0, "No bet placed");
    require(!bets[symbol][msg.sender].claimed, "Already claimed");

    int256 latestPrice = getLatestPrice(symbol);
    Prediction winningPrediction =
      (latestPrice > bets[symbol][msg.sender].entryPrice) ? Prediction.Rise : Prediction.Fall;

    uint256 totalWinnersPool = (winningPrediction == Prediction.Rise)
      ? cryptoPools[symbol].totalRiseBets
      : cryptoPools[symbol].totalFallBets;
    uint256 totalLosersPool = cryptoPools[symbol].totalBetAmount - totalWinnersPool;

    require(totalWinnersPool > 0, "No winners, no payout");

    if (bets[symbol][msg.sender].prediction == winningPrediction) {
      uint256 userBet = bets[symbol][msg.sender].amount;
      uint256 userWinnings = (userBet * totalLosersPool) / totalWinnersPool;
      uint256 payout = userBet + (userWinnings * (100 - commissionRate)) / 100;

      (bool success,) = payable(msg.sender).call{ value: payout }("");
      require(success, "Transfer failed");
    }

    bets[symbol][msg.sender].claimed = true;
  }

  function withdrawCommission(string memory symbol) external {
    require(msg.sender == owner, "Only owner can withdraw");
    uint256 commission = (cryptoPools[symbol].totalBetAmount * commissionRate) / 100;
    cryptoPools[symbol].totalBetAmount -= commission;

    (bool success,) = payable(owner).call{ value: commission }("");
    require(success, "Transfer failed");
  }
}
