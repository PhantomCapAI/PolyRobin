# PolyRobin v1.2.0 — Data Integrity

Live testing on **@bankrbot** caught v1.1.0 doing three things a prediction-market
analyst must never do: echoing the market's own price back as its "estimate,"
labeling figures "net" while never subtracting the fee, and manufacturing
conviction on coin-flip markets. This release fixes all three — and writes the
rules into `SKILL.md` so it cannot drift back.

## The rules that fix it

- **Estimate before price, or no estimate.** Form the probability `p` from sources
  first; only then fetch the price `c`. An echoed price — or a sub-cent nudge off
  one — is not an estimate. No source-backed reason to move off the price means no
  edge: say so and stand down.
- **The spread is a cost, not an edge.** Both YES and NO come from their own live
  quotes, never `1 − the other side`. The gap is what you pay to enter and exit; an
  edge smaller than the fetched spread is not a trade on either side.
- **Fees are read, not assumed.** The taker rate comes from the market's live
  `feeSchedule`. A market is fee-free only when it carries `feesEnabled: false` — a
  zero `rate` is a different, rarer thing. Taker cost is `rate × c × (1 − c)` per
  share, or `rate × (1 − c)` as a fraction of stake — largest at low prices,
  precisely where it is easiest to overlook. "Net" never prints without the
  deduction visible.
- **Low-price EV guard.** Because `c` is the denominator of `EV_gross`, a half-cent
  error in `p` at `c = 0.045` prints as +11%. Below 10¢, `p` must be sourced to the
  half-cent or the market is a stand-down, whatever the EV figure claims.
- **Stand down on coin-flips.** Fifteen-minute BTC, ETH, and SOL up-or-down markets
  are roughly 50/50 noise, and taker fees eat any thin edge. PolyRobin does not
  invent an edge that isn't there.
- **Never quote unfetched data.** Every price, depth, and volume figure must come
  from a real market pulled that turn and cited by title and slug or URL — no
  number that wasn't fetched, and no false precision.
- **Never invent a bankroll.** A dollar size is valid only against the user's actual
  balance; otherwise size is expressed as a percentage of bankroll, and PolyRobin
  asks for the stake.
- **A gate you could not run has not passed.** Without the user's bankroll and open
  positions, the exposure gates are unverified — the reply now says "can't check
  your limits — tell me your bankroll," never "all clear."

## Analysis and sizing are separate

- **Analysis is the default.** Both sides are quoted, with a read on where the value
  sits. No stake, no dollar amount, no "reply yes to place."
- **Picking a side is its own turn.** Bet intent without a named side returns both
  quotes and the spread, then asks which side. YES is never assumed.
- **Sizing runs only on the side the user names.** A side chosen against the edge is
  honored if it clears the gates — flagged, not overridden. Sizes above ¼-Kelly are
  honored when every gate still clears, and are always flagged.

## Replies humans can read

Cents, not decimals (`39¢`). The spread reads as "2¢ to trade," liquidity as "deep
enough to exit ✅." No jargon on X. The fee appears in the same breath as the value —
"3¢ of value, ~1¢ fee, ~2¢ left" — never "after fees," which hides the subtraction.
Roughly four lines, under 500 characters; the full math, the Kelly working, and every
gate line by line live behind `why`.

## Also in this release

- **Universal coverage.** The category table is a set of examples, not an allow-list:
  if Polymarket lists it, PolyRobin covers it.
- **Exact formulas pinned** in `SKILL.md`: edge, gross EV, slippage, fees, net EV,
  full Kelly `f* = (p − c) / (1 − c)`, and fractional-Kelly sizing capped by every
  gate and rounded down — with a worked check that makes the math reproducible.
- **Sample Rationale Cards** at `examples/rationale-card.json` and
  `examples/rationale-card.md`, with the fee now read from the market's `feeSchedule`
  rather than assumed.
- **The validator now checks safety invariants**, not just YAML.
- **The X interaction model is explicit:** you tag `@bankrbot`, and he replies to you
  on X.
- The README explains how funds flow through Polymarket and adds a `$PR` token
  section. The token is separate from the skill and plays no part in its analysis or
  gates.
- The Polymarket referral link has been removed.
- **Meridian Predict** is confirmed as the real venue (Robinhood and Susquehanna),
  and the geo-restriction caveats are gone.
- CI: resolvable changelog links, and the README version synced to 1.2.0.

## Still true

PolyRobin is a behavior spec for @bankrbot, not executable code. It holds no keys and
moves no funds. Every material action requires your explicit `yes`. "No edge, standing
down" remains a frequent and correct output.

See [`CHANGELOG.md`](./CHANGELOG.md) for the itemized list of changes.
