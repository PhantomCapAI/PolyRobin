# 🏹 PolyRobin

**A safety-first prediction-market co-pilot for Polymarket + Robinhood Chain — an analyst that guides execution, not a black-box trader.**

PolyRobin is a **BankrBot skill** (a behavior spec, *not* executable code). It
upgrades BankrBot's decision-making on prediction markets: it builds an
**independent probability estimate**, only surfaces **real edges** with the math
shown, runs every idea through **7 hard safety gates**, and then **guides
execution through the rails BankrBot already has** — Polymarket betting, Robinhood
Chain tokenized stocks / swaps / bridging, Hyperliquid perps, and Morpho. Every
trade requires your explicit confirmation.

[![Skill](https://img.shields.io/badge/BankrBot-Skill-6C5CE7)](./SKILL.md)
[![Version](https://img.shields.io/badge/version-1.1.0-blue)](./SKILL.md)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Safety](https://img.shields.io/badge/mode-safety--first-critical)](#-safety-cheat-sheet)

> **New to Polymarket?** Trade on the largest prediction market →
> **[polymarket.com](https://polymarket.com/?r=PolyRobin)**
> *(referral link — signing up through it supports PolyRobin's development. Not an
> endorsement to trade; markets are risky and can lose 100% of stake.)*

---

## Table of Contents

- [What it is](#what-it-is)
- [How you use it](#how-you-use-it)
- [🛡️ Safety Cheat Sheet](#-safety-cheat-sheet)
- [Supported Markets](#supported-markets)
- [Example Flows](#example-flows)
- [How funds flow through Polymarket](#how-funds-flow-through-polymarket)
- [Install](#install)
- [Configuration](#configuration)
- [What runs where](#what-runs-where)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## What it is

- ✅ **A decision layer** — discovery, independent modeling, edge detection,
  conviction scoring, Kelly sizing, risk gating, and transparent reasoning.
- ✅ **An execution *guide*** — hands BankrBot a clear, confirmed instruction and
  monitors the result.
- ❌ **Not an autonomous trader** — never bets, bridges, or hedges without your `yes`.
- ❌ **Not a new venue or contract** — it adds judgment on top of BankrBot's
  existing integrations.

**Robinhood Chain (realistic scope):** the split, plainly — **funding, bridging,
swaps, and tokenized assets are live on Robinhood Chain; prediction execution is
still mostly Polymarket today.** Robinhood Chain / **Meridian Predict** prediction
markets are **discovery + analysis only for now** (new venue) — PolyRobin falls
back to Polymarket for execution where an equivalent market exists, and says so.

---

## How you use it

PolyRobin runs on **BankrBot, which lives on X (Twitter)** — so you place and manage
everything by **tagging `@bankrbot` in a post or reply on X**. He reads your request,
runs PolyRobin's analysis, and **replies to you on X** with the edge, the math, and a
confirmation prompt before any money moves. There's no dashboard and no separate app:
if you can post on X, you can use it.

```
@bankrbot using the polyrobin skill, put $20 on tonight's fight — size it and show the math
@bankrbot using the polyrobin skill, bet $100 my friend Tony loses $100 today on memes
```

He replies in-thread with his independent probability, the edge and size math, the 7
gates' status, and a `Confirm?` — nothing executes until you reply `yes` on X.

---

## 🛡️ Safety Cheat Sheet

Conservative defaults, all configurable. **Gate 5 (confirmation) can't be disabled.**

| # | Gate | Default |
|---|------|---------|
| 1 | Daily loss limit | **5%** of bankroll → breach trips HALT |
| 2 | Max exposure per market | **10%** |
| 3 | Max exposure per category | **25%** |
| 4 | Conviction + edge threshold | **≥65/100 AND EV ≥ +4% net** |
| 5 | Confirmation required | **every material action** 🔒 always on |
| 6 | Total deployed cap | **60%** |
| 7 | Liquidity / exitability floor | **$50k depth · $250k volume** |

**HALT triggers:** extreme volatility · stale/disagreeing oracles · conflicting
data sources · 3 losses in 24h.
**Emergency controls:** `pause` (soft freeze) · `halt` (no new positions) ·
`panic` (kill-switch: HALT + snapshot + cancel working orders) · `resume`.
**Golden rules:** stricter gate wins · no gate bypassed silently · keys never
touch PolyRobin · ambiguous-resolution markets are never recommended.

---

## Supported Markets

| Category | Discovery | Execution today |
|----------|-----------|-----------------|
| Politics · Crypto · Sports · Macro · Weather | Polymarket (+ RH Chain where listed) | Polymarket (live) |
| RWAs / tokenized assets | Robinhood Chain | Guided via BankrBot RH-Chain rails |
| Tokenized stock events (Meridian Predict) | Robinhood Chain | **Analysis now · Polymarket fallback** |

---

## Example Flows

**Put $20 on the fight tonight**
```
You:  @bankrbot PolyRobin, should I put $20 on <fighter> tonight? size it and show the math
PR:   Market found on Polymarket. My est 0.58 vs price 0.52 → edge +6pts, EV ≈ +4.9%.
      Conviction 68/100. Suggested $20 (¼-Kelly), within all 7 gates ✅. Confirm?
You:  yes
PR:   ✅ BankrBot placed $20 YES. Rationale Card saved.
```

**Analyze a Robinhood Chain / Meridian market (analysis-only)**
```
You:  @bankrbot use PolyRobin to scan Robinhood Chain for tokenized-stock event markets
PR:   Found 3 on Meridian Predict (analysis-only, new venue). Top: "NVDA beats Q3 EPS"
      — my est 0.63 vs 0.55, edge +8pts. No native execution yet; equivalent exists on
      Polymarket — want me to execute there instead?
```

**Guard rails doing their job**
```
You:  @bankrbot PolyRobin, go bigger on politics
PR:   ⚠️ Category cap (gate 3) would exceed 25%. Stricter gate wins — I won't size up.
      You can raise the cap explicitly, but I'd advise against it here.
```

---

## How funds flow through Polymarket

**Short version: PolyRobin never touches your money.** It decides *whether* and
*how much*; **BankrBot** carries out the transfer from **your own wallet**, and only
after you reply `yes`. Prediction-market bets settle on **Polymarket (Polygon)** in
**USDC** — everything else PolyRobin guides stays on Robinhood Chain.

Here is the full path of a single dollar, using a real Polymarket-style market:

> **Market:** *"How many times will Elon tweet this week?"* — a multi-outcome market
> split into buckets (e.g. `<100`, `100–149`, `150–199`, `200–249`, `250+`). Each
> bucket is its own **YES/NO outcome share** that pays **$1 if it's right and $0 if
> it's wrong**. The price of a share (between $0.00 and $1.00) *is* the market's
> implied probability — a share at `0.32` means the market thinks that bucket has a
> ~32% chance.

**1. Analyze (no money moves).** PolyRobin builds its *own* probability for each
bucket from posting history, recent cadence, and news, compares that to the share
prices, and looks for a bucket where its estimate beats the price by enough to clear
the edge gate. If nothing clears, it stands down — no bet.

**2. Size + gate + confirm.** For the bucket with an edge (say **`150–199`** priced
at `0.28` while PolyRobin estimates `0.38`), it computes a fractional-Kelly size,
runs all **7 safety gates**, and shows you the math. **Nothing is spent yet** — gate
5 requires your explicit `yes`.

**3. Fund the venue.** Bets need **USDC on Polygon** (Polymarket's collateral).
Robinhood Chain is your home base, so if that's where your funds sit, BankrBot
**bridges the USDC into Polygon first**, and PolyRobin accounts for bridge latency in
time-sensitive markets. Your keys stay yours — PolyRobin never holds them.

**4. Place the order (your funds, your signature).** On your `yes`, BankrBot submits
the order to Polymarket's on-chain order book and spends **your USDC to buy YES
shares of the `150–199` bucket** at the going price. Example: $28 buys 100 shares at
`0.28`. The shares sit in **your** Polymarket position — a contract *you* control,
not PolyRobin and not a PolyRobin-held pool.

**5. Resolve.** At week's end, Polymarket's resolution mechanism (the **UMA optimistic
oracle**) records the actual tweet count. Exactly one bucket wins. **Winning shares
redeem 1-for-$1; losing shares go to $0.** If Elon posted 172 times, your 100
`150–199` shares are now worth **$100** (bought for $28).

**6. Settle back.** PolyRobin tracks the resolution, notifies you, and — again only on
your `yes` — has BankrBot **redeem the winning shares back to USDC** in your wallet,
which can then bridge back to Robinhood Chain. Every step is written to a Rationale
Card in `~/.polyrobin/audit/`.

```
Your wallet (USDC)
   │  ┌── PolyRobin: estimate → edge → size → 7 gates ─┐   (no funds move)
   │  └──────────────── you reply `yes` ───────────────┘
   ▼
[BankrBot] bridge USDC → Polygon ──► buy YES shares of the chosen bucket on Polymarket
   ▼
Your Polymarket position (shares you control)
   ▼
UMA oracle resolves ──► winning shares redeem $1 each, losers $0
   ▼
[BankrBot] redeem → USDC back in your wallet  (you confirm)  ──► optional bridge home
```

**What you actually pay:** the cost of the shares (your stake) plus Polygon network
gas and any spread/slippage between the quoted and filled price — PolyRobin folds
those into the net-EV math *before* asking you to confirm, so the edge it quotes is
after costs, not before. It never fronts, pools, or custodies funds, and it will not
size a bet it can't cleanly exit (gate 7).

---

## Install

`SKILL.md` lives on the **`main`** branch of this repo. Point BankrBot at it:

```
install the polyrobin skill from https://github.com/PhantomCapAI/PolyRobin
```

Then talk to it **on X** — tag `@bankrbot` in a post or reply, e.g.
`@bankrbot using the polyrobin skill, find crypto markets resolving this week` — and
he replies to you on X.

For local development:
```bash
git clone https://github.com/PhantomCapAI/PolyRobin.git
cd PolyRobin
cp examples/config.yaml ~/.polyrobin/config.yaml   # tune your gates
./scripts/validate.sh                              # check SKILL.md + config
```

---

## Configuration

Copy [`examples/config.yaml`](./examples/config.yaml) to `~/.polyrobin/config.yaml`.
It holds **decision parameters only** — gates, Kelly fraction, venue scope.
Execution runs through BankrBot; **no private keys ever go in config.**
`./scripts/validate.sh` checks the config parses *and* that every gate value sits
inside its safe band (and that gate 5 confirmation stays on).

**Want to see what PolyRobin actually outputs?** Every recommendation is logged as a
**Rationale Card**. See a full worked sample:
[`examples/rationale-card.md`](./examples/rationale-card.md) (readable) ·
[`examples/rationale-card.json`](./examples/rationale-card.json) (machine-readable).

---

## What runs where

| Concern | Owner |
|---------|-------|
| Placing bets, swaps, bridging, perps, lending | **BankrBot** (existing rails) |
| Independent probability, edge, conviction, sizing | **PolyRobin** (this skill) |
| The 7 gates, HALT, kill-switch, confirmations | **PolyRobin** |
| Signing / custody of funds | **You / your wallet** — never PolyRobin |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Run `./scripts/validate.sh` before a PR
(CI runs it too), keep `SKILL.md` / `README.md` / `examples/config.yaml`
consistent, and report vulnerabilities privately per [SECURITY.md](./SECURITY.md).

---

## Disclaimer

PolyRobin is a decision-support tool, **not financial advice.** Prediction markets
are speculative and can lose 100% of staked capital. Availability and legality vary
by jurisdiction — you are solely responsible for compliance with applicable laws and
platform terms. PolyRobin cannot guarantee profit and will regularly and correctly
recommend doing nothing.

---

## License

MIT © PolyRobin Labs. See [LICENSE](./LICENSE).
