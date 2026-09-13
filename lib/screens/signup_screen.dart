import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import '../widgets/gold_coin_painter.dart';
import '../widgets/auth_coin_flip.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.85,
            colors: [
              AppColors.cardBorder,
              AppColors.surface,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - 56),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'R I Y A L',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Strings.t('brand_tagline'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: AuthCoinFlip(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.32,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: GoldCoinPainter(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Big, translucent riyal watermark
                                      // sitting behind the form, on the
                                      // coin's face.
                                      ExcludeSemantics(
                                        child: FractionallySizedBox(
                                          widthFactor: 0.6,
                                          heightFactor: 0.6,
                                          child: Opacity(
                                            opacity: 0.14,
                                            child: SvgPicture.asset(
                                              'assets/icons/saudi_riyal.svg',
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    AppColors.surface,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(34),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: SizedBox(
                                            width: 440,
                                            height: 600,
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    Strings.t('signup_heading'),
                                                    style: const TextStyle(
                                                      fontFamily: 'Georgia',
                                                      fontSize: 36,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.surface,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    Strings.t(
                                                      'create_account_subtitle',
                                                    ),
                                                    style: const TextStyle(
                                                      color: AppColors.staff,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  _field(
                                                    fieldKey: 'full_name',
                                                    icon: Icons
                                                        .person_outline_rounded,
                                                    autofillHints: const [
                                                      AutofillHints.name,
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _field(
                                                    fieldKey: 'email',
                                                    icon: Icons.email_outlined,
                                                    autofillHints: const [
                                                      AutofillHints.email,
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _field(
                                                    fieldKey: 'password',
                                                    icon: Icons
                                                        .lock_outline_rounded,
                                                    password: true,
                                                    autofillHints: const [
                                                      AutofillHints.newPassword,
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _field(
                                                    fieldKey:
                                                        'confirm_password',
                                                    icon: Icons
                                                        .lock_outline_rounded,
                                                    password: true,
                                                    autofillHints: const [
                                                      AutofillHints.newPassword,
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    width: 250,
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40,
                                                          ),
                                                      gradient:
                                                          const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Color(0xFFD9C68A),
                                                              AppColors
                                                                  .goldDark,
                                                              Color(0xFFD9C68A),
                                                            ],
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .goldDark
                                                              .withValues(
                                                                alpha: 0.28,
                                                              ),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                            0,
                                                            3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: FilledButton(
                                                      onPressed: _signUp,
                                                      style: FilledButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors.surface,
                                                        foregroundColor:
                                                            const Color(
                                                              0xFFFFF0C2,
                                                            ),
                                                        minimumSize:
                                                            const Size.fromHeight(
                                                              42,
                                                            ),
                                                        shape:
                                                            const StadiumBorder(),
                                                      ),
                                                      child: Text(
                                                        Strings.t(
                                                          'create_account_button',
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 1.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          Strings.t('have_account_signin'),
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ),
                      Text(
                        Strings.t('demo_no_account'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            Strings.t('finances_on_device'),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String fieldKey,
    required IconData icon,
    required List<String> autofillHints,
    bool password = false,
  }) {
    final hint = Strings.t(fieldKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: TextFormField(
        controller: fieldKey == 'password' ? _passwordController : null,
        keyboardType: fieldKey == 'email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        obscureText: password && _obscurePassword,
        autofillHints: autofillHints,
        autocorrect: false,
        enableSuggestions: !password,
        textInputAction: fieldKey == 'confirm_password'
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: fieldKey == 'confirm_password'
            ? (_) => _signUp()
            : null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return Strings.f('enter_your_field', hint.toLowerCase());
          }
          if (fieldKey == 'email' &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
            return Strings.t('valid_email_error');
          }
          if (fieldKey == 'password' && value.length < 8) {
            return Strings.t('password_length_error');
          }
          if (fieldKey == 'confirm_password' &&
              value != _passwordController.text) {
            return Strings.t('passwords_no_match');
          }
          return null;
        },
        style: const TextStyle(color: AppColors.surface, fontSize: 16),
        cursorColor: AppColors.goldDark,
        decoration: InputDecoration(
          isDense: true,
          errorStyle: const TextStyle(fontSize: 10),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.staff),
          prefixIcon: Icon(icon, color: AppColors.staff, size: 22),
          suffixIcon: password
              ? IconButton(
                  tooltip: _obscurePassword
                      ? Strings.t('show_password')
                      : Strings.t('hide_password'),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.staff,
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFFFFAE9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.goldDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColors.goldDark.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.surface, width: 2),
          ),
        ),
      ),
    );
  }
}
