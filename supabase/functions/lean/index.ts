// Supabase Edge Function: everything that needs the Lean Client Secret,
// plus persisting fetched accounts/transactions into Postgres. Deploy with:
//   supabase functions deploy lean --no-verify-jwt
// (no-verify-jwt because this demo app has no real Supabase Auth login —
// see the note in supabase/migrations/0001_init.sql.)
//
// Secrets (never committed): supabase secrets set LEAN_CLIENT_ID=... LEAN_CLIENT_SECRET=...

import { createClient } from 'jsr:@supabase/supabase-js@2';
import {
  createLeanCustomer,
  fetchAccounts,
  fetchBalance,
  fetchTransactions,
  getCustomerAccessToken,
  listEntities,
} from '../_shared/leanClient.ts';
import { extractList, firstNum, firstString, maskAccountNumber } from '../_shared/parsing.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function adminClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const url = new URL(req.url);
  // Supabase invokes this at .../functions/v1/lean/<route> — strip the
  // function's own name so routing below doesn't need to know it.
  const path = url.pathname.replace(/^\/(functions\/v1\/)?lean/, '') || '/';
  const admin = adminClient();

  try {
    if (path === '/customer' && req.method === 'POST') {
      const { deviceId } = await req.json();
      if (!deviceId) return json({ error: 'deviceId is required' }, 400);

      const { data: existing } = await admin
        .from('lean_customers')
        .select('customer_id')
        .eq('device_id', deviceId)
        .maybeSingle();
      if (existing) return json({ customerId: existing.customer_id });

      const customer = await createLeanCustomer(deviceId);
      await admin
        .from('lean_customers')
        .insert({ device_id: deviceId, customer_id: customer.customer_id });
      return json({ customerId: customer.customer_id });
    }

    if (path === '/connect-token' && req.method === 'POST') {
      const { customerId } = await req.json();
      if (!customerId) return json({ error: 'customerId is required' }, 400);
      return json({ accessToken: await getCustomerAccessToken(customerId) });
    }

    if (path === '/entities' && req.method === 'GET') {
      const deviceId = url.searchParams.get('deviceId');
      if (!deviceId) return json({ error: 'deviceId query param is required' }, 400);
      const { data } = await admin
        .from('lean_customers')
        .select('customer_id')
        .eq('device_id', deviceId)
        .maybeSingle();
      if (!data) return json({ error: 'No Lean customer for this device yet' }, 404);
      return json(await listEntities(data.customer_id));
    }

    if (path === '/accounts' && req.method === 'GET') {
      const entityId = url.searchParams.get('entityId');
      const deviceId = url.searchParams.get('deviceId');
      if (!entityId || !deviceId) {
        return json({ error: 'entityId and deviceId query params are required' }, 400);
      }
      const data = await fetchAccounts(entityId);
      const accounts = extractList(data, 'accounts');
      if (accounts.length > 0) {
        const raw = (accounts[0].account as Record<string, unknown>) ?? accounts[0];
        await admin.from('bank_accounts').upsert(
          {
            device_id: deviceId,
            entity_id: entityId,
            account_id: firstString(raw, ['account_id', 'id']) ?? null,
            bank_name:
              firstString(raw, ['bank_name', 'institution_name', 'nickname', 'name', 'display_name']) ??
              'Connected bank',
            masked_account_number: maskAccountNumber(
              firstString(raw, ['account_number', 'iban', 'masked_account_number', 'number']) ?? '',
            ),
            status: 'connected',
            last_synced_at: new Date().toISOString(),
          },
          { onConflict: 'device_id,entity_id' },
        );
      }
      return json(data);
    }

    if (path === '/transactions' && req.method === 'GET') {
      const entityId = url.searchParams.get('entityId');
      const deviceId = url.searchParams.get('deviceId');
      if (!entityId || !deviceId) {
        return json({ error: 'entityId and deviceId query params are required' }, 400);
      }
      const data = await fetchTransactions(entityId);
      const transactions = extractList(data, 'transactions');
      const rows = transactions
        .map((raw) => {
          const leanTransactionId = firstString(raw, ['id', 'transaction_id']);
          const description = firstString(raw, ['description', 'narrative', 'merchant_name']);
          const amount = firstNum(raw, ['amount']);
          const occurredAt = firstString(raw, ['timestamp', 'date', 'booking_date']);
          if (!leanTransactionId || !description || amount === undefined || !occurredAt) {
            return null;
          }
          return {
            device_id: deviceId,
            entity_id: entityId,
            lean_transaction_id: leanTransactionId,
            description,
            amount: Math.abs(amount),
            occurred_at: occurredAt,
          };
        })
        .filter((row): row is NonNullable<typeof row> => row !== null);
      if (rows.length > 0) {
        await admin
          .from('bank_transactions')
          .upsert(rows, { onConflict: 'device_id,lean_transaction_id' });
      }
      return json(data);
    }

    if (path === '/balance' && req.method === 'GET') {
      const entityId = url.searchParams.get('entityId');
      if (!entityId) return json({ error: 'entityId query param is required' }, 400);
      return json(await fetchBalance(entityId));
    }

    return json({ error: `No route for ${req.method} ${path}` }, 404);
  } catch (error) {
    console.error(error);
    return json({ error: error instanceof Error ? error.message : String(error) }, 502);
  }
});
