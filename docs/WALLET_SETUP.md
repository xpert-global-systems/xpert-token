# 🏦 CrossChainAggregator: Wallet & Network Setup Guide

## Which Wallet Do You Need?

You need **ONE wallet address** that will receive all cryptocurrency across multiple chains.

### Recommended Wallets

| Wallet | Best For | Setup Time | Security |
|--------|----------|-----------|----------|
| **MetaMask** | Easiest to use | 5 min | Medium |
| **Ledger Hardware** | Maximum security | 10 min | High |
| **Coinbase Wallet** | Native app | 5 min | Medium |
| **Gnosis Safe** | Team/Multi-sig | 15 min | Very High |

### ✅ Recommended: MetaMask (Free & Easy)
- Same wallet address across ALL chains
- Works with all EVM networks
- Simple interface

---

## 🌐 Which Networks to Add to Your Wallet

Your **CrossChainAggregator** supports receiving assets from these networks:

### **Essential Networks (Already configured in contract)**

| Network | Chain ID | Native Token | Purpose | RPC URL |
|---------|----------|--------------|---------|---------|
| **Ethereum** | 1 | ETH | Send USDC, wBTC, stables | https://eth.rpc.blxrbdn.com |
| **Base** | 8453 | ETH | Send USDbC, AERO | https://mainnet.base.org |
| **Polygon** | 137 | MATIC | Send USDC, USDT | https://polygon-rpc.com |
| **Arbitrum** | 42161 | ETH | Send USDC, ARB | https://arb1.arbitrum.io/rpc |
| **Optimism** | 10 | ETH | Send USDC, OP | https://mainnet.optimism.io |

### **Testing Networks (For development ONLY)**

| Network | Chain ID | Purpose | Faucet | RPC |
|---------|----------|---------|--------|-----|
| **Base Sepolia** | 84532 | Test Base | https://www.baser.org | https://sepolia.base.org |
| **Ethereum Sepolia** | 11155111 | Test Ethereum | https://sepoliafaucet.com | https://rpc.sepolia.org |

---

## 🚀 Step-by-Step: Set Up MetaMask

### **Step 1: Install MetaMask**
1. Go to https://metamask.io/
2. Click "Install MetaMask"
3. Add to your browser
4. Click "Create new wallet"
5. **Save your 12-word seed phrase somewhere safe** ⚠️

### **Step 2: Add Networks to MetaMask**

#### **Add Ethereum Network**
1. Open MetaMask
2. Click network dropdown (top left)
3. Click "Add Network" → "Add network manually"
4. Fill in:
   ```
   Network name: Ethereum
   RPC URL: https://eth.rpc.blxrbdn.com
   Chain ID: 1
   Currency: ETH
   Block Explorer: https://etherscan.io
   ```
5. Save ✅

#### **Add Base Network** (Main deployment)
1. Network dropdown → "Add Network"
2. Fill in:
   ```
   Network name: Base
   RPC URL: https://mainnet.base.org
   Chain ID: 8453
   Currency: ETH
   Block Explorer: https://basescan.org
   ```
3. Save ✅

#### **Add Polygon Network**
1. Network dropdown → "Add Network"
2. Fill in:
   ```
   Network name: Polygon
   RPC URL: https://polygon-rpc.com
   Chain ID: 137
   Currency: MATIC
   Block Explorer: https://polygonscan.com
   ```
3. Save ✅

#### **Add Arbitrum Network**
1. Network dropdown → "Add Network"
2. Fill in:
   ```
   Network name: Arbitrum
   RPC URL: https://arb1.arbitrum.io/rpc
   Chain ID: 42161
   Currency: ETH
   Block Explorer: https://arbiscan.io
   ```
3. Save ✅

#### **Add Optimism Network**
1. Network dropdown → "Add Network"
2. Fill in:
   ```
   Network name: Optimism
   RPC URL: https://mainnet.optimism.io
   Chain ID: 10
   Currency: ETH
   Block Explorer: https://optimistic.etherscan.io
   ```
3. Save ✅

---

## 🧪 Testing Networks (Optional - for development)

### **Add Base Sepolia (Testnet)**
1. Click network dropdown
2. Toggle "Show test networks" ON
3. Select "Base Sepolia" (or add manually)
4. Get test ETH: https://www.baser.org/
5. Paste your wallet address, claim 0.1 ETH

### **Add Ethereum Sepolia (Testnet)**
1. Click network dropdown
2. Toggle "Show test networks" ON
3. Select "Ethereum Sepolia"
4. Get test ETH: https://sepoliafaucet.com/
5. Paste your wallet address, claim 0.5 ETH

---

## 💰 Fund Your Wallet

### **On Mainnet (Real Money)**

**Option 1: From Exchange (Easiest)**
1. Sign up on Coinbase, Kraken, or Binance
2. Buy ETH
3. Send to your MetaMask wallet address
4. It arrives on Ethereum (Chain ID: 1)

**Option 2: Bridge from Ethereum to other chains**
- Ethereum → Base: https://bridge.base.org
- Ethereum → Polygon: https://wallet.polygon.technology/bridge
- Ethereum → Arbitrum: https://bridge.arbitrum.io

### **On Testnet (FREE!)**

**Base Sepolia Testnet:**
1. Go to https://www.baser.org/
2. Paste your wallet address
3. Claim 0.1 testnet ETH ✅

**Ethereum Sepolia Testnet:**
1. Go to https://sepoliafaucet.com/
2. Paste your wallet address
3. Claim 0.5 testnet ETH ✅

---

## 📋 Your Wallet Info

After setup, you should have:

```
Your Wallet Address (Same on ALL networks):
0x1234567890123456789012345678901234567890

✅ Networks Added:
   - Ethereum (1)
   - Base (8453)
   - Polygon (137)
   - Arbitrum (42161)
   - Optimism (10)

✅ Test Networks (Optional):
   - Base Sepolia (84532)
   - Ethereum Sepolia (11155111)
```

---

## 🎯 Deploy Contract on Base

1. Go to https://remix.ethereum.org
2. Create file `CrossChainAggregator.sol`
3. Paste contract code
4. Click Compile (v0.8.20)
5. Click Deploy & Run Transactions
6. Change Environment to "Injected Provider - MetaMask"
7. **Switch MetaMask to Base network**
8. In Constructor, enter:
   ```
   _feeRecipient: 0x1234567890123456789012345678901234567890
   (use your wallet address)
   ```
9. Click Deploy
10. Confirm in MetaMask ✅

---

## 🪙 Token Addresses to Whitelist

### **On Base Mainnet**
```
USDC (Circle): 0x833589fCD6eDb6E08f4c7C32D4f71b1566469c3d
WETH: 0x4200000000000000000000000000000000000006
DAI: 0x50c5725949A6F0c72E6C4a641F14DA7493d45457
```

### **On Ethereum Mainnet**
```
USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7
wBTC: 0x2260FAC5E5542a773Aa44fBCfeDd86b8040F6e4C
WETH: 0xC02aaA39b223FE8D0A0e8e4F27ead9083C756Cc2
```

### **On Polygon Mainnet**
```
USDC: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174
USDT: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F
WETH: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619
WMATIC: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270
```

---

## ✅ Quick Checklist

- [ ] MetaMask installed and wallet created
- [ ] Seed phrase saved securely
- [ ] Ethereum network added
- [ ] Base network added (Primary)
- [ ] Polygon network added
- [ ] Arbitrum network added
- [ ] Optimism network added
- [ ] Wallet funded with ETH
- [ ] Contract deployed on Base
- [ ] Fee recipient address configured

---

## ⚠️ Security Best Practices

1. **Never share your seed phrase** - Anyone with it can steal all your funds
2. **Never share your private key** - Only MetaMask should see this
3. **Test on testnet first** - Use Base Sepolia before mainnet
4. **Keep wallet address public** - Share this for receiving funds
5. **For large amounts, use Ledger Hardware Wallet** - Maximum security
6. **Enable 2FA on connected websites** - Add extra protection

---

## 🔗 Useful Resources

| Resource | Link |
|----------|------|
| MetaMask | https://metamask.io/ |
| Base Mainnet | https://base.org/ |
| BaseScan Explorer | https://basescan.org |
| Base Bridge | https://bridge.base.org |
| Uniswap (Swap) | https://uniswap.org |
| Faucets (Testnet) | https://www.baser.org |

---

## ❓ FAQ

**Q: Do I need different wallets for each network?**  
A: No! One wallet address works on all EVM chains.

**Q: How do I switch networks in MetaMask?**  
A: Click the network dropdown at the top of MetaMask, select your network.

**Q: How do I get ETH on Base?**  
A: Bridge it from Ethereum using https://bridge.base.org

**Q: What's the difference between Mainnet and Testnet?**  
A: Testnet uses fake money (free), Mainnet uses real money (costs gas fees).

**Q: Can I use the same wallet for both test and production?**  
A: Yes, just switch between networks in MetaMask.

**Q: What if I lose my seed phrase?**  
A: You permanently lose access to all funds. Guard it carefully!

---

**Deploy Ready? Start here:**
1. ✅ Set up wallet + networks (this guide)
2. ✅ Deploy contract on Base (Remix)
3. ✅ Whitelist tokens (USDC, wBTC, etc.)
4. ✅ Make test deposit
5. ✅ Check BaseScan for verification
