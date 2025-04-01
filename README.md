# MultiCryptoBetting Smart Contract

## Overview
MultiCryptoBetting is a decentralized betting contract that allows users to place bets on the price movement of cryptocurrencies. Users can bet on whether the price of a specific cryptocurrency will rise or fall based on Chainlink price feeds. The contract distributes winnings proportionally among the winners and takes a small commission on winnings.

## Features
- Supports multiple cryptocurrencies with Chainlink price feeds.
- Users can place bets predicting price movement (rise or fall).
- Bets are resolved based on real-time Chainlink price data.
- Winnings are distributed proportionally among winners.
- The contract owner can withdraw a 5% commission on winnings.

## Prerequisites
To use this contract, you need:
- **Foundry (Forge)** installed ([Installation Guide](https://book.getfoundry.sh/getting-started/installation.html))
- **Chainlink contracts** installed: `forge install smartcontractkit/chainlink`
- **Forge Standard Library** installed: `forge install foundry-rs/forge-std`

## Deployment
### 1. Compile the contract
```sh
forge build
```

### 2. Run tests
```sh
forge test
```

### 3. Deploy the contract
Deploy the contract using `forge script` or any deployment tool of your choice (e.g., Hardhat, Remix, or a custom deployment script).

## Contract Details
### Contract: `MultiCryptoBetting`
#### State Variables
- `owner` - Address of the contract owner.
- `commissionRate` - The percentage of winnings taken as commission (5%).
- `cryptoPools` - A mapping of cryptocurrency symbols to their respective betting pools.
- `bets` - A mapping of user bets by cryptocurrency symbol and user address.
- `bettors` - A list of users who placed bets for each cryptocurrency.

#### Enums
- `Prediction`
  - `Rise`: Predicts that the cryptocurrency price will increase.
  - `Fall`: Predicts that the cryptocurrency price will decrease.

#### Structs
- `Bet`
  - `amount`: The amount of the bet.
  - `prediction`: The user's prediction (Rise or Fall).
  - `claimed`: Whether the bet has been resolved.
  - `entryPrice`: The price at which the bet was placed.
- `CryptoPool`
  - `priceFeed`: Chainlink price feed address for the cryptocurrency.
  - `totalBetAmount`: Total amount bet on the cryptocurrency.
  - `totalRiseBets`: Total amount bet on "Rise".
  - `totalFallBets`: Total amount bet on "Fall".

### Functions
#### `constructor()`
- Sets the contract deployer as the `owner`.

#### `addCrypto(string memory symbol, address priceFeed) external`
- Allows the owner to add a cryptocurrency with its Chainlink price feed.
- **Requirements:**
  - Only callable by the owner.
  - Cannot add a cryptocurrency that already exists.

#### `placeBet(string memory symbol, Prediction _prediction) external payable`
- Allows users to place a bet on a given cryptocurrency.
- **Requirements:**
  - The bet amount must be greater than 0.
  - The cryptocurrency must be registered.
  - Users cannot place multiple bets on the same cryptocurrency.

#### `getLatestPrice(string memory symbol) public view returns (int256)`
- Fetches the latest price of a given cryptocurrency from Chainlink price feeds.

#### `resolveBet(string memory symbol) external`
- Determines the outcome of a user's bet based on the latest price.
- Winners receive payouts proportional to their bet size.
- **Requirements:**
  - The user must have placed a bet.
  - The bet must not have been claimed already.
  - There must be at least one winner.

#### `withdrawCommission(string memory symbol) external`
- Allows the owner to withdraw the commission earned from bets.
- **Requirements:**
  - Only callable by the owner.

## Example Usage
### Adding a cryptocurrency
```solidity
multiCryptoBetting.addCrypto("ETH", 0xe7656e23fE8077D438aEfbec2fAbDf2D8e070C4f);
```

### Placing a bet
```solidity
multiCryptoBetting.placeBet{value: 1 ether}("ETH", Prediction.Rise);
```

### Resolving a bet
```solidity
multiCryptoBetting.resolveBet("ETH");
```

### Withdrawing commission
```solidity
multiCryptoBetting.withdrawCommission("ETH");
```

## Security Considerations
- **Reentrancy Protection:** The contract ensures that no external calls are made before updating state variables.
- **Access Control:** Only the contract owner can add cryptocurrencies and withdraw commissions.
- **Fair Bet Resolution:** Bets are resolved using Chainlink's decentralized and tamper-proof price feeds.

## License
This project is licensed under the MIT License.

