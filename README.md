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
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./SKILL.md)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Safety](https://img.shields.io/badge/mode-safety--first-critical)](#-safety-cheat-sheet)

---

## Table of Contents

- [What it is](#what-it-is)
- [🛡️ Safety Cheat Sheet](#-safety-cheat-sheet)
- [Supported Markets](#supported-markets)
- [Example Flows](#example-flows)
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

**Robinhood Chain (realistic scope):** tokenized stocks / swaps / bridging run on
BankrBot's live RH-Chain rails. Robinhood Chain / **Meridian Predict** prediction
markets are **discovery + analysis only for now** (new venue) — PolyRobin falls
back to Polymarket for execution where an equivalent market exists, and says so.

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

## Install

PolyRobin lives on the **`main`** branch, so BankrBot reads `SKILL.md` from root.

```
@bankrbot install skill PolyRobin from github.com/PhantomCapAI/PolyRobin
```

Then just talk to it: `@bankrbot ask PolyRobin to find crypto markets resolving this week`.

For local development:
```bash
git clone https://github.com/PhantomCapAI/PolyRobin.git
cd PolyRobin
cp examples/config.yaml ~/.polyrobin/config.yaml   # tune your gates
```

---

## Configuration

Copy [`examples/config.yaml`](./examples/config.yaml) to `~/.polyrobin/config.yaml`.
It holds **decision parameters only** — gates, Kelly fraction, venue scope.
Execution runs through BankrBot; **no private keys ever go in config.**

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
