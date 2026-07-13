# Contributing to PolyRobin

Thanks for your interest in improving PolyRobin. This project is a BankrBot
skill, so the "source of truth" is the [`SKILL.md`](./SKILL.md) definition plus
its supporting docs.

## Ground rules

- **Safety is not negotiable.** Any change that could let PolyRobin exceed a risk
  gate, bypass the kill-switch, or act on stale/ambiguous data will be rejected.
  If you touch the Safety Model, explain the risk implications explicitly in your
  PR.
- **Transparency over cleverness.** Every behavior should be explainable to a
  user in plain language. If a feature can't produce a clear Rationale Card, it
  probably doesn't belong.
- **No key handling.** Never introduce code, config, or docs that store, log, or
  transmit private keys or seed phrases.

## How to contribute

1. **Open an issue first** for anything beyond a typo — use the templates in
   `.github/ISSUE_TEMPLATE/`.
2. Fork and branch from `main` (`feat/…`, `fix/…`, or `docs/…`).
3. Make your change and keep the docs in sync — `SKILL.md`, `README.md`, and the
   sample config in `examples/` should never contradict each other.
4. Run validation locally:
   ```bash
   ./scripts/validate.sh
   ```
5. Update [`CHANGELOG.md`](./CHANGELOG.md) under **Unreleased**.
6. Open a PR using the template. Describe *what* changed and *why*, and call out
   any safety-relevant impact.

## What we're looking for

- New strategies (with explicit entry thesis, sizing rule, and exit plan).
- Additional integration adapters that honor the `quote/execute/status/health`
  contract.
- Sharper edge-case handling.
- Docs, examples, and clearer explanations.

## Style

- Markdown wrapped at ~80 columns where practical.
- Command examples use the `polyrobin <verb> <args>` convention.
- Prefer concrete numbers and worked examples over abstractions.

## Code of Conduct

By participating you agree to uphold our
[Code of Conduct](./CODE_OF_CONDUCT.md).
