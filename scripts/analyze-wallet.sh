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
