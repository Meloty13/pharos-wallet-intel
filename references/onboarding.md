# New Wallet Onboarding Guide

Detects new or empty wallets and guides users through their first steps on
Pharos: getting test tokens and understanding the network.

## When to Use

Activate when:
- Portfolio check reveals native balance = 0 AND nonce = 0
- User asks: "how do I get started on Pharos"
- User asks: "I'm new to Pharos"
- User asks: "how do I get test tokens" / "Pharos faucet"
- User asks: "how do I fund my wallet"
- User asks: "what is the Atlantic testnet"

## Step 1: Confirm wallet state (if address provided)

```bash
BALANCE=$(cast balance <address> --rpc-url https://atlantic.dplabs-internal.com --ether)
NONCE=$(cast nonce <address> --rpc-url https://atlantic.dplabs-internal.com)
```

- If balance > 0 OR nonce > 0: wallet is not new — skip onboarding, run portfolio instead
- If balance = 0 AND nonce = 0: proceed with onboarding guide below

## Step 2: Present onboarding guide

```
## 🚀 Getting Started on Pharos Atlantic Testnet

Your wallet `0x1234...abcd` has no activity yet.
Here's how to go from zero to your first transaction:

---

### 1️⃣  Get test PHRS tokens (the faucet)

Pharos uses PHRS as the native gas token on the Atlantic testnet.
You need PHRS to pay for any transaction.

**Option A — Discord faucet (recommended):**
1. Join the Pharos Discord: https://discord.com/invite/pharos
2. Find the #faucet channel
3. Post your wallet address and request test PHRS

**Option B — Explorer faucet (if available):**
Visit: https://atlantic.pharosscan.xyz
Look for a "Faucet" link in the navigation.

---

### 2️⃣  Verify your balance arrived

Once the faucet sends tokens, ask me:
> "Show my portfolio for 0x<your_address>"

A successful faucet drop will show PHRS > 0 in your portfolio.

---

### 3️⃣  Your first transaction

With PHRS in your wallet, you can send your first transaction.
This requires the base pharos-skill-engine installed alongside this skill.

Ask me:
> "Send 0.001 PHRS to 0x<any_address> on Atlantic testnet"

---

### 4️⃣  Check token approvals

Once active, you can audit what contracts have permission to spend your tokens:
> "Check my token allowances for spender 0x<contract_address>"

---

### Network details for your wallet config

| Field | Value |
|-------|-------|
| Network name | Pharos Atlantic Testnet |
| Chain ID | 688689 |
| RPC URL | https://atlantic.dplabs-internal.com |
| Native token | PHRS |
| Block explorer | https://atlantic.pharosscan.xyz |

Add these to MetaMask or any EVM wallet under "Add Network".

---

**Explorer link:** https://atlantic.pharosscan.xyz/address/<address>
```

## Notes for Agent

- Do NOT attempt to interact with the faucet automatically — it requires Discord
  or a web browser interaction that cannot be automated via cast/forge
- Do NOT suggest sending transactions — wallet has no funds to pay gas
- Do NOT make any on-chain write calls in this flow
- This is a pure information and guidance flow — no commands executed
- If the user does not provide a wallet address, skip the balance/nonce check
  and present the guide directly

### Supported Institutional Wallets

Pharos integrates with major wallet providers for frictionless onboarding:

| Wallet | Users | Type |
|---|---|---|
| **OKX Wallet** | 50M+ | Full Pharos mainnet support (Apr 29, 2026) |
| **Topnod Wallet** | Ant Group | Institutional-grade, Web2-native UX |
| **Any EVM Wallet** | — | Custom RPC: `https://rpc.pharos.xyz` |

OKX Wallet users can participate in exclusive airdrop events directly within the app.
Topnod provides Web2-native onboarding to reduce friction for institutional users.
