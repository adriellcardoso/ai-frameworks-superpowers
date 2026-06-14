# Afiliame — Product Context

Durable product context for the Afiliame engineering/product agent. This is a
**vocabulary and orientation map**, not a copy of any source repo. Keep it
short; the authoritative spec for any given feature lives in Linear (team
Afiliame), not here.

## What Afiliame is

Afiliame is a **multi-tenant SaaS for managing affiliate programs**, aimed at
the **Brazilian market**:

- Language: **pt-BR**. Currency: **BRL**.
- Clients are businesses, identified by **CNPJ**.
- Affiliate payouts are expected via **PIX**.
- Stage: **early** — the work is mostly feature discovery and roadmap shaping,
  so most sessions start from a problem space rather than a fixed spec.

## Domain model (vocabulary map)

Entity hierarchy, roughly top-down:

```
Admin ─▶ Client ─▶ Store ─▶ Integration / UserStoreLink ─▶ Order ─▶ WalletEvent
```

- **Admin** — operates the platform across all tenants.
- **Client** — a tenant business running an affiliate program (CNPJ-identified).
- **Store** — a client's storefront; the unit integrations attach to.
- **Integration** — connection between a Store and an e-commerce platform
  (e.g. **Bagy**, **Dooca**) that supplies orders.
- **UserStoreLink** — links an affiliate user to a store (their participation in
  that store's program).
- **Order** — a purchase pulled from the integration; the thing that gets
  **attributed** to an affiliate.
- **WalletEvent** — an entry in the event-sourced affiliate wallet.

Key behaviors:

- **Order attribution** — an order is attributed to an affiliate by **coupon
  match** or **UTM match**.
- **Commission lifecycle** — an attributed order generates a commission that
  moves through states until it is payable/paid.
- **Event-sourced wallet** — affiliate balances are derived from an ordered log
  of `WalletEvent`s, not a single mutable balance field.
- **RBAC roles** — `USER` (affiliate), `CLIENT` (tenant business), `ADMIN`
  (platform operator).
- **4-stage signup** — onboarding is a multi-step flow (4 stages).

## Tech stack

- **Nx monorepo.**
- **NestJS** server (API).
- **React + Vite** web app.
- **schedule** app — cron/scheduled jobs.
- **Prisma + MongoDB** for persistence, via `@prisma-affiliate/client`.
- E-commerce integrations: **Bagy**, **Dooca**.

## How this plugin uses the context

- New feature / problem space → `afiliame-product:brainstorming-to-linear`
  (refine, then persist the spec + task breakdown to Linear).
- Existing feature follow-up → `afiliame-product:linear-feature-context`
  (load from Linear, write decisions back to Linear).
- Ready to build → `afiliame-product:dispatching-from-linear`
  (materialize Linear tasks into worktree plans, dispatch via superpowers).
