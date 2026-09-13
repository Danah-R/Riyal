/// A transaction fetched from Lean's Data API for a connected bank entity.
///
/// Field mapping is best-effort — see the note on [BankAccount.fromLeanAccountJson]
/// about not having a live sandbox response to confirm exact key names
/// against. [fromLeanJson] tries several plausible shapes.
class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.entityId,
    required this.description,
    required this.amount,
    required this.date,
  });

  final String id;
  final String entityId;

  /// Raw bank-provided description/narrative, e.g. "NETFLIX.COM" — kept
  /// as-is (not translated), matching how the mock charges already treat
  /// bank-statement text.
  final String description;

  /// Positive for money out of the account (a purchase/payment), matching
  /// how this app treats subscription/utility amounts elsewhere.
  final double amount;
  final DateTime date;

  static List<BankTransaction> fromLeanJson({
    required String entityId,
    required dynamic json,
  }) {
    final list = _extractList(json);
    return list
        .whereType<Map<String, dynamic>>()
        .map((raw) => _fromRaw(entityId, raw))
        .whereType<BankTransaction>()
        .toList();
  }

  static List<dynamic> _extractList(dynamic json) {
    if (json is List) return json;
    if (json is Map<String, dynamic>) {
      final payload = json['payload'];
      if (payload is Map<String, dynamic> && payload['transactions'] is List) {
        return payload['transactions'] as List;
      }
      if (json['transactions'] is List) return json['transactions'] as List;
    }
    return const [];
  }

  static BankTransaction? _fromRaw(String entityId, Map<String, dynamic> raw) {
    final id = _firstString(raw, ['id', 'transaction_id']);
    final description = _firstString(raw, [
      'description',
      'narrative',
      'merchant_name',
    ]);
    final amount = _firstNum(raw, ['amount']);
    final dateString = _firstString(raw, ['timestamp', 'date', 'booking_date']);
    final date = dateString != null ? DateTime.tryParse(dateString) : null;

    if (id == null || description == null || amount == null || date == null) {
      return null;
    }
    return BankTransaction(
      id: id,
      entityId: entityId,
      description: description,
      amount: amount.abs().toDouble(),
      date: date,
    );
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static num? _firstNum(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
