# Portfolio: Complete Wallet Asset Overview

Aggregates all assets held by a wallet on Pharos — native token balance plus
all known ERC20 token balances — and presents them in a clean summary table.

## When to Use

Activate when user asks:
- "show my portfolio"
- "what's in my wallet"
- "check all my balances"
- "wallet overview for 0x..."
- "what tokens do I hold"
- "show my Pharos assets"
- "asset summary for this address"
- "how much do I have on Pharos"

## Execution Flow

### Step 1: Read network and token config

```bash
RPC_URL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .rpcUrl' assets/networks.json)
NATIVE_SYMBOL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .nativeToken' assets/networks.json)
EXPLORER_URL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .explorerUrl' assets/networks.json)
```

Use `select(.name=="mainnet")` when user specifies mainnet.

### Step 2: Validate address

Address must match: `0x` followed by exactly 40 hex characters.
If invalid: respond "Please provide a valid wallet address (0x + 40 hex characters)" and stop.

### Step 3: Query native token balance

```bash
cast balance <address> --rpc-url $RPC_URL --ether
```

- Output is a decimal string in ether units e.g. `1.250000000000000000`
- Display as: `PHRS: 1.2500` (Atlantic testnet) or `PROS: 1.2500` (mainnet)
- Truncate display to 4 decimal places

### Step 4: Query all ERC20 balances

Read token list for the current network from `assets/tokens.json`.

```bash
# Get token addresses for atlantic-testnet
jq -r '."atlantic-testnet"[] | .address' assets/tokens.json
```

For each token run:

```bash
cast call <token_address> "balanceOf(address)(uint256)" <address> --rpc-url $RPC_URL
```

Convert raw value to human-readable:
- `readable = rawValue / 10^decimals`
- Use the `decimals` field from `assets/tokens.json` — do NOT make extra on-chain calls
- For USDC/USDT (decimals=6): divide by 1000000
- For WETH/WBTC/WPHRS (decimals=18): divide by 1000000000000000000

**Skip tokens with zero balance** — do not show them.
**If a token call fails** — skip it silently, continue with remaining tokens.

### Step 5: Check wallet activity

```bash
cast nonce <address> --rpc-url $RPC_URL
```

- Nonce = number of transactions sent FROM this address
- Nonce = 0 AND native balance = 0 → new wallet, suggest onboarding
- Nonce = 0 AND native balance > 0 → funded but never transacted
- Nonce > 0 → active wallet

### Step 6: Present results

Format output as a clean table:

```
## 💼 Pharos Wallet Portfolio

**Address:** `0x1234...abcd`
**Network:** Atlantic Testnet
**Explorer:** https://atlantic.pharosscan.xyz/address/0x1234...abcd

| Token | Balance    | Type         |
|-------|------------|--------------|
| PHRS  | 12.5000    | Native       |
| USDC  | 1,000.0000 | Stablecoin   |
| WETH  | 0.2500     | Wrapped      |

**Wallet status:** Active (42 outbound transactions)

💡 To check tokens not listed above, find their contract address at:
   https://atlantic.pharosscan.xyz/tokens
   Then ask: "Check balance of 0x<token_address> for this wallet"

⚠️  Read-only query — no transactions executed.
```

Rules for the table:
- Always list native token (PHRS/PROS) first
- Only show tokens with balance > 0
- Sort ERC20 tokens alphabetically after native
- Format large numbers with commas for readability
- If ALL balances are zero, say so clearly and suggest the faucet

## Error Handling

| Error | Response |
|-------|---------|
| Invalid address format | "Please provide a valid 0x-prefixed address (42 characters)" — stop |
| All ERC20 calls fail | Show only native balance, note: "ERC20 queries unavailable — RPC issue" |
| `cast nonce` fails | Skip wallet status line, show balances only |
| No tokens in `tokens.json` for network | Show native balance only |
| Native balance = 0 AND nonce = 0 | Show empty portfolio + direct user to `references/onboarding.md` flow |

### Step 6: CCTP Cross-Chain Detection

After USDC balance is queried, add:
- "This USDC may have arrived via Circle CCTP from Ethereum, Arbitrum, Solana, or 20+ other supported chains."
- "Verify origin chain: check the deposit transaction on PharosScan for CCTP `messageReceived` events."
- "CCTP enables native USDC transfers without additional bridging steps — regulated liquidity flows directly into Pharos."

For wallets holding both USDC and WETH/LINK (mainnet), note:
- "Multi-chain asset pattern detected. Likely bridged via LI.FI or LayerZero rather than CCTP-only."
