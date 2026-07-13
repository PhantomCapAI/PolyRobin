# Sample Rationale Card (human-readable)

> **Illustrative output — not a live recommendation.** PolyRobin writes one of these
> (JSON + this readable form) to `~/.polyrobin/audit/` for **every** recommendation,
> including stand-downs. The machine-readable version is
> [`rationale-card.json`](./rationale-card.json).

---

**Market:** *Will Fighter A win tonight's main event?* · **Venue:** Polymarket (Polygon)
**Resolution:** official promotion result feed — KO/TKO, submission, or decision → YES;
draw or no-contest → NO. **Ambiguity:** low ✅ (single authoritative source, binary).

**Price (YES):** 0.52 · **My independent estimate:** 0.58 · **Conviction:** 68/100

### Why (source-tagged, weighted, timestamped)
| Source | Signal | Weight | Leans |
|--------|--------|:------:|:-----:|
| Historical matchup & form | A is 4–1 last 5, favorable style matchup; B on a 9-month layoff | 0.55 | YES |
| News sentiment | Beat-writer consensus mildly favors A; no injury/weight-cut flags | 0.25 | YES |
| Market microstructure | Line drifted 0.54→0.52 on modest YES volume; no sharp reversal | 0.20 | neutral |

### Edge math
```
gross EV = (0.58 / 0.52) − 1        = +11.5%
− est. slippage on a $20 fill        ≈  1.2%
net EV                               ≈ +4.9%   → clears the +4% gate (thin headroom)
```

### Size math
```
bankroll                 $1,000
¼-Kelly on +4.9% edge  → 2.1% of bankroll
volatility trim (×0.95)→ ~$19.9
recommended size       → $20   (2.0% of bankroll — inside the 10% per-market cap)
```

### The 7 gates
| # | Gate | Status | Detail |
|---|------|:------:|--------|
| 1 | Daily loss limit (5%) | ✅ PASS | Day drawdown 0.0% |
| 2 | Max per market (10%) | ✅ PASS | $20 = 2.0% |
| 3 | Max per category (25%) | ✅ PASS | Sports 2.0% after bet |
| 4 | Conviction ≥65 & net EV ≥+4% | ✅ PASS | 68 and +4.9% |
| 5 | Confirmation required | ⏳ PENDING | Awaiting your `yes` — cannot be bypassed |
| 6 | Total deployed cap (60%) | ✅ PASS | 12% → 14% after bet |
| 7 | Liquidity floor ($50k/$250k) | ✅ PASS | ~$120k depth, ~$1.4M volume |

**State:** HALT off · pause off · kill-switch off.

> **Suggested:** Place $20 YES at ≤0.52 on Polymarket. **Confirm?** Reply `yes` and
> BankrBot places it from your wallet, or ask `why` for the full card. **Nothing has
> moved** — gate 5 is pending.

*Decision-support only, not financial advice. PolyRobin never custodies funds or keys.*
