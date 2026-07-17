# Changelog

All notable changes to PolyRobin are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Social bets are held-stakes, not escrow/multisig — corrected to match BankrBot's
  real rails.** The spec claimed PolyRobin could route a no-market friend bet into a
  peer-to-peer **escrow contract** or a **2-of-3 multisig**, and into a **custom
  Polymarket market**. BankrBot has none of those rails: per
  [docs.bankr.bot](https://docs.bankr.bot/features/polymarket/) it bets on **listed**
  Polymarket markets only (search, bet, positions, redeem) and moves funds by
  **transfer to a handle or address** — it does not deploy escrow contracts, create
  multisigs, or create markets. Instructing it to do so told BankrBot to perform
  actions it cannot execute. The social-bet model is now honest: **(1)** a listed
  market first — the only trustless path; **(2)** otherwise a **trust-based side bet**
  whose stakes sit with an agreed stake-holder via a BankrBot transfer, adjudicated
  against the resolution statement and settled by a confirmed, human-issued transfer,
  with the trust assumption stated up front; **(3)** if no market exists and no one
  will hold the stakes, PolyRobin says the bet can't be run safely and stands down.
  Updated the frontmatter description, the "What PolyRobin is (and isn't)" bullet, the
  Social & Friend Bets section (path selection, tracking/settlement, worked example,
  fairness rules), the example command, and the two social-bet edge cases. The
  parsing, resolution statement, refusal of ambiguous/manipulable bets, objective-
  source requirement, gate-5 confirmation, and bad-faith guard are unchanged — none of
  that value depended on rails that don't exist.

## [1.2.0] — 2026-07-17

**Data Integrity.** Live testing on `@bankrbot` caught v1.1.0 echoing the market
price back as its "estimate," labeling figures "net" without ever subtracting the
fee, and manufacturing conviction on coin-flip markets. This release fixes all
three and writes the rules into `SKILL.md` so it cannot drift back.

### Added
- **Exact formulas pinned in `SKILL.md`** — edge (`p − c`), gross EV
  (`EV_gross = (p − c)/c`), slippage from order size vs. book depth, fees, net EV
  (`EV_net = gross − slippage − fees`), full Kelly `f* = (p − c)/(1 − c)`, and
  fractional-Kelly sizing capped by every gate and rounded down — with a worked
  check that makes the math reproducible.
- **Low-price EV guard** — because `c` is the denominator of `EV_gross`, a
  half-cent error in `p` at `c = 0.045` prints as +11%. Below 10¢, `p` must be
  sourced to the half-cent or the market is a stand-down, whatever the EV figure
  claims.
- **Sample Rationale Cards** — `examples/rationale-card.json` (machine-readable)
  and `examples/rationale-card.md` (human-readable) show a full worked
  recommendation: independent probability, source-tagged inputs, edge/EV math,
  Kelly size math, all 7 gate results, and state.
- **README: "How funds flow through Polymarket"** — a plain-language walkthrough of
  the money path for a prediction-market bet (funded in USDC on Polygon, executed
  by BankrBot from the user's own wallet on confirmation, resolved via the UMA
  oracle, redeemed 1-for-$1), using a bucketed "How many times will Elon tweet this
  week?" market as the worked example. Reinforces that PolyRobin never custodies
  funds.
- **README `$PR` token section** — documents the PolyRobin community token on
  Robinhood Chain (durable fields only, no hardcoded price/mcap) and states plainly
  that the token is **separate from the skill** and plays no part in its analysis
  or gates.
- **Explicit X interaction model** — `SKILL.md` and `README.md` document that
  BankrBot lives on X: you tag `@bankrbot`, and he replies to you on X.
- **`▶️ Demo quick-start`** block in `SKILL.md` — a safe, four-message sequence that
  ends in analysis or a `Confirm?` prompt (no funds move), for live demos.

### Changed
- **Estimate before price, or no estimate.** Form the probability `p` from sources
  first; only then fetch the market price `c`. Never derive `p` from `c`. An echoed
  price is not an estimate, and neither is a sub-cent nudge away from one — if there
  is no source-backed reason to move off the price, there is no edge: say so and
  stand down.
- **The spread is a cost, not an edge.** Both YES and NO are fetched from their own
  live quotes, never as `1 − the other side`. The gap between them is what you pay
  to enter and exit; an edge smaller than the fetched spread is not a trade on
  either side. Quoting a 2.8¢ spread and calling it a 2.5¢ edge is refused.
- **Fees are read, not assumed.** The taker rate comes from the market's live
  `feeSchedule`. A market is fee-free only when it carries `feesEnabled: false`; a
  zero `rate` is a different and rarer thing. Taker cost is `rate × c × (1 − c)` per
  share, or `rate × (1 − c)` as a fraction of stake — largest at low prices. "Net"
  never prints without the deduction visible.
- **Stand down on coin-flips.** Fifteen-minute BTC/ETH/SOL up-or-down markets are
  ~50/50 noise and taker fees eat any thin edge; PolyRobin reports them as
  near-efficient and stands down instead of manufacturing a >4% edge.
- **Never quote unfetched data.** Every price, depth, and volume figure must come
  from a real market pulled that turn and cited by title and slug/URL — no number
  that wasn't fetched, and no false precision (e.g. a to-the-cent volume like
  `$14,823,508.62`).
- **Never invent a bankroll.** A dollar size is valid only against the user's
  actual, known balance; otherwise size is expressed as a percentage of bankroll
  and the user is asked for the stake. Two markets in one session must imply the
  same bankroll.
- **A gate you could not run has not passed.** Without the user's bankroll and open
  positions, the exposure limits (gates 1/2/3/6) are unverified — the reply now says
  "can't check your limits — tell me your bankroll," never "all clear."
- **Analysis and sizing are separate.** Discovery/analysis is the default and returns
  both sides quoted with a read on where the value sits — no stake, no dollar amount,
  no "reply yes to place." Picking a side is its own turn: bet intent without a named
  side returns both fetched quotes and the spread, then a question; YES is never
  assumed. Sizing runs only on the side the user names; a side chosen against the edge
  is honored if it clears the gates (flagged, not overridden). Sizes above ¼-Kelly are
  honored when every gate still clears, and are always flagged — never allowed silently.
- **Plain-English replies.** Cents, not decimals (`39¢`, not `0.58`); the spread reads
  as "2¢ to trade," liquidity as "deep enough to exit ✅." No jargon on X (no est / conv
  / EV / gross / net / pts / gate-N / Kelly). The fee appears in the same breath as the
  value ("3¢ of value, ~1¢ fee, ~2¢ left"), never "after fees." Roughly four lines, under
  500 characters; the full gross→net math, the Kelly working, and every gate line by line
  live behind `why`. A reply containing a bare `p`, `<price>`, `[URL]`, or `$<S>` means a
  field was never filled and the reply is wrong.
- **Universal coverage.** The category table is a set of examples, not an allow-list:
  if Polymarket lists it, PolyRobin covers it.
- **Meridian Predict confirmed** as the real venue name (Robinhood + Susquehanna); the
  earlier fictional rename and the geo-restriction caveats were removed.
- **Validator now checks safety invariants, not just YAML** — `scripts/validate.sh`
  verifies every `risk.*` value sits inside its safe gate band, that gate 5
  (confirmation) is `true`, and that the sample Rationale Card documents all 7 gates
  with the confirmation gate present.
- **Corrected the sample Rationale Card math** (`examples/rationale-card.{json,md}`):
  gross→net EV reconciles (slippage shown, ≈0 when order ≪ depth), the fee is read from
  the market's `feeSchedule` rather than assumed, Kelly uses the explicit formula, and
  gate 5 (confirmation) reads PENDING until `yes`.

### Fixed
- **Reply template was being echoed with unfilled placeholders** (`est p`, `conv
  n/100`, `+xpts`, `[URL]`). Replaced the `<token>` template in `SKILL.md` with a
  filled example plus an explicit "never output a literal placeholder" rule.
- **CI** — repointed the CHANGELOG footer links at resolvable URLs and synced the
  README version badge with the `SKILL.md` frontmatter version.

### Removed
- **Polymarket referral link** from the README.
- **Geo-restriction caveats** on the Robinhood-Chain stock-token rails.

## [1.1.0] — 2026-07-13

### Added
- **Social & Friend Bets** — a new major capability in `SKILL.md`. Turns a
  natural-language friend/group wager (e.g. "bet $100 my friend Tony loses $100
  today on memes") into structured terms (condition, amount, parties, resolution
  criteria, deadline, source), writes a fair and verifiable resolution statement,
  and suggests the best execution path: a real custom market (Polymarket /
  Meridian Predict / Hunch) where one exists, otherwise a peer-to-peer escrow via
  BankrBot wallet tools (escrow contract, multisig, or simple conditional
  transfer). Runs the full 7 safety gates — confirmation required before any funds
  move — and tracks/auto-settles on resolution. Includes a dedicated section,
  example commands, and edge cases.
- **`catalog.json`** — required BankrBot discovery metadata (slug, provider,
  logo, install command); without it the skill is excluded from the catalog.
- **`logo.svg`** — square brand mark.
- **Execution Routing & Chain Targeting** section in `SKILL.md` — forces
  Robinhood Chain by default and forbids silent fallback to Base for Morpho,
  swaps, bridging, and tokenized stocks (fixes the "landed on Base" failure mode).
- `execution` block in the sample config encoding per-action chain targeting.
- Validator now checks `catalog.json`; README documents the real install routes
  (registry PR or `npx skills add`), correcting the earlier mention-a-repo myth.

### Changed
- Reframed PolyRobin as a **decision co-pilot / behavior spec on top of BankrBot's
  existing rails** — explicitly not executable code and not an autonomous trader.
- Execution scope made realistic: Polymarket betting and Robinhood Chain tokenized
  stocks/swaps/bridging run through BankrBot; **Meridian Predict is discovery +
  analysis only** for now, with Polymarket fallback where an equivalent exists.
- Example Commands rewritten in natural-language `@bankrbot` style.
- Integration Hooks split into "rails BankrBot already supports" vs "PolyRobin's
  own analysis layer".
- Config restructured to decision parameters only (`venues` + `rails`), no keys.
- Added `bankrbot`, `social-bets`, and `friend-bets` tags.
- Reworked the skill around a dual-venue model with **Robinhood Chain as a
  first-class home venue** (Meridian Predict + tokenized event markets)
  alongside Polymarket.
- Frontmatter: single-sentence description, focused tag set, added
  `visibility: public`.
- Safety model restated as **7 hard gates** (adding an always-on confirmation
  gate and a conviction+EV gate), with HALT-on-volatility, a kill-switch, and a
  separate emergency `pause`.
- Bridging now always routes funds **into Robinhood Chain** with optimal routing
  (no fixed source chain).
- Added Chainlink oracle integration and auto-claiming on resolution.
- Repository scaffolding: sample config, CI validation, security policy,
  contribution guide, issue/PR templates.

## [1.0.0] — 2026-07-13

### Added
- Initial PolyRobin skill (`SKILL.md`) — autonomous, safety-first prediction
  market agent for Polymarket.
- Seven-gate safety model with kill-switch and HALT state.
- Decision pipeline: discover → model → price edge → size → confirm → execute →
  manage → resolve → report.
- Independent probability modeling from news, onchain, sentiment, and
  resolution-criteria analysis, with a 0–100 conviction score.
- Fractional-Kelly, volatility-adjusted position sizing with portfolio caps.
- Seven composable strategies (Conviction Value on by default).
- Cross-protocol hedging via Hyperliquid perps and Morpho borrow/lend.
- Robinhood Chain support: USDC bridging, cross-chain views, RWA markets.
- Three autonomy levels (assisted / supervised / autonomous).
- Full auditability via per-decision Rationale Cards.
- Professional `README.md` and MIT `LICENSE`.

[Unreleased]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/PhantomCapAI/PolyRobin/releases/tag/v1.0.0
