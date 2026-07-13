# Changelog

All notable changes to PolyRobin are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Token section (README)** — documents the **PolyRobin ($PR)** community token on
  **Robinhood Chain** (contract `0x41f2…8ba3`, PR/WETH pair) with links to live price
  (GeckoTerminal) and Bankr. Durable fields only — no hardcoded price/mcap. Clarifies
  the token is separate from the skill's logic. Reworded the "not a new contract"
  bullets in `README.md` and `SKILL.md` so they no longer read as contradictory.
- **`Sizing & EV — exact formulas` section in `SKILL.md`** — pins down the math so
  BankrBot computes it correctly and reproducibly: `EV_gross = (p − c)/c`,
  `EV_net = gross − slippage − fees` (slippage from order size vs. depth; Polymarket
  fee ≈ 0), and Kelly `f* = (p − c)/(1 − c)` × fractional-Kelly × vol-adj, capped by
  gates and rounded down. Includes a worked check. Fixes an observed live error where
  BankrBot reported a wildly overstated "full Kelly" (~0.56 vs. the correct ~0.20).

### Added
- **X-sized response format** — `SKILL.md` now instructs a **compact default reply**
  that fits one X post (verdict + one-line EV/size + one-line gate summary + `yes`/
  `why`), with the full multi-section Rationale Card reserved for the `why` command.
  Prevents truncated/spammy replies on X while keeping full transparency on demand.

### Changed
- **Data-integrity non-negotiable** — PolyRobin must never quote a price, depth, or
  volume it didn't actually retrieve; it must cite the real market by title + slug/
  URL, and if no real market matches, say so and route social bets to escrow rather
  than inventing a market or its numbers.
- **Flag requested sizes above ¼-Kelly** — `SKILL.md` now instructs that if a user
  names a size larger than the volatility-adjusted ¼-Kelly recommendation, it's
  honored only if it still clears every gate and is **explicitly flagged** (e.g.
  "note: $20 exceeds ¼-Kelly ($14.50)"), never silently allowed.
- **Corrected the sample Rationale Card math** (`examples/rationale-card.{json,md}`):
  gross→net EV now reconciles (slippage shown, ≈0 when order ≪ depth), Kelly uses the
  explicit formula, and gate 5 (confirmation) reads PENDING until `yes`.

### Added (earlier)
- **Sample Rationale Card** — `examples/rationale-card.json` (machine-readable) and
  `examples/rationale-card.md` (human-readable) show a full worked recommendation:
  independent probability, source-tagged inputs, edge/EV math, Kelly size math, all 7
  gate results, and state — so users can see PolyRobin's output before installing.
- **`▶️ Demo quick-start`** block in `SKILL.md` — a safe, four-message sequence that
  ends in analysis or a `Confirm?` prompt (no funds move), for live demos.

### Changed
- **Validator now checks safety, not just syntax** — `scripts/validate.sh` verifies
  every `risk.*` value sits inside its safe gate band and that gate 5 (confirmation)
  is `true`, and validates the sample Rationale Card (7 gates, confirmation present).
- **Tightened Robinhood-Chain wording** in `SKILL.md` and `README.md` to state the
  funding-vs-execution split plainly (funding/bridging/swaps/tokenized assets live on
  RH Chain; prediction execution still mostly Polymarket), removing the "first-class"
  ambiguity flagged in review.

### Added (prior)
- **"How you use it" (README) + X interaction model made explicit** — documents that
  BankrBot lives on **X**, so PolyRobin is used by tagging `@bankrbot` in a post or
  reply and he responds on X. Reflected in the `SKILL.md` frontmatter description and
  the Example Commands intro as well.
- **README: "How funds flow through Polymarket"** — a plain-language walkthrough of
  the money path for a prediction-market bet (funded in USDC on Polygon, executed by
  BankrBot from the user's own wallet on confirmation, resolved via the UMA oracle,
  redeemed 1-for-$1), using a "How many times will Elon tweet this week?" bucketed
  market as the worked example. Reinforces that PolyRobin never custodies funds.

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

[Unreleased]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/PhantomCapAI/PolyRobin/releases/tag/v1.0.0
