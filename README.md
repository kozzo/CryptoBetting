# CryptoBetting

## Overview
CryptoBetting is a decentralized betting platform that allows users to place bets on the rise or fall of cryptocurrency prices using Chainlink Data Feeds for price validation.

## Features
- Secure and verifiable on-chain betting.
- Uses Chainlink Price Feeds to determine outcomes.
- Ensures fair payouts using Solidity best practices.
- Optimized for gas efficiency and security.

## Installation

1. **Clone the repository**
   ```sh
   git clone https://github.com/kozzo/CryptoBetting.git
   cd CryptoBetting
   ```

2. **Install dependencies**
   ```sh
   forge install
   ```

3. **Run tests**
   ```sh
   forge test
   ```

## Deployment

1. **Compile the contract**
   ```sh
   forge build
   ```

2. **Deploy to a testnet (example: Sepolia)**
   ```sh
   forge create --rpc-url YOUR_RPC_URL --private-key YOUR_PRIVATE_KEY src/CryptoBetting.sol:CryptoBetting
   ```

## Security Considerations
- The contract uses `call{value: ...}('')` instead of `transfer()` to handle gas limits safely.
- The betting logic is tested with Foundry.
- Chainlink is used as a trusted oracle.

## Future Improvements
- Implementing a frontend for user interaction.
- Adding support for multiple cryptocurrencies.
- Enabling a decentralized governance mechanism.

## License
MIT License

