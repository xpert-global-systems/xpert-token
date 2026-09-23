# Contributing to XPERT Token

Thank you for contributing to XPERT Token, the smart-contract infrastructure for the XPERT Global Systems ecosystem.

This repository contains experimental blockchain software. Contributions must prioritize correctness, security, reproducibility, and clear documentation over speed of delivery.

## Contribution Principles

Every contribution should be:

1. **Secure** — access control, accounting, failure paths, and external calls are tested.
2. **Clear** — behavior, assumptions, governance decisions, and deployment impact are documented.
3. **Auditable** — important state changes emit events and claims are supported by reproducible evidence.
4. **Risk-aware** — no hidden mechanisms, unsupported performance claims, guaranteed-return language, or fabricated audit/deployment status.

Security and transparency take priority over feature velocity.

## Before You Start

1. Read the README and the relevant documentation in `docs/`.
2. Search existing issues and pull requests before starting duplicate work.
3. Open an issue before making material changes to contracts, tokenomics, fees, governance, risk parameters, or deployment procedures.
4. Never commit private keys, seed phrases, API tokens, RPC credentials, or populated environment files.
5. Use Base testnet for development unless a maintainer explicitly authorizes another network.

## Tooling and Local Setup

Use **pnpm** for all TypeScript and JavaScript dependencies. Do not add npm or yarn lockfiles.

Required tooling:

- Node.js 18 or newer
- pnpm
- Foundry for Solidity compilation and testing where configured
- Base testnet credentials for deployment tests only

```bash
git clone https://github.com/xpert-global-systems/xpert-token.git
cd xpert-token
pnpm install
cp .env.example .env
```

Keep `.env` untracked and use testnet credentials only.

Run the checks supported by the repository:

```bash
pnpm run compile
pnpm test
pnpm run test:coverage
pnpm run test:gas
```

For Foundry-based projects:

```bash
forge install
forge build
forge test -vvv
forge test --gas-report
forge coverage
```

If a command is not defined by the repository configuration, do not claim that it passed. Report the unavailable command and the checks you actually ran.

## Branches and Commits

Create a focused branch from the default branch:

```bash
git switch -c feat/short-description
```

Use conventional commits:

- `feat:` — new functionality
- `fix:` — defect correction or vulnerability patch
- `test:` — tests only
- `docs:` — documentation only
- `refactor:` — behavior-preserving restructuring
- `security:` — security hardening
- `chore:` — tooling or dependency maintenance

Keep commits small and avoid mixing unrelated formatting changes with contract behavior changes.

## Smart-Contract Change Requirements

Every contract change must include:

- Unit tests for successful and failing paths
- Access-control tests for privileged functions
- Boundary tests for zero values, maximum values, fee limits, rounding, and decimals
- Reentrancy and external-call review where applicable
- Events for user- or operator-relevant state changes
- NatSpec for public and external interfaces
- Storage-layout or upgradeability impact notes, where applicable
- Updated documentation for changed functions, parameters, roles, and permissions
- Gas comparison when claiming an optimization

Do not assume an OpenZeppelin import makes the surrounding system safe. Review integration logic, authorization, accounting, configuration limits, and external calls.

## Governance and Risk Changes

Changes affecting minting, burning, vault deposits or withdrawals, fees, drawdown limits, pause behavior, signers, or treasury allocation require maintainer review before merge.

The pull request must explain:

- Who can call the changed function
- Which values are permitted
- Whether the change is reversible
- What happens during an emergency
- How the change is tested
- Whether deployment, migration, or multisig procedures must change

Do not describe a parameter as governance-controlled unless the deployed implementation actually enforces that control.

## Testing and Security Evidence

Before opening a pull request:

1. Run the relevant compile and test commands.
2. Run coverage for contract behavior changes.
3. Run fuzz or invariant tests for accounting and authorization logic where available.
4. Run static analysis where configured, such as Slither.
5. Review the diff for secrets, placeholder addresses, incorrect network IDs, and production configuration.
6. Record the exact commands and results in the pull request.

Do not claim that an audit, deployment, verification, or test passed without reproducible evidence in the repository or an authoritative linked source.

## Pull Request Checklist

- [ ] The change has a clear, narrow purpose.
- [ ] An issue exists for material protocol or contract changes.
- [ ] `pnpm install` and relevant `pnpm` checks pass.
- [ ] Foundry checks pass when applicable.
- [ ] Tests cover success, failure, authorization, and boundary cases.
- [ ] No secrets or production credentials are included.
- [ ] Contract addresses and network labels are accurate.
- [ ] Public interfaces and documentation are updated.
- [ ] Gas, storage, and security implications are documented.
- [ ] Deployment and rollback considerations are documented.
- [ ] The pull request makes no unsupported return, safety, or performance guarantees.

Use this structure in the pull request description:

```markdown
## Summary

## Risk and security impact

## Tests run

## Deployment or migration steps

## Rollback or emergency considerations

## Documentation updated
```

## Security Reports

Do not disclose an undisclosed vulnerability in a public issue or pull request. Use the repository's private security contact or GitHub's private vulnerability reporting channel when available.

Include:

- A concise description
- Affected contract, function, and commit
- Reproduction steps or proof of concept
- Impact assessment
- Suggested mitigation, if known

Do not exploit a vulnerability beyond what is necessary to demonstrate it, and do not move real funds during testing.

## Documentation Standards

Documentation must:

- Distinguish implemented behavior from planned behavior
- Identify testnet versus mainnet deployments
- Use exact contract addresses only after verification
- State assumptions, limits, fees, and privileged roles plainly
- Include dates and commit or deployment references where relevant
- Avoid hype, guaranteed outcomes, or unsupported performance claims

Retain the project risk disclosure: smart contracts carry risk, users may lose capital, and past performance does not guarantee future results.

## Review and Merge

Maintainers may request additional tests, threat-model review, deployment rehearsal, or multisig approval. Contract and protocol changes should not be merged solely because they compile or pass a narrow unit test.

A change is ready to merge when the implementation, tests, documentation, security impact, and deployment plan are all reviewable.

## License

By contributing, you agree that your contribution will be licensed under the repository's MIT License.
