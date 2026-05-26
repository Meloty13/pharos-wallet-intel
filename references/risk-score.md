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
