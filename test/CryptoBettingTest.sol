// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/CryptoBetting.sol";
import "forge-std/console.sol";

contract CryptoBettingTest is Test {
  MultiCryptoBetting bettingContract;
  address priceFeedETH = 0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f;
  address priceFeedBTC = 0xA39434A63A52E749F02807ae27335515BA4b07F7;

  function setUp() public {
    bettingContract = new MultiCryptoBetting();
    bettingContract.addCrypto("ETH", priceFeedETH);
    bettingContract.addCrypto("BTC", priceFeedBTC);
  }

  function testPlaceBet() public {
    vm.deal(address(this), 1 ether);

    vm.mockCall(
      priceFeedETH,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0) // 50,000 USD
    );

    bettingContract.placeBet{ value: 0.1 ether }("ETH", MultiCryptoBetting.Prediction.Rise);

    (uint256 amount, MultiCryptoBetting.Prediction prediction, bool claimed, int256 entryPrice) =
      bettingContract.bets("ETH", address(this));

    assertEq(amount, 0.1 ether);
    assertEq(uint256(prediction), uint256(MultiCryptoBetting.Prediction.Rise));
    assertEq(claimed, false);
    assertEq(entryPrice, 500000000000);
  }

  function testMockChainlinkPrice() public {
    vm.mockCall(
      priceFeedBTC,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 600000000000, 0, 0, 0) // 60,000 USD
    );

    int256 price = bettingContract.getLatestPrice("BTC");
    console.log(vm.toString(price));
    assertEq(price, 600000000000);
  }

  function testMultipleBetsAndPayouts() public {
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    vm.deal(user1, 1 ether);
    vm.deal(user2, 1 ether);
    vm.deal(user3, 1 ether);

    vm.mockCall(
      priceFeedETH,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 500000000000, 0, 0, 0)
    );

    vm.prank(user1);
    bettingContract.placeBet{ value: 0.5 ether }("ETH", MultiCryptoBetting.Prediction.Rise);

    vm.prank(user2);
    bettingContract.placeBet{ value: 0.3 ether }("ETH", MultiCryptoBetting.Prediction.Rise);

    vm.prank(user3);
    bettingContract.placeBet{ value: 0.5 ether }("ETH", MultiCryptoBetting.Prediction.Fall);

    vm.mockCall(
      priceFeedETH,
      abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
      abi.encode(0, 510000000000, 0, 0, 0)
    );

    vm.prank(user1);
    bettingContract.resolveBet("ETH");

    vm.prank(user2);
    bettingContract.resolveBet("ETH");

    vm.prank(user3);
    bettingContract.resolveBet("ETH");

    uint256 totalLosersPool = 0.5 ether;
    uint256 commission = (totalLosersPool * 5) / 100;
    uint256 distributedWinnings = totalLosersPool - commission;

    uint256 expectedPayout1 = 1 ether + (0.5 ether * distributedWinnings) / 0.8 ether;
    uint256 expectedPayout2 = 1 ether + (0.3 ether * distributedWinnings) / 0.8 ether;
    uint256 expectedPayout3 = 0.5 ether;

    assertApproxEqAbs(user1.balance, expectedPayout1, 0.0001 ether);
    assertApproxEqAbs(user2.balance, expectedPayout2, 0.0001 ether);
    assertApproxEqAbs(user3.balance, expectedPayout3, 0.0001 ether);
  }
}
