import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/notifications_store.dart';
import '../theme/app_theme.dart';
import '../widgets/account_section.dart';
import '../widgets/coin_back_button.dart';
import 'profile_screen.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = AppSettings.instance;
  bool _saving = false;
  Future<void> _save(bool enabled, int days) async {
    setState(() => _saving = true);
    try {
      await _settings
          .save(enabled: enabled, days: days)
          .timeout(const Duration(seconds: 5));
      NotificationsStore.instance.refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save settings. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      leading: const CoinBackButton(),
      title: const Text('Settings'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AccountPageHeader(
                icon: Icons.settings_outlined,
                title: 'Make Riyal yours',
                subtitle: 'A few preferences for your everyday payments.',
              ),
              AccountSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PAYMENT REMINDERS',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.gold,
                      title: const Text(
                        'Upcoming payments',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Renewals, utility bills and staff payments.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      value: _settings.paymentReminders,
                      onChanged: _saving
                          ? null
                          : (value) => _save(value, _settings.reminderDays),
                    ),
                    const Divider(color: AppColors.cardBorder, height: 28),
                    const Text(
                      'Remind me before payment',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final days in [1, 3, 5, 7])
                          ChoiceChip(
                            label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                            selected: _settings.reminderDays == days,
                            selectedColor: AppColors.gold,
                            labelStyle: TextStyle(
                              color: _settings.reminderDays == days
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                            ),
                            onSelected: _saving || !_settings.paymentReminders
                                ? null
                                : (_) => _save(true, days),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Applies to new reminders in your in-app inbox. Existing messages stay in your history. New-item notifications remain enabled.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    if (_saving)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(color: AppColors.gold),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AccountSection(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: AppColors.gold,
                      ),
                      title: const Text('Personal details'),
                      subtitle: const Text('Name, email and phone number'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.gold,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.cardBorder),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.payments_outlined,
                        color: AppColors.gold,
                      ),
                      title: Text('Currency'),
                      subtitle: Text('Saudi riyal'),
                      trailing: Text(
                        'SAR',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.cardBorder),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.dark_mode_outlined,
                        color: AppColors.gold,
                      ),
                      title: Text('Appearance'),
                      subtitle: Text('Riyal dark theme'),
                      trailing: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AccountSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.gold),
                        SizedBox(width: 10),
                        Text(
                          'Your data, on your device',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Profile edits, preferences and notification read status are saved locally. Payment data is currently a demo and resets when the app restarts. No bank account is connected.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AccountSection(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.gold,
                  ),
                  title: const Text('Help & feedback'),
                  subtitle: const Text('Quick answers and suggestions'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.gold,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ContactUsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'RIYAL · Student demo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
