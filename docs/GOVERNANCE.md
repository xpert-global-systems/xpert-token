# Governance

## Purpose

Governance is intended to control protocol parameters and emergency actions through an approved multisig or DAO process. Governance authority must be verified against deployed bytecode and configuration; comments and diagrams are not proof of control.

## Intended Scope

Potential governance actions include:

- Updating bounded fee parameters
- Updating risk limits
- Allocating approved treasury funds
- Managing privileged contract ownership
- Activating emergency pause procedures

Governance must not be described as decentralized or multisig-protected until signer membership, threshold, proposal execution, and privileged ownership are independently verified.

## Proposal Requirements

Every material proposal should state:

- Target contract and function
- Encoded parameters
- Reason for the change
- Current and proposed values
- Expected user impact
- Security and accounting impact
- Effective time and reversibility
- Emergency and rollback procedure

## Multisig Controls

The README describes a proposed 3-of-5 signer model. Before relying on it, publish the verified signer set, threshold, transaction history, and any timelock or pause authority. Never publish placeholder addresses as active governance addresses.

## Risk Controls

Fee and risk parameters should have contract-enforced bounds. Governance proposals should be rejected when they exceed those bounds. Emergency controls should be narrowly scoped, event-emitting, and tested for both activation and recovery.

## Transparency

Record executed proposals, parameter changes, signer changes, and emergency actions with transaction links and the repository commit that defines the relevant behavior.

Governance participation does not guarantee protocol safety or financial returns. Past performance does not guarantee future returns.
