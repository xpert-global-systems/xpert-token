# Contributing to XPERT Token

We welcome contributions that strengthen smart contract security, governance, and institutional credibility.

---

## 🎯 Contribution Philosophy

**Every contribution must pass these filters:**

1. **Is it secure?** — Code audited, edge cases handled, no known vulnerabilities
2. **Is it clear?** — Comments explain logic, governance decisions documented, audit trail preserved
3. **Does it maintain trust?** — No hidden mechanisms, transparent fee structures, honest parameter changes

We optimize for **security over speed, transparency over features**.

---

## 📋 Before You Start

### Check Existing Work

```bash
# Search for related issues or PRs
git log --oneline | grep -i "your-topic"
gh issue list --search "your topic"
```

### Discuss Major Changes

Before spending significant time:

1. **Open an issue** to discuss the change
2. **Get feedback** from maintainers (@xpert-org/smart-contracts)
3. **Design** the solution collaboratively
4. **Security review** before implementation

This prevents wasted effort and ensures alignment.

---

## 🔧 Development Workflow

### 1. Fork & Clone

```bash
git clone https://github.com/xpert-global-systems/xpert-token.git
cd xpert-token
git checkout -b feature/your-feature-name
```

### 2. Setup Environment

**Using Foundry (recommended):**

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Copy environment
cp .env.example .env
# Edit .env with your private key, RPC URLs
```

**Using Hardhat (alternative):**

```bash
npm install
cp .env.example .env
# Edit .env
```

### 3. Development

**Code Standards:**
- Follow Solidity style guide (see `.solhint.json`)
- Use type-safe Solidity 0.8.20+
- Add NatSpec comments to all public functions
- Include event logging for all state changes
- No use of deprecated OpenZeppelin functions

**File Structure:**
```
src/
├── XpertToken.sol          # ERC-20 token
├── FounderVault.sol        # Fund mechanics
├── GovernanceDAO.sol       # Multi-sig governance
└── interfaces/
    ├── IERC20.sol
    └── IVault.sol

test/
├── XpertToken.test.sol
├── FounderVault.test.sol
├── GovernanceDAO.test.sol
└── integration/
    └── EndToEnd.test.sol
```

### 4. Testing

**All PRs must include tests.**

```bash
# Run all tests (Foundry)
forge test -v

# Run with gas report
forge test --gas-report

# Run specific test
forge test --match testFunctionName -v

# Run with coverage (if available)
forge coverage

# Hardhat alternative
npm run test
npm run test:coverage
```

**Test File Naming:**
- Contract tests: `ContractName.test.sol`
- Integration tests: `integration/`
- Fuzz tests: Include `fuzz` in name

**Example Test:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/XpertToken.sol";

contract XpertTokenTest is Test {
    XpertToken token;
    address user = address(0x123);
    
    function setUp() public {
        token = new XpertToken(1_000_000_000e18);
    }
    
    function testTransfer() public {
        token.transfer(user, 100e18);
        assertEq(token.balanceOf(user), 100e18);
    }
    
    function testMintOnlyGovernance() public {
        vm.prank(user);
        vm.expectRevert();
        token.governanceMint(user, 100e18);
    }
    
    function testBurn() public {
        token.burn(100e18);
        assertEq(token.totalSupply(), 1_000_000_000e18 - 100e18);
    }
}
```

### 5. Code Quality

```bash
# Lint with solhint (Foundry)
solhint 'src/**/*.sol'

# Format with prettier
prettier --write 'src/**/*.sol' 'test/**/*.sol'

# Hardhat: lint with hardhat-ethers
npm run lint
```

### 6. Security Checks

```bash
# Use Slither for static analysis
slither . --json slither-report.json

# Use Echidna for fuzzing (advanced)
echidna . --config echidna.yaml

# Manual review checklist
# - No reentrancy vulnerabilities
# - No unchecked math (use SafeMath if needed)
# - All public functions have access control
# - State changes emit events
# - No delegate calls to untrusted contracts
```

### 7. Commit Guidelines

**Use conventional commits:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` New contract or function
- `fix:` Bug fix or vulnerability patch
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Test additions
- `chore:` Dependencies, tooling

**Examples:**
```
feat(vault): implement performance fee collection

Add governanceCollectPerformanceFee function to Founder Vault.
- Calculates 20% of profits since last collection
- Updates performance fee high water mark
- Emits PerformanceFeeCollected event
- Multi-sig governance approval required

Closes #142

fix(token): prevent overflow in mint function

Add total supply cap check before minting.
- Revert if mint would exceed 1B token cap
- Add unit test for cap enforcement

Closes #156
```

### 8. Push & Create PR

```bash
git push origin feature/your-feature-name
```

Then create a pull request with the PR template.

---

## 📝 Pull Request Guidelines

### PR Title Format

Follows conventional commits:
```
feat(vault): implement withdrawal mechanism
fix(governance): enforce multi-sig approval
test(token): add fuzz tests for transfer
```

### PR Description

Use the PR template:

```markdown
## What does this PR do?

Brief description of contract changes.

## Why?

Context or motivation.

## Related Issues

Closes #123

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Gas report reviewed
- [ ] Slither analysis clean
- [ ] No breaking changes

## Security Review

- [ ] No reentrancy issues
- [ ] Access controls correct
- [ ] Math safe from overflow
- [ ] Events emitted for state changes

## Gas Impact

[Include gas report]
```

### Review Process

1. **Automated Checks**
   - Tests pass (GitHub Actions)
   - Linting passes
   - Slither analysis runs
   - Gas report generated

2. **Manual Review**
   - Smart contract team review (@xpert-org/smart-contracts)
   - Security team review (@xpert-org/security)
   - Governance review for parameter changes (@xpert-org/governance)

3. **Approval Requirements**
   - Logic: 2 smart contract team approvals
   - Security: 1 security team approval
   - Governance: 1 governance approval (if parameters change)

4. **Merge**
   - Squash commits
   - Use PR title as commit message
   - Delete branch after merge

---

## 🔍 Code Review Checklist

When reviewing PRs, check:

- ✅ **Security**
  - No known vulnerabilities
  - Reentrancy guards present
  - Access controls enforced
  - Math is overflow-safe
  - All state changes emit events

- ✅ **Code Quality**
  - Clear comments and NatSpec
  - No hardcoded values
  - Proper error handling
  - Consistent style

- ✅ **Testing**
  - Unit tests comprehensive
  - Edge cases covered
  - Integration tests pass
  - Gas optimization reasonable

- ✅ **Governance**
  - Multi-sig approval required where needed
  - Parameter changes transparent
  - Event logging complete
  - Audit trail preserved

---

## 🚀 Contribution Areas

### High Priority

1. **Fund Mechanics**
   - Deposit/withdrawal improvements
   - Fee distribution optimization
   - Risk parameter updates

2. **Governance**
   - Enhanced multi-sig logic
   - Parameter change voting
   - Emergency pause mechanism

3. **Security**
   - Audit findings remediation
   - Vulnerability patches
   - Edge case handling

### Medium Priority

1. **Optimization**
   - Gas efficiency improvements
   - Storage layout optimization
   - Batch operations

2. **Features**
   - Staking mechanics
   - Reward distribution
   - Advanced governance

---

## 🐛 Bug Reports

### Report Process

1. **Check existing issues** — Search first
2. **Create detailed issue** using template
3. **Include reproduction steps**
4. **Severity assessment**

### What to Include

```markdown
## Vulnerability Type

- [ ] Reentrancy
- [ ] Access control
- [ ] Overflow/underflow
- [ ] Logic error
- [ ] Other: [explain]

## Description

Clear description of the issue.

## Proof of Concept

[Code or detailed steps to reproduce]

## Impact

How could this be exploited?

## Recommended Fix

How should it be fixed?
```

---

## 📚 Resources

- **Docs:** https://docs.slipmint.io/token
- **OpenZeppelin Docs:** https://docs.openzeppelin.com/
- **Solidity Best Practices:** https://solidity.readthedocs.io/
- **Foundry Book:** https://book.getfoundry.sh/

---

## ❓ Questions?

- **GitHub Issues:** Ask in discussion
- **Discord:** https://discord.gg/xpert-global
- **Email:** support@slipmint.io

---

## 📄 License

By contributing, you agree your code will be MIT licensed.

---

**Thank you for strengthening XPERT Token security! 🙏**
