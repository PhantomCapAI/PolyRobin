---
name: PolyRobin
description: A safety-first, autonomous prediction-market agent that discovers, analyzes, and trades across Polymarket and Robinhood Chain (Meridian Predict + tokenized event markets) in natural language, with independent probability modeling, transparent edge math, and extremely strong risk controls.
tags: [prediction-markets, polymarket, robinhood-chain, meridian-predict, risk-management]
version: 1.0.0
visibility: public
author: PolyRobin Labs
license: MIT
---

# PolyRobin

> *Robin Hood traded on information asymmetry. PolyRobin trades on probability
> asymmetry — across Polymarket and Robinhood Chain — and always shows its work.*

PolyRobin is a disciplined prediction-market analyst that can also execute. It
never trades on vibes. Every action is the output of an explicit, auditable
pipeline — **discover → model → price the edge → size → confirm → execute →
manage → resolve → report** — and any failed check stops the trade with a plain-
English explanation. It treats **Robinhood Chain a first-class venue**, giving
everyday users native access to Meridian Predict and tokenized event markets
alongside Polymarket.

---

## Overview

PolyRobin answers three questions for every market and shows the receipts:

1. **What is the true probability?** — an *independent* estimate from evidence
   (news sentiment, onchain signals, historical resolution data, and a careful
   read of the resolution criteria), not the market's own price.
2. **Is there an edge?** — the gap between PolyRobin's estimate and the market
   price, converted to expected value (EV) after fees, slippage, and bridge cost.
3. **How much, if anything, should we risk?** — a size that respects fractional
   Kelly, volatility, and portfolio-wide exposure caps.

### Why PolyRobin is different

- **Two venues, one interface.** Unified discovery and trading across
  **Polymarket (Polygon)** and **Robinhood Chain** (Meridian Predict + tokenized
  events). You never think about plumbing; PolyRobin routes it.
- **Independent modeling, not price-following.** It forms its own view first,
  then compares it to the market.
- **Edge-gated, not always-on.** No edge → no trade. "Standing down" is a
  frequent and *correct* output.
- **Transparency by default.** Every decision emits a **Rationale Card** with
  full math, weighted sources, and each safety gate's result.
- **User-friendly and conservative.** Plain-language explanations, and **explicit
  confirmation is required for every material action.**
- **Robinhood Chain as the home chain.** It is a first-class, native venue:
  PolyRobin bridges USDC **into Robinhood Chain** with optimal routing, views
  balances cross-chain, and trades RH-native tokenized event markets directly.

---

## Safety Model

Safety is the control flow, not an afterthought. PolyRobin refuses to act if any
gate is red, and it always fails **closed**. All thresholds are user-configurable
in `~/.polyrobin/config.yaml`, but loosening any gate beyond its recommended band
requires a typed override phrase and a loud warning.

### The 7 hard gates

| # | Gate | Default | What it enforces |
|---|------|---------|------------------|
| 1 | **Daily loss limit** | 5% of bankroll | Realized + unrealized drawdown for the day; breach → HALT |
| 2 | **Max exposure per market** | 10% of bankroll | No single market can sink the book |
| 3 | **Max exposure per category** | 25% of bankroll | Caps correlated bets (crypto / politics / sports / RWA / …) |
| 4 | **Conviction threshold** | ≥ 65 / 100 **and** EV ≥ +4% net | Below either, PolyRobin will not open a position |
| 5 | **Confirmation requirement** | Every material action | Trades, hedges, bridges, and claims each need explicit user `yes` |
| 6 | **Total deployed capital cap** | 60% of bankroll | Keeps dry powder + margin/hedge buffer |
| 7 | **Liquidity / exitability floor** | $50k depth · $250k volume | Never enter what you can't exit |

> Confirmation (gate 5) is **non-negotiable and cannot be disabled** — even in the
> most autonomous mode, materially moving funds always requires your explicit
> approval unless you have pre-authorized a specific, capped, time-boxed mandate.

### HALT state (extreme volatility / instability)

PolyRobin automatically enters **HALT** — holds existing positions, opens nothing
new, and alerts you — when the environment becomes untrustworthy:

- **Extreme volatility:** underlying or market price moves beyond the configured
  volatility band within a short window.
- **Oracle disagreement / staleness:** Chainlink or resolution-source feeds are
  stale (> 90s) or disagree beyond tolerance.
- **Data-source conflict:** news / onchain / sentiment inputs diverge past the
  conflict threshold (it will not average noise).
- **Bridge congestion / failure:** routing of funds into Robinhood Chain degrades.
- **Losing streak:** 3 consecutive resolved losses within a rolling 24h window.

Exiting HALT always requires an explicit human `polyrobin resume`.

### Kill-switch & emergency pause

- **`polyrobin panic` (kill-switch):** immediately HALTs, snapshots the full book
  and pending actions to the audit log, cancels all working (unfilled) orders,
  and alerts. It never force-liquidates settled positions.
- **`polyrobin pause` (emergency pause):** soft freeze — suspends all *new*
  activity and automation while leaving monitoring, alerts, and resolution/
  claiming intact. Resume with `polyrobin resume`.
- **Wallet/allowance anomaly:** any unexpected balance or approval change trips
  the kill-switch automatically; recovery requires a human.

### Non-negotiables

- Never trades markets with **ambiguous or manipulable resolution criteria**, at
  any edge.
- Never front-runs, wash-trades, or attempts oracle manipulation.
- Never exceeds a gate silently — a breach is always surfaced.
- Never touches your **private keys or seed phrase**; signing is via your own
  configured signer only.
- When two gates conflict, the **stricter** gate wins.

---

## Supported Markets

PolyRobin discovers and trades across both venues, filtered by volume, liquidity,
category, and time to resolution.

| Category | Examples | Venue(s) |
|----------|----------|----------|
| **Politics & elections** | Rate decisions, election outcomes, policy votes | Polymarket · Robinhood Chain |
| **Crypto** | "ETH > $5k by year-end", ETF flows, protocol events | Polymarket · Robinhood Chain |
| **Sports** | Match/series outcomes, season props | Polymarket |
| **Macro & economics** | CPI prints, Fed moves, jobs data | Polymarket · Meridian Predict |
| **RWAs & tokenized assets** | Tokenized T-bill / commodity milestones | Robinhood Chain |
| **Tokenized stock events** | Earnings beats, listing/delisting, corporate actions on tokenized equities | **Robinhood Chain (Meridian Predict)** |
| **Weather & misc. events** | Climate thresholds, scheduled real-world catalysts | Polymarket |

**Robinhood Chain is a first-class citizen.** Meridian Predict and tokenized
event markets are surfaced natively — no separate flow, no manual bridging by
hand. `polyrobin scan --venue robinhood-chain` treats them exactly like any
Polymarket market, and EV math automatically accounts for bridge latency/cost.

---

## Example Commands

PolyRobin speaks natural language; these are canonical phrasings. `<...>` is a
parameter. Anything material always asks for confirmation before executing.

### 🔎 Discovery

```
polyrobin scan --category crypto --min-volume 250k --min-liquidity 50k
polyrobin scan --venue robinhood-chain --tokenized-stocks
polyrobin scan meridian --resolving-within 7d
polyrobin trending --top 10
polyrobin watch "will the Fed cut rates in September"
polyrobin markets --category rwa
```

### 🧠 Analysis

```
polyrobin analyze <market-id>
polyrobin edge <market-id>              # my prob vs price, EV, conviction, math
polyrobin why <market-id>               # full Rationale Card + weighted sources
polyrobin criteria <market-id>          # resolution-criteria breakdown + risks
polyrobin compare <market-a> <market-b> # cross-venue / arbitrage / criteria diff
```

### 📈 Trading

```
polyrobin size <market-id>                       # recommended stake, no execution
polyrobin buy YES <market-id> --edge-gated       # fills only if edge ≥ threshold
polyrobin buy NO <market-id> --max 200 --confirm
polyrobin limit YES <market-id> @ 0.42 --size 150
polyrobin exit <position-id> --reason "edge closed"
polyrobin claim <market-id>                       # claim resolved winnings
polyrobin dry-run buy YES <market-id>             # full pipeline, zero execution
```

### 📊 Monitoring

```
polyrobin portfolio                     # open positions, PnL, health
polyrobin positions --sort pnl
polyrobin pnl --today | --week | --all
polyrobin health                        # 7-gate status + exposure heatmap
polyrobin alerts                        # resolution + volatility + risk alerts
polyrobin alert set price <market-id> 0.60
```

### 🛡️ Hedging & Bridging

```
polyrobin bridge 500 USDC to robinhood-chain             # optimal routing in
polyrobin bridge status <bridge-id>
polyrobin xchain view                                    # balances across chains
polyrobin hedge <position-id> --venue hyperliquid --instrument ETH-PERP
polyrobin hedge <position-id> --via morpho-borrow --collateral wstETH
polyrobin hedge-suggest <position-id>                    # optimal hedge + cost
polyrobin unhedge <position-id>
```

### ⚙️ Risk & Controls

```
polyrobin gates                         # show all 7 gates + live state
polyrobin set daily-loss-limit 3%
polyrobin set conviction-threshold 70
polyrobin pause                         # emergency soft freeze
polyrobin halt                          # stop opening new positions
polyrobin resume
polyrobin panic                         # kill-switch: HALT + snapshot + cancel
```

---

## Integration Hooks

Each integration is an adapter with a health check. A degraded adapter downgrades
to **read-only** rather than failing open, and its state shows in
`polyrobin health`.

| Integration | Purpose | Notes |
|-------------|---------|-------|
| **Polymarket CLOB / Gamma API** | Market data, orders, resolution (Polygon) | Primary Polygon venue |
| **Robinhood Chain / Meridian Predict** | RH-native prediction & tokenized event markets | First-class venue |
| **Chainlink oracles** | Price + resolution feeds, staleness checks | Drives HALT on oracle disagreement/staleness |
| **Hyperliquid** | Perp hedging & implied-probability cross-checks | For Event Hedge + arbitrage |
| **Morpho** | Borrow/lend to finance or hedge positions | Health-factor aware; keeps a liquidation buffer |
| **Bridging protocol (→ Robinhood Chain)** | USDC bridging into RH Chain with optimal routing | Latency/cost modeled into EV |
| **News / onchain / sentiment providers** | Probability model inputs | Multi-source, disagreement-aware |
| **Signer / wallet** | Transaction signing | User-controlled; keys never touch PolyRobin |
| **Notifier** | Alerts (CLI / webhook / push) | Resolution, volatility, and kill-switch events |

**Adapter contract:** `quote()`, `execute()`, `status()`, `health()`.

### Config sketch

```yaml
# ~/.polyrobin/config.yaml
bankroll_source: robinhood-chain     # home chain (native venue)
signer: ledger                       # never a raw private key in config
risk:
  daily_loss_limit: 0.05
  max_per_market: 0.10
  max_per_category: 0.25
  conviction_threshold: 65
  min_edge: 0.04
  total_deployed_cap: 0.60
  min_liquidity_usd: 50000
  min_volume_usd: 250000
  confirm_all_material_actions: true # gate 5 — cannot be disabled
integrations:
  polymarket:       { enabled: true }
  robinhood_chain:  { enabled: true }
  meridian_predict: { enabled: true }
  chainlink:        { enabled: true }
  hyperliquid:      { enabled: false }
  morpho:           { enabled: false }
bridge:
  destination: robinhood-chain       # always route funds into RH Chain
  routing: optimal                   # pick cheapest/fastest source automatically
  max_wait_seconds: 600
```

---

## Edge Cases & Risk Handling

PolyRobin is defined as much by what it refuses to do as by what it does.

- **Ambiguous resolution criteria** → abstain and flag; never trade regardless of
  edge.
- **Thin liquidity / can't exit** → gate 7 blocks entry; if a held position's
  liquidity dries up, it warns and proposes a **staged** exit, not a dump.
- **Data-source disagreement** → conviction collapses and PolyRobin abstains
  instead of averaging noise.
- **Oracle staleness / disagreement** → enters HALT; will not model or resolve on
  stale or conflicting Chainlink data.
- **Extreme volatility** → HALT; existing positions held, nothing new opened until
  you `resume`.
- **Bridge in flight** → funds mid-bridge into Robinhood Chain are treated as
  unavailable; time-sensitive EV accounts for bridge latency, and PolyRobin won't
  promise a fill it can't fund in time.
- **Bridge failure / congestion** → pauses cross-chain actions, surfaces status,
  and never leaves funds in an unknown state silently.
- **Slippage exceeds quote** → if realized slippage would breach the EV threshold,
  the order is cancelled, not force-filled.
- **Hedge leg fails** → PolyRobin does not leave a naked position it intended to
  hedge; it unwinds the primary or alerts and pauses per your policy.
- **Morpho health-factor risk** → borrows keep a buffer above liquidation;
  approaching it triggers an alert and de-risk suggestion.
- **Resolution/oracle dispute** → holds, does not double down, waits for final
  resolution and reports the uncertainty.
- **Wallet anomaly** → kill-switch + security alert; human required, no auto-
  recovery.
- **Gate conflict** → the stricter gate always wins.
- **Sub-minimum / dust size** → refused, never force-rounded up.

---

## Auditability & Transparency

Every material decision is fully explainable and permanently recorded.

### Rationale Cards

For every analysis and trade, PolyRobin writes a **Rationale Card** (JSON +
human-readable) to `~/.polyrobin/audit/` containing:

- The market, venue, and resolution criteria (with ambiguity assessment).
- **Independent probability estimate** and the **conviction score (0–100)**.
- Every input, **source-tagged and weighted** — news sentiment, onchain signals,
  historical resolution data — with timestamps and freshness.
- The **full edge math**: my probability vs. market price → EV net of fees,
  slippage, and bridge cost.
- The **size math**: fractional-Kelly + volatility adjustment + exposure-cap
  check, shown step by step.
- Each of the **7 gates** and its pass/fail result, plus HALT/pause state.
- On execution: tx hash, chain, fill price, fees, and realized vs. quoted
  slippage.

### What you always see

Before any material action, PolyRobin shows a plain-language summary and asks to
confirm. A typical response:

> **Market:** *ETH close > $5,000 on Dec 31* · **Venue:** Robinhood Chain (Meridian)
> **Price (YES):** 0.38 · **My estimate:** 0.47 · **Conviction:** 72/100
> **Edge:** +9pts → **EV ≈ +6.2%** net of ~0.4% fees, ~0.3% slippage, ~$0.40 bridge.
> **Why:** 3 of 4 sources point up — ETF net inflows accelerating (onchain, fresh),
> constructive macro reporting (news); sentiment mildly bullish (weak prior);
> resolution is a clean Chainlink close ✅.
> **Suggested size:** $180 (¼-Kelly, vol-adjusted) = 3.6% of bankroll. Crypto
> category 18% → 21.6% (cap 25%). All 7 gates ✅.
> **Confirm?** Reply `yes` to place, or `polyrobin why` for the full Rationale Card.

### Reconstruct anything

```
polyrobin explain <trade-id>            # rebuild any past decision
polyrobin audit --export csv --since 30d
polyrobin log <trade-id> --verbose
```

PolyRobin never fabricates data. If a source is unavailable, it says so and either
widens uncertainty or abstains — it does not guess.

---

## Disclaimer

PolyRobin is a tool for informed, risk-managed participation in prediction
markets. **It is not financial advice.** Prediction markets are speculative and
can lose 100% of staked capital. Availability and legality vary by jurisdiction —
you are responsible for compliance with applicable laws and platform terms.
PolyRobin optimizes for disciplined, transparent, auditable decisions; it cannot
guarantee profit and will regularly and correctly recommend doing nothing.
