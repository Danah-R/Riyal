import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Thin wrapper around Supabase Auth (email/password). Login/signup screens
/// call [signIn]/[signUp] directly and surface [AuthException.message] on
/// failure rather than this class translating every possible error itself.
class AuthStore {
  AuthStore._();
  static final instance = AuthStore._();

  User? get currentUser => supabase.auth.currentUser;

  /// Null session after [signUp] means email confirmation is required
  /// (the project's default) — the caller should tell the user to check
  /// their email before they can sign in.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => supabase.auth.signOut();
}
