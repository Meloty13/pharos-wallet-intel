<p align="center">
<img width="900" height="600" alt="Pharos Intelligence_V2_900x600" src="https://github.com/user-attachments/assets/7c713f83-34a8-47e9-b635-f35347de17c9" />
</p>

# 🔬 Pharos Wallet Intelligence Skill

<div align="center">

<pre>
╔══════════════════════════════════════════════════════════╗
║  PHAROS WALLET INTELLIGENCE                              ║
║  ───────────────────────────────────                     ║
║  Portfolio • History • Health Score • RealFi • Ecosystem ║
║  All read-only. No private key. Agent-native.            ║
╚══════════════════════════════════════════════════════════╝
</pre>

</div>

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
