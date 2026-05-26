# Token Allowance Checker

Checks how much spending permission (allowance) a wallet has granted to other
addresses for each known ERC20 token. Essential for security audits — unlimited
approvals to unknown contracts are a common attack vector.

## When to Use

Activate when user asks:
- "check my token approvals"
- "what allowances have I set"
- "did I approve any contracts"
- "check my USDC allowance for 0x..."
- "how much spending permission did I give"
- "is my wallet safe / check my approvals"
- "revoke check" / "approval audit"
- "what contracts can spend my tokens"

## Background

When a user calls `approve()` on an ERC20 token, they grant another address
(a DEX, bridge, lending protocol, etc.) permission to spend up to a set amount
of their tokens. This skill reads those permissions using `allowance()`, which
is a free read-only call — no transaction, no gas cost.

## Two Modes

### Mode A: Check allowance for a specific spender
User provides both a wallet address AND a spender address.

### Mode B: Check all known tokens against a specific spender
User provides a wallet address and wants to see all token allowances for one spender.

Determine the mode from context. If the user only provides one address, ask:
"Should I check allowances for a specific spender address, or do you want to
provide a spender address to audit?"

## Execution Flow

### Step 1: Read network config

```bash
RPC_URL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .rpcUrl' assets/networks.json)
EXPLORER_URL=$(jq -r '.networks[] | select(.name=="atlantic-testnet") | .explorerUrl' assets/networks.json)
```

### Step 2: Validate addresses

Both wallet address and spender address must match `0x` + 40 hex characters.
Validate both before running any commands.

### Step 3: Query allowance for each known token

For each token in `assets/tokens.json` for the current network:

```bash
cast call <token_address> \
  "allowance(address,address)(uint256)" \
  <wallet_address> \
  <spender_address> \
  --rpc-url $RPC_URL
```

Convert raw value to human-readable using `decimals` from `assets/tokens.json`.

Special case — unlimited approval detection:
- Raw value = `115792089237316195423570985008687907853269984665640564039457584007913129639935`
- This is `type(uint256).max` — means unlimited approval
- Always display this as `UNLIMITED ⚠️` not as a number

### Step 4: Present results

```
## 🔍 Token Allowance Audit

**Wallet:**  `0xABCD...1234`
**Spender:** `0xDEF0...5678`
**Network:** Atlantic Testnet

| Token | Allowance       | Risk     |
|-------|-----------------|----------|
| USDC  | UNLIMITED ⚠️   | HIGH     |
| USDT  | 500.000000      | LOW      |
| WETH  | 0               | NONE     |
| WBTC  | 0               | NONE     |
| WPHRS | 0               | NONE     |

**Explorer (wallet):**  https://atlantic.pharosscan.xyz/address/0xABCD...1234
**Explorer (spender):** https://atlantic.pharosscan.xyz/address/0xDEF0...5678

### 🛡️ Security Summary
- 1 UNLIMITED approval found — review the spender contract carefully
- To revoke: call `approve(spender, 0)` on the token contract
  (requires the base pharos-skill-engine for write operations)

⚠️  Read-only query — no transactions executed.
```

### Risk Classification

| Allowance | Risk Label |
|-----------|-----------|
| 0 | NONE |
| > 0 and < token total supply | LOW |
| = uint256 max (unlimited) | HIGH |

### Step 5: Security advice

Always append after the table:
- If any UNLIMITED approvals found: warn prominently, explain the risk
- If all zero: "No active approvals found for this spender — wallet is clean"
- Remind user: to revoke, they need to send a transaction (`approve(spender, 0)`)
  which requires the base `pharos-skill-engine` write capability

## Checking a Specific Single Token

If user asks "how much USDC allowance did I give to 0x...":

1. Look up USDC address from `assets/tokens.json`
2. Run the single allowance call
3. Present concisely:

```
**USDC allowance granted to `0xDEF0...5678`:** 500.000000 USDC

Explorer: https://atlantic.pharosscan.xyz/address/0xDEF0...5678
⚠️  Read-only — no transactions executed.
```

## Error Handling

| Error | Response |
|-------|---------|
| Invalid wallet address | "Please provide a valid 0x-prefixed wallet address (42 characters)" — stop |
| Invalid spender address | "Please provide a valid 0x-prefixed spender address (42 characters)" — stop |
| `execution reverted` on a token | Skip that token, note it failed, continue |
| Empty return from token | Token contract may not exist on this network — skip silently |
| User does not provide spender address | Ask: "Which spender address should I check the allowance for?" |
