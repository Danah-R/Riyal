import 'dart:math';

/// A dependency-free RFC 4122 v4 UUID generator. [Subscription.id] is
/// written into Postgres's `subscriptions.id` column, which is typed
/// `uuid`, so a real spec-compliant string is required (not just any
/// unique string) — not worth pulling in the `uuid` package for this one
/// call site.
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  static String uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10xx

    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
