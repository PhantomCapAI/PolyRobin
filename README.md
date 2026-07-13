# 🏹 PolyRobin

**An autonomous, safety-first prediction-market agent for Polymarket.**

PolyRobin discovers high-conviction markets, builds its *own* probability
estimates from live news, onchain, and sentiment signals, and only trades when it
finds a real, fee-adjusted edge. It sizes with fractional Kelly, enforces hard
risk limits, manages positions to resolution, and hedges across **Hyperliquid**
and **Morpho** — with native **Robinhood Chain** bridging for funding and
tokenized-asset (RWA) markets.

> Built as a [BankrBot](https://bankr.bot) skill. It's an analyst that can pull
> the trigger — not a black box that trades while you sleep.

[![Skill](https://img.shields.io/badge/BankrBot-Skill-6C5CE7)](./SKILL.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./SKILL.md)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Safety](https://img.shields.io/badge/mode-safety--first-critical)](#-safety-cheat-sheet)

---

## Table of Contents

- [Why PolyRobin](#why-polyrobin)
- [Features](#features)
- [How It Works](#how-it-works)
- [Safety Cheat Sheet](#-safety-cheat-sheet)
- [Installation](#installation)
- [Configuration](#configuration)
- [Quick Start](#quick-start)
- [Example Flows](#example-flows)
- [Command Reference](#command-reference)
- [Supported Strategies](#supported-strategies)
- [Integrations](#integrations)
- [Autonomy Levels](#autonomy-levels)
- [Auditability](#auditability)
- [FAQ](#faq)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Why PolyRobin

Most trading bots arbitrage the order book or follow momentum. PolyRobin does
something harder and more honest: it forms an **independent view of the truth**
first, then compares that view to the market price. If the market already agrees
with it, PolyRobin does nothing — and tells you why.

Three questions, answered with receipts, for every market:

1. **What's the true probability?** — an independent estimate from evidence.
2. **Is there an edge?** — the gap between estimate and price, in EV after costs.
3. **How much should we risk?** — Kelly-sized, volatility-adjusted, capped.

---

## Features

- 🔎 **Market discovery & filtering** by volume, liquidity, category, and time to
  resolution (crypto, politics, sports, weather, RWA, and more).
- 🧠 **Independent probability modeling** from news, onchain signals, sentiment,
  and rigorous resolution-criteria analysis.
- 🎯 **Edge detection** with EV thresholds and a 0–100 conviction score.
- 📐 **Smart sizing** via fractional Kelly, volatility adjustment, and
  portfolio-wide exposure caps.
- 🛡️ **Cross-protocol hedging** with Hyperliquid perps and Morpho borrow/lend.
- 🌉 **Robinhood Chain support** — bridge USDC, cross-chain balance views, and
  tokenized-asset market targeting.
- 📊 **Portfolio monitoring** — open positions, PnL, health, resolution alerts.
- 🚨 **Safety-first framework** — seven hard gates, kill-switch, and a HALT state.
- 🔬 **Full auditability** — a Rationale Card for every decision.
- 💬 **Natural-language interface** that always explains its reasoning.

---

## How It Works

```
DISCOVER → MODEL P → PRICE EDGE → SIZE → CONFIRM → EXECUTE → MANAGE → RESOLVE → REPORT
   │          │          │         │        │          │         │         │        │
 filter    news+      EV net    frac-    human      place     monitor   settle+  PnL +
 vol/liq   onchain+   of fees/  Kelly    gate       order     + hedge   claim    audit
 /category sentiment  slippage  +vol-adj (>thresh)                                card
```

Every stage can veto. If the resolution criteria are ambiguous, if liquidity is
too thin to exit, if data is stale or sources disagree — PolyRobin abstains.
**Silence is a valid and frequent output.**

---

## 🛡️ Safety Cheat Sheet

Keep this handy. All values are configurable but ship at safe defaults.

| Gate | Default | Command to view/change |
|------|---------|------------------------|
| Daily loss limit | **5%** of bankroll | `polyrobin set daily-loss-limit 3%` |
| Max per market | **10%** | `polyrobin set max-per-market 8%` |
| Max per category | **25%** | `polyrobin set max-per-category 20%` |
| Total deployed cap | **60%** | `polyrobin set total-cap 50%` |
| Min edge (EV) | **+4% net** | `polyrobin set min-edge 5%` |
| Min liquidity / volume | **$50k / $250k** | `polyrobin set min-liquidity 75k` |
| Confirm over | **$250 / trade** | `polyrobin set confirm-over 100` |

**Kill-switch trips on:** daily loss limit hit · 3 consecutive losses in 24h ·
stale/conflicting data feeds · wallet/allowance anomaly · manual `panic`.

**Emergency commands:**

```
polyrobin halt      # stop opening new positions
polyrobin panic     # HALT + alert + snapshot everything
polyrobin resume    # requires explicit human action to exit HALT
polyrobin gates     # see all seven gates and their live state
polyrobin health    # exposure heatmap + integration health
```

**Golden rules baked into the agent:**
- The *stricter* gate always wins when two conflict.
- No mode ever disables the hard gates or the kill-switch.
- Keys never touch PolyRobin — signing is via your own signer.
- Ambiguous-resolution markets are never traded, at any edge.

---

## Installation

> Requires a BankrBot-compatible environment and a funded wallet/signer.

```bash
# 1. Clone the skill
git clone https://github.com/<you>/polyrobin.git
cd polyrobin

# 2. Install into your BankrBot skills directory
bankr skill install ./SKILL.md
#    or symlink for development:
ln -s "$(pwd)/SKILL.md" ~/.bankr/skills/polyrobin.md

# 3. Initialize config (writes ~/.polyrobin/config.yaml with safe defaults)
polyrobin init

# 4. Connect your signer (keys stay with you — never in config)
polyrobin signer connect ledger        # or: walletconnect | keystore

# 5. Verify integrations
polyrobin health
```

---

## Configuration

PolyRobin reads `~/.polyrobin/config.yaml`. A minimal, safe starting point:

```yaml
bankroll_source: robinhood-chain
signer: ledger               # never a raw private key here
autonomy: assisted           # assisted | supervised | autonomous

risk:
  daily_loss_limit: 0.05
  max_per_market: 0.10
  max_per_category: 0.25
  total_deployed_cap: 0.60
  min_edge: 0.04
  min_liquidity_usd: 50000
  min_volume_usd: 250000
  confirm_over_usd: 250
  kelly_fraction: 0.25

strategies:
  conviction_value: on
  late_snipe: off
  arbitrage: off
  event_hedge: off
  category_basket: off
  criteria_arb: off
  rwa_plays: off

integrations:
  polymarket:      { enabled: true }
  robinhood_chain: { enabled: true }
  hyperliquid:     { enabled: false }
  morpho:          { enabled: false }
  notifier:        { enabled: true, channel: cli }
```

Loosening any gate beyond its recommended band requires a typed override phrase —
PolyRobin will warn you first.

---

## Quick Start

```bash
# See what's interesting right now
polyrobin scan --category crypto --min-volume 250k

# Get PolyRobin's independent read on a specific market
polyrobin analyze <market-id>
polyrobin why <market-id>          # sources + full rationale card

# Ask for a size (no execution)
polyrobin size <market-id>

# Place it — only fills if the edge still clears the threshold
polyrobin buy YES <market-id> --edge-gated --confirm

# Watch your book
polyrobin portfolio
polyrobin pnl --today
```

---

## Example Flows

### Flow 1 — Find an edge and enter (assisted mode)

```
> polyrobin scan --category crypto --resolving-within 30d
  Found 6 markets clearing volume/liquidity gates. Top by conviction:
  1. "ETH close > $5,000 on Dec 31"   price 0.38 | est 0.47 | edge +9pts

> polyrobin why "ETH close > $5,000 on Dec 31"
  My estimate: 0.47 (conviction 72/100)
  • Onchain: spot-ETF net inflows accelerating (strong, fresh)
  • News: constructive macro reporting (moderate)
  • Sentiment: mildly bullish (weak prior)
  • Resolution: Chainlink close — unambiguous ✅
  EV ≈ +6.2% net of ~0.4% fees, ~0.3% est. slippage.

> polyrobin size "ETH close > $5,000 on Dec 31"
  Suggested $180 (¼-Kelly, vol-adjusted) = 3.6% of bankroll.
  Crypto category exposure 18% → 21.6% (cap 25%). All gates ✅.

> polyrobin buy YES "ETH close > $5,000 on Dec 31" --size 180 --edge-gated
  ✅ Filled 474 shares @ 0.38. tx: 0xabc… Rationale Card saved: RC-1042.
```

### Flow 2 — Hedge a conviction position across protocols

```
> polyrobin hedge-suggest POS-1042
  Position: YES ETH>$5k, $180 notional, directional-long.
  Suggested hedge: Hyperliquid ETH-PERP short, 0.05 ETH (~$170 delta).
  Est. hedge cost (funding, 30d): ~$3.10. Shapes payoff to +EV, lower variance.

> polyrobin hedge POS-1042 --venue hyperliquid --instrument ETH-PERP --confirm
  ✅ Hedge leg placed. Combined position variance ↓ 41%. Both legs linked.
```

### Flow 3 — Fund from Robinhood Chain and target an RWA market

```
> polyrobin bridge 500 USDC from robinhood-chain to polygon
  Bridging 500 USDC. Est. time 3–6 min, cost ~$0.40. bridge-id: BR-77.

> polyrobin markets --tokenized-assets
  3 RWA/RH-linked markets clear gates.

> polyrobin dry-run buy YES <rwa-market-id>
  Full pipeline, zero execution: edge +5.1%, size $120, all gates ✅.
  (Funds mid-bridge treated as unavailable until BR-77 settles.)
```

### Flow 4 — A day the kill-switch does its job

```
> polyrobin pnl --today
  Realized -3.1%, unrealized -2.2%. Combined -5.3% ≥ 5% daily limit.
  🚨 Kill-switch tripped. State: HALT. No new positions will open.
  Open positions held; resolution monitoring continues.

> polyrobin resume
  ⚠️ You are exiting HALT after a limit breach. Type: RESUME TRADING
> RESUME TRADING
  ✅ Resumed. Consider lowering size for the rest of the session.
```

---

## Command Reference

Grouped canonical commands (see [SKILL.md](./SKILL.md) for the full set):

| Category | Examples |
|----------|----------|
| **Funding / RH Chain** | `bridge`, `fund`, `xchain view`, `balance` |
| **Discovery** | `scan`, `watch`, `trending`, `markets --tokenized-assets` |
| **Analysis** | `analyze`, `edge`, `why`, `compare`, `model` |
| **Entry / Sizing** | `size`, `buy`, `snipe`, `limit`, `dry-run` |
| **Hedging** | `hedge`, `hedge-suggest`, `unhedge` |
| **Portfolio** | `portfolio`, `positions`, `pnl`, `health`, `alerts` |
| **Exit** | `exit`, `exit-all`, `claim`, `trailing-stop` |
| **Risk / Config** | `config`, `set`, `gates`, `halt`, `resume`, `panic` |
| **Audit** | `explain`, `audit`, `log` |

---

## Supported Strategies

1. **Conviction Value** *(on by default)* — trade genuine mispricings, ¼-Kelly.
2. **Late-Window Snipe** — exploit end-of-life stale liquidity.
3. **Cross-Venue Arbitrage** — same event, different implied prob across venues.
4. **Event Hedge** — neutralize direction with Hyperliquid/Morpho.
5. **Category Basket** — diversify a thesis within a category cap.
6. **Resolution-Criteria Arbitrage** — profit from unambiguous fine-print gaps.
7. **Robinhood-Chain RWA Plays** — tokenized-asset & RH-ecosystem markets.

All strategies are off by default except Conviction Value. Enable with
`polyrobin strategy enable <name>`.

---

## Integrations

| Integration | Purpose |
|-------------|---------|
| **Polymarket** | Primary market data, execution, resolution |
| **Robinhood Chain** | USDC bridging, cross-chain views, RH/RWA markets |
| **Hyperliquid** | Perp hedging + implied-probability cross-checks |
| **Morpho** | Borrow/lend to finance or hedge (health-factor aware) |
| **News / onchain / sentiment providers** | Probability model inputs |
| **Signer / wallet** | User-controlled signing (keys never leave you) |
| **Notifier** | Resolution + kill-switch alerts (CLI/webhook/push) |

Each adapter exposes `quote() / execute() / status() / health()`. A degraded
adapter downgrades to read-only rather than failing open.

---

## Autonomy Levels

| Level | Behavior |
|-------|----------|
| **Assisted** (default) | Recommends; every trade needs your confirmation |
| **Supervised** | Auto-executes below the confirm threshold, within all gates |
| **Autonomous** | Executes within *all* gates without per-trade confirmation, still HALTs on any kill-switch, reports everything. Opt-in + lower per-trade cap required. |

No autonomy level can disable the hard gates or the kill-switch.

---

## Auditability

- Every decision writes a **Rationale Card** (JSON + human-readable) to
  `~/.polyrobin/audit/`: inputs, sources, timestamps, model version, edge, size
  math, and each gate's result.
- Every trade logs tx hash, chain, fill price, fees, and realized vs. quoted
  slippage.
- Reconstruct any decision: `polyrobin explain <trade-id>`.
- Export the trail: `polyrobin audit --export csv --since 30d`.
- PolyRobin never fabricates data. Missing source → widened uncertainty or
  abstention, never a guess.

---

## FAQ

**Does it trade on its own?** Only if you explicitly enable Supervised or
Autonomous mode — and even then, never outside your gates, and always with a
kill-switch.

**Will it always find a trade?** No. Frequently the correct output is "no edge,
standing down." That's a feature.

**Does it hold my keys?** Never. Signing happens through your configured signer.

**What if a data source disagrees or goes stale?** Conviction collapses and
PolyRobin abstains rather than average noise or act on old data.

**Can it lose money?** Yes. Prediction markets are speculative; see the
disclaimer.

---

## Disclaimer

PolyRobin is a tool for informed, risk-managed participation in prediction
markets. **It is not financial advice.** Prediction markets are speculative and
can lose 100% of staked capital. Availability and legality vary by jurisdiction —
you are solely responsible for compliance with applicable laws and platform
terms. PolyRobin optimizes for disciplined, transparent, auditable decisions; it
cannot guarantee profit and will regularly and correctly recommend doing nothing.

---

## License

MIT © PolyRobin Labs. See [LICENSE](./LICENSE).
