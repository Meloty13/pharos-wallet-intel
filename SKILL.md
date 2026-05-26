---
name: pharos-wallet-intel
description: >
  Pharos Wallet Intelligence Skill. Use for any wallet analysis task on Pharos:
  complete portfolio overview (native PHRS/PROS + all known ERC20 tokens),
  token allowance and approval audit (security check on what contracts can spend
  your tokens), or onboarding guidance for new wallets with zero activity.
  Invoke when user mentions: "portfolio", "balances", "wallet overview",
  "token approvals", "allowance check", "approval audit", "is my wallet safe",
  "I'm new to Pharos", "how do I get started", "faucet", or asks to check any
  wallet address on the Pharos network. Defaults to Atlantic testnet.
  All operations are read-only — no transactions executed, no private key needed.
version: 1.0.0
requires:
  anyBins:
    - cast
---

# Pharos Wallet Intelligence Skill

Extended wallet analysis for the Pharos blockchain — portfolio aggregation,
token allowance security auditing, and new-user onboarding. Powered by
Foundry (`cast`) against Pharos network RPC endpoints.

## Prerequisites

1. **Check Foundry is installed:**
   ```bash
   which cast
   ```
   If not found, install immediately:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   source ~/.zshenv && foundryup
   cast --version
   ```
   Do NOT proceed without Foundry.

2. **Check jq is installed:**
   ```bash
   which jq
   ```
   If not found: `sudo apt install jq` or `brew install jq`

3. **No private key required.** All operations are read-only (`cast balance`,
   `cast call`, `cast nonce` only). Users do not need to configure `$PRIVATE_KEY`.

## Network Configuration

Network details are stored in `assets/networks.json`.

- **Default network:** Atlantic testnet (`atlantic-testnet`)
- **Switch to mainnet:** When user says "mainnet", use the `mainnet` entry

```bash
# Read RPC for Atlantic testnet (default)
RPC_URL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .rpcUrl' assets/networks.json)
NATIVE=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .nativeToken' assets/networks.json)
EXPLORER=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .explorerUrl' assets/networks.json)

# Read RPC for mainnet
RPC_URL=$(jq -r '.networks[] | select(.name=="mainnet") | .rpcUrl' assets/networks.json)
```

## Address Validation

Before running ANY command, validate every address provided:
- Must be: `0x` followed by exactly 40 hexadecimal characters
- Pattern: `/^0x[a-fA-F0-9]{40}$/`
- If invalid: respond with "Please provide a valid wallet address
  (0x followed by 40 hex characters)" and stop. Do not proceed.

## Capability Index

| User Need | Reference File |
|-----------|---------------|
| Portfolio / all balances / wallet overview | → `references/portfolio.md` |
| Token allowances / approval audit / security check | → `references/allowance.md` |
| New wallet / onboarding / faucet / getting started | → `references/onboarding.md` |

Load the full reference file for the matched capability before executing.
The reference files contain the exact commands, output format, and error
handling for each operation.

## Quick Command Reference

```bash
# Native balance
cast balance <address> --rpc-url <rpc> --ether

# ERC20 token balance
cast call <token> "balanceOf(address)(uint256)" <address> --rpc-url <rpc>

# Token allowance (how much spender can spend from wallet)
cast call <token> "allowance(address,address)(uint256)" <wallet> <spender> --rpc-url <rpc>

# Transaction count (nonce)
cast nonce <address> --rpc-url <rpc>

# Read token name
cast call <token> "name()(string)" --rpc-url <rpc>
```

## General Error Handling

| Error | Action |
|-------|--------|
| `invalid address` in cast output | Recheck address format, report to user |
| Connection timeout / `connection refused` | Verify RPC URL from `assets/networks.json`, retry once |
| `execution reverted` on a token call | Skip that token, continue with remaining |
| `jq: parse error` | Check that `assets/networks.json` and `assets/tokens.json` exist and are valid JSON |
| Network not recognized | Only `atlantic-testnet` and `mainnet` are supported |

## Security Policy

This skill is **strictly read-only**:
- Only uses: `cast balance`, `cast call` (view functions), `cast nonce`
- Never uses: `cast send`, `forge script`, `--private-key`
- No transactions are broadcast
- No wallet connections initiated
- Safe to run against any address — yours or anyone else's
