import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/l10n/app_locale.dart';
import 'package:riyal/screens/login_screen.dart';
import 'package:riyal/screens/signup_screen.dart';

/// Regression coverage for a real bug: the bottom "your finances stay on
/// your device" row had no flex/wrap headroom at all, so it silently
/// RenderFlex-overflowed (and got clipped) on narrower phones — reported
/// as the login screen looking "off" and disproportionate on an iPhone.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget screen,
    Size size,
    String languageCode,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    AppLocale.locale.value = Locale(languageCode);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
  }

  group('LoginScreen', () {
    testWidgets('no overflow at iPhone SE width, English', (tester) async {
      await pump(tester, const LoginScreen(), const Size(375, 667), 'en');
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at iPhone SE width, Arabic', (tester) async {
      await pump(tester, const LoginScreen(), const Size(375, 667), 'ar');
      expect(tester.takeException(), isNull);
    });
  });

  group('SignupScreen', () {
    testWidgets('no overflow at iPhone SE width, English', (tester) async {
      await pump(tester, const SignupScreen(), const Size(375, 667), 'en');
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at iPhone SE width, Arabic', (tester) async {
      await pump(tester, const SignupScreen(), const Size(375, 667), 'ar');
      expect(tester.takeException(), isNull);
    });
  });
}
