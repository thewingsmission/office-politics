import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:office_politics/app.dart';
import 'package:office_politics/core/theme/app_theme.dart';
import 'package:office_politics/core/widgets/app_button.dart';
import 'package:office_politics/features/account/application/session_controller.dart';
import 'package:office_politics/features/account/data/local_account_repository.dart';
import 'package:office_politics/features/engineering/data/first_launch_design_draft.dart';
import 'package:office_politics/features/engineering/data/workspace_setup_design_draft.dart';
import 'package:office_politics/features/engineering/domain/design_screen_definition.dart';
import 'package:office_politics/features/engineering/presentation/advice_input_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/auth_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/arcade_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/arcade_game_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/design_back_button.dart';
import 'package:office_politics/features/engineering/presentation/design_avatar.dart';
import 'package:office_politics/features/engineering/presentation/design_preview_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/character_profile_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/colleague_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/engineering_screen.dart';
import 'package:office_politics/features/engineering/presentation/event_editor_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/event_timeline_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/face_lab_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/first_launch_hero_panel.dart';
import 'package:office_politics/features/engineering/presentation/home_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/language_setup_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/leaderboard_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/name_setup_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/office_map_editor_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/people_network_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/privacy_notice_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/relationship_setup_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/relationship_quality_bar.dart';
import 'package:office_politics/features/engineering/presentation/screen_map_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/splash_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/workspace_setup_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/workplace_design_screen.dart';
import 'package:office_politics/features/engineering/presentation/yourself_design_screen.dart';
import 'package:office_politics/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    engineeringScrollOffsetDesignScreen = 0;
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

  testWidgets('engineering screen is the design-mode landing screen', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Office Politics UI Lab'), findsOneWidget);
    expect(find.text('ENGINEERING'), findsNothing);
    expect(find.text('DESIGN MODE'), findsNothing);
    expect(find.textContaining('presentation-ready'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('Screen Map'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('engineering-screen-map-button')),
      findsOneWidget,
    );
    expect(find.text('Home Hub'), findsOneWidget);
    expect(find.text('First Launch'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d+ SCREENS?$').hasMatch(widget.data ?? ''),
      ),
      findsNothing,
    );

    final homeTop = tester.getTopLeft(find.text('Home Screen'));
    final splashTop = tester.getTopLeft(find.text('Splash Screen'));
    expect(homeTop.dy, closeTo(splashTop.dy, 0.1));

    await tester.tap(find.text('Screen Map'));
    await tester.pumpAndSettle();
    expect(find.text('Office Politics Screen Map'), findsOneWidget);
  });

  testWidgets('engineering screen map explains and switches user journeys', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ScreenMapDesignScreen()),
    );
    await tester.pump();

    expect(find.text('Office Politics Screen Map'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('50 SCREENS'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'First launch'));
    await tester.pump();
    expect(find.text('3. WORKSPACE SETUP · 5 SCREENS'), findsOneWidget);
    expect(find.text('Colleague'), findsOneWidget);
    expect(find.text('Relationship Setup'), findsOneWidget);

    await tester.tap(find.text('Coach').first);
    await tester.pump();

    expect(find.text('Coach journey'), findsOneWidget);
    expect(find.text('Advice Input'), findsOneWidget);
    expect(find.text('Reply Simulator Result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('engineering info button reveals the screen description', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('i').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A living office map with quick access to Coach, Events, and People.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('engineering buttons open tailored design previews', (
    tester,
  ) async {
    await pumpApp(tester);

    final adviceInputDesignScreen = find.text('Advice Input Screen');
    await tester.scrollUntilVisible(
      adviceInputDesignScreen,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(adviceInputDesignScreen);
    await tester.pump();
    final scrollOffsetBeforeNavigation = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(scrollOffsetBeforeNavigation, greaterThan(0));
    await tester.tap(adviceInputDesignScreen);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Tell us what happened'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Analyze'), findsOneWidget);

    tester.widget<DesignBackButton>(find.byType(DesignBackButton)).onPressed();
    await tester.pumpAndSettle();
    expect(find.byType(EngineeringScreen), findsOneWidget);
    final restoredScrollOffset = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(restoredScrollOffset, closeTo(scrollOffsetBeforeNavigation, 0.5));
  });

  testWidgets('engineering launches reusable setup screens in correct modes', (
    tester,
  ) async {
    await pumpApp(tester);

    Future<void> openAndVerify(String buttonLabel, String scenarioLabel) async {
      final button = find.text(buttonLabel);
      await tester.scrollUntilVisible(
        button,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('workspace-scenario-selector')),
          matching: find.text(scenarioLabel),
        ),
        findsOneWidget,
      );
      tester
          .widget<DesignBackButton>(find.byType(DesignBackButton))
          .onPressed();
      await tester.pumpAndSettle();
    }

    await openAndVerify('Colleague Screen', 'First Launch');
    await openAndVerify('Relationship Setup Screen', 'First Launch');
    await openAndVerify('Create Colleague', 'Create');
    await openAndVerify('Modify Colleague', 'Modify');
    await openAndVerify('Create Relationship', 'Create');
    await openAndVerify('Modify Relationship', 'Modify');
  });

  testWidgets('all design previews fit a landscape phone', (tester) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final definition in designScreenDefinitions) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: DesignPreviewDesignScreen(definition: definition),
        ),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: '${definition.className} overflowed',
      );
    }
  });

  testWidgets('language design is a complete interactive selector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const LanguageSetupDesignScreen(),
      ),
    );

    expect(find.byType(AppButton), findsAtLeastNWidgets(7));
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('English'), findsWidgets);
    expect(find.textContaining('简体中文'), findsOneWidget);
    expect(find.text('Your office\nYour language'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(
      find.text('Advice and the app interface will use this language.'),
      findsNothing,
    );
    expect(find.textContaining('Device:'), findsNothing);
    expect(find.textContaining('“'), findsNothing);

    final gridTop = tester
        .getTopLeft(find.byKey(const ValueKey('language-grid')))
        .dy;
    await tester.tap(find.textContaining('简体中文'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('language-grid'))).dy,
      gridTop,
    );
    expect(find.text('选择语言'), findsOneWidget);
    expect(find.text('你的办公室\n你的语言'), findsOneWidget);
    expect(find.text('继续'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('language-grid'))).dy,
      gridTop,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('first-launch screens share the same left hero panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final screen in <Widget>[
      const LanguageSetupDesignScreen(),
      const PrivacyNoticeDesignScreen(),
      const NameSetupDesignScreen(),
      const AuthDesignScreen(),
    ]) {
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
      await tester.pump();
      expect(find.byType(FirstLaunchHeroPanel), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: '${screen.runtimeType} overflowed at 667×375',
      );
    }
  });

  testWidgets('privacy items are interactive before notice acceptance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PrivacyNoticeDesignScreen(),
      ),
    );
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'I Understand'))
          .onPressed,
      isNull,
    );

    for (final label in <String>[
      'Use pseudonyms',
      'Avoid sensitive material',
      'Politics consultant limits',
      'Provider and data consent',
    ]) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(4));
    expect(find.text('I Understand'), findsOneWidget);
    await tester.tap(find.text('I Understand'));
    await tester.pump();
    expect(find.text('Notice accepted'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('name setup enforces a 15-character display name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const NameSetupDesignScreen()),
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('name-setup-field')))
          .autofocus,
      isFalse,
    );
    expect(find.text('Display Name'), findsOneWidget);
    final nameDecoration = tester
        .widget<TextField>(find.byKey(const ValueKey('name-setup-field')))
        .decoration!;
    expect(nameDecoration.floatingLabelBehavior, FloatingLabelBehavior.always);
    expect(
      (nameDecoration.enabledBorder! as OutlineInputBorder).borderSide.color,
      const Color(0xFF3CA9DD),
    );
    await tester.enterText(
      find.byKey(const ValueKey('name-setup-field')),
      '   ',
    );
    await tester.pump();
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Continue'))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const ValueKey('name-setup-field')),
      '李佳恩',
    );
    await tester.pump();
    expect(find.text('李佳恩'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('name-setup-field')),
      '12345678901234567890',
    );
    await tester.pump();

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('name-setup-field')),
    );
    expect(field.controller!.text, '123456789012345');
    expect(find.text('123456789012345'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auth design chooses a method before showing email fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AuthDesignScreen()),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Visitor'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.textContaining('Anonymous access'), findsNothing);

    final chooserButtons = [
      find.widgetWithText(AppButton, 'Email'),
      find.widgetWithText(AppButton, 'Visitor'),
      find.widgetWithText(AppButton, 'Google'),
      find.widgetWithText(AppButton, 'Apple'),
    ];
    final chooserX = tester.getTopLeft(chooserButtons.first).dx;
    for (final button in chooserButtons.skip(1)) {
      expect(tester.getTopLeft(button).dx, chooserX);
    }

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    await tester.enterText(
      find.byKey(const ValueKey('auth-email-field')),
      'invalid',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password-field')),
      'short',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-confirm-password-field')),
      'different',
    );
    await tester.tap(find.text('Continue with Email'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.tap(find.text('Other Methods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitor'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('visitor-access-view')), findsOneWidget);
    expect(find.textContaining('Later, you can link'), findsOneWidget);

    await tester.tap(find.text('Other Methods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();
    expect(find.text('Save with Google'), findsOneWidget);

    await tester.tap(find.text('Other Methods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(find.text('Save with Apple'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('first-launch Face Lab guides self then colleague avatars', (
    tester,
  ) async {
    FirstLaunchDesignDraft.selfSex = 'Female';
    FirstLaunchDesignDraft.colleagueSex = 'Male';
    addTearDown(() {
      FirstLaunchDesignDraft.selfSex = '';
      FirstLaunchDesignDraft.colleagueSex = '';
    });
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FaceLabDesignScreen(firstLaunch: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create two recognizable avatars'), findsOneWidget);
    expect(find.text('Create your avatar'), findsOneWidget);
    expect(
      tester
          .widget<CustomPaint>(find.byKey(const ValueKey('avatar-preview-0')))
          .painter,
      isA<DesignAvatarPainter>(),
    );
    final faceOptions = tester.widget<ListView>(
      find.byKey(const ValueKey('avatar-Face-options')),
    );
    expect(faceOptions.semanticChildCount, 20);
    expect(find.text('Outfit color'), findsOneWidget);
    final hairOptions = tester.widget<ListView>(
      find.byKey(const ValueKey('avatar-Hair-options')),
    );
    expect(hairOptions.controller!.offset, greaterThan(0));
    expect(
      tester
          .widget<AppButton>(
            find.byKey(const ValueKey('avatar-target-colleague')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Randomize'));
    await tester.pump();
    expect(find.text('New look generated'), findsOneWidget);

    expect(find.text('Randomize'), findsOneWidget);
    expect(find.text('Save & Create Alex'), findsOneWidget);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Randomize'))
          .didExceedMaxLines,
      isFalse,
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Save & Create Alex'))
          .didExceedMaxLines,
      isFalse,
    );
    await tester.tap(find.text('Save & Create Alex'));
    await tester.pump();
    expect(find.text('Create Alex’s avatar'), findsOneWidget);
    expect(find.text('Finish Avatar Setup'), findsOneWidget);
    expect(
      tester
          .widget<AppButton>(
            find.byKey(const ValueKey('avatar-target-colleague')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Finish Avatar Setup'));
    await tester.pump();
    expect(find.text('Both first-launch avatars are ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('People Face Lab modifies an existing character', (tester) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const FaceLabDesignScreen()),
    );
    await tester.pump();

    expect(find.text('Modify Alex’s avatar'), findsOneWidget);
    expect(find.text('Alex'), findsNothing);
    expect(find.text('EXISTING CHARACTER'), findsNothing);
    expect(find.text('Editing an existing character'), findsNothing);
    expect(find.byKey(const ValueKey('avatar-target-self')), findsNothing);
    expect(find.text('Save Changes'), findsOneWidget);
    final faceLabTune = tester.getRect(
      find.byKey(const ValueKey('face-lab-mode-tune')),
    );
    expect(faceLabTune.top, closeTo(16, 0.1));
    expect(faceLabTune.right, closeTo(940, 0.1));

    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(find.text('Changes to Alex’s avatar are ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('People Network selects personas and relationships', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const PeopleNetworkDesignScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('People & Relationships'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('people-network-glow-tune')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('people-network-guide')), findsOneWidget);
    expect(find.text('Create Colleague'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(AppButton, 'Create Colleague'),
        matching: find.byIcon(Icons.person_add_alt_1_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-person-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-person-3')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('people-network-person-1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('people-network-persona')),
      findsOneWidget,
    );
    expect(find.text('Create Colleague'), findsNothing);
    expect(find.text('View Full Profile'), findsOneWidget);
    expect(find.text('Modify Persona'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(AppButton, 'View Full Profile'),
        matching: find.byIcon(Icons.account_box_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-hexagon-chart')),
      findsOneWidget,
    );
    final panelAvatarPainter = tester
        .widget<CustomPaint>(
          find.byKey(const ValueKey('people-network-avatar-Alex')),
        )
        .painter;
    final walkingAvatarPainter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byKey(
              const ValueKey('people-network-walking-avatar-Alex'),
            ),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter;
    expect(panelAvatarPainter, isA<DesignAvatarPainter>());
    expect(walkingAvatarPainter, isA<DesignAvatarHeadPainter>());
    final dynamic glowPainter = tester
        .widget<CustomPaint>(
          find
              .descendant(
                of: find.byKey(const ValueKey('people-network-person-1')),
                matching: find.byType(CustomPaint),
              )
              .first,
        )
        .painter;
    expect(glowPainter.headInnerScale, 1.15);
    expect(glowPainter.headOuterScale, 1.75);
    expect(glowPainter.headOuterOpacity, 0.65);
    expect(glowPainter.bodyInnerScale, 1.65);
    expect(glowPainter.bodyOuterScale, 1.75);
    expect(glowPainter.bodyOuterOpacity, 0.65);
    expect(
      identical(
        (panelAvatarPainter! as DesignAvatarPainter).avatar,
        (walkingAvatarPainter! as DesignAvatarHeadPainter).avatar,
      ),
      isTrue,
    );
    final loopStart = collisionSafePeoplePositionsDesignScreen(
      const Size(500, 260),
      0,
    );
    final loopEnd = collisionSafePeoplePositionsDesignScreen(
      const Size(500, 260),
      1,
    );
    for (var index = 0; index < loopStart.length; index++) {
      expect((loopStart[index] - loopEnd[index]).distance, lessThan(0.01));
    }
    final modifyPersonaRect = tester.getRect(
      find.widgetWithText(AppButton, 'Modify Persona'),
    );
    expect(modifyPersonaRect.right, closeTo(955, 0.1));
    for (var index = 0; index < 4; index++) {
      expect(
        tester
            .getRect(find.byKey(ValueKey('people-network-person-$index')))
            .overlaps(modifyPersonaRect),
        isFalse,
      );
    }

    final scene = tester.getRect(
      find.byKey(const ValueKey('people-network-scene')),
    );
    await tester.tapAt(scene.topLeft + const Offset(8, 8));
    await tester.pump();
    expect(find.byKey(const ValueKey('people-network-guide')), findsOneWidget);

    var source = tester.getCenter(
      find.byKey(const ValueKey('people-network-person-0')),
    );
    var target = tester.getCenter(
      find.byKey(const ValueKey('people-network-person-1')),
    );
    final heldTap = await tester.startGesture(source);
    await tester.pump(const Duration(milliseconds: 500));
    await heldTap.up();
    await tester.pump();
    expect(
      find.byKey(const ValueKey('people-network-persona')),
      findsOneWidget,
    );
    await tester.tapAt(scene.topLeft + const Offset(8, 8));
    await tester.pump();

    source = tester.getCenter(
      find.byKey(const ValueKey('people-network-person-0')),
    );
    target = tester.getCenter(
      find.byKey(const ValueKey('people-network-person-1')),
    );
    final gesture = await tester.startGesture(source);
    await gesture.moveTo(source + const Offset(30, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      find.byKey(const ValueKey('people-network-silhouette-glow-You-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-relationship-drag-none')),
      findsOneWidget,
    );
    final sourceLinePainter =
        tester
                .widget<CustomPaint>(
                  find.byKey(
                    const ValueKey('people-network-relationship-drag-none'),
                  ),
                )
                .painter
            as dynamic;
    expect(
      sourceLinePainter.sourceColor,
      peopleNetworkPeopleDesignScreen.first.shirtColor,
    );
    expect(sourceLinePainter.targetColor, isNull);
    await gesture.moveTo(target);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('people-network-relationship-drag-1')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      find.byKey(const ValueKey('people-network-silhouette-glow-Alex-active')),
      findsOneWidget,
    );
    final growingLinePainter =
        tester
                .widget<CustomPaint>(
                  find.byKey(
                    const ValueKey('people-network-relationship-drag-1'),
                  ),
                )
                .painter
            as dynamic;
    expect(
      growingLinePainter.targetColor,
      peopleNetworkPeopleDesignScreen[1].shirtColor,
    );
    expect(growingLinePainter.connectionProgress, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 200));
    final readyLinePainter =
        tester
                .widget<CustomPaint>(
                  find.byKey(
                    const ValueKey('people-network-relationship-drag-1'),
                  ),
                )
                .painter
            as dynamic;
    expect(readyLinePainter.ready, isTrue);

    expect(
      find.byKey(const ValueKey('people-network-relationship')),
      findsNothing,
    );
    await gesture.up();
    await tester.pump();
    expect(
      find.byKey(const ValueKey('people-network-relationship')),
      findsOneWidget,
    );
    expect(find.text('You ↔ Alex'), findsOneWidget);
    expect(find.text('Bad'), findsOneWidget);
    expect(find.text('Neutral'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('people-network-relationship-gradient')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-relationship-indicator')),
      findsOneWidget,
    );
    expect(find.text('Modify Relationship'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(AppButton, 'Modify Relationship'),
        matching: find.byIcon(Icons.hub_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-relationship-avatar-You')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('people-network-relationship-avatar-Alex')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('character profile switches self and colleague records', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CharacterProfileDesignScreen(initialPerson: 'You'),
      ),
    );
    await tester.pump();
    expect(find.text('Character Profile'), findsOneWidget);
    expect(find.text('You'), findsWidgets);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Colleague Relationships'), findsOneWidget);
    expect(find.text('Recent Events Involving You'), findsOneWidget);
    expect(find.text('PERSON METRIC HISTORY'), findsOneWidget);
    expect(find.text('RELATIONSHIP SCORE HISTORY'), findsNothing);
    expect(
      tester.getTopLeft(find.text('1. Maya')).dy,
      lessThan(tester.getTopLeft(find.text('2. Jordan')).dy),
    );
    expect(
      tester.getTopLeft(find.text('2. Jordan')).dy,
      lessThan(tester.getTopLeft(find.text('3. Alex')).dy),
    );
    expect(find.text('Modify Relationship'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('character-profile-selector')));
    await tester.pumpAndSettle();
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('character-profile-person-1')));
    await tester.pumpAndSettle();
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Relationship With You'), findsOneWidget);
    expect(find.text('Recent Events Involving Alex'), findsOneWidget);
    expect(find.text('RELATIONSHIP SCORE HISTORY'), findsOneWidget);
    expect(find.text('Colleague Relationships'), findsNothing);
    expect(find.text('Modify Relationship'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('relationship setup reuses one screen for all pair modes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const RelationshipSetupDesignScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('Step 4 · Describe your relationship'), findsOneWidget);
    expect(find.text('Relationship Score'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('workspace-scenario-selector')));
    await tester.pumpAndSettle();
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Modify'), findsWidgets);
    expect(find.text('Create Pair'), findsOneWidget);
    expect(find.text('Modify Pair'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('workspace-scenario-createPair')),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('relationship-setup-pair-hero')),
      findsOneWidget,
    );
    expect(find.text('Maya and Jordan'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workspace-scenario-createPair')),
      findsOneWidget,
    );
    expect(find.text('Create a Relationship'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('relationship analysis suggests a confirmable score', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    WorkspaceSetupDesignDraft.clear();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const RelationshipSetupDesignScreen(),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('workspace-prompt-4')),
      'Alex and I have a tense, difficult relationship with very little trust.',
    );
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final suggestedScore = tester.widget<RelationshipScorePill>(
      find.byKey(const ValueKey('workspace-relationship-value')),
    );
    expect(suggestedScore.label, 'Bad');
    expect(suggestedScore.score, 0.25);
    final scoreConfirmation = find.byKey(
      const ValueKey('review-Relationship Score'),
    );
    expect(
      find.descendant(
        of: scoreConfirmation,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNothing,
    );
    await tester.tap(scoreConfirmation);
    await tester.pump();
    expect(
      find.descendant(
        of: scoreConfirmation,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    WorkspaceSetupDesignDraft.clear();
  });

  testWidgets(
    'modify setup previews fill fields with requested review states',
    (tester) async {
      tester.view.physicalSize = const Size(956, 440);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Rect? sharedSelectorRect;
      Future<void> verifyModifyScreen(
        Widget screen, {
        required int visibleReviewedFields,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: KeyedSubtree(key: UniqueKey(), child: screen),
          ),
        );
        await tester.pump();
        expect(
          find.byIcon(Icons.check_rounded),
          findsNWidgets(visibleReviewedFields),
        );
        final selectorRect = tester.getRect(
          find.byKey(const ValueKey('workspace-scenario-selector')),
        );
        if (sharedSelectorRect == null) {
          sharedSelectorRect = selectorRect;
        } else {
          expect(selectorRect.top, closeTo(sharedSelectorRect!.top, 0.1));
          expect(selectorRect.right, closeTo(sharedSelectorRect!.right, 0.1));
        }
        expect(tester.takeException(), isNull);
      }

      await verifyModifyScreen(
        const WorkplaceDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
        visibleReviewedFields: 6,
      );
      await verifyModifyScreen(
        const YourselfDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
        visibleReviewedFields: 6,
      );
      await verifyModifyScreen(
        const ColleagueDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
        visibleReviewedFields: 0,
      );
      expect(find.text('Modify a Colleague'), findsOneWidget);
      expect(find.textContaining('Profile Change Date'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      await verifyModifyScreen(
        const RelationshipSetupDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
        visibleReviewedFields: 0,
      );
      expect(find.text('Modify a Relationship'), findsOneWidget);
      expect(find.textContaining('Relationship Change Date'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      final scorePill = tester.widget<RelationshipScorePill>(
        find.byKey(const ValueKey('workspace-relationship-value')),
      );
      expect(scorePill.label, isNotEmpty);
      expect(scorePill.score, inInclusiveRange(0, 1));
      expect(find.text('You and Alex'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      WorkspaceSetupDesignDraft.clear();
    },
  );

  testWidgets('event timeline and editor cover inspect create and analysis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const EventTimelineDesignScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('Event Timeline'), findsOneWidget);
    expect(find.text('Deadline Ownership Escalation'), findsOneWidget);
    expect(find.text('Add Event'), findsOneWidget);
    expect(find.byKey(const ValueKey('event-timeline-list')), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EventEditorDesignScreen(
          key: UniqueKey(),
          initialMode: EventEditorModeDesignScreen.create,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Create Event'), findsWidgets);
    expect(find.text('Date and Time'), findsOneWidget);
    expect(find.text('Involved People'), findsOneWidget);
    expect(find.text('Detailed Story'), findsOneWidget);
    expect(find.text('Your Personal Feeling'), findsOneWidget);
    expect(find.text('Political Impact'), findsOneWidget);
    expect(find.text('Personal Stress'), findsOneWidget);
    expect(find.text('Urgency'), findsOneWidget);
    expect(find.text('Evidence Confidence'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(4));

    await tester.enterText(
      find.byKey(const ValueKey('event-editor-prompt')),
      'Yesterday Alex disputed deadline ownership by email and copied the director. I felt worried and frustrated.',
    );
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Preview analysis ready'), findsOneWidget);
    expect(find.text('Deadline ownership escalation'), findsWidgets);

    await tester.tap(find.text('Inspect Existing'));
    await tester.pump();
    expect(find.text('Event Detail'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('colleague setup reuses one screen for create and modify', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ColleagueDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Modify a Colleague'), findsOneWidget);
    expect(find.text('Observed Style'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('workspace-scenario-selector')));
    await tester.pumpAndSettle();
    expect(find.text('First Launch'), findsWidgets);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Modify'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('workspace-scenario-create')));
    await tester.pump();
    expect(find.text('Create a Colleague'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workspace-scenario-create')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('workspace-field-3-0')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('workspace-editor-title')),
      'Saved Colleague',
    );
    await tester.tap(find.widgetWithText(AppButton, 'OK'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ColleagueDesignScreen(
          initialScenario: WorkspaceScenarioDesignScreen.modify,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Saved Colleague'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FaceLabDesignScreen(
          creatingColleague: true,
          colleagueName: 'Taylor',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Create Taylor’s avatar'), findsWidgets);
    expect(find.text('Creating one colleague avatar'), findsNothing);
    expect(find.text('Create Colleague'), findsOneWidget);
    expect(find.byKey(const ValueKey('avatar-target-self')), findsNothing);
    expect(find.byKey(const ValueKey('face-lab-mode-tune')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('face-lab-mode-tune')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modify Self').last);
    await tester.pumpAndSettle();
    expect(find.text('Modify your avatar'), findsWidgets);
    expect(find.byKey(const ValueKey('avatar-preview-0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arcade screen offers four illustrated game buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ArcadeDesignScreen()),
    );
    await tester.pump();

    expect(find.text('Office Arcade'), findsOneWidget);
    expect(find.text('Choose a game'), findsOneWidget);
    expect(find.byType(FirstLaunchHeroPanel), findsOneWidget);
    for (final game in ArcadeGameDesignType.values) {
      expect(find.text(game.title), findsOneWidget);
      expect(
        find.byKey(ValueKey('arcade-image-placeholder-${game.name}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('arcade-game-button-${game.name}')),
        findsOneWidget,
      );
    }
    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('arcade-game-grid')),
    );
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      2,
    );
    final heroBottom = tester
        .getBottomRight(find.byType(FirstLaunchHeroPanel))
        .dy;
    for (final game in ArcadeGameDesignType.values.skip(2)) {
      expect(
        tester
            .getBottomRight(
              find.byKey(ValueKey('arcade-game-button-${game.name}')),
            )
            .dy,
        closeTo(heroBottom, 0.1),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('all four arcade games accept playable controls', (tester) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpGame(ArcadeGameDesignType game) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ArcadeGameDesignScreen(game: game),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('arcade-start-${game.name}')));
      await tester.pump();
      expect(find.byType(FirstLaunchHeroPanel), findsNothing);
      expect(
        tester.getRect(find.byKey(ValueKey('arcade-arena-${game.name}'))),
        Offset.zero & const Size(956, 440),
      );
    }

    Offset arenaPoint(Rect arena, Offset normalized) => Offset(
      arena.left + arena.width * normalized.dx,
      arena.top + arena.height * normalized.dy,
    );

    await pumpGame(ArcadeGameDesignType.slapDesk);
    dynamic gameState = tester.state(find.byType(ArcadeGameDesignScreen));
    Finder arena = find.byKey(const ValueKey('arcade-arena-slapDesk'));
    Rect arenaRect = tester.getRect(arena);
    final int target = gameState.targetDesignScreen as int;
    final List<Offset> actors =
        gameState.movingActorsDesignScreen() as List<Offset>;
    await tester.tap(find.byKey(const ValueKey('arcade-pause-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('arcade-pause-popup')), findsOneWidget);
    tester
        .widget<AppButton>(find.widgetWithText(AppButton, 'Resume'))
        .onPressed!();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('arcade-pause-popup')), findsNothing);
    await tester.tapAt(arenaPoint(arenaRect, actors[target]));
    await tester.pump();
    expect(find.textContaining('Correct Target'), findsOneWidget);
    gameState.timerDesignScreen.cancel();
    gameState.runningDesignScreen = false;
    final Future<void> resultFuture =
        gameState.showResultDesignScreen() as Future<void>;
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('arcade-result-popup')), findsOneWidget);
    tester
        .widget<AppButton>(find.widgetWithText(AppButton, 'Play Again'))
        .onPressed!();
    await tester.pump();
    await resultFuture;

    await pumpGame(ArcadeGameDesignType.creditChase);
    gameState = tester.state(find.byType(ArcadeGameDesignScreen));
    arena = find.byKey(const ValueKey('arcade-arena-creditChase'));
    arenaRect = tester.getRect(arena);
    final List<Offset> credits =
        gameState.movingActorsDesignScreen() as List<Offset>;
    await tester.dragFrom(
      arenaPoint(arenaRect, const Offset(0.16, 0.58)),
      arenaPoint(arenaRect, credits.first) -
          arenaPoint(arenaRect, const Offset(0.16, 0.58)),
    );
    await tester.pump();
    expect(find.textContaining('Credit Reclaimed'), findsOneWidget);

    await pumpGame(ArcadeGameDesignType.rumourFlip);
    arena = find.byKey(const ValueKey('arcade-arena-rumourFlip'));
    arenaRect = tester.getRect(arena);
    await tester.dragFrom(
      arenaPoint(arenaRect, const Offset(0.20, 0.62)),
      arenaPoint(arenaRect, const Offset(0.80, 0.34)) -
          arenaPoint(arenaRect, const Offset(0.20, 0.62)),
    );
    await tester.pump();
    expect(find.textContaining('Honest Subtext Found'), findsOneWidget);

    await pumpGame(ArcadeGameDesignType.fivePmGhost);
    arena = find.byKey(const ValueKey('arcade-arena-fivePmGhost'));
    arenaRect = tester.getRect(arena);
    await tester.dragFrom(
      arenaPoint(arenaRect, const Offset(0.16, 0.58)),
      arenaPoint(arenaRect, const Offset(0.91, 0.20)) -
          arenaPoint(arenaRect, const Offset(0.16, 0.58)),
    );
    await tester.pump();
    expect(find.textContaining('Escaped!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaderboard switches games and scrolls three periods', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LeaderboardDesignScreen()),
    );
    await tester.pump();

    expect(find.text('Three Leaderboards'), findsOneWidget);
    final gameButtons = [
      for (final game in ArcadeGameDesignType.values)
        find.byKey(ValueKey('leaderboard-game-${game.name}')),
    ];
    expect(
      gameButtons
          .map((finder) => tester.widget<AppButton>(finder).selected)
          .where((selected) => selected),
      hasLength(1),
    );

    final selectedIndex = gameButtons.indexWhere(
      (finder) => tester.widget<AppButton>(finder).selected,
    );
    final nextIndex = (selectedIndex + 1) % gameButtons.length;
    await tester.tap(gameButtons[nextIndex]);
    await tester.pump();
    expect(tester.widget<AppButton>(gameButtons[nextIndex]).selected, isTrue);

    await tester.scrollUntilVisible(
      find.text('Monthly Leaderboard'),
      130,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('leaderboard-period-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Monthly Leaderboard'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('leaderboard-you-monthly')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('workspace setup guides four editable collection steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WorkspaceSetupDesignScreen(),
      ),
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );
    expect(find.text('Complete four short setup steps'), findsOneWidget);
    expect(find.text('Your workplace'), findsOneWidget);
    expect(find.text('Yourself'), findsOneWidget);
    expect(find.text('First colleague'), findsOneWidget);
    expect(find.text('Relationship'), findsOneWidget);
    final workplaceDescription = find.text(
      'The industry, department, location, culture, structure, and current situation.',
    );
    expect(
      tester
          .renderObject<RenderParagraph>(workplaceDescription)
          .didExceedMaxLines,
      isFalse,
    );
    expect(
      find.byKey(const ValueKey('workspace-temp-footer-y-control')),
      findsNothing,
    );
    final afterSetup = tester.getRect(
      find.textContaining('After setup, you can add or change colleagues'),
    );
    final introductionNext = tester.getRect(
      find.widgetWithText(AppButton, 'Next'),
    );
    expect(afterSetup.bottom, greaterThan(introductionNext.top));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WorkplaceDesignScreen()),
    );
    await tester.pump();
    expect(find.text('Step 1 · Describe your workplace'), findsOneWidget);
    expect(find.text('Current Situation'), findsOneWidget);
    expect(
      find.text('Example: Anything important we should know'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Department')).dy,
      lessThan(tester.getTopLeft(find.text('Location')).dy),
    );
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Next'))
          .onPressed,
      isNotNull,
    );
    final fixedPromptTop = tester
        .getRect(find.byKey(const ValueKey('workspace-prompt-visual-1')))
        .top;
    expect(
      tester
          .getRect(find.byKey(const ValueKey('workspace-analyze-visual-1')))
          .top,
      closeTo(fixedPromptTop, 0.1),
    );
    await tester.tap(find.byKey(const ValueKey('workspace-prompt-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final expandingPrompt = tester.getRect(
      find.byKey(const ValueKey('workspace-prompt-visual-1')),
    );
    final expandingAnalyze = tester.getRect(
      find.byKey(const ValueKey('workspace-analyze-visual-1')),
    );
    expect(
      expandingPrompt.top,
      closeTo(fixedPromptTop, 0.1),
      reason: 'prompt top remains fixed while expanding',
    );
    expect(
      expandingAnalyze.top,
      closeTo(fixedPromptTop, 0.1),
      reason: 'Analyze top remains fixed while expanding',
    );
    expect(
      expandingAnalyze.height,
      closeTo(expandingPrompt.height, 0.1),
      reason: 'controls expand at the same pace',
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.testTextInput.isVisible, isTrue);
    final expandedPromptHeight = tester
        .getRect(find.byKey(const ValueKey('workspace-prompt-visual-1')))
        .height;
    final analyzeHeight = tester
        .getRect(find.byKey(const ValueKey('workspace-analyze-visual-1')))
        .height;
    expect(expandedPromptHeight, greaterThan(100));
    expect(analyzeHeight, expandedPromptHeight);
    await tester.tap(find.text('Step 1 · Describe your workplace'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final contractingPrompt = tester.getRect(
      find.byKey(const ValueKey('workspace-prompt-visual-1')),
    );
    final contractingAnalyze = tester.getRect(
      find.byKey(const ValueKey('workspace-analyze-visual-1')),
    );
    expect(contractingPrompt.top, closeTo(fixedPromptTop, 0.1));
    expect(contractingAnalyze.top, closeTo(fixedPromptTop, 0.1));
    expect(contractingAnalyze.height, closeTo(contractingPrompt.height, 0.1));
    expect(
      tester.getRect(find.byKey(const ValueKey('workspace-prompt-1'))).height,
      closeTo(contractingAnalyze.height, 0.1),
    );
    await tester.pump(const Duration(milliseconds: 120));
    final contractedPromptHeight = tester
        .getRect(find.byKey(const ValueKey('workspace-prompt-visual-1')))
        .height;
    expect(contractedPromptHeight, lessThan(expandedPromptHeight));
    expect(
      tester
          .getRect(find.byKey(const ValueKey('workspace-analyze-visual-1')))
          .height,
      closeTo(contractedPromptHeight, 3.1),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('workspace-prompt-1'))).height,
      closeTo(contractedPromptHeight, 0.1),
    );
    await tester.tap(find.byKey(const ValueKey('workspace-prompt-1')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('workspace-prompt-1')),
      '   ',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('workspace-prompt-1')))
          .decoration!
          .fillColor,
      Colors.white,
    );
    await tester.enterText(
      find.byKey(const ValueKey('workspace-prompt-1')),
      'I work in the product department of a regional travel company.',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('workspace-prompt-1')))
          .decoration!
          .fillColor,
      const Color(0xFFE7F4FF),
    );
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('workspace-analysis-overlay')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.byKey(const ValueKey('workspace-analysis-overlay')),
      findsNothing,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('workspace-prompt-1')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.byKey(const ValueKey('workspace-voice-1')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Financial services'), findsOneWidget);
    expect(find.text('Preview analysis ready'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workspace-field-1-0')));
    await tester.pumpAndSettle();
    expect(find.text('Answer'), findsOneWidget);
    expect(find.text('Full Description'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('workspace-editor-title')),
      'Travel services',
    );
    await tester.tap(find.widgetWithText(AppButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.text('Travel services'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('workspace-field-1-3')));
    await tester.pumpAndSettle();
    expect(find.text('Full Description'), findsOneWidget);
    expect(find.textContaining('• Decision style'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('review-Industry')));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('workspace-prompt-1')),
      'Replace the industry with banking and keep the other context.',
    );
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Travel services'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const YourselfDesignScreen()),
    );
    await tester.pump();
    expect(find.text('Step 2 · Describe yourself at work'), findsOneWidget);
    expect(find.text('Example: Product Analyst'), findsOneWidget);
    expect(find.text('Sex'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Responsibilities'), findsNothing);
    expect(find.text('Limits'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('workspace-field-2-0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Main Responsibilities'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Other Information'),
      80,
      scrollable: find
          .descendant(
            of: find.byType(GridView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Other Information'), findsOneWidget);
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Next'))
          .onPressed,
      isNotNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('workspace-prompt-2')),
      'I am a product analyst with two years of experience and limited authority.',
    );
    await tester.tap(find.text('Analyze'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ColleagueDesignScreen()),
    );
    await tester.pump();
    expect(find.text('Step 3 · Add one colleague'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('How You Work Together'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('workspace-field-3-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Main Responsibilities'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const RelationshipSetupDesignScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('Step 4 · Describe your relationship'), findsOneWidget);
    expect(find.text('How You Work Together'), findsOneWidget);
    expect(find.text('Current Dynamic'), findsOneWidget);
    expect(find.text('Relationship Score'), findsOneWidget);
    expect(find.byKey(const ValueKey('workspace-field-4-3')), findsNothing);
    expect(find.text('Very Bad'), findsOneWidget);
    expect(find.text('Neutral'), findsNWidgets(2));
    expect(find.text('Very Good'), findsOneWidget);
    expect(find.text('Tap the bar to choose'), findsNothing);
    final defaultScorePill = tester.widget<RelationshipScorePill>(
      find.byKey(const ValueKey('workspace-relationship-value')),
    );
    expect(defaultScorePill.label, 'Neutral');
    expect(defaultScorePill.score, 0.5);
    final scoreBar = tester.getRect(
      find.byKey(const ValueKey('workspace-relationship-gradient')),
    );
    final scoreGesture = await tester.startGesture(
      Offset(scoreBar.left + scoreBar.width * 0.25, scoreBar.center.dy),
    );
    await scoreGesture.moveTo(
      Offset(scoreBar.left + scoreBar.width * 0.68, scoreBar.center.dy),
    );
    await tester.pump();
    final continuousIndicator = tester.getCenter(
      find.byKey(const ValueKey('workspace-relationship-indicator')),
    );
    expect(
      continuousIndicator.dx,
      closeTo(scoreBar.left + scoreBar.width * 0.68, 1),
    );
    await scoreGesture.up();
    await tester.pumpAndSettle();
    final snappedIndicator = tester.getCenter(
      find.byKey(const ValueKey('workspace-relationship-indicator')),
    );
    expect(
      snappedIndicator.dx,
      closeTo(scoreBar.left + 11 + (scoreBar.width - 22) * 0.75, 1),
    );
    expect(
      find.byKey(const ValueKey('workspace-relationship-value')),
      findsOneWidget,
    );
    expect(find.text('Good'), findsWidgets);
    expect(find.text('Finish'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('workspace layout fits a keyboard-height landscape viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 247);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WorkplaceDesignScreen()),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shared buttons reserve their full pressed growth area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: SizedBox(
                  key: const ValueKey('left-button-slot'),
                  child: AppButton(
                    key: const ValueKey('left-button'),
                    label: 'Left',
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  key: const ValueKey('right-button-slot'),
                  child: AppButton(
                    key: const ValueKey('right-button'),
                    label: 'Right',
                    selected: true,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final slot = tester.getRect(find.byKey(const ValueKey('left-button-slot')));
    final visual = find
        .descendant(
          of: find.byKey(const ValueKey('left-button')),
          matching: find.byType(Stack),
        )
        .first;
    final leftSurface = find.descendant(
      of: find.byKey(const ValueKey('left-button')),
      matching: find.byType(Material),
    );
    final rightSurface = find.descendant(
      of: find.byKey(const ValueKey('right-button')),
      matching: find.byType(Material),
    );
    expect(tester.widget<Material>(leftSurface).color, Colors.white);
    expect(
      tester.widget<Material>(rightSurface).color,
      const Color(0xFFD2F2FF),
    );
    final gesture = await tester.startGesture(tester.getCenter(visual));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    final pressedVisual = tester.getRect(visual);

    expect(tester.widget<Material>(leftSurface).color, const Color(0xFFD2F2FF));
    expect(pressedVisual.left, greaterThanOrEqualTo(slot.left));
    expect(pressedVisual.right, lessThanOrEqualTo(slot.right));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 230));
    expect(tester.widget<Material>(leftSurface).color, Colors.white);
  });

  testWidgets('engineering cards reserve their full pressed growth area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: const ValueKey('engineering-card-slot'),
              width: 190,
              height: 72,
              child: EngineeringDesignButton(
                definition: designScreenDefinitions.first,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final slot = tester.getRect(
      find.byKey(const ValueKey('engineering-card-slot')),
    );
    final visual = find
        .descendant(
          of: find.byType(EngineeringDesignButton),
          matching: find.byType(Stack),
        )
        .first;
    final gesture = await tester.startGesture(
      tester.getCenter(visual) - const Offset(35, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    final pressedVisual = tester.getRect(visual);

    expect(pressedVisual.left, greaterThanOrEqualTo(slot.left));
    expect(pressedVisual.right, lessThanOrEqualTo(slot.right));
    expect(pressedVisual.top, greaterThanOrEqualTo(slot.top));
    expect(pressedVisual.bottom, lessThanOrEqualTo(slot.bottom));
    await gesture.up();
  });

  testWidgets(
    'home design presents a living office and hides controls on hold',
    (tester) async {
      tester.view.physicalSize = const Size(956, 440);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeDesignScreen()),
      );
      await tester.pump();

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Advice'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('ARCADE QUICK-LAUNCH'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Office Politics · Tactical Dashboard'), findsNothing);
      expect(find.byKey(const ValueKey('home-top-control')), findsOneWidget);
      expect(find.text('POLITICS INTENSITY'), findsOneWidget);
      expect(find.text('YOUR LEVEL & METRICS'), findsOneWidget);
      expect(find.text('LEVEL 7 · STRATEGIST'), findsOneWidget);
      expect(find.text('Influence'), findsWidgets);
      expect(find.text('Support Network'), findsOneWidget);
      expect(find.text('Credibility'), findsOneWidget);
      expect(find.text('Exposure Risk'), findsOneWidget);
      expect(find.text('PERSONA'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('home-left-panel'))),
        const Rect.fromLTWH(12, 43, 232, 331),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('home-right-panel'))),
        const Rect.fromLTWH(756, 43, 188, 331),
      );
      expect(find.textContaining('Panel H'), findsNothing);
      final homeHexagonPainter = tester
          .widget<CustomPaint>(
            find.byKey(const ValueKey('home-persona-hexagon-chart')),
          )
          .painter;
      expect(homeHexagonPainter, isA<PersonaHexagonPainterDesignScreen>());
      expect(
        tester.getRect(
          find.byKey(const ValueKey('home-infinite-office-floor')),
        ),
        Offset.zero & const Size(956, 440),
      );
      final officeCanvas = tester.getRect(
        find.byKey(const ValueKey('home-office-canvas')),
      );
      expect(officeCanvas.left, closeTo(-191.2, 0.1));
      expect(officeCanvas.right, closeTo(1147.2, 0.1));
      expect(officeCanvas.top, closeTo(-88, 0.1));
      expect(officeCanvas.bottom, closeTo(528, 0.1));
      final dynamic homeState = tester.state(find.byType(HomeDesignScreen));
      final initialPersona = homeState.selectedPersonDesignScreen as int;
      final initialPerson = officePeopleDesignScreen[initialPersona];
      final personaOutline = find.byKey(
        const ValueKey('home-persona-panel-outline'),
      );
      final initialOutlineRect = tester.getRect(personaOutline);
      final initialOutlineDecoration =
          tester.widget<AnimatedContainer>(personaOutline).decoration!
              as BoxDecoration;
      expect(
        (initialOutlineDecoration.gradient! as LinearGradient).colors.last,
        initialPerson.shirtColor,
      );
      expect(
        find.text('${initialPerson.name} · ${initialPerson.role}'),
        findsOneWidget,
      );
      expect(find.text(initialPerson.role), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-right-panel')),
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );
      await tester.pump(const Duration(seconds: 4));
      expect(homeState.selectedPersonDesignScreen, initialPersona);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 800));
      expect(homeState.selectedPersonDesignScreen, isNot(initialPersona));
      expect(tester.getRect(personaOutline), initialOutlineRect);
      final rotatedPerson =
          officePeopleDesignScreen[homeState.selectedPersonDesignScreen as int];
      final rotatedOutlineDecoration =
          tester.widget<AnimatedContainer>(personaOutline).decoration!
              as BoxDecoration;
      expect(
        (rotatedOutlineDecoration.gradient! as LinearGradient).colors.last,
        rotatedPerson.shirtColor,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter is DesignAvatarHeadPainter,
        ),
        findsNWidgets(4),
      );
      for (final label in [
        'people',
        'events',
        'advice',
        'map',
        'arcade',
        'profile',
        'more',
      ]) {
        final nav = tester.widget<InkWell>(
          find.byKey(ValueKey('home-nav-$label')),
        );
        expect(nav.borderRadius, BorderRadius.circular(14));
      }

      expect(
        tester.getCenter(find.byKey(const ValueKey('home-nav-advice'))).dx,
        closeTo(478, 1),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('home-nav-people'))).left,
        closeTo(75, 0.1),
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('home-nav-more'))).right,
        closeTo(881, 0.1),
      );
      expect(
        tester
            .widget<AnimatedScale>(
              find.byKey(const ValueKey('home-nav-scale-advice')),
            )
            .scale,
        1,
      );
      final navRects = [
        for (final label in [
          'people',
          'events',
          'map',
          'advice',
          'arcade',
          'profile',
          'more',
        ])
          tester.getRect(find.byKey(ValueKey('home-nav-$label'))),
      ];
      for (var index = 1; index < navRects.length; index++) {
        expect(
          navRects[index].left - navRects[index - 1].right,
          closeTo(10, 0.1),
        );
      }
      final peopleLabel = tester.widget<Text>(find.text('People'));
      expect(
        peopleLabel.style?.fontSize,
        Theme.of(
          tester.element(find.text('People')),
        ).textTheme.labelLarge?.fontSize,
      );
      expect(
        find.byKey(
          const ValueKey('people-network-silhouette-glow-Alex-active'),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Alex'));
      await tester.pump();
      expect(find.text('Alex · Project Manager'), findsWidgets);
      expect(find.byKey(const ValueKey('home-persona-popup')), findsOneWidget);
      expect(find.text('Open Full Profile'), findsOneWidget);
      expect(find.text('Major linked event'.toUpperCase()), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pump();

      final topPanel = find.byKey(const ValueKey('home-top-control'));
      final controlsVisibleY = tester.getTopLeft(topPanel).dy;
      final office = find.byKey(const ValueKey('home-office-interaction'));
      final gesture = await tester.startGesture(tester.getCenter(office));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      expect(homeState.panelAnimationDesignScreen.value, greaterThan(0.9));
      final controlsHiddenY = tester.getTopLeft(topPanel).dy;
      expect(controlsHiddenY, lessThan(controlsVisibleY));
      await gesture.moveBy(const Offset(34, 18));
      await tester.pump();
      expect(homeState.mapPanOffsetDesignScreen, const Offset(34, 18));
      final dynamic floorPainter = tester
          .widget<CustomPaint>(
            find.byKey(const ValueKey('home-infinite-office-floor')),
          )
          .painter;
      expect(floorPainter.offset, const Offset(34, 18));

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      expect(
        tester.getTopLeft(topPanel).dy,
        greaterThanOrEqualTo(controlsVisibleY),
      );

      final peopleNav = find.byKey(const ValueKey('home-nav-people'));
      final navGesture = await tester.startGesture(tester.getCenter(peopleNav));
      await tester.pump(const Duration(milliseconds: 190));
      expect(
        tester
            .widget<AnimatedScale>(
              find.byKey(const ValueKey('home-nav-scale-people')),
            )
            .scale,
        1.12,
      );
      expect(
        tester
            .widget<AnimatedScale>(
              find.byKey(const ValueKey('home-nav-scale-events')),
            )
            .scale,
        0.88,
      );
      await navGesture.cancel();
      await tester.pump(const Duration(milliseconds: 190));
      expect(
        tester
            .widget<AnimatedScale>(
              find.byKey(const ValueKey('home-nav-scale-people')),
            )
            .scale,
        1,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('office map editor is an isometric drag-and-drop builder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const OfficeMapEditorDesignScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Isometric Office Builder'), findsOneWidget);
    expect(find.text('BUILD ITEMS'), findsOneWidget);
    expect(find.text('Partition'), findsOneWidget);
    expect(find.text('ITEM INSPECTOR'), findsOneWidget);
    expect(find.text('Save Layout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('advice input combines text image voice and analysis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AdviceInputDesignScreen()),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('advice-camera')), findsOneWidget);
    expect(find.byKey(const ValueKey('advice-gallery')), findsOneWidget);
    expect(find.byKey(const ValueKey('advice-voice')), findsOneWidget);
    expect(find.byKey(const ValueKey('advice-voice-language')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('advice-input-notes')),
      'Alex disputed deadline ownership and copied our director.',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Analyze'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('advice-processing-overlay')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    final summary = tester.widget<TextField>(
      find.byKey(const ValueKey('advice-analysis-0')),
    );
    expect(summary.controller!.text, contains('Situation'));
    expect(find.text('Get Advice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home dashboard fits a compact landscape phone', (tester) async {
    tester.view.physicalSize = const Size(667, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HomeDesignScreen()),
    );
    await tester.pump();

    expect(find.text('POLITICS INTENSITY'), findsOneWidget);
    expect(find.text('YOUR LEVEL & METRICS'), findsOneWidget);

    await tester.tap(find.text('Alex'));
    await tester.pump();
    expect(find.byKey(const ValueKey('home-persona-popup')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash design fades in the sea-blue logo', (tester) async {
    tester.view.physicalSize = const Size(956, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SplashDesignScreen()));
    await tester.pump(const Duration(milliseconds: 1200));

    final logo = tester.widget<Image>(find.byType(Image));
    expect(logo.color, const Color(0xFF2AB7E8));
    expect(logo.width, greaterThan(150));
    expect(find.byType(Slider), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
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
