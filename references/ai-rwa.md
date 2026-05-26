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
