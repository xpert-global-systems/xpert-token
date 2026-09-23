# Deployment Guide

This guide covers the operational sequence for deploying XPERT Token infrastructure. Use Base testnet for rehearsal. Mainnet deployment requires completed testing, security review, verified governance approval, and confirmed addresses.

## Prerequisites

- Node.js 18+
- pnpm for TypeScript and JavaScript dependencies
- Foundry where the repository configuration requires it
- Base RPC URLs
- Testnet funds for testnet deployment
- A dedicated deployment account or approved multisig process
- Verified environment configuration with no committed secrets

```bash
pnpm install
cp .env.example .env
```

Never commit `.env`, private keys, seed phrases, or production credentials.

## Pre-deployment Checklist

- [ ] Contracts compile from a clean checkout.
- [ ] Unit, integration, fuzz, and invariant tests pass where configured.
- [ ] Gas and coverage reports are reviewed.
- [ ] Access control and owner/governance handoff are tested.
- [ ] Fee bounds, supply policy, pause behavior, and withdrawal behavior are reviewed.
- [ ] External security review status is documented accurately.
- [ ] Constructor arguments and deployment order are recorded.
- [ ] Multisig signers and threshold are confirmed.
- [ ] Deployment addresses have not been copied from placeholders.

## Testnet Deployment

Use the repository's configured deployment command. Confirm the exact script in `package.json` before running it:

```bash
pnpm run deploy:testnet
```

For Foundry deployments, use a private key supplied through the environment and verify the chain ID before broadcasting.

After deployment:

1. Record transaction hashes and contract addresses.
2. Transfer ownership or governance authority only after verifying the destination.
3. Verify source code on BaseScan.
4. Execute smoke tests for transfers, mint authorization, deposits, withdrawals, governance, and pause controls.
5. Update the address table in the README only with verified values.

## Mainnet Deployment

Do not deploy to mainnet solely because testnet deployment succeeded. Require explicit multisig approval and a documented rollback or emergency response plan. Smart-contract deployments may be irreversible.

## Verification and Records

Each deployment record should include:

- Network and chain ID
- Commit SHA
- Deployer and final owner/governance addresses
- Constructor arguments
- Contract addresses
- Transaction hashes
- Verification links
- Test results and review status

Deployment status is operational information, not a performance claim. Past performance does not guarantee future returns.
