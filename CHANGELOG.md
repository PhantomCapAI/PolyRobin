# Changelog

All notable changes to PolyRobin are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
