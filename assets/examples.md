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
