---
title: Pharos Wallet Intelligence
description: Extended, strictly read-only wallet analysis skill for Pharos. Portfolio aggregation, transaction history, Wallet Health Score (5-axis risk grading), onboarding guidance, RealFi context, and ecosystem discovery. No private key required.
triggers:
  - show my portfolio
  - what's in my wallet
  - wallet balance for 0x
  - show my transactions
  - recent activity for 0x
  - score my wallet
  - wallet health
  - wallet health check
  - risk assessment
  - is my wallet safe
  - wallet grade
  - I'm new to Pharos
  - how do I get test tokens
  - explain my RealFi assets
  - what can I do with this token
  - what DeFi protocols exist
  - what protocols are on Pharos
  - show me RealFi opportunities
  - how do AI agents work on Pharos
  - what is agent coordination
  - explain x402 protocol
---

# Pharos Wallet Intelligence — SKILL.md

## Capability Index

| User Intent | Reference File |
|---|---|
| Portfolio overview (all tokens) | → `references/portfolio.md` |
| Transaction history | → `references/history.md` |
| Wallet health score / risk assessment | → `references/risk-score.md` |
| AI Agent / RWA coordination context | → `references/ai-rwa.md` |
| Onboarding (empty wallet, new user) | → `references/onboarding.md` |
| RealFi asset explanation | → `references/realfi.md` |
| Ecosystem discovery | → `references/discover.md` |
| Single balance query (not aggregated) | Use base `cast balance` directly |

## Network Configuration

Load `assets/networks.json` for:
- RPC URLs (Atlantic Testnet + Pacific Ocean Mainnet)
- Chain IDs (688689 / 1672)
- Explorer URLs (PharosScan)
- Native token symbols (PHRS / PROS)

## Token Registry

Load `assets/tokens.json` for:
- All known ERC20 addresses per network
- Decimals per token
- Symbol mappings

## Ecosystem Data

Load `assets/ecosystem.json` for:
- RealFi Alliance partner statuses
- Bridge infrastructure (LI.FI, LayerZero, Circle CCTP)
- Analytics sources (Dune, PharosScan)
- Incubator and funding information

## Automation

Use `scripts/analyze-wallet.sh` for one-command portfolio aggregation:
```bash
./scripts/analyze-wallet.sh <address> [atlantic-testnet|mainnet]
```

## Examples

See `assets/examples.md` for three wallet archetypes:
1. Active Developer Wallet (A grade)
2. Dormant Whale (D grade)
3. New Wallet (onboarding flow)

## Security & Constraints

- **Read-only**: No private keys, no transactions, no state changes
- **Agent-native**: Designed for AI agent invocation via trigger phrases
- **RealFi-aware**: Flags stablecoin depegging, liquidity drought, NAV staleness risks
- **Cross-chain aware**: Detects CCTP, LI.FI, LayerZero patterns

## Version

v2.0 — May 2026
