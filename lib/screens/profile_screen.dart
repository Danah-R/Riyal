import 'package:flutter/material.dart';
import '../data/profile_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';
import '../widgets/gold_coin_painter.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _store = ProfileStore.instance;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _store.load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load saved profile. Showing demo data.'),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _edit(String field) async {
    if (field == 'Joined on') return;
    final result = await showDialog<String>(
      context: context,
      builder: (_) =>
          _EditProfileDialog(field: field, value: _store.values[field]!),
    );
    if (result == null || !mounted) return;
    try {
      await _store.save(field, result);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save changes. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      leading: const CoinBackButton(),
      title: const Text('Profile'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 112,
                      height: 112,
                      child: CustomPaint(
                        painter: NavCoinPainter(),
                        child: Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 56,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _store.values['Full name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your personal details · Demo profile',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    for (final entry in const [
                      ('Full name', Icons.person_outline),
                      ('Email', Icons.email_outlined),
                      ('Phone number', Icons.phone_outlined),
                      ('Joined on', Icons.calendar_month_outlined),
                    ])
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: Icon(entry.$2, color: AppColors.gold),
                          title: Text(
                            entry.$1,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _store.values[entry.$1]!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          trailing: entry.$1 == 'Joined on'
                              ? null
                              : IconButton(
                                  tooltip: 'Edit ${entry.$1}',
                                  onPressed: () => _edit(entry.$1),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.gold,
                                    size: 20,
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      tileColor: AppColors.surface,
                      leading: const Icon(
                        Icons.lock_outline,
                        color: AppColors.gold,
                      ),
                      title: const Text(
                        'Change password',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.gold,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ChangePasswordScreen(),
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

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.field, required this.value});
  final String field, value;
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.value);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    title: Text('Edit ${widget.field}'),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.field == 'Email'
            ? TextInputType.emailAddress
            : widget.field == 'Phone number'
            ? TextInputType.phone
            : TextInputType.name,
        decoration: InputDecoration(
          labelText: widget.field,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return 'This field is required';
          if (widget.field == 'Email' &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
            return 'Enter a valid email';
          }
          if (widget.field == 'Phone number' &&
              !RegExp(
                r'^\+?[0-9]{8,15}$',
              ).hasMatch(text.replaceAll(RegExp(r'[\s()-]'), ''))) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _controller.text.trim());
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
