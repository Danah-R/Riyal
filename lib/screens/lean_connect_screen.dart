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
        country: LeanCountry.sa,
        language: isArabic ? LeanLanguage.ar : LeanLanguage.en,
        permissions: const [
          LeanPermissions.accounts,
          LeanPermissions.balance,
          LeanPermissions.transactions,
        ],
        callback: (response) => Navigator.of(context).pop(response),
      ),
    );
  }
}
