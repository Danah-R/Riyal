// Talks to Lean Technologies' auth + data APIs. Holds the Client Secret —
// this only ever runs inside the Supabase Edge Function, never shipped to
// the Flutter app. See https://docs.leantech.me/v2.0-KSA/docs/authentication.

const AUTH_BASE_URL = Deno.env.get('LEAN_AUTH_BASE_URL') ?? 'https://auth.sandbox.sa.leantech.me';
const API_BASE_URL = Deno.env.get('LEAN_API_BASE_URL') ?? 'https://sandbox.sa.leantech.me';

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(
      `Missing required secret ${name}. Set it with: supabase secrets set ${name}=...`,
    );
  }
  return value;
}

let cachedApiToken: string | null = null;
let cachedApiTokenExpiresAt = 0;

async function fetchOAuthToken(scope: string): Promise<{ access_token: string; expires_in: number }> {
  const clientId = requireEnv('LEAN_CLIENT_ID');
  const clientSecret = requireEnv('LEAN_CLIENT_SECRET');

  const response = await fetch(`${AUTH_BASE_URL}/oauth2/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      grant_type: 'client_credentials',
      scope,
    }),
  });

  if (!response.ok) {
    throw new Error(`Lean OAuth token request failed (${response.status}): ${await response.text()}`);
  }

  return response.json();
}

/** App-scoped token, used for customer creation and data endpoints. */
export async function getApiAccessToken(): Promise<string> {
  const now = Date.now();
  if (cachedApiToken && now < cachedApiTokenExpiresAt) {
    return cachedApiToken;
  }
  const data = await fetchOAuthToken('api');
  cachedApiToken = data.access_token;
  cachedApiTokenExpiresAt = now + (data.expires_in - 30) * 1000;
  return cachedApiToken;
}

/** Customer-scoped token, handed to the Flutter app for Lean.connect(). */
export async function getCustomerAccessToken(customerId: string): Promise<string> {
  const data = await fetchOAuthToken(`customer.${customerId}`);
  return data.access_token;
}

export async function createLeanCustomer(appUserId: string): Promise<{ customer_id: string }> {
  const token = await getApiAccessToken();
  const response = await fetch(`${API_BASE_URL}/customers/v1/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({ app_user_id: appUserId }),
  });

  if (!response.ok) {
    throw new Error(`Lean create-customer failed (${response.status}): ${await response.text()}`);
  }

  return response.json();
}

export async function listEntities(customerId: string): Promise<unknown> {
  const token = await getApiAccessToken();
  const response = await fetch(
    `${API_BASE_URL}/customers/v1/${encodeURIComponent(customerId)}/entities`,
    { headers: { Accept: 'application/json', Authorization: `Bearer ${token}` } },
  );

  if (!response.ok) {
    throw new Error(`Lean list-entities failed (${response.status}): ${await response.text()}`);
  }

  return response.json();
}

async function fetchData(path: string, entityId: string): Promise<unknown> {
  const token = await getApiAccessToken();
  const url = `${API_BASE_URL}${path}?entity_id=${encodeURIComponent(entityId)}`;
  const response = await fetch(url, {
    headers: { Accept: 'application/json', Authorization: `Bearer ${token}` },
  });

  if (!response.ok) {
    throw new Error(`Lean data fetch ${path} failed (${response.status}): ${await response.text()}`);
  }

  return response.json();
}

export const fetchAccounts = (entityId: string) => fetchData('/data/v2/accounts', entityId);
export const fetchTransactions = (entityId: string) => fetchData('/data/v2/transactions', entityId);
export const fetchBalance = (entityId: string) => fetchData('/data/v2/balances', entityId);
