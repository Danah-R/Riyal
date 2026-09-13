// Best-effort JSON parsing helpers for Lean's data API responses. Exact
// KSA v2 field names weren't confirmed against a live sandbox response
// while building this (no way to make a real authenticated call from that
// environment) — these try several plausible shapes. After a real
// connect, check one live response and adjust if needed.

export function firstString(json: Record<string, unknown>, keys: string[]): string | undefined {
  for (const key of keys) {
    const value = json[key];
    if (typeof value === 'string' && value.length > 0) return value;
  }
  return undefined;
}

export function firstNum(json: Record<string, unknown>, keys: string[]): number | undefined {
  for (const key of keys) {
    const value = json[key];
    if (typeof value === 'number') return value;
    if (typeof value === 'string') {
      const parsed = Number(value);
      if (!Number.isNaN(parsed)) return parsed;
    }
  }
  return undefined;
}

export function extractList(json: unknown, key: string): Record<string, unknown>[] {
  if (Array.isArray(json)) return json as Record<string, unknown>[];
  if (json && typeof json === 'object') {
    const obj = json as Record<string, unknown>;
    const payload = obj.payload as Record<string, unknown> | undefined;
    if (payload && Array.isArray(payload[key])) return payload[key] as Record<string, unknown>[];
    if (Array.isArray(obj[key])) return obj[key] as Record<string, unknown>[];
  }
  return [];
}

export function maskAccountNumber(raw: string): string {
  if (!raw) return '•••• ••••';
  const last4 = raw.length > 4 ? raw.slice(-4) : raw;
  return `•••• ${last4}`;
}
