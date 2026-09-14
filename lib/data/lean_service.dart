import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Talks to the `lean` Supabase Edge Function — never to Lean directly for
/// anything that needs the Client Secret (customer creation, connect-token
/// generation, data fetches). See supabase/README.md.
class LeanService {
  LeanService._();
  static final instance = LeanService._();

  /// Raw response body, untyped — Lean's endpoints don't consistently
  /// return a JSON object (e.g. the entities list comes back as a bare
  /// JSON array), so callers decide how to interpret the shape themselves
  /// rather than this helper forcing a cast that can throw.
  Future<dynamic> _invokeRaw(
    String route, {
    HttpMethod method = HttpMethod.post,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'lean$route',
        method: method,
        body: body,
        queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
      );
      return response.data;
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map && details['error'] != null
          ? details['error'] as String
          : 'Request failed (${e.status})';
      throw LeanServiceException(message);
    }
  }

  Future<Map<String, dynamic>> _invoke(
    String route, {
    HttpMethod method = HttpMethod.post,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final data = await _invokeRaw(route, method: method, body: body, query: query);
    return data as Map<String, dynamic>;
  }

  Future<String> createCustomer(String deviceId) async {
    final result = await _invoke('/customer', body: {'deviceId': deviceId});
    return result['customerId'] as String;
  }

  Future<String> getConnectToken(String customerId) async {
    final result = await _invoke(
      '/connect-token',
      body: {'customerId': customerId},
    );
    return result['accessToken'] as String;
  }

  /// The Flutter SDK's connect callback doesn't include an entity_id, so we
  /// look up the device's connected entities after a successful connect.
  /// Returns the most recently created entity id, or null if none yet.
  ///
  /// Lean's "entities for a customer" endpoint returns a bare JSON array
  /// directly (confirmed by a live 502 stack trace during testing — an
  /// earlier version of this method assumed an `{entities: [...]}` /
  /// `{payload: {...}}` wrapper and crashed on the cast). Handle both the
  /// bare-array shape and a wrapped one defensively.
  Future<String?> latestEntityId(String deviceId) async {
    final data = await _invokeRaw(
      '/entities',
      method: HttpMethod.get,
      query: {'deviceId': deviceId},
    );

    final list = switch (data) {
      List() => data,
      Map() when data['entities'] is List => data['entities'] as List,
      Map() when data['payload'] is List => data['payload'] as List,
      _ => const [],
    };
    if (list.isEmpty) return null;
    final last = list.last;
    if (last is Map<String, dynamic>) {
      return (last['entity_id'] ?? last['id']) as String?;
    }
    return null;
  }

  /// Also causes the Edge Function to upsert the account into the
  /// `bank_accounts` table. Return shape isn't relied on by callers (the
  /// app re-reads `bank_accounts` from Supabase afterwards), so this stays
  /// untyped rather than risking the same bad-cast crash as [latestEntityId].
  Future<dynamic> fetchAccounts({
    required String entityId,
    required String deviceId,
  }) => _invokeRaw(
    '/accounts',
    method: HttpMethod.get,
    query: {'entityId': entityId, 'deviceId': deviceId},
  );

  /// Also causes the Edge Function to upsert rows into the
  /// `bank_transactions` table.
  Future<dynamic> fetchTransactions({
    required String entityId,
    required String deviceId,
  }) => _invokeRaw(
    '/transactions',
    method: HttpMethod.get,
    query: {'entityId': entityId, 'deviceId': deviceId},
  );
}

class LeanServiceException implements Exception {
  LeanServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
