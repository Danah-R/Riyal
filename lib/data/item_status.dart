import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme/app_theme.dart';

/// A subscription/tracked item's lifecycle state, shown as the details
/// page's status badge. Subscriptions can reach all four values (via the
/// Pause/Cancel actions); People only ever use active/paused; Utility
/// bills have no action that changes this and stay active.
enum ItemStatus { active, trial, cancelled, paused }

extension ItemStatusDisplay on ItemStatus {
  String get label => switch (this) {
    ItemStatus.active => Strings.t('status_active'),
    ItemStatus.trial => Strings.t('status_trial'),
    ItemStatus.cancelled => Strings.t('status_cancelled'),
    ItemStatus.paused => Strings.t('status_paused'),
  };

  Color get color => switch (this) {
    ItemStatus.active => AppColors.statusActive,
    ItemStatus.trial => AppColors.statusTrial,
    ItemStatus.cancelled => AppColors.statusCancelled,
    ItemStatus.paused => AppColors.statusPaused,
  };

  static ItemStatus fromName(String? name) => ItemStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => ItemStatus.active,
  );
}
