# Riyal on Supabase

Replaces the earlier local Express backend. Postgres holds accounts,
transactions, and subscriptions; one Edge Function holds the Lean Client
Secret and does the OAuth exchange + data fetches (writing results into
Postgres along the way).

**I could not run any of this from the environment that built it** — no
`supabase` CLI, `deno`, or `node` was available there. This is written
carefully against Lean's documented API and Supabase's standard Edge
Function conventions, but treat the first real run as the actual test.

## Setup

```bash
# from the repo root
supabase login
supabase link --project-ref <your-project-ref>   # after creating the project in the dashboard
supabase db push                                  # applies supabase/migrations/0001_init.sql
supabase secrets set LEAN_CLIENT_ID=... LEAN_CLIENT_SECRET=...
supabase functions deploy lean --no-verify-jwt
```

`--no-verify-jwt` because this app has no real Supabase Auth sign-in yet —
see the note at the top of `migrations/0001_init.sql` about what that means
for the (currently permissive) row-level security policies.

## Local dev

```bash
supabase start                    # local Postgres + functions runtime
cp supabase/functions/.env.example supabase/functions/.env   # fill in real values
supabase functions serve lean --env-file supabase/functions/.env
```

## Pointing the Flutter app at it

Add to the app's `.env` (not `supabase/functions/.env` — that one's for the
function):

```
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your anon/public key, from Project Settings -> API>
```

The anon key is meant to be public-ish (it only grants what your RLS
policies allow) — safe to keep in the app's `.env`, unlike the Lean Client
Secret or the Supabase *service role* key (never put the service role key
in the Flutter app; it bypasses RLS entirely and only belongs in the Edge
Function, where Supabase injects it automatically as
`SUPABASE_SERVICE_ROLE_KEY`).

## Tables

- `lean_customers` — maps this device's locally-generated id to the Lean
  `customer_id` created for it.
- `bank_accounts` — one row per connected entity, updated whenever the
  `accounts` route is called.
- `bank_transactions` — upserted (by `lean_transaction_id`) whenever the
  `transactions` route is called.
- `subscriptions` — read/written directly by the Flutter app via
  `supabase_flutter` (no secret involved, so no Edge Function needed for
  this one).

## Endpoints (Edge Function `lean`)

- `POST /customer` `{ deviceId }` → `{ customerId }` (creates once, reuses after)
- `POST /connect-token` `{ customerId }` → `{ accessToken }`
- `GET /entities?deviceId=...`
- `GET /accounts?entityId=...&deviceId=...` (also upserts into `bank_accounts`)
- `GET /transactions?entityId=...&deviceId=...` (also upserts into `bank_transactions`)
- `GET /balance?entityId=...` (passthrough, not persisted — no balances table was requested)
