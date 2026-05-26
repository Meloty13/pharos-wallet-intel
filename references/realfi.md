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
