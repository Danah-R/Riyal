import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Talks to the `lean` Supabase Edge Function — never to Lean directly for
/// anything that needs the Client Secret (customer creation, connect-token
/// generation, data fetches). See supabase/README.md.
class LeanService {
  LeanService._();
  static final instance = LeanService._();

  Future<Map<String, dynamic>> _invoke(
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
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map && details['error'] != null
          ? details['error'] as String
          : 'Request failed (${e.status})';
      throw LeanServiceException(message);
    }
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
  Future<String?> latestEntityId(String deviceId) async {
    final body = await _invoke(
      '/entities',
      method: HttpMethod.get,
      query: {'deviceId': deviceId},
    );
    final entities = (body['entities'] ?? body['payload']) as Object?;
    final list = entities is List
        ? entities
        : (entities is Map && entities['entities'] is List
              ? entities['entities'] as List
              : const []);
    if (list.isEmpty) return null;
    final last = list.last;
    if (last is Map<String, dynamic>) {
      return (last['entity_id'] ?? last['id']) as String?;
    }
    return null;
  }

  /// Also causes the Edge Function to upsert the account into the
  /// `bank_accounts` table.
  Future<Map<String, dynamic>> fetchAccounts({
    required String entityId,
    required String deviceId,
  }) => _invoke(
    '/accounts',
    method: HttpMethod.get,
    query: {'entityId': entityId, 'deviceId': deviceId},
  );

  /// Also causes the Edge Function to upsert rows into the
  /// `bank_transactions` table.
  Future<dynamic> fetchTransactions({
    required String entityId,
    required String deviceId,
  }) => _invoke(
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
