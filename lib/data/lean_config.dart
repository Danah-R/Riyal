import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads Lean Technologies configuration from the (gitignored) `.env` file
/// loaded at startup — never hardcode the app token in source.
class LeanConfig {
  LeanConfig._();

  static String get appToken {
    final token = dotenv.env['LEAN_APP_TOKEN'];
    if (token == null || token.isEmpty) {
      throw StateError(
        'LEAN_APP_TOKEN is not set. Add it to .env (see .env.example).',
      );
    }
    return token;
  }

  static bool get isSandbox =>
      (dotenv.env['LEAN_SANDBOX'] ?? 'true').toLowerCase() != 'false';
}
