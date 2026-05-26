# Pharos Wallet Intelligence Skill

> A wallet analysis skill for the [Pharos Agent Center](https://www.pharos.xyz/agent-center).
> Portfolio overview, token approval auditing, and new-user onboarding —
> built on Foundry (`cast`) following the official `pharos-skill-engine-0.1.0` architecture.

## What It Does

| Capability | Example phrases |
|------------|----------------|
| **Portfolio overview** | "show my portfolio for 0x...", "what tokens do I hold on Pharos", "check all my balances" |
| **Allowance audit** | "check my token approvals", "what allowances have I set for 0x...", "is my wallet safe" |
| **Onboarding guidance** | "I'm new to Pharos", "how do I get test tokens", "how do I get started on Pharos" |

All operations are **read-only** — no transactions, no private key required.

---

## Prerequisites

Install these once. They are required for the skill to run.

**1. Foundry** (provides the `cast` command):
```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.zshenv && foundryup
cast --version   # should print: cast Version: x.x.x
```

**2. jq** (JSON parser — reads network and token config):
```bash
# Ubuntu / Debian / WSL:
sudo apt install jq

# macOS:
brew install jq

jq --version   # should print: jq-1.x
```

---

## Installation

**Step 1: Clone the skill**
```bash
git clone https://github.com/YOUR_USERNAME/pharos-wallet-intel.git
cd pharos-wallet-intel
```

**Step 2: Verify it works** (run this before installing into any agent):
```bash
cast balance 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045 \
  --rpc-url https://atlantic.dplabs-internal.com --ether
# Expected output: a number like 0.277843753174938036
# If you see a number, the RPC is live and cast is working correctly.
```

**Step 3: Install into your agent**

Choose the framework you use:

```bash
# Claude Code:
mkdir -p ~/.claude/skills/pharos-wallet-intel
cp -r . ~/.claude/skills/pharos-wallet-intel/

# OpenClaw:
mkdir -p ~/.openclaw/skills/pharos-wallet-intel
cp -r . ~/.openclaw/skills/pharos-wallet-intel/

# Codex:
mkdir -p ~/.codex/skills/pharos-wallet-intel
cp -r . ~/.codex/skills/pharos-wallet-intel/
```

**Step 4: Start your agent and talk to it**

```
"Show my portfolio for 0x<your_wallet_address>"
```

The agent reads `SKILL.md`, runs the `cast` commands automatically, and
returns a formatted result. You never touch the commands directly.

---

## Usage Examples

Once installed, just ask your agent in plain English:

### Portfolio
```
"Show my portfolio for 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
"What tokens does 0x1234...abcd hold on Pharos?"
"Check all balances for 0x... on mainnet"
```

### Allowance Audit
```
"Check token allowances for wallet 0xABCD... spender 0xDEF0..."
"Did I approve any contracts to spend my USDC?"
"Is wallet 0x... safe — check all approvals for spender 0x..."
```

### Onboarding
```
"I'm new to Pharos, how do I get started?"
"How do I get test PHRS tokens?"
"What is the Atlantic testnet?"
```

### What the agent does behind the scenes

When you ask "show my portfolio for 0x1234...":

```
Agent reads SKILL.md → loads references/portfolio.md
Runs: cast balance 0x1234... --rpc-url https://atlantic.dplabs-internal.com --ether
Runs: cast call 0xE0BE... "balanceOf(address)(uint256)" 0x1234... --rpc-url ...
      (repeated for all 5 known tokens)
Runs: cast nonce 0x1234... --rpc-url ...

Returns a formatted portfolio table — you never see the raw commands.
```

---

## Network Support

| Network | Chain ID | Native Token | RPC URL |
|---------|----------|-------------|---------|
| **Atlantic Testnet** (default) | 688689 | PHRS | https://atlantic.dplabs-internal.com |
| Pacific Ocean Mainnet | 1672 | PROS | https://rpc.pharos.xyz |

Specify mainnet by saying "on mainnet" in your request. Defaults to Atlantic testnet.

---

## Known Token Addresses

### Atlantic Testnet (Chain 688689)
| Symbol | Address | Decimals |
|--------|---------|----------|
| USDC | `0xE0BE08c77f415F577A1B3A9aD7a1Df1479564ec8` | 6 |
| USDT | `0xE7E84B8B4f39C507499c40B4ac199B050e2882d5` | 6 |
| WBTC | `0x0c64F03EEa5c30946D5c55B4b532D08ad74638a4` | 18 |
| WETH | `0x7d211F77525ea39A0592794f793cC1036eEaccD5` | 18 |
| WPHRS | `0x838800b758277CC111B2d48Ab01e5E164f8E9471` | 18 |

### Mainnet (Chain 1672)
| Symbol | Address | Decimals |
|--------|---------|----------|
| WPROS | `0x52c48d4213107b20bc583832b0d951fb9ca8f0b0` | 18 |
| USDC | `0xc879c018db60520f4355c26ed1a6d572cdac1815` | 6 |
| LINK | `0x51e2A24742Db77604B881d6781Ee16B5b8fcBE29` | 18 |
| WETH | `0x1f4b7011Ee3d53969bb67F59428a9ec0477856E9` | 18 |

To track additional tokens, add an entry to `assets/tokens.json` and the skill
picks it up automatically — no code changes needed.

---

## File Structure

```
pharos-wallet-intel/
├── SKILL.md                  ← Agent instruction file (loaded automatically)
├── assets/
│   ├── networks.json         ← RPC endpoints, chain IDs, explorer URLs
│   └── tokens.json           ← Deployed token contract addresses (real, verified)
├── references/
│   ├── portfolio.md          ← Portfolio aggregation: commands + output format
│   ├── allowance.md          ← Token allowance audit: commands + output format
│   └── onboarding.md         ← New wallet guidance flow
└── README.md
```

Follows the exact `SKILL.md` + `assets/` + `references/` structure of the
official [`pharos-skill-engine-0.1.0`](https://www.pharos.xyz/agent-center).

---

## Security

This skill is strictly read-only:
- Only uses `cast balance`, `cast call` (view functions), `cast nonce`
- Never broadcasts transactions
- Never accesses or requests a private key
- Safe to run against any address

---

## Dependencies

| Tool | Purpose | Required |
|------|---------|---------|
| `cast` (Foundry) | EVM queries via RPC | Yes |
| `jq` | Read JSON config files | Yes |
| Pharos RPC | Live network data | Auto (from `networks.json`) |

No npm packages. No Python. No API keys.

---

## License

MIT
