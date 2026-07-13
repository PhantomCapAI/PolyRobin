# Changelog

All notable changes to PolyRobin are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added (installability + chain-safety)
- **`catalog.json`** — required BankrBot discovery metadata (slug, provider,
  logo, install command); without it the skill is excluded from the catalog.
- **`logo.svg`** — square brand mark.
- **Execution Routing & Chain Targeting** section in `SKILL.md` — forces
  Robinhood Chain by default and forbids silent fallback to Base for Morpho,
  swaps, bridging, and tokenized stocks (fixes the "landed on Base" failure mode).
- `execution` block in the sample config encoding per-action chain targeting.
- Validator now checks `catalog.json`; README documents the real install routes
  (registry PR or `npx skills add`), correcting the earlier mention-a-repo myth.

### Changed (grounded co-pilot rework)
- Reframed PolyRobin as a **decision co-pilot / behavior spec on top of BankrBot's
  existing rails** — explicitly not executable code and not an autonomous trader.
- Execution scope made realistic: Polymarket betting and Robinhood Chain tokenized
  stocks/swaps/bridging run through BankrBot; **Meridian Predict is discovery +
  analysis only** for now, with Polymarket fallback where an equivalent exists.
- Example Commands rewritten in natural-language `@bankrbot` style.
- Integration Hooks split into "rails BankrBot already supports" vs "PolyRobin's
  own analysis layer".
- Config restructured to decision parameters only (`venues` + `rails`), no keys.
- Added `bankrbot` tag.

### Changed (earlier iterations)
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
- New section structure: Overview, Safety Model, Supported Markets, Example
  Commands (Discovery / Analysis / Trading / Monitoring / Hedging & Bridging),
  Integration Hooks, Edge Cases & Risk Handling, Auditability & Transparency.
- Added Chainlink oracle integration and auto-claiming on resolution.
- Updated sample config and validator to match the new structure.

### Added
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

[Unreleased]: https://github.com/PhantomCapAI/PolyRobin/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/PhantomCapAI/PolyRobin/releases/tag/v1.0.0
