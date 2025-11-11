# Proton Prediction Market Platform

A decentralized prediction market platform built on the Proton (XPR) blockchain, featuring binary Yes/No markets with an on-chain order book trading engine.

## Overview

This platform combines the best features of Polymarket, Kalshi, and PredictIt to create a transparent, low-fee prediction market on the Proton blockchain. Users can create markets, trade on outcomes, and claim winnings - all with full on-chain transparency and non-custodial wallet integration.

## Features

### Smart Contract Features
- **Binary Markets**: Yes/No prediction markets on any topic
- **Central Limit Order Book (CLOB)**: On-chain order matching engine
- **Non-Custodial**: Users maintain full control of funds via Proton WebAuth
- **Minimal Fees**: 0.01% taker fee, 0% maker fee
- **Automated Settlement**: Smart contract handles market resolution and payouts
- **Collateral Management**: Automatic handling of short selling collateral (1 XPR per share)

### Frontend Features
- **Wallet Integration**: Seamless Proton WebAuth connection
- **Markets List**: Browse and filter markets by category and status
- **Order Book Display**: Real-time bid/ask order book visualization
- **Trading Interface**: Place buy/sell orders with limit pricing
- **Portfolio Management**: View positions, balances, and claim winnings
- **Admin Panel**: Create and resolve markets
- **Real-time Updates**: Automatic polling every 5 seconds
- **Mobile Responsive**: Optimized for all screen sizes

## Technology Stack

- **Blockchain**: Proton (XPR Network) - EOSIO-based with WASM smart contracts
- **Smart Contracts**: TypeScript/AssemblyScript using proton-tsc SDK
- **Frontend**: React with TypeScript
- **Wallet**: Proton WebAuth (@proton/web-sdk)
- **Blockchain Interaction**: @proton/js for RPC queries

## Project Structure

```
proton-prediction-market/
├── contracts/                 # Smart contract code
│   ├── assembly/
│   │   ├── tables/           # Data table definitions
│   │   │   ├── market.table.ts
│   │   │   ├── order.table.ts
│   │   │   ├── position.table.ts
│   │   │   ├── balance.table.ts
│   │   │   └── index.ts
│   │   ├── target/           # Compiled WASM output
│   │   │   ├── prediction.contract.wasm
│   │   │   └── prediction.contract.abi
│   │   └── prediction.contract.ts  # Main contract
│   ├── package.json
│   ├── tsconfig.json
│   └── asconfig.json
└── frontend/                  # React frontend
    ├── src/
    │   ├── components/
    │   │   ├── MarketsList.tsx
    │   │   ├── MarketDetail.tsx
    │   │   ├── Portfolio.tsx
    │   │   └── AdminPanel.tsx
    │   ├── App.tsx
    │   └── App.css
    ├── package.json
    └── .env
```

## Smart Contract Architecture

### Data Tables

1. **Markets Table** (`markets`)
   - Stores market questions, categories, expiry times, and resolution status
   - Scoped by contract account

2. **Orders Table** (`orders`)
   - Central limit order book with bids/asks
   - Scoped by market ID for efficient querying

3. **Positions Table** (`positions`)
   - Tracks user holdings of Yes/No shares per market
   - Scoped by user account

4. **Balances Table** (`balances`)
   - Internal ledger for deposited XPR funds
   - Scoped by contract account

### Contract Actions

1. **transfer (notify)** - Deposit XPR tokens into the contract
2. **withdraw** - Withdraw XPR tokens from internal balance
3. **createmkt** - Create a new prediction market (admin only)
4. **placeorder** - Place a buy/sell order for Yes/No shares
5. **cancelorder** - Cancel an open order and refund collateral
6. **resolve** - Resolve a market with Yes/No outcome (admin only)
7. **claim** - Claim winnings from resolved markets
8. **collectfees** - Collect accumulated platform fees (admin only)

### Trading Mechanics

- **Order Matching**: Automatic on-chain matching of compatible bids and asks
- **Collateral System**: 
  - Buyers lock `price × quantity` in XPR
  - Sellers either provide shares or lock 1 XPR per share for short positions
- **Share Creation**: Yes/No shares created on-demand when trades execute
- **Fee Structure**: 0.01% charged to taker, maker receives full amount minus fee
- **Price Discovery**: Market-driven through order book (0-1 XPR per share)

## Setup Instructions

### Prerequisites

- **Node.js v22.x** (recommended for production) or v16.x/v18.x/v20.x
  - Use [nvm](https://github.com/nvm-sh/nvm) to manage Node.js versions
  - For AlmaLinux/RHEL: `gcc-c++`, `make`, `python3`, `openssl-devel` (for native module compilation)
- **npm** (comes with Node.js) or **yarn**
- **Proton testnet account** with XPR tokens
  - Create at https://testnet.protonchain.com

### Smart Contract Setup

1. **Install Node.js 22** (recommended):
```bash
# Using nvm (Node Version Manager)
nvm install 22
nvm use 22
```

2. **Navigate to the contracts directory**:
```bash
cd contracts
```

3. **Install dependencies**:
```bash
npm install
```
This will install `proton-asc` (AssemblyScript compiler), `proton-tsc` (SDK), and other dependencies.

4. **Compile the smart contract**:
```bash
npm run build
```
This runs `proton-asc assembly/prediction.contract.ts --target release` to compile the contract.

5. **Verify the build**:
The compiled WASM and ABI files will be in `assembly/target/`:
- `prediction.contract.wasm` - Compiled WebAssembly binary
- `prediction.contract.abi` - Contract ABI (Application Binary Interface)

### Frontend Setup

1. **Ensure Node.js 22 is active**:
```bash
nvm use 22
node --version  # Should show v22.x.x
```

2. **Navigate to the frontend directory**:
```bash
cd frontend
```

3. **Install dependencies**:
```bash
npm install
```
This will install React, @proton/web-sdk, and other dependencies. The `postinstall` script will automatically apply patches via `patch-package` to fix Node.js 22 compatibility issues.

4. **Configure environment variables**:
Create a `.env` file in the `frontend/` directory with the following:
```env
REACT_APP_PROTON_ENDPOINT=https://testnet.protonchain.com
REACT_APP_CONTRACT_NAME=your-contract-account
REACT_APP_CHAIN_ID=71ee83bcf52142d61019d95f9cc5427ba6a0d7ff8accd9e2088ae2abeaf3d3dd
```
Replace `your-contract-account` with your deployed contract account name.

5. **Start the development server**:
```bash
npm start
```
The app will be available at `http://localhost:3000` and will automatically reload when you make changes.

## Deployment

### Smart Contract Deployment

1. **Create a Proton testnet account**:
   - Visit https://testnet.protonchain.com
   - Create an account and fund it with testnet XPR tokens

2. **Install Proton CLI** (if not already installed):
```bash
npm install -g @proton/cli
```

3. **Deploy the contract**:
```bash
cd contracts
proton contract deploy your-contract-account ./assembly/target/prediction.contract.wasm ./assembly/target/prediction.contract.abi
```
Replace `your-contract-account` with your Proton account name.

4. **Set contract permissions**:
Configure the contract to allow inline actions and set appropriate permissions for admin operations.

### Frontend Deployment

1. **Build the production bundle**:
```bash
cd frontend
npm run build
```
This creates an optimized production build in the `build/` directory.

2. **Deploy to hosting provider**:
   - **Vercel**: `vercel deploy`
   - **Netlify**: Drag and drop the `build/` folder or use Netlify CLI
   - **GitHub Pages**: Push the `build/` folder to a `gh-pages` branch
   - **Any static host**: Upload the contents of the `build/` directory

3. **Configure environment variables** on your hosting provider:
   - `REACT_APP_PROTON_ENDPOINT` - Your Proton RPC endpoint
   - `REACT_APP_CONTRACT_NAME` - Your deployed contract account
   - `REACT_APP_CHAIN_ID` - Proton chain ID

## Usage Guide

### For Traders

1. **Connect Wallet**: Click "Connect Wallet" and authenticate with Proton WebAuth
2. **Deposit Funds**: Transfer XPR to the contract to fund your trading account
3. **Browse Markets**: View available markets and filter by category
4. **Place Orders**: Select a market, choose Yes/No, set price and quantity
5. **Manage Portfolio**: View your positions and available balance
6. **Claim Winnings**: After market resolution, claim payouts for winning shares
7. **Withdraw**: Withdraw XPR from your internal balance back to your wallet

### For Admins

1. **Create Markets**: Use the Admin panel to create new prediction markets
   - Enter question, category, and expiration date
   - Markets become active immediately

2. **Resolve Markets**: After expiry, resolve markets with the correct outcome
   - Select market ID and choose Yes/No outcome
   - Users can then claim winnings

3. **Collect Fees**: Withdraw accumulated platform fees to admin account

## Fee Structure

- **Maker Fee**: 0% (no fee for providing liquidity)
- **Taker Fee**: 0.01% (fee charged when taking liquidity)
- **Withdrawal Fee**: None
- **Market Creation**: Free (admin only)

## Security Considerations

- All funds are held in the smart contract with full transparency
- Users maintain control via their Proton wallet
- No custodial risk - withdraw anytime
- Smart contract handles all collateral and settlement automatically
- Admin actions (create/resolve) require proper authorization

## Future Enhancements

- Trade history and price charts
- Community governance for market creation
- Multi-outcome markets (beyond binary)
- Advanced order types (stop-loss, take-profit)
- Liquidity incentives and market maker rewards
- Mobile app with native wallet integration

## Development Notes

### Node.js Version Compatibility

**Node.js 22 Support (Recommended for Production)**

This project now supports Node.js 22 for both smart contract compilation and frontend builds. Node.js 22 is recommended for production deployments, especially on AlmaLinux systems.

**Smart Contract Build:**
- Uses `proton-asc` compiler (proton-tsc CLI is not available in v0.3.58)
- Builds successfully with Node.js 16, 18, 20, and 22
- Minor deprecation warning from AssemblyScript on Node.js 22 (non-blocking)

**Frontend Build:**
- Requires patch-package to fix @proton/js ESM import compatibility
- Patch automatically applied via postinstall script
- Builds successfully with Node.js 22

**Quick Start with Node.js 22:**
```bash
nvm install 22
nvm use 22

# Smart contract
cd contracts && npm install && npm run build

# Frontend
cd ../frontend && npm install && npm run build
```

**Legacy Node.js 16 Support:**
Node.js 16 is still supported but no longer required. Use nvm to manage Node versions:
```bash
nvm install 16
nvm use 16
```

### AlmaLinux Deployment Requirements

For deploying on AlmaLinux 8/9 with Node.js 22, ensure the following system packages are installed for native module compilation (particularly secp256k1):

```bash
# AlmaLinux 8/9
sudo dnf install -y gcc-c++ make python3 openssl-devel

# Verify installations
gcc --version
make --version
python3 --version
```

These packages are required for building native dependencies during `npm install`.

### AssemblyScript Version

The project uses AssemblyScript v0.18 (required by proton-asc). Do not upgrade to newer versions as they are incompatible.

### Testing

The smart contract should be thoroughly tested on Proton testnet before mainnet deployment:

1. Create test markets with various scenarios
2. Test order matching with multiple users
3. Verify collateral handling for short positions
4. Test market resolution and claiming
5. Verify fee calculations

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly on testnet
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

## Acknowledgments

- Built on the Proton blockchain
- Inspired by Polymarket, Kalshi, and PredictIt
- Uses Proton WebAuth for seamless wallet integration
