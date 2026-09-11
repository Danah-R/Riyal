import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
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
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
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
                      const Text(
                        'Your spending, in balance.',
                        style: TextStyle(
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
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 40,
                                      offset: const Offset(0, 22),
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: GoldCoinPainter(),
                                  child: Padding(
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
                                              Semantics(
                                                label:
                                                    'Saudi emblem: palm tree and crossed swords',
                                                image: true,
                                                child: SizedBox(
                                                  width: 58,
                                                  height: 58,
                                                  child: Image.asset(
                                                    'assets/icons/saudi_emblem.png',
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                    excludeFromSemantics: true,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  fontFamily: 'Georgia',
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.surface,
                                                  height: 1.1,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Create your Riyal account',
                                                style: TextStyle(
                                                  color: AppColors.staff,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              _field(
                                                hint: 'Full name',
                                                icon: Icons
                                                    .person_outline_rounded,
                                                autofillHints: const [
                                                  AutofillHints.name,
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              _field(
                                                hint: 'Email',
                                                icon: Icons.email_outlined,
                                                autofillHints: const [
                                                  AutofillHints.email,
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              _field(
                                                hint: 'Password',
                                                icon:
                                                    Icons.lock_outline_rounded,
                                                password: true,
                                                autofillHints: const [
                                                  AutofillHints.newPassword,
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              _field(
                                                hint: 'Confirm password',
                                                icon:
                                                    Icons.lock_outline_rounded,
                                                password: true,
                                                autofillHints: const [
                                                  AutofillHints.newPassword,
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                width: 250,
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  gradient:
                                                      const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xFFFFF4C6),
                                                          AppColors.goldDark,
                                                          Color(0xFFFFE9A6),
                                                        ],
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.goldDark
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
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
                                                        const Color(0xFFFFF0C2),
                                                    minimumSize:
                                                        const Size.fromHeight(
                                                          42,
                                                        ),
                                                    shape:
                                                        const StadiumBorder(),
                                                  ),
                                                  child: const Text(
                                                    'CREATE ACCOUNT',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Bundled SVG avoids relying on currency glyph support in fonts.
                                              Container(
                                                width: 44,
                                                height: 44,
                                                padding: const EdgeInsets.all(
                                                  9,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.goldDark,
                                                    width: 0.7,
                                                  ),
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/saudi_riyal.svg',
                                                  semanticsLabel: 'Saudi riyal',
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                        AppColors.surface,
                                                        BlendMode.srcIn,
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Already have an account? Sign in',
                          style: TextStyle(color: AppColors.gold),
                        ),
                      ),
                      const Text(
                        'Demo only - No account is created',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Your finances stay on your device',
                            style: TextStyle(
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
    required String hint,
    required IconData icon,
    required List<String> autofillHints,
    bool password = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: TextFormField(
        controller: hint == 'Password' ? _passwordController : null,
        keyboardType: hint == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        obscureText: password && _obscurePassword,
        autofillHints: autofillHints,
        autocorrect: false,
        enableSuggestions: !password,
        textInputAction: hint == 'Confirm password'
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: hint == 'Confirm password' ? (_) => _signUp() : null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter your ${hint.toLowerCase()}';
          }
          if (hint == 'Email' &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
            return 'Enter a valid email';
          }
          if (hint == 'Password' && value.length < 8) {
            return 'Use at least 8 characters';
          }
          if (hint == 'Confirm password' && value != _passwordController.text) {
            return 'Passwords do not match';
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
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
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
