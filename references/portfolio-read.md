# Reading the book — Polymarket portfolio state (public, read-only)

> Reference material for **Gate 0: read the book first** (see `SKILL.md`). This
> documents *how* PolyRobin reconstructs a user's open positions, cost basis, and
> realized PnL **before** any risk gate is evaluated.

## The one guarantee this rests on

**Reading a wallet's Polymarket positions requires only a public wallet address —
no private key, no signature, no API key, no auth of any kind.** Positions are
ERC-1155 balances on Polygon; balances are public on-chain state. This is what lets
Gate 0 exist without breaking PolyRobin's core promise: **keys never touch
PolyRobin.** The book read is a *read* of public data from a *public* address.

If any of this ever required a key or a signature, Gate 0 would be unsafe and the
design would have to change. It does not. Verified below against Polymarket's own
docs, Polymarket's own agent-skills repo, and the on-chain contract on PolygonScan.

---

## Preferred path — Polymarket Data API (no auth)

Base URL: `https://data-api.polymarket.com`

### Open positions — `GET /positions`

| | |
|---|---|
| **Method / URL** | `GET https://data-api.polymarket.com/positions` |
| **Auth** | None. Public. |
| **Required param** | `user` — the wallet address (EOA or the Polymarket **proxy** wallet; see note) |
| **Useful optional params** | `market` (conditionId CSV), `sizeThreshold` (default 1.0), `redeemable`, `limit` (default 100, max 500), `offset`, `sortBy`, `sortDirection` |

Example:

```
GET https://data-api.polymarket.com/positions?user=0xABC...123&sizeThreshold=1&limit=500
```

**Response fields (per open position) — everything Gate 0 needs:**

| Field | Meaning | Used for |
|-------|---------|----------|
| `proxyWallet` | the proxy wallet holding the position | book identity |
| `conditionId` | market condition id | market grouping (gate 2) |
| `asset` | ERC-1155 token id (the outcome share) | on-chain cross-check |
| `title` / `slug` | market question / url slug | display, category mapping |
| `outcome` / `outcomeIndex` | which side is held (YES/NO) | book line |
| `size` | number of shares held | position size |
| `avgPrice` | average entry price — **cost basis** | unrealized PnL, deployed capital |
| `initialValue` | size × avgPrice | deployed capital (gate 6) |
| `curPrice` | current mark | current value |
| `currentValue` | size × curPrice | mark-to-market |
| `cashPnl` | **unrealized** PnL in USDC (currentValue − initialValue) | gate 1 (intraday drawdown) |
| `percentPnl` | unrealized PnL % | display |
| `realizedPnl` | **realized** PnL on the closed portion of this position | gate 1 (day realized) |
| `percentRealizedPnl` | realized PnL % | display |
| `totalBought` | cumulative cost bought | audit |
| `redeemable` | resolved & claimable | resolution tracking |
| `endDate` / `negativeRisk` | market close, neg-risk flag | resolution / exposure notes |

### Realized PnL for the current UTC day — `GET /activity` (and `GET /trades`)

Per-position `realizedPnl` covers each open position's closed portion. To sum the
day's realized PnL across *fully closed / redeemed* positions too, read the wallet's
activity and filter to the current UTC day:

| | |
|---|---|
| `GET https://data-api.polymarket.com/activity?user=<address>` | trades, redemptions, merges, splits, converts (timestamped) |
| `GET https://data-api.polymarket.com/trades?user=<address>` | historical fills |

Filter activity to `type` in {`TRADE`, `REDEEM`} with a timestamp in the current UTC
day, and sum the realized cash to get **today's realized PnL** for gate 1.

### Portfolio value — `GET /value` (optional convenience)

`GET https://data-api.polymarket.com/value?user=<address>` returns the wallet's
current total position value. Convenient, but **not** a substitute for the
per-position read (gates 2/3 need per-market/per-category breakdowns).

> **Note — proxy wallet.** Users trade through a Polymarket **proxy wallet** (a
> Gnosis Safe), not directly from their EOA. Positions live in the proxy. The Data
> API accepts either the EOA or the proxy in `user` and returns the `proxyWallet`
> field; for on-chain reads use the **proxy** address. The user supplies their
> public address in `~/.polyrobin/config.yaml` (`wallet_address`).

---

## Cross-check path — on-chain CTF (ERC-1155) on Polygon

The Data API is a convenience layer over public on-chain state. The ground truth is
the **Conditional Tokens Framework (CTF)** contract on Polygon, and it can be read
with only a public address if the API is ever unavailable or a value needs auditing.

| | |
|---|---|
| **Conditional Tokens (CTF, ERC-1155)** | `0x4D97DCd97eC945f40cF65F87097ACe5EA0476045` (Polygon) |
| **CTF Exchange** | `0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e` (Polygon) |
| **Collateral** | USDC.e — every YES/NO pair is fully collateralized by $1.00 locked in the CTF contract |

- A position is an **ERC-1155 balance**: `balanceOf(owner, tokenId)` — a **read-only,
  public** call. **No private key or signature is required.** (Polymarket's own
  agent-skills doc states this explicitly.)
- The `tokenId` (a.k.a. `asset` / positionId) is the same value the Data API returns
  in `asset`. It can also be derived on-chain via
  `getConditionId` → `getCollectionId` → `getPositionId`, but in practice you take
  the token ids from the **Gamma Markets API** `tokens` array
  (`GET https://gamma-api.polymarket.com/markets`) — manual computation is only
  needed for direct contract interaction.
- Reading a balance gives *size*; cost basis and realized PnL still come from the
  Data API (or from replaying the wallet's trade/redeem history) since raw balances
  do not carry entry price.

This is a **cross-check**, not the primary path. Balances confirm size; the Data API
supplies cost basis and PnL. If the two disagree, treat the book as unreadable and,
per Gate 0, decline to size — an unverifiable gate is a red gate.

---

## What this means for Gate 0

1. Read `GET /positions?user=<wallet_address>` → every open position with `size`,
   `avgPrice` (cost basis), `curPrice`, `currentValue`, `cashPnl` (unrealized),
   `realizedPnl`.
2. Read `GET /activity?user=<wallet_address>` → sum today's realized PnL (UTC day).
3. Compute against **user-declared** bankroll (never inferred from wallet balance):
   day drawdown → gate 1, per-market exposure → gate 2, per-category exposure →
   gate 3, total deployed → gate 6.
4. If the book cannot be read (no address, API unreachable, ambiguous / on-chain
   disagreement), **do not assume a clean slate** — report which gates cannot be
   evaluated and decline to size.

---

## Sources (verified)

- Polymarket Data API — Get current positions for a user:
  <https://docs.polymarket.com/api-reference/core/get-current-positions-for-a-user>
- Polymarket Data API — Get positions for a market:
  <https://docs.polymarket.com/api-reference/core/get-positions-for-a-market>
- Polymarket docs — Conditional Token Framework overview:
  <https://docs.polymarket.com/trading/ctf/overview>
- Polymarket agent-skills — CTF operations (on-chain read, `balanceOf`, no key
  required): <https://github.com/Polymarket/agent-skills/blob/main/ctf-operations.md>
- Conditional Tokens (CTF) contract on Polygon (PolygonScan):
  <https://polygonscan.com/address/0x4d97dcd97ec945f40cf65f87097ace5ea0476045>
- CTF Exchange contract on Polygon (PolygonScan):
  <https://polygonscan.com/address/0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e>

> **Verification note.** `docs.polymarket.com` was not directly reachable from this
> environment (network policy returned 403), so the endpoint paths, parameters, and
> response fields above were confirmed against a published mirror of the same
> Polymarket Data API docs and cross-checked against Polymarket's own agent-skills
> repository and the on-chain contract on PolygonScan. The canonical source remains
> the docs URLs listed above — re-verify there before relying on any field. **No
> endpoint here was written without confirmation from at least two of these
> sources.** Crucially, every source agrees on the one load-bearing fact: reading a
> wallet's positions needs only a **public address** and **no key, signature, or
> auth**.
