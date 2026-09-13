import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import '../widgets/gold_coin_painter.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.arTitle,
    required this.enTitle,
    required this.arBody,
    required this.enBody,
    required this.accent,
  });

  final IconData icon;
  final String arTitle;
  final String enTitle;
  final String arBody;
  final String enBody;
  final Color accent;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _languageSelected = false;
  bool _saving = false;

  bool get _arabic => AppLocale.locale.value.languageCode == 'ar';
  String t(String ar, String en) => _arabic ? ar : en;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.account_balance_wallet_outlined,
      arTitle: 'كل التزاماتك في مكان واحد',
      enTitle: 'Every commitment in one place',
      arBody:
          'تابع الاشتراكات وفواتير الخدمات ومدفوعات الموظفين والبدلات بوضوح.',
      enBody:
          'Track subscriptions, utility bills, household staff payments and allowances clearly.',
      accent: AppColors.subscriptions,
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      arTitle: 'اعرف موعد الدفع قبل وصوله',
      enTitle: 'Know before every payment',
      arBody:
          'استلم تنبيهات التجديد ومواعيد الدفع والتجارب المجانية في الوقت المناسب.',
      enBody:
          'Get timely reminders for renewals, due dates and free-trial endings.',
      accent: AppColors.utilities,
    ),
    _OnboardingSlide(
      icon: Icons.savings_outlined,
      arTitle: 'راجع حاجتك ووفر أكثر',
      enTitle: 'Review what you need and save',
      arBody:
          'المراجعة الشهرية تسألك عن استخدامك وتقترح الإلغاء أو الإيقاف أو فحص الخطة السنوية.',
      enBody:
          'The monthly check-in reviews your usage and suggests cancelling, pausing or checking an annual plan.',
      accent: AppColors.gold,
    ),
    _OnboardingSlide(
      icon: Icons.auto_graph_outlined,
      arTitle: 'افهم إنفاقك مع ريال',
      enTitle: 'Understand your spending with Riyal',
      arBody:
          'شاهد الإحصائيات وفرص التوفير، واطلب من ريال بوت شرحها بالعربية أو الإنجليزية.',
      enBody:
          'Explore analytics and saving opportunities, then ask Riyal Bot to explain them in Arabic or English.',
      accent: Color(0xFF82C7A8),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _chooseLanguage(String code) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await AppLocale.set(Locale(code));
    } catch (error) {
      debugPrint('Onboarding language save failed: $error');
      AppLocale.locale.value = Locale(code);
      AppSettings.instance.languageCode = code;
    }
    if (!mounted) return;
    setState(() {
      _languageSelected = true;
      _saving = false;
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await AppSettings.instance.completeOnboarding();
    } catch (error) {
      debugPrint('Onboarding completion save failed: $error');
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _languageSelected
            ? _buildSlides()
            : _LanguageChoice(
                key: const ValueKey('language-choice'),
                saving: _saving,
                onArabic: () => _chooseLanguage('ar'),
                onEnglish: () => _chooseLanguage('en'),
              ),
      ),
    ),
  );

  Widget _buildSlides() => Column(
    key: const ValueKey('onboarding-slides'),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
        child: Row(
          children: [
            const Text(
              'R I Y A L',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _saving ? null : _finish,
              child: Text(
                t('تخطي', 'Skip'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (value) => setState(() => _page = value),
          itemBuilder: (context, index) => _SlidePage(
            slide: _slides[index],
            arabic: _arabic,
            pageIndex: index,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == _page ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.gold : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_page > 0) ...[
                  IconButton.outlined(
                    tooltip: t('السابق', 'Back'),
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeInOutCubic,
                    ),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    icon: Icon(
                      _arabic
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    label: Text(
                      _page == _slides.length - 1
                          ? t('ابدأ مع ريال', 'Start with Riyal')
                          : t('التالي', 'Next'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Icon(
                            _page == _slides.length - 1
                                ? Icons.login_rounded
                                : _arabic
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    super.key,
    required this.saving,
    required this.onArabic,
    required this.onEnglish,
  });

  final bool saving;
  final VoidCallback onArabic;
  final VoidCallback onEnglish;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, constraints.maxHeight - 48),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 116,
                  height: 116,
                  child: CustomPaint(
                    painter: const NavCoinPainter(),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.surface,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to Riyal',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'مرحبًا بك في ريال',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Choose your preferred language\nاختر لغتك المفضلة',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 32),
                _LanguageButton(
                  label: 'العربية',
                  icon: Icons.language_rounded,
                  onPressed: saving ? null : onArabic,
                ),
                const SizedBox(height: 12),
                _LanguageButton(
                  label: 'English',
                  icon: Icons.translate_rounded,
                  onPressed: saving ? null : onEnglish,
                ),
                if (saving) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppColors.gold),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.gold),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 17),
        side: const BorderSide(color: AppColors.goldDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({
    required this.slide,
    required this.arabic,
    required this.pageIndex,
  });

  final _OnboardingSlide slide;
  final bool arabic;
  final int pageIndex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, constraints.maxHeight - 24),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SlideVisual(
                  icon: slide.icon,
                  accent: slide.accent,
                  pageIndex: pageIndex,
                ),
                const SizedBox(height: 34),
                Text(
                  arabic ? slide.arTitle : slide.enTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 29,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  arabic ? slide.arBody : slide.enBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SlideVisual extends StatelessWidget {
  const _SlideVisual({
    required this.icon,
    required this.accent,
    required this.pageIndex,
  });

  final IconData icon;
  final Color accent;
  final int pageIndex;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 230,
    height: 230,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
        ),
        Transform.rotate(
          angle: pageIndex.isEven ? -0.18 : 0.18,
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.32)),
            ),
          ),
        ),
        SizedBox(
          width: 128,
          height: 128,
          child: CustomPaint(
            painter: const NavCoinPainter(),
            child: Icon(icon, color: AppColors.surface, size: 52),
          ),
        ),
        Positioned(
          top: 20 + (pageIndex * 3),
          right: 25,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          left: 26,
          bottom: 28 + (pageIndex * 2),
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
