# 🏹 PolyRobin

**A safety-first, autonomous prediction-market agent for Polymarket and Robinhood Chain.**

PolyRobin discovers, analyzes, and trades prediction markets across **Polymarket
(Polygon)** and **Robinhood Chain** — including **Meridian Predict** and tokenized
event markets — all in natural language. It builds its *own* probability estimates
from news sentiment, onchain signals, historical resolution data, and a careful
read of the resolution criteria, only trades when there's a real edge, sizes with
fractional Kelly, and wraps everything in **7 hard safety gates**, a **HALT**
state, and a **kill-switch**. Robinhood Chain is a first-class home venue.

> Built as a [BankrBot](https://bankr.bot) skill. It's an analyst that can pull
> the trigger — and always shows its work before it does.

[![Skill](https://img.shields.io/badge/BankrBot-Skill-6C5CE7)](./SKILL.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./SKILL.md)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Safety](https://img.shields.io/badge/mode-safety--first-critical)](#-safety-cheat-sheet)

---

## Table of Contents

- [Why PolyRobin](#why-polyrobin)
- [Features](#features)
- [How It Works](#how-it-works)
- [🛡️ Safety Cheat Sheet](#-safety-cheat-sheet)
- [Supported Markets](#supported-markets)
- [Installation](#installation)
- [Configuration](#configuration)
- [Quick Start](#quick-start)
- [Example User Flows](#example-user-flows)
- [Command Reference](#command-reference)
- [Integrations](#integrations)
- [Auditability](#auditability)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Why PolyRobin

Most bots arbitrage the order book or follow momentum. PolyRobin forms an
**independent view of the truth** first, then compares it to the market price. If
the market already agrees, it does nothing — and tells you why. Three questions,
answered with receipts, for every market:

1. **What's the true probability?** — an independent estimate from evidence.
2. **Is there an edge?** — estimate vs. price, in EV after fees, slippage, bridge.
3. **How much should we risk?** — Kelly-sized, volatility-adjusted, capped.

---

## Features

- 🌐 **Unified discovery** across Polymarket (Polygon) and **Robinhood Chain**
  (Meridian Predict + tokenized event markets).
- 🧠 **Independent probability modeling** from news sentiment, onchain signals,
  historical resolution data, and resolution-criteria analysis.
- 🎯 **Transparent edge detection** with a 0–100 conviction score and full math.
- 📐 **Smart sizing** via fractional Kelly, volatility adjustment, exposure caps.
- 🔁 **Full position management** — entry, exit, hedging, resolution monitoring,
  and auto-claiming.
- 🛡️ **Cross-protocol hedging** with Hyperliquid perps and Morpho lending.
- 🌉 **Bridging into Robinhood Chain** with optimal routing.
- 📊 **Real-time monitoring** — positions, PnL, health, customizable alerts.
- 🚨 **7 hard safety gates** + HALT-on-volatility + kill-switch + emergency pause.
- 🔬 **Full auditability** — a Rationale Card for every decision.

---

## How It Works

```
DISCOVER → MODEL P → PRICE EDGE → SIZE → CONFIRM → EXECUTE → MANAGE → RESOLVE → REPORT
   │          │          │         │        │          │         │         │        │
 Polymarket news+      EV net    frac-    human      route +   monitor   settle+  PnL +
 + RH Chain onchain+   fees/slip/ Kelly    yes (gate  place     + hedge   auto-    Rationale
 /Meridian  sentiment  bridge     +vol-adj  5)                            claim    Card
```

Every stage can veto. Ambiguous resolution criteria, thin liquidity, stale/
conflicting oracles, or extreme volatility all cause PolyRobin to abstain or HALT.
**Standing down is a valid and frequent output.**

---

## 🛡️ Safety Cheat Sheet

All values are configurable but ship conservative. **Gate 5 (confirmation) cannot
be disabled.**

| # | Gate | Default | Change with |
|---|------|---------|-------------|
| 1 | Daily loss limit | **5%** of bankroll | `polyrobin set daily-loss-limit 3%` |
| 2 | Max per market | **10%** | `polyrobin set max-per-market 8%` |
| 3 | Max per category | **25%** | `polyrobin set max-per-category 20%` |
| 4 | Conviction threshold | **≥65/100 & EV ≥ +4%** | `polyrobin set conviction-threshold 70` |
| 5 | Confirmation required | **every material action** | 🔒 always on |
| 6 | Total deployed cap | **60%** | `polyrobin set total-cap 50%` |
| 7 | Liquidity / exitability | **$50k depth · $250k vol** | `polyrobin set min-liquidity 75k` |

**HALT triggers:** extreme volatility · oracle staleness/disagreement (Chainlink)
· data-source conflict · bridge congestion/failure · 3 losses in 24h.

**Emergency controls:**

```
polyrobin pause     # soft freeze — suspend new activity, keep monitoring/claiming
polyrobin halt      # stop opening new positions
polyrobin panic     # kill-switch: HALT + snapshot + cancel working orders + alert
polyrobin resume    # explicit human action required to exit HALT/pause
polyrobin gates     # live state of all 7 gates
```

**Golden rules:** stricter gate always wins · no gate bypassed silently · keys
never touch PolyRobin · ambiguous-resolution markets are never traded, at any edge.

---

## Supported Markets

| Category | Examples | Venue(s) |
|----------|----------|----------|
| Politics & elections | Rate decisions, elections, policy votes | Polymarket · RH Chain |
| Crypto | "ETH > $5k EOY", ETF flows, protocol events | Polymarket · RH Chain |
| Sports | Match/series outcomes, season props | Polymarket |
| Macro & economics | CPI, Fed moves, jobs data | Polymarket · Meridian |
| RWAs & tokenized assets | Tokenized T-bill / commodity milestones | Robinhood Chain |
| **Tokenized stock events** | Earnings beats, listings, corporate actions | **RH Chain (Meridian Predict)** |
| Weather & misc events | Climate thresholds, scheduled catalysts | Polymarket |

Robinhood Chain is a **first-class home venue** — Meridian Predict and tokenized
event markets are surfaced natively, with EV math that already accounts for bridge
latency and cost.

---

## Installation

> Requires a BankrBot-compatible environment and a funded wallet/signer.

```bash
# Clone
git clone https://github.com/PhantomCapAI/PolyRobin.git
cd PolyRobin

# Install the skill into BankrBot
bankr skill install ./SKILL.md
#   or symlink for development:
ln -s "$(pwd)/SKILL.md" ~/.bankr/skills/polyrobin.md

# Initialize config with safe defaults
polyrobin init

# Connect your signer (keys stay with you)
polyrobin signer connect ledger        # or: walletconnect | keystore

# Verify integrations + gates
polyrobin health
```

See [Exact BankrBot install command](#installation) below for the one-liner.

---

## Configuration

Copy [`examples/config.yaml`](./examples/config.yaml) to `~/.polyrobin/config.yaml`
and adjust. Never put private keys in config — PolyRobin signs through a
user-controlled signer only. Loosening a gate beyond its safe band requires a
typed override.

---

## Quick Start

```bash
polyrobin scan --venue robinhood-chain --tokenized-stocks   # discover
polyrobin why <market-id>                                   # full reasoning
polyrobin size <market-id>                                  # recommended stake
polyrobin buy YES <market-id> --edge-gated --confirm        # trade (asks yes)
polyrobin portfolio                                         # monitor
```

---

## Example User Flows

### Flow 1 — Discover and trade a tokenized-stock event on Robinhood Chain

```
> polyrobin scan --venue robinhood-chain --tokenized-stocks --resolving-within 14d
  4 Meridian Predict markets clear volume/liquidity gates. Top by conviction:
  1. "NVDA beats Q3 EPS estimate"   price 0.55 | est 0.63 | conviction 71

> polyrobin why "NVDA beats Q3 EPS estimate"
  My estimate 0.63 (conviction 71/100)
  • Historical resolution: 8 of last 10 quarters beat (strong prior)
  • News sentiment: supply-chain commentary constructive (moderate)
  • Onchain/flow: tokenized NVDA net accumulation (weak-moderate)
  • Resolution: Chainlink-verified earnings feed — unambiguous ✅
  EV ≈ +5.4% net of fees/slippage.

> polyrobin buy YES "NVDA beats Q3 EPS estimate" --size 150 --edge-gated
  Suggested $150 (¼-Kelly) = 3% of bankroll. All 7 gates ✅.
  Confirm? reply `yes`
> yes
  ✅ Filled on Robinhood Chain. Rationale Card RC-2087 saved.
```

### Flow 2 — Bridge into Robinhood Chain, then hedge across protocols

```
> polyrobin bridge 500 USDC to robinhood-chain
  Optimal route selected. Est. 3–6 min, cost ~$0.40. bridge-id BR-77.

> polyrobin hedge-suggest POS-2087
  Suggested: Hyperliquid short to neutralize event-day delta. Cost ~$2.90/30d.
  Confirm? reply `yes`
```

### Flow 3 — The kill-switch does its job

```
> polyrobin pnl --today
  Realized -3.1%, unrealized -2.2% → -5.3% ≥ 5% limit.
  🚨 Kill-switch: state HALT. Working orders cancelled, book snapshotted (RC-2101).
  Positions held; resolution + auto-claim monitoring continues.

> polyrobin resume
  ⚠️ Exiting HALT after a limit breach. Type: RESUME TRADING
> RESUME TRADING
  ✅ Resumed. Consider smaller size for the rest of the session.
```

---

## Command Reference

| Group | Examples |
|-------|----------|
| **Discovery** | `scan`, `scan --venue robinhood-chain`, `trending`, `watch`, `markets` |
| **Analysis** | `analyze`, `edge`, `why`, `criteria`, `compare` |
| **Trading** | `size`, `buy`, `limit`, `exit`, `claim`, `dry-run` |
| **Monitoring** | `portfolio`, `positions`, `pnl`, `health`, `alerts` |
| **Hedging & Bridging** | `bridge`, `xchain view`, `hedge`, `hedge-suggest`, `unhedge` |
| **Risk & Controls** | `gates`, `set`, `pause`, `halt`, `resume`, `panic` |

Full command set lives in [`SKILL.md`](./SKILL.md).

---

## Integrations

| Integration | Purpose |
|-------------|---------|
| **Polymarket** | Market data, execution, resolution (Polygon) |
| **Robinhood Chain / Meridian Predict** | RH-native prediction & tokenized event markets |
| **Chainlink oracles** | Price + resolution feeds, staleness/disagreement checks |
| **Hyperliquid** | Perp hedging + implied-probability cross-checks |
| **Morpho** | Borrow/lend to finance or hedge (health-factor aware) |
| **Bridging protocol** | USDC routing into Robinhood Chain |
| **News / onchain / sentiment** | Probability model inputs |
| **Signer / wallet** | User-controlled signing (keys never leave you) |

Each adapter exposes `quote() / execute() / status() / health()` and downgrades to
read-only rather than failing open.

---

## Auditability

Every decision writes a **Rationale Card** (JSON + human-readable) to
`~/.polyrobin/audit/`: independent estimate, conviction score, weighted +
timestamped sources, full edge and size math, and each of the 7 gates' results —
plus, on execution, tx hash, chain, fill price, fees, and realized slippage.

```
polyrobin explain <trade-id>            # reconstruct any decision
polyrobin audit --export csv --since 30d
```

PolyRobin never fabricates data. Missing source → widened uncertainty or
abstention, never a guess.

---

## FAQ

**Does it trade on its own?** Only within your gates, and **every material action
still requires your explicit confirmation** (gate 5 can't be disabled).

**Is Robinhood Chain really first-class?** Yes — Meridian Predict and tokenized
event markets are native, not bolted on. Bridging routes funds *into* RH Chain.

**Will it always find a trade?** No. "No edge, standing down" is common and correct.

**Does it hold my keys?** Never. Signing is via your configured signer.

**Can it lose money?** Yes — prediction markets are speculative. See the disclaimer.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Run `./scripts/validate.sh` before a PR
(CI runs it too), keep `SKILL.md` / `README.md` / `examples/config.yaml`
consistent, document any safety impact, and report vulnerabilities privately per
[SECURITY.md](./SECURITY.md).

| Path | What it is |
|------|------------|
| [`SKILL.md`](./SKILL.md) | The BankrBot skill definition (source of truth) |
| [`examples/config.yaml`](./examples/config.yaml) | Annotated sample configuration |
| [`scripts/validate.sh`](./scripts/validate.sh) | Validates frontmatter, sections, config |
| [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) | CI: validation + link check |

---

## Disclaimer

PolyRobin is a tool for informed, risk-managed participation in prediction
markets. **It is not financial advice.** Prediction markets are speculative and
can lose 100% of staked capital. Availability and legality vary by jurisdiction —
you are solely responsible for compliance with applicable laws and platform terms.
PolyRobin optimizes for disciplined, transparent, auditable decisions; it cannot
guarantee profit and will regularly and correctly recommend doing nothing.

---

## License

MIT © PolyRobin Labs. See [LICENSE](./LICENSE).
