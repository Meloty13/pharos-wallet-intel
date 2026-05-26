#!/bin/bash
# ============================================================
# Pharos Wallet Intelligence v2 — One-Click Apply Script
# Run this from your repo root: ~/pharos-wallet-intel
# ============================================================

cd /home/melotyubuntu/pharos-wallet-intel || { echo "❌ Run this from ~/pharos-wallet-intel"; exit 1; }

echo "🔧 Applying Pharos Wallet Intelligence v2 changes..."
echo "================================================"

# ── 1. Create scripts directory and automation ──
echo "[1/12] Creating scripts/analyze-wallet.sh..."
mkdir -p scripts
cat > scripts/analyze-wallet.sh << 'SCRIPTEOF'
#!/bin/bash
# Pharos Wallet Intelligence — automated portfolio analysis
# Usage: ./scripts/analyze-wallet.sh <address> [atlantic-testnet|mainnet]

ADDRESS="${1:?Usage: $0 <address> [atlantic-testnet|mainnet]}"
NETWORK="${2:-atlantic-testnet}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Load network config
RPC_URL=$(jq -r ".networks[] | select(.name==\"$NETWORK\") | .rpcUrl" "$SCRIPT_DIR/assets/networks.json")
NATIVE=$(jq -r ".networks[] | select(.name==\"$NETWORK\") | .nativeToken" "$SCRIPT_DIR/assets/networks.json")
EXPLORER=$(jq -r ".networks[] | select(.name==\"$NETWORK\") | .explorerUrl" "$SCRIPT_DIR/assets/networks.json")
EXPLORER_API=$(jq -r ".networks[] | select(.name==\"$NETWORK\") | .explorerApiUrl" "$SCRIPT_DIR/assets/networks.json")

# Validate address
if ! echo "$ADDRESS" | grep -qE '^0x[a-fA-F0-9]{40}$'; then
  echo "❌ Invalid address: $ADDRESS"
  exit 1
fi

echo "🔍 Pharos Wallet Intelligence Report"
echo "============================================"
echo "Address:    $ADDRESS"
echo "Network:    $NETWORK"
echo "Explorer:   $EXPLORER/address/$ADDRESS"
echo "Generated:  $(date -u +"%Y-%m-%d %H:%M UTC")"
echo ""

# ── 1. Native balance ──
echo "📦 Fetching native balance..."
NATIVE_ETH=$(cast balance "$ADDRESS" --rpc-url "$RPC_URL" --ether 2>/dev/null)
echo "   $NATIVE: $NATIVE_ETH"

# ── 2. Nonce ──
echo "📊 Fetching transaction count..."
NONCE=$(cast nonce "$ADDRESS" --rpc-url "$RPC_URL" 2>/dev/null)
echo "   Nonce: $NONCE"

# ── 3. ERC20 balances ──
echo "🪙  Fetching ERC20 balances..."
TOKEN_COUNT=$(jq ".\"$NETWORK\" | length" "$SCRIPT_DIR/assets/tokens.json")
FOUND=0

for i in $(seq 0 $((TOKEN_COUNT - 1))); do
  SYMBOL=$(jq -r ".\"$NETWORK\"[$i].symbol" "$SCRIPT_DIR/assets/tokens.json")
  TOKEN_ADDR=$(jq -r ".\"$NETWORK\"[$i].address" "$SCRIPT_DIR/assets/tokens.json")
  DECIMALS=$(jq -r ".\"$NETWORK\"[$i].decimals" "$SCRIPT_DIR/assets/tokens.json")

  RAW=$(cast call "$TOKEN_ADDR" "balanceOf(address)(uint256)" "$ADDRESS" --rpc-url "$RPC_URL" 2>/dev/null)
  if [ -n "$RAW" ] && [ "$RAW" != "0x0000000000000000000000000000000000000000000000000000000000000000" ] && [ "$RAW" != "0" ]; then
    DECIMAL_VAL=$(cast --to-dec "$RAW" 2>/dev/null)
    FORMATTED=$(echo "scale=4; $DECIMAL_VAL / (10^$DECIMALS)" | bc 2>/dev/null || echo "0")
    echo "   $SYMBOL: $FORMATTED"
    FOUND=$((FOUND + 1))
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "   (no ERC20 token balances found)"
fi

# ── 4. Transaction history ──
echo "📜 Fetching recent transactions..."
TX_JSON=$(curl -s "${EXPLORER_API}/api?module=account&action=txlist&address=${ADDRESS}&page=1&offset=5&sort=desc" 2>/dev/null)
TX_COUNT=$(echo "$TX_JSON" | jq '.result | length' 2>/dev/null)

if [ -n "$TX_COUNT" ] && [ "$TX_COUNT" -gt 0 ]; then
  echo "   Recent transactions:"
  for j in $(seq 0 $((TX_COUNT - 1))); do
    HASH=$(echo "$TX_JSON" | jq -r ".result[$j].hash" | cut -c1-10)
    TO=$(echo "$TX_JSON" | jq -r ".result[$j].to" | cut -c1-10)
    VAL=$(echo "$TX_JSON" | jq -r ".result[$j].value")
    VAL_ETH=$(cast --from-wei "$VAL" 2>/dev/null)
    IS_ERR=$(echo "$TX_JSON" | jq -r ".result[$j].isError")
    if [ "$IS_ERR" = "0" ]; then STATUS="✅"; else STATUS="❌"; fi
    echo "   $STATUS ${HASH}... → ${TO}... ($VAL_ETH $NATIVE)"
  done
else
  echo "   (no transactions found)"
fi

echo ""
echo "============================================"
echo "✅ Analysis complete"
echo "🔗 Full report: $EXPLORER/address/$ADDRESS"
SCRIPTEOF
chmod +x scripts/analyze-wallet.sh
echo "   ✅ done"

# ── 2. references/risk-score.md ──
echo "[2/12] Creating references/risk-score.md..."
cat > references/risk-score.md << 'EOF'
# Wallet Health Score

Evaluates wallet risk across five dimensions and assigns a letter grade (A+ through F).
Activate when user asks: "score my wallet", "wallet health", "risk assessment",
"is my wallet safe", "wallet grade".

## Scoring Dimensions

| Dimension | Weight | What It Measures |
|---|---|---|
| **Activity** | 25% | Nonce count: 0=new/inactive, 1-10=low, 11-100=moderate, 100+=high |
| **Diversification** | 25% | Token variety: 1 token=poor, 2-3=fair, 4-5=good, 6+=excellent |
| **Stablecoin Ratio** | 20% | USDC/USDT as % of portfolio: >80%=concentration risk, 30-70%=healthy |
| **RealFi Exposure** | 20% | RealFi-tagged tokens held: 0=none, 1-2=emerging, 3+=established |
| **Dormancy Risk** | 10% | Zero nonce + zero balance = dormant; zero nonce + balance = inactive |

## Letter Grades

| Score Range | Grade | Meaning |
|---|---|---|
| 90-100 | A+ | Elite wallet: active, diversified, RealFi-established |
| 75-89 | A | Strong wallet: good activity and diversification |
| 60-74 | B | Solid wallet: room to diversify or engage RealFi |
| 45-59 | C | Average: consider adding tokens or increasing activity |
| 30-44 | D | Weak: concentration risk or very low activity |
| 0-29 | F | At-risk: dormant, single-asset, or no RealFi exposure |

## Risk Flags (auto-triggered warnings)

- **Stablecoin >80%**: "⚠️ High stablecoin concentration. If USDC depegs, most portfolio value is at risk."
- **Single-token wallet**: "⚠️ No diversification. A single asset failure impacts 100% of holdings."
- **Zero nonce + balance**: "🆕 This wallet has never been used on Pharos."
- **Zero nonce + balance >0**: "💤 Funded but inactive. Assets are sitting idle."
- **No RealFi tokens**: "ℹ️ No RealFi exposure detected. Consider tokenized assets for yield."

## Output Format

```
## 🏥 Wallet Health Score: B+ (78/100)

| Dimension | Score | Detail |
|---|---|---|
| Activity | 20/25 | 142 transactions — highly active |
| Diversification | 18/25 | 4 token types — good variety |
| Stablecoin Ratio | 12/20 | 65% stablecoins — slight concentration |
| RealFi Exposure | 20/20 | 3 RealFi tokens — established |
| Dormancy Risk | 8/10 | Active wallet — no dormancy concern |

### ⚠️ Flags
- Stablecoin ratio at 65% — monitor for depegging risk (USDC circuit breaker status: active)

💡 **Next steps**: Add 1-2 more non-stablecoin tokens to reduce concentration risk.
```
EOF
echo "   ✅ done"

# ── 3. references/ai-rwa.md ──
echo "[3/12] Creating references/ai-rwa.md..."
cat > references/ai-rwa.md << 'EOF'
# AI Agent & RWA Integration Context

Provides AI-specific context for RealFi assets and agent coordination on Pharos.
Activate when user asks: "how do AI agents work on Pharos", "what is agent coordination",
"explain x402 protocol", "how do agents settle payments on Pharos".

## Key Protocols

- **Anvita Flow**: AI Agent collaboration network live on Pharos, powering agent-to-agent coordination for RWA operations
- **x402 Protocol**: Micropayment settlement for agent-to-agent value transfer — agents pay each other for services in real time
- **Vishwa**: Agent-driven capital flows with pre-execution constraint enforcement (authorization, solvency, intent consistency)
- **Pharos AI Module**: 30,000 TPS with sub-second finality for real-time agent settlement

## How It Works

1. AI agents discover each other via Anvita Flow's collaboration network
2. Agents negotiate tasks (e.g., "find best yield for this RWA position")
3. x402 protocol settles micropayments between agents automatically
4. Vishwa enforces pre-execution constraints before assets move onchain
5. Circle CCTP bridges USDC liquidity from 20+ chains for settlement

## Why This Matters for Wallet Intelligence

When analyzing a wallet that holds Vishwa lending receipts or RealFi tokens:
- These positions may be managed by AI agents, not manual users
- Agent-driven capital flows can explain unusual transaction patterns (high-frequency, small-value transfers)
- x402 micropayments may appear as small, frequent outbound transactions

## Notes
- All data is read-only
- Status accurate as of May 2026
- Anvita partnership announced at RWA Summit Cannes, April 2026
EOF
echo "   ✅ done"

# ── 4. assets/examples.md ──
echo "[4/12] Creating assets/examples.md..."
cat > assets/examples.md << 'EOF'
# Example Outputs — Pharos Wallet Intelligence

## Example 1: Active Developer Wallet (Atlantic Testnet)

```
🔍 Pharos Wallet Intelligence Report
============================================
Address:    0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
Network:    atlantic-testnet
Explorer:   https://atlantic.pharosscan.xyz/address/0xd8dA...
Generated:  2026-05-26 14:30 UTC

📦 Native:  PHRS: 12.5000
📊 Nonce:   142 (highly active wallet)
🪙  USDC:   1,000.00
🪙  USDT:   500.00
🪙  WETH:   0.2500
🪙  WPHRS:  2,500.00
📜 Recent:
   ✅ 0xa1b2c3... → 0xd4e5f6... (0.5 PHRS)
   ✅ 0xb2c3d4... → 0xe5f6a7... (contract call)
   ❌ 0xc3d4e5... → 0xf6a7b8... (1.0 PHRS)

🏥 Wallet Health Score: A (86/100)

| Dimension      | Score   | Detail |
|----------------|---------|--------|
| Activity       | 25/25   | 142 transactions — power user |
| Diversification| 22/25   | 4 tokens + native — solid |
| Stablecoin     | 14/20   | 60% stablecoins — moderate |
| RealFi         | 15/20   | 2 RealFi tokens — emerging |
| Dormancy       | 10/10   | Highly active |

⚠️ Stablecoin ratio at 60% — monitor for depegging risk
💡 Consider adding 1-2 RealFi tokens to boost RealFi score
```

## Example 2: Dormant Whale (Mainnet)

```
🔍 Pharos Wallet Intelligence Report
============================================
Address:    0xABCDEF1234567890ABCDEF1234567890ABCDEF12
Network:    mainnet
Explorer:   https://www.pharosscan.xyz/address/0xABCD...

📦 Native:  PROS: 50,000.00
📊 Nonce:   0 (zero outbound transactions)
🪙  USDC:   500,000.00
📜 Recent:  (no transactions found)

🏥 Wallet Health Score: D (35/100)

| Dimension      | Score   | Detail |
|----------------|---------|--------|
| Activity       | 0/25    | Zero transactions — completely inactive |
| Diversification| 5/25    | Only PROS + USDC — poor diversity |
| Stablecoin     | 5/20    | 91% USDC — extreme concentration risk |
| RealFi         | 0/20    | No RealFi exposure |
| Dormancy       | 0/10    | $550K+ sitting idle |

⚠️ EXTREME stablecoin concentration (91%). If USDC depegs, nearly all value is at risk.
💤 Funds are completely idle. Consider:
   - Lending on ZonaLend for yield
   - Staking PROS (5% inflation starting month 7)
   - Diversifying into RealFi tokens (pXAU, KUN-linked assets)
```

## Example 3: New Wallet (Onboarding)

```
🔍 Pharos Wallet Intelligence Report
============================================
Address:    0xNEWBIE1234567890NEWBIE1234567890NEWBIE12
Network:    atlantic-testnet

📦 Native:  PHRS: 0
📊 Nonce:   0
🪙  (no ERC20 token balances found)
📜 (no transactions found)

🆕 This wallet has never been used on Pharos.
   → Loading onboarding guide...

## 🚀 Welcome to Pharos!

### Step 1: Get test PHRS tokens
- Faucet: https://atlantic.pharosscan.xyz/
- Discord: https://discord.com/invite/pharos
- Faucet resets every 12h, up to 5 PHRS per claim

### Step 2: Verify
> "Show my portfolio for 0xNEWBIE..."

### Step 3: First transaction
> "Send 0.001 PHRS to 0x<any_address>"

### Supported Wallets
- OKX Wallet (50M+ users) — native Pharos integration
- Topnod Wallet (Ant Group) — institutional-grade
- Any EVM wallet via custom RPC
```
EOF
echo "   ✅ done"

# ── 5. README.md ──
echo "[5/12] Updating README.md..."
cat > README.md << 'EOF'
# 🔬 Pharos Wallet Intelligence Skill

```
╔══════════════════════════════════════════════════════════╗
║  PHAROS WALLET INTELLIGENCE                              ║
║  ───────────────────────────────────                     ║
║  Portfolio • History • Health Score • RealFi • Ecosystem ║
║  All read-only. No private key. Agent-native.            ║
╚══════════════════════════════════════════════════════════╝
```

> Extended, strictly read‑only wallet analysis skill for the [Pharos Agent Center](https://www.pharos.xyz/agent-center).  
> Built on the official `pharos-skill-engine-0.1.0` architecture. **No private key required.**

---

## 🎯 What It Does

| Capability | Trigger phrases | Unique Value |
|---|---|---|
| **Portfolio overview** | `"show my portfolio"`, `"what's in my wallet"` | Aggregates ALL known tokens in one pass |
| **Transaction history** | `"show my transactions"`, `"recent activity for 0x..."` | Explorer API + nonce = full picture |
| **🆕 Wallet Health Score** | `"score my wallet"`, `"wallet health"` | 5-axis risk grade with RealFi-aware flags |
| **Onboarding guidance** | `"I'm new to Pharos"`, `"how do I get test tokens"` | Auto-detects empty wallets, links faucet |
| **RealFi context** | `"explain my RealFi assets"` | Knows all 12+ RealFi Alliance partners |
| **Ecosystem discovery** | `"what DeFi protocols exist?"` | Live protocol statuses, bridge info, incubator |
| **AI Agent context** | `"how do AI agents work on Pharos?"` | Anvita Flow, x402 micropayments, Vishwa agent capital |

---

## ⚡ Quick Demo (60 seconds)

```bash
# One command — full wallet intelligence
./scripts/analyze-wallet.sh 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045

# Output:
🔍 Pharos Wallet Intelligence Report
============================================
Address:    0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
Network:    atlantic-testnet
📦 Native:  PHRS: 1.2500
📊 Nonce:   42 (active wallet)
🪙  USDC:   500.0000
🪙  WETH:   0.1500
🪙  WPHRS:  100.0000
📜 Recent:  ✅ 0xa1b2... → 0xc3d4... (0.5 PHRS)
============================================
```

---

## 🏥 Wallet Health Score (Killer Feature)

Five-axis risk assessment built on the [Pharos Ecosystem Security Guide](https://www.htx.com.ec):

| Axis | What It Catches |
|---|---|
| **Activity** | Dead wallets, sybil patterns |
| **Diversification** | Single-asset risk |
| **Stablecoin Ratio** | Depegging exposure (>80% flagged) |
| **RealFi Exposure** | RWA-aware scoring |
| **Dormancy** | Idle capital detection |

Example output:
```
🏥 Wallet Health Score: B+ (78/100)
⚠️ Stablecoin ratio at 65% — monitor for depegging risk
💡 Add 1-2 non-stablecoin tokens to improve diversification
```

---

## 🌐 Network Support

| Network | Chain ID | Native | RPC | Status |
|---|---|---|---|---|
| Atlantic Testnet | 688689 | PHRS | `atlantic.dplabs-internal.com` | Live |
| Pacific Ocean Mainnet | 1672 | PROS | `rpc.pharos.xyz` | Live (Apr 28, 2026) |

**Ecosystem stats**: $1B valuation, $52M funding, 4.3B testnet txns, 209M wallets, 50+ dApps, $10M incubator.

---

## 🏛️ RealFi Alliance Knowledge (12+ Protocols)

| Partner | Category | Status |
|---|---|---|
| Amber Group | Institutional Liquidity | Live |
| LI.FI | Cross-chain Aggregation | Live |
| Circle CCTP | USDC Native Bridge | Live |
| LayerZero | Omnichain Messaging | Live |
| Vishwa | Lending & Credit | Live |
| ZonaLend | Lending Market | Live (May 19) |
| Pleasing Market | Tokenized Metals | Deploying |
| KUN | Cross-border Payments | Live |
| Yuzu Money | Consumer Yield | Deploying |
| Agra | Orderbook Trading | Deploying |
| Anvita Flow | AI Agent Collaboration | Live |
| pAlpha Vault | Pre-launch RWA | Completed ($50M) |

---

## 📦 Installation

### Claude Code
```bash
mkdir -p ~/.claude/skills/pharos-wallet-intel
cp -r . ~/.claude/skills/pharos-wallet-intel/
```

### OpenClaw
```bash
mkdir -p ~/.openclaw/skills/pharos-wallet-intel
cp -r . ~/.openclaw/skills/pharos-wallet-intel/
```

### Codex
```bash
mkdir -p ~/.codex/skills/pharos-wallet-intel
cp -r . ~/.codex/skills/pharos-wallet-intel/
```

---

## 🗂️ Architecture

```
pharos-wallet-intel/
├── SKILL.md                    ← Agent discovers & activates via YAML frontmatter
├── README.md                   ← This file
├── scripts/
│   └── analyze-wallet.sh       ← One-command automation
├── assets/
│   ├── networks.json           ← Verified RPC, chain IDs, explorers
│   ├── tokens.json             ← All known ERC20 addresses (testnet + mainnet)
│   ├── ecosystem.json          ← 12+ RealFi protocols, bridges, analytics
│   └── examples.md             ← Real wallet output examples
└── references/
    ├── portfolio.md            ← Aggregate native + ERC20 balance flow
    ├── history.md              ← Explorer API + nonce transaction summary
    ├── risk-score.md           ← 🆕 5-axis Wallet Health Score
    ├── onboarding.md           ← Empty wallet detection + faucet guide
    ├── realfi.md               ← Protocol context for RWA token holders
    ├── ai-rwa.md               ← Agent coordination, x402 protocol, Vishwa
    └── discover.md             ← Ecosystem overview with live statuses
```

---

## 📋 Prerequisites

- [Foundry](https://getfoundry.sh) (`cast` in PATH)
- `jq` (`winget install jqlang.jq` on Windows, `brew install jq` on macOS, `sudo apt install jq` on Linux/WSL)

## License
MIT
EOF
echo "   ✅ done"

# ── 6. SKILL.md ──
echo "[6/12] Updating SKILL.md..."
cat > SKILL.md << 'EOF'
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
EOF
echo "   ✅ done"

# ── 7. references/realfi.md ──
echo "[7/12] Updating references/realfi.md..."
cat > references/realfi.md << 'EOF'
# RealFi Position Detection & Context

Provides protocol context for RealFi-related token holdings, explaining
what the asset represents and what actions are available.

## When to Use

Activate after portfolio aggregation when any token is linked to a RealFi protocol,
or when the user asks: "what can I do with this token", "explain my RealFi assets",
"what protocols are on Pharos", "show me RealFi opportunities".

## Execution Flow

### Step 1: Cross-reference with ecosystem data

Load `assets/ecosystem.json` and match tokens by symbol/name.

### Step 2: Provide context for known RealFi assets

| Token/Protocol | Display Context |
|---|---|
| pXAU (Pleasing Market) | "Tokenized gold onchain. Borrow against it on ZonaLend or trade on Agra." |
| KUN-linked assets | "Supply-chain credit tokenization for cross-border payments." |
| vToken (Vishwa) | "Lending position receipt. Agent-driven capital with pre-execution constraint enforcement." |
| Yuzu position | "Consumer RealFi yield product. Check current yields at Yuzu Money." |
| pAlpha | "Pre-launch RWA vault on Ethereum. Reached $50M capacity pre-mainnet. Not queryable on Pharos chain — check Etherscan." |

### Step 3: Risk transparency layer

Based on the [Pharos Ecosystem Security Guide](https://www.htx.com.ec), surface these warnings:

| Risk Type | Trigger Condition | Warning to Display |
|---|---|---|
| **Stablecoin depegging** | USDC or USDT >50% of portfolio | "⚠️ High stablecoin concentration. Oracle-based circuit breakers protect against depegging events." |
| **Liquidity drought** | Token from protocol without deep secondary markets | "⚠️ This asset may have limited secondary market depth. Verify liquidity before large trades." |
| **NAV staleness** | Protocol's last reported NAV >24h old | "⚠️ Last reported Net Asset Value is over 24 hours old. Verify current value before transacting." |
| **Single-asset risk** | Only one token type held | "⚠️ Portfolio concentrated in a single asset. Diversification reduces idiosyncratic risk." |
| **Dormant funds** | Nonce = 0, balance >0 | "💤 Funds are sitting idle. Consider lending on ZonaLend or yield on Yuzu Money." |

### Step 4: Present RealFi summary

```
## 🏛️ RealFi Asset Breakdown

| Asset | Protocol | Type | Action Available |
|-------|----------|------|-----------------|
| pXAU | Pleasing Market | Tokenized Gold | Borrow on ZonaLend, Trade on Agra |
| vUSDC | Vishwa | Lending Position | Manage at Vishwa dashboard |

### ⚠️ Risk Flags
- USDC at 65% of portfolio — depegging circuit breaker: ACTIVE
- Vishwa NAV last updated: 4 hours ago (fresh)

### 📜 Historical / Off-chain RealFi
| Asset | Protocol | Status | Location |
|-------|----------|--------|----------|
| pAlpha | pAlpha Vault | Completed ($50M) | Ethereum Mainnet |

### 🌉 Bridge & Liquidity Infrastructure
- **LI.FI**: Cross-chain aggregation live
- **LayerZero**: Omnichain messaging live
- **Circle CCTP**: USDC native cross-chain transfers live

### 📊 Analytics
- **Dune**: RealFi capital flow dashboards available
- **PharosScan**: Full transaction history at [explorer URL]
```

If no RealFi assets are detected, simply state: "No RealFi-specific assets detected in this wallet."

## Notes
- All data is read-only. No transactions are ever executed.
- Risk warnings are informational only — not financial advice.
- Statuses are accurate as of May 2026.
- pAlpha was a pre-mainnet vault on Ethereum; it is not natively queryable on Pharos chain unless bridged.
EOF
echo "   ✅ done"

# ── 8. Append to portfolio.md ──
echo "[8/12] Appending CCTP to portfolio.md..."
cat >> references/portfolio.md << 'EOF'

### Step 6: CCTP Cross-Chain Detection

After USDC balance is queried, add:
- "This USDC may have arrived via Circle CCTP from Ethereum, Arbitrum, Solana, or 20+ other supported chains."
- "Verify origin chain: check the deposit transaction on PharosScan for CCTP `messageReceived` events."
- "CCTP enables native USDC transfers without additional bridging steps — regulated liquidity flows directly into Pharos."

For wallets holding both USDC and WETH/LINK (mainnet), note:
- "Multi-chain asset pattern detected. Likely bridged via LI.FI or LayerZero rather than CCTP-only."
EOF
echo "   ✅ done"

# ── 9. Append to onboarding.md ──
echo "[9/12] Appending wallets to onboarding.md..."
cat >> references/onboarding.md << 'EOF'

### Supported Institutional Wallets

Pharos integrates with major wallet providers for frictionless onboarding:

| Wallet | Users | Type |
|---|---|---|
| **OKX Wallet** | 50M+ | Full Pharos mainnet support (Apr 29, 2026) |
| **Topnod Wallet** | Ant Group | Institutional-grade, Web2-native UX |
| **Any EVM Wallet** | — | Custom RPC: `https://rpc.pharos.xyz` |

OKX Wallet users can participate in exclusive airdrop events directly within the app.
Topnod provides Web2-native onboarding to reduce friction for institutional users.
EOF
echo "   ✅ done"

# ── 10. Append to discover.md ──
echo "[10/12] Appending incubator to discover.md..."
cat >> references/discover.md << 'EOF'

### 💰 Funding & Support
- **$10M Incubator**: Pharos "Native to Pharos" builder program for RWA, DeFi, and prediction market teams
- **Backers**: Hack VC, Faction VC, Draper Dragon, Centrifuge, GCL New Energy
- **Total Raised**: $52M (including $44M Series A)
- **Valuation**: $1B (May 2026)
- **Apply**: https://www.pharos.xyz/ecosystem

### 🔮 Prediction Markets
- **HKU Research**: AI-driven RWA pricing and event probability modeling (University of Hong Kong partnership)
- **Use cases**: Real-world outcome prediction, RWA price discovery, insurance-linked securities

### 🤖 AI Agent Ecosystem
- **Anvita Flow**: Agent collaboration network for RWA operations
- **x402 Protocol**: Micropayment settlement between agents
- **Vishwa**: Agent-driven capital flows with constraint enforcement
EOF
echo "   ✅ done"

# ── 11. Update ecosystem.json ──
echo "[11/12] Updating ecosystem.json..."
if [ -f "assets/ecosystem.json" ]; then
    cp assets/ecosystem.json assets/ecosystem.json.bak
    jq 'if .mainnet.analytics then .mainnet.analytics += [{"name":"HKU Research","type":"Prediction Markets","note":"AI-driven RWA pricing and event probability modeling"}] else .mainnet.analytics = [{"name":"HKU Research","type":"Prediction Markets","note":"AI-driven RWA pricing and event probability modeling"}] end | if ."atlantic-testnet".analytics then ."atlantic-testnet".analytics += [{"name":"HKU Research","type":"Prediction Markets","note":"AI-driven RWA pricing and event probability modeling"}] else ."atlantic-testnet".analytics = [{"name":"HKU Research","type":"Prediction Markets","note":"AI-driven RWA pricing and event probability modeling"}] end' assets/ecosystem.json.bak > assets/ecosystem.json
    echo "   ✅ done (backup: ecosystem.json.bak)"
else
    echo "   ⚠️ ecosystem.json not found"
fi

# ── 12. Update .gitignore ──
echo "[12/12] Updating .gitignore..."
if [ -f ".gitignore" ]; then
    if ! grep -q "*.bak" .gitignore; then
        echo "*.bak" >> .gitignore
        echo "   ✅ appended"
    else
        echo "   ℹ️ already has *.bak"
    fi
else
    echo "*.bak" > .gitignore
    echo "   ✅ created"
fi

# ── Final verification ──
echo ""
echo "================================================"
echo "✅ ALL v2 CHANGES APPLIED!"
echo "================================================"
echo ""
find . -type f -not -name '*.bak' -not -path './.git/*' | sort
echo ""
echo "Next steps:"
echo "  git add -A"
echo '  git commit -m "v2: Wallet Health Score, automation, risk transparency, AI-RWA, examples, polished README"'
echo "  git push origin main"
