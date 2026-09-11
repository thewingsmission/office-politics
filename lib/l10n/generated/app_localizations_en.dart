// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Office Politics';

  @override
  String get appTagline => 'Predict the next move. Walk the floor.';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageSimplifiedChinese => '简体';

  @override
  String get languageTraditionalChinese => '繁體';

  @override
  String get arcadeTitle => 'Arcade';

  @override
  String get arcadeBody =>
      'Landscape floor games: Slap Desk, Credit Chase, Rumour Flip, 5pm Ghost.';

  @override
  String get coachTitle => 'Coach';

  @override
  String get coachBody => 'Private advice, reply simulator, and roleplay.';

  @override
  String get mapTitle => 'Office map';

  @override
  String get mapBody => 'Place desks and colleagues. Built in a later step.';

  @override
  String get comingNext => 'Coming next';

  @override
  String get landscapeOnly => 'This app is landscape only.';

  @override
  String get authSubtitle =>
      'An account is required. Coaching data stays private to you.';

  @override
  String get sensitiveWarning =>
      'Do not upload confidential or sensitive material. Use fake names for colleagues.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get needAccount => 'New here? Create an account';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get exportAccount => 'Export my data';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This permanently deletes your account on this device, and in the cloud when Supabase is connected.';

  @override
  String get deleteAccountAction => 'Delete permanently';

  @override
  String get cancel => 'Cancel';

  @override
  String get planFree => 'Free';

  @override
  String get planPremium => 'Premium';

  @override
  String get planContest => 'Contest pass';

  @override
  String planExpires(String date) {
    return 'Access until $date';
  }

  @override
  String get premiumUntilForever => 'Active subscription';

  @override
  String get paywallTitle => 'Coach is a subscription';

  @override
  String get paywallBody =>
      'Arcade contests stay free. Subscribe to use Coach, or win a daily, weekly, or monthly contest for a time-limited pass. If you would rather spend time than money, rewarded ads will give you a fair shot in those contests.';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeHint =>
      'Store billing comes later. This grants a 30-day premium pass so the rest of the app can be built against a real access flag.';

  @override
  String get contestCta => 'Back to arcade';

  @override
  String get exported => 'Account export copied';

  @override
  String get invalidCredentials => 'Email or password is wrong.';

  @override
  String get emailTaken => 'That email already has an account.';

  @override
  String get weakPassword => 'Use at least 8 characters.';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get confirmEmail => 'Check your email to confirm this account.';

  @override
  String get genericError => 'Something went wrong. Try again.';

  @override
  String get coachLocked => 'Subscription required';

  @override
  String accountEmail(String email) {
    return 'Signed in as $email';
  }

  @override
  String get localAccountNote =>
      'Demo account stored on this device. Connect Supabase to use a cloud account.';

  @override
  String get cloudAccountNote =>
      'Cloud account. Export and delete apply to your server records.';
}
