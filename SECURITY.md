# Security Policy

PolyRobin moves real money on real markets. Security is a first-class concern.

## Core security guarantees

- **PolyRobin never holds your keys.** All signing is delegated to a
  user-controlled signer (hardware wallet, WalletConnect, or keystore). Private
  keys and seed phrases never appear in config, logs, or Rationale Cards.
- **Config never contains secrets.** `~/.polyrobin/config.yaml` references a
  signer by type, not by key material.
- **Fail closed, not open.** A degraded integration downgrades to read-only; an
  anomaly (unexpected balance/allowance change) triggers HALT and requires human
  intervention.
- **Hard gates cannot be silently bypassed.** No autonomy level disables the
  seven risk gates or the kill-switch.

## Reporting a vulnerability

If you discover a security vulnerability, please **do not open a public issue**.

1. Email the maintainers at `security@polyrobin.example` (replace with the real
   contact for your deployment) with a description and reproduction steps.
2. Allow a reasonable disclosure window before any public discussion.
3. We aim to acknowledge reports within 72 hours.

## Scope

In scope:
- Logic that could exceed configured risk gates.
- Any path that could leak key material, allowances, or signer access.
- Bridge/hedge flows that could strand or misroute funds.
- Kill-switch or HALT bypasses.

Out of scope:
- Losses from ordinary market movement (prediction markets are speculative).
- Third-party protocol outages (Polymarket, Hyperliquid, Morpho, Robinhood
  Chain) outside PolyRobin's control.

## Operator hardening checklist

- Use a hardware signer for any non-trivial bankroll.
- Start in `assisted` autonomy; only escalate after reviewing Rationale Cards.
- Set conservative gates; loosen deliberately, never by default.
- Keep `~/.polyrobin/audit/` on durable storage and review it regularly.
- Scope wallet allowances to the minimum required and revoke stale approvals.
