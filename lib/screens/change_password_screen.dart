import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _controllers = List.generate(3, (_) => TextEditingController());
  final _hidden = [true, true, true];
  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      leading: const CoinBackButton(),
      title: const Text('Change password'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Demo form. Password changes will be available when account authentication is connected.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: _controllers[i],
                      obscureText: _hidden[i],
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: [
                          'Current password',
                          'New password',
                          'Confirm new password',
                        ][i],
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        suffixIcon: IconButton(
                          tooltip: _hidden[i]
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () =>
                              setState(() => _hidden[i] = !_hidden[i]),
                          icon: Icon(
                            _hidden[i]
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a password';
                        }
                        if (i == 1 && value.length < 8) {
                          return 'Use at least 8 characters';
                        }
                        if (i == 1 && value == _controllers[0].text) {
                          return 'Choose a different password';
                        }
                        if (i == 2 && value != _controllers[1].text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo validation passed. No password has been changed.',
                        ),
                      ),
                    );
                    for (final c in _controllers) {
                      c.clear();
                    }
                  },
                  child: const Text('Change password'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
