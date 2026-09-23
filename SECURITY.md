# Security

## Status

Security status must be reported factually. An internal review, external audit, bug bounty, or verification should be marked complete only when supporting evidence is available.

## Development Requirements

- Use current, pinned dependencies where practical.
- Review access control, reentrancy, accounting, rounding, and external calls.
- Test privileged and emergency paths.
- Use fuzzing and invariant testing for token and vault accounting where configured.
- Run static analysis and review findings before deployment.
- Keep deployment keys outside the repository and CI logs.

## Reporting a Vulnerability

Do not disclose an undisclosed vulnerability in a public issue or pull request. Use GitHub private vulnerability reporting or the private security contact published by the maintainers.

Include the affected contract and function, commit or deployment address, reproduction steps, impact, and suggested mitigation. Do not move real funds or exploit a vulnerability beyond what is needed to demonstrate the issue.

## Release Gate

A production release should not proceed until tests pass, critical findings are resolved or formally accepted, governance authority is verified, deployment parameters are reviewed, and contract source is verified on the relevant explorer.

Security review does not guarantee safety or returns. Past performance does not guarantee future returns.
