import 'package:flutter/material.dart';
import 'package:lean_sdk_flutter/lean_sdk_flutter.dart';

import '../data/lean_config.dart';
import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';

/// Thin wrapper around the Lean webview widget — pops with the
/// [LeanResponse] once the sandbox bank-login flow finishes (success,
/// error, or the user backing out mid-flow via the coin back button, which
/// pops with null).
class LeanConnectScreen extends StatelessWidget {
  const LeanConnectScreen({
    super.key,
    required this.customerId,
    required this.accessToken,
  });

  final String customerId;
  final String accessToken;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocale.locale.value.languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const CoinBackButton(),
      ),
      body: Lean.connect(
        appToken: LeanConfig.appToken,
        customerId: customerId,
        accessToken: accessToken,
        isSandbox: LeanConfig.isSandbox,
        showLogs: true,
        country: LeanCountry.sa,
        language: isArabic ? LeanLanguage.ar : LeanLanguage.en,
        permissions: const [
          LeanPermissions.accounts,
          LeanPermissions.balance,
          LeanPermissions.transactions,
        ],
        // Required for Open Banking banks to appear at all — without these,
        // Lean's own webview JS hides every OB bank (silently, as "No
        // available banks") since it has nowhere to send the customer back
        // to after the real bank's auth step.
        //
        // Tried `leanlink://success` (the scheme lean_web_client.dart
        // intercepts *inside* the WebView, avoiding the Safari bounce
        // below) but it hung indefinitely on Lean's own "we're taking you
        // back" screen — Lean's JS likely validates this must be a real
        // http(s) URL and silently refuses to navigate otherwise. Falling
        // back to a plain https:// URL, which does provably complete the
        // flow (confirmed working), at the cost of a brief bounce to the
        // system browser: the WebView's "external handoff" path
        // (LeanWebClient.handleUrlOverride) opens it via url_launcher and
        // then fires a LeanResponse(status: 'SUCCESS') fallback itself,
        // since no `leanlink://` event preceded it.
        successRedirectUrl: 'https://www.leantech.me/?success=true',
        failRedirectUrl: 'https://www.leantech.me/?success=false',
        callback: (response) => Navigator.of(context).pop(response),
      ),
    );
  }
}
