import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:office_politics/app.dart';
import 'package:office_politics/features/account/application/session_controller.dart';
import 'package:office_politics/features/account/data/local_account_repository.dart';
import 'package:office_politics/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1334, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRepositoryProvider.overrideWith(
            (ref) => LocalAccountRepository(),
          ),
        ],
        child: const OfficePoliticsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('auth screen switches language', (tester) async {
    await pumpApp(tester);

    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.text('简体'));
    await tester.pumpAndSettle();
    expect(find.text('登录'), findsOneWidget);

    await tester.tap(find.text('繁體'));
    await tester.pumpAndSettle();
    expect(find.text('登入'), findsOneWidget);
  });

  testWidgets('create account, paywall, subscribe, export, delete', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password1');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Arcade'), findsOneWidget);
    expect(find.text('Free'), findsWidgets);

    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();
    expect(find.text('Coach is a subscription'), findsOneWidget);

    await tester.tap(find.text('Subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Premium'), findsWidgets);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Export my data'), findsOneWidget);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    await tester.tap(find.text('Export my data'));
    await tester.pumpAndSettle();
    expect(find.text('Account export copied'), findsOneWidget);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('localizations cover the three launch languages', (tester) async {
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('zh')));
    expect(
      AppLocalizations.supportedLocales,
      contains(const Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW')),
    );
  });
}
