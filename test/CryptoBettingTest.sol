// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/CryptoBetting.sol";
import "forge-std/console.sol";

contract CryptoBettingTest is Test {
  CryptoBetting bettingContract;
  address priceFeed = 0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f;

  function setUp() public {
    bettingContract = new CryptoBetting(0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f);
  }

  function testPlaceBet() public {
    vm.deal(address(this), 1 ether);

    // Mock Chainlink price feed response
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // 50,000 USD
    );

    bettingContract.placeBet{ value: 0.1 ether }(CryptoBetting.Prediction.Rise);

    (uint256 amount, CryptoBetting.Prediction prediction, bool claimed, int256 entryPrice) =
      bettingContract.bets(address(this));

    assertEq(amount, 0.1 ether);
    assertEq(uint256(prediction), uint256(CryptoBetting.Prediction.Rise));
    assertEq(claimed, false);
    assertEq(entryPrice, 500000000000);
  }

  function testMockChainlinkPrice() public {
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0)
    );

    int256 price = bettingContract.getLatestPrice();
    console.log(vm.toString(price));
    assertEq(price, 500000000000);
  }

  function testMultipleBetsAndPayouts() public {
    // Ensure test accounts have ETH
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    vm.deal(user1, 1 ether);
    vm.deal(user2, 1 ether);
    vm.deal(user3, 1 ether);

    // Mock the Chainlink price feed response (initial price)
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // Price = 50,000 USD
    );

    // Place bets
    vm.prank(user1);
    bettingContract.placeBet{ value: 0.5 ether }(CryptoBetting.Prediction.Rise);

    vm.prank(user2);
    bettingContract.placeBet{ value: 0.3 ether }(CryptoBetting.Prediction.Rise);

    vm.prank(user3);
    bettingContract.placeBet{ value: 0.5 ether }(CryptoBetting.Prediction.Fall);

    // Mock price increase (winners: user1, user2 | loser: user3)
    vm.mockCall(
      priceFeed,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 510000000000, 0, 0, 0) // Price moves to 51,000 USD
    );

    // Resolve bets
    vm.prank(user1);
    bettingContract.resolveBet();

    vm.prank(user2);
    bettingContract.resolveBet();

    vm.prank(user3);
    bettingContract.resolveBet(); // This should do nothing since user3 lost

    // Verify payouts
    uint256 totalLosersPool = 0.5 ether;
    uint256 commission = (totalLosersPool * 5) / 100;
    uint256 distributedWinnings = totalLosersPool - commission; // 0.475 ETH

    uint256 expectedPayout1 = 1 ether + (0.5 ether * distributedWinnings) / 0.8 ether;
    uint256 expectedPayout2 = 1 ether + (0.3 ether * distributedWinnings) / 0.8 ether;
    uint256 expectedPayout3 = 0.5 ether; // Loser had 1 ether, bets 0.5 ether, gets 0, ends up with 0.5 ether

    assertApproxEqAbs(user1.balance, expectedPayout1, 0.0001 ether);
    assertApproxEqAbs(user2.balance, expectedPayout2, 0.0001 ether);
    assertApproxEqAbs(user3.balance, expectedPayout3, 0.0001 ether); // Loser gets 0
  }
}
