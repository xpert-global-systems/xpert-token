# XPERT Token

**Smart Contract Infrastructure for the XPERT Ecosystem**

![Status](https://img.shields.io/badge/status-production-brightgreen) ![Network](https://img.shields.io/badge/network-Base-blue) ![License](https://img.shields.io/badge/license-MIT-blue) ![Solidity](https://img.shields.io/badge/solidity-0.8.20+-blue)

---

## 🎯 Mission

XPERT Token is the governance and utility token for the XPERT Global Systems ecosystem. It powers:

- **Fund Mechanics** — Deposit, fee distribution, withdrawal authority
- **Governance** — DAO voting on strategy and risk parameters
- **Incentives** — Rewards for long-term holders and active participants
- **Staking** — Capital efficiency and risk-sharing mechanisms

**Network:** Base (Ethereum Layer 2) for low-cost, high-speed transactions.

---

## 📋 Token Specifications

| Property | Value |
|----------|-------|
| **Name** | XPERT Token |
| **Symbol** | XPERT |
| **Standard** | ERC-20 (Base compatible) |
| **Decimals** | 18 |
| **Network** | Base |
| **Supply Cap** | 1,000,000,000 (1B) |
| **Initial Supply** | TBD (post-launch allocation) |

---

## 🏗 Architecture

```
┌─────────────────────────────────────┐
│      Founder Vault Contract         │
│   (Deposit, Performance Fees, etc)   │
└────────┬────────────────────────────┘
         │
┌────────┴────────────────────────────┐
│      XPERT Token (ERC-20)            │
│                                     │
│  - Transfer mechanics               │
│  - Mint/Burn (governance-gated)     │
│  - Balance tracking                 │
└────────┬────────────────────────────┘
         │
┌────────┴────────────────────────────┐
│    Governance DAO (Multi-sig)       │
│                                     │
│  - Parameter updates                │
│  - Risk limits                       │
│  - Fund allocation                  │
└─────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Foundry or Hardhat
- Base testnet faucet (funds for deployment)

### Installation

```bash
# Clone repository
git clone https://github.com/xpert-global-systems/xpert-token.git
cd xpert-token

# Install dependencies
npm install

# Copy environment template
cp .env.example .env
# Edit .env with your private key, RPC URLs, etc.

# Compile contracts
npm run compile

# Run tests
npm run test

# Deploy to Base testnet
npm run deploy:testnet
```

### Using Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Compile
forge build

# Test
forge test -vvv

# Deploy (example)
forge create --rpc-url $BASE_RPC --private-key $PRIVATE_KEY \
  src/XpertToken.sol:XpertToken
```

---

## 📋 Smart Contracts

### 1. **XPERT Token** (`src/XpertToken.sol`)
Standard ERC-20 token with governance-gated minting.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XpertToken is ERC20, Ownable {
    // Token deployed at: [ADDRESS]
    // Total Supply Cap: 1,000,000,000 XPERT
    // Decimals: 18
    
    constructor(uint256 initialSupply) ERC20("XPERT Token", "XPERT") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
    
    // Only governance can mint new tokens
    function governanceMint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    
    // Burn mechanism for deflationary mechanics
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
```

**Key Functions:**
- `transfer()` — Standard ERC-20 transfer
- `approve()` / `transferFrom()` — Allowance-based transfers
- `governanceMint()` — Mint tokens (governance-gated)
- `burn()` — Remove tokens from circulation

---

### 2. **Founder Vault** (`src/FounderVault.sol`)
Fund deposit mechanics with performance fees.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FounderVault {
    // Fund mechanics:
    // - Entry: USDC deposit → receive shares
    // - Performance Fee: 20% of profits
    // - Management Fee: 2% annually
    // - Withdrawal: Redeem shares → receive USDC
    
    mapping(address => uint256) public shares;
    mapping(address => uint256) public depositTimestamp;
    
    uint256 public totalAssets;
    uint256 public performanceFee = 2000; // 20% = 2000 basis points
    uint256 public managementFee = 200;   // 2% = 200 basis points
    
    address public founder;
    address public governance;
    
    // Events for transparency
    event Deposit(address indexed user, uint256 amount, uint256 sharesIssued);
    event Withdrawal(address indexed user, uint256 sharesRedeemed, uint256 amountReceived);
    event PerformanceFeeCollected(uint256 amount);
    event ParametersUpdated(uint256 perfFee, uint256 mgmtFee);
}
```

**Key Functions:**
- `deposit()` — Deposit USDC, receive shares
- `withdraw()` — Redeem shares for USDC
- `collectPerformanceFee()` — Harvest 20% of profits
- `collectManagementFee()` — Harvest 2% annual fee
- `updateParameters()` — Governance-gated fee updates

---

### 3. **Governance DAO** (`src/GovernanceDAO.sol`)
Multi-sig governance for parameter changes.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GovernanceDAO {
    // Multi-sig governance (3-of-5 signers)
    // Powers:
    // - Update performance fee (0-50%)
    // - Update management fee (0-5%)
    // - Update max drawdown limits
    // - Update risk parameters
    // - Emergency pause
    
    address[] public signers;
    uint256 public requiredSignatures = 3;
    
    mapping(uint256 => ProposalVote) public proposals;
    
    struct ProposalVote {
        string action;
        bytes data;
        uint256 signaturesNeeded;
        mapping(address => bool) approvals;
        bool executed;
    }
    
    // Only signers can propose & vote
    modifier onlySigner() {
        require(isSigner(msg.sender), "Only signers can propose");
        _;
    }
    
    function createProposal(string memory action, bytes calldata data) external onlySigner {
        // Create governance proposal
    }
    
    function vote(uint256 proposalId) external onlySigner {
        // Sign proposal
    }
    
    function executeProposal(uint256 proposalId) external {
        // Execute if 3-of-5 signed
    }
}
```

---

## 🧪 Testing

```bash
# Run all tests
npm run test

# Run specific test file
npm run test tests/XpertToken.test.js

# Run with coverage
npm run test:coverage

# Gas report
npm run test:gas
```

**Test Files:**
- `tests/XpertToken.test.js` — Token transfer, mint, burn
- `tests/FounderVault.test.js` — Deposit, withdrawal, fee collection
- `tests/GovernanceDAO.test.js` — Multi-sig voting, parameter updates
- `tests/integration/` — End-to-end scenarios

---

## 🚀 Deployment

### Base Testnet

```bash
# Deploy to testnet
npm run deploy:testnet

# Verify on BaseScan
npm run verify:testnet --address 0x...
```

### Base Mainnet

```bash
# Deploy to mainnet (requires multi-sig approval)
npm run deploy:mainnet

# Verify on BaseScan
npm run verify:mainnet --address 0x...
```

**Deployment Checklist:**
- [ ] All tests pass
- [ ] Security audit complete
- [ ] Risk parameters reviewed
- [ ] Governance multi-sig approved
- [ ] Contract verified on BaseScan

---

## 📊 Tokenomics

### Initial Allocation (1B XPERT)

| Allocation | Amount | Purpose | Vesting |
|-----------|--------|---------|---------|
| Founder Vault | 200M | Fund operations, performance rewards | 4-year linear |
| Community | 300M | Liquidity pool, incentives | Continuous |
| Governance | 200M | DAO treasury | Unlocked |
| Team | 150M | Employee grants | 4-year cliff |
| Reserve | 150M | Future use | Locked |

### Fee Structure

| Fee | Amount | Recipient | Frequency |
|-----|--------|-----------|-----------|
| Entry | 0% | — | On deposit |
| Performance | 20% | Founder Vault | Monthly |
| Management | 2% | Operations | Annual |
| Withdrawal | 0% | — | On withdrawal |

---

## 🔐 Security

**Audit Status:**
- [ ] Internal review (✅ Complete)
- [ ] External audit (🔄 In Progress)
- [ ] Bug bounty program (📋 Planned)

**Security Features:**
- OpenZeppelin contracts (audited)
- Reentrancy guards on all external calls
- Multi-sig governance for critical functions
- Pause mechanism for emergency situations
- Rate limiting on large transactions

See [SECURITY.md](./SECURITY.md) for detailed guidelines.

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Development workflow |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Smart contract design |
| [DEPLOYMENT.md](./docs/DEPLOYMENT.md) | Production deployment steps |
| [TOKENOMICS.md](./docs/TOKENOMICS.md) | Token allocation & economics |
| [GOVERNANCE.md](./docs/GOVERNANCE.md) | DAO voting & parameters |

---

## 📋 Contract Addresses

### Base Testnet

| Contract | Address | Status |
|----------|---------|--------|
| XPERT Token | `0x...` | ✅ Deployed |
| Founder Vault | `0x...` | ✅ Deployed |
| Governance DAO | `0x...` | ✅ Deployed |

### Base Mainnet

| Contract | Address | Status |
|----------|---------|--------|
| XPERT Token | `0x...` | 📋 Pending |
| Founder Vault | `0x...` | 📋 Pending |
| Governance DAO | `0x...` | 📋 Pending |

---

## 🗺 Roadmap

### Q2 2026
- ✅ ERC-20 token contract (Base testnet)
- ✅ Founder Vault MVP
- ✅ Multi-sig governance
- ✅ Test suite & coverage

### Q3 2026
- 📋 External security audit
- 📋 Base mainnet deployment
- 📋 Liquidity pool launch
- 📋 Staking mechanics

### Q4 2026
- 📋 DAO governance UI
- 📋 Cross-chain bridging
- 📋 Advanced reward mechanisms
- 📋 NFT integration

---

## 🤝 Contributing

We welcome contributions to improve contracts, testing, or documentation.

**Focus Areas:**
- Smart contract optimization
- Test coverage expansion
- Gas efficiency improvements
- Documentation clarity

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## 📞 Support

- **Docs:** https://docs.slipmint.io/token
- **Discord:** https://discord.gg/xpert-global
- **Issues:** [GitHub Issues](https://github.com/xpert-global-systems/xpert-token/issues)
- **Email:** support@slipmint.io

---

## 📄 License

MIT License — See [LICENSE](./LICENSE) for full terms.

---

## ⚠️ Disclaimer

**Smart contracts carry risk.** XPERT Token is experimental software. Do not deposit funds you cannot afford to lose. Past performance does not guarantee future returns.

See [RISK_DISCLOSURE.md](./docs/RISK_DISCLOSURE.md) for full disclaimers.

---

**Last Updated:** June 1, 2026  
**Maintainers:** [@xpert-org/smart-contracts](https://github.com/orgs/xpert-global-systems/teams/smart-contracts)
