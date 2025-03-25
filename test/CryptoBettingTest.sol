// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CryptoBetting.sol";
import "forge-std/console.sol";

contract CryptoBettingTest is Test {
  CryptoBetting bettingContract;
  address priceFeed = 0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f; // Use a mock or a real Chainlink price feed

  function setUp() public {
    bettingContract = new CryptoBetting();
  }

  function testPlaceBet() public {
    vm.deal(address(this), 1 ether); // Ensure we have ETH

    // Mock the Chainlink price feed response before placing a bet
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // Return BTC price of 50,000 USD
    );

    bettingContract.placeBet{ value: 0.1 ether }(CryptoBetting.Prediction.Rise);

    (uint256 amount, CryptoBetting.Prediction prediction, bool claimed, int256 entryPrice) =
      bettingContract.bets(address(this));

    assertEq(amount, 0.1 ether);
    assertEq(uint256(prediction), uint256(CryptoBetting.Prediction.Rise));
    assertEq(claimed, false);
  }

  function testMockChainlinkPrice() public {
    address chainlinkFeed = 0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f;

    // Mock the Chainlink price feed response
    vm.mockCall(
      chainlinkFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // Return BTC price of 50,000 USD
    );

    int256 price = bettingContract.getLatestPrice();
    console.log(vm.toString(price));
    assertEq(price, 500000000000);
  }

  function testMultipleBetsAndPayouts() public {
    // Ensure test accounts have ETH
    address user1 = address(1);
    address user2 = address(2);
    vm.deal(user1, 1 ether);
    vm.deal(user2, 1 ether);

    // Mock the Chainlink price feed response
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // Price = 50,000 USD
    );

    // Place bets
    vm.prank(user1);
    bettingContract.placeBet{ value: 0.5 ether }(CryptoBetting.Prediction.Rise);

    vm.prank(user2);
    bettingContract.placeBet{ value: 0.5 ether }(CryptoBetting.Prediction.Fall);

    // Verify bets are stored
    (uint256 amount1,, bool claimed1,) = bettingContract.bets(user1);
    (uint256 amount2,, bool claimed2,) = bettingContract.bets(user2);
    assertGt(amount1, 0, "User1 bet should be recorded");
    assertGt(amount2, 0, "User2 bet should be recorded");
    assertEq(claimed1, false);
    assertEq(claimed2, false);

    // Mock a new price feed response (simulate price change)
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 510000000000, 0, 0, 0) // Price moves to 51,000 USD
    );

    // Resolve bets as correct users
    vm.prank(user1);
    bettingContract.resolveBet();

    vm.prank(user2);
    bettingContract.resolveBet();

    // Verify payouts
    (,, bool claimedUser1,) = bettingContract.bets(user1);
    assertEq(claimedUser1, true);
    (,, bool claimedUser2,) = bettingContract.bets(user2);
    assertEq(claimedUser2, true);
  }
}
