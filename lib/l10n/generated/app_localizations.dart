import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Office Politics'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Predict the next move. Walk the floor.'**
  String get appTagline;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'简体'**
  String get languageSimplifiedChinese;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'繁體'**
  String get languageTraditionalChinese;

  /// No description provided for @arcadeTitle.
  ///
  /// In en, this message translates to:
  /// **'Arcade'**
  String get arcadeTitle;

  /// No description provided for @arcadeBody.
  ///
  /// In en, this message translates to:
  /// **'Landscape floor games: Slap Desk, Credit Chase, Rumour Flip, 5pm Ghost.'**
  String get arcadeBody;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coachTitle;

  /// No description provided for @coachBody.
  ///
  /// In en, this message translates to:
  /// **'Private advice, reply simulator, and roleplay.'**
  String get coachBody;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Office map'**
  String get mapTitle;

  /// No description provided for @mapBody.
  ///
  /// In en, this message translates to:
  /// **'Place desks and colleagues. Built in a later step.'**
  String get mapBody;

  /// No description provided for @comingNext.
  ///
  /// In en, this message translates to:
  /// **'Coming next'**
  String get comingNext;

  /// No description provided for @landscapeOnly.
  ///
  /// In en, this message translates to:
  /// **'This app is landscape only.'**
  String get landscapeOnly;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An account is required. Coaching data stays private to you.'**
  String get authSubtitle;

  /// No description provided for @sensitiveWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not upload confidential or sensitive material. Use fake names for colleagues.'**
  String get sensitiveWarning;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get needAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @exportAccount.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account on this device, and in the cloud when Supabase is connected.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @planContest.
  ///
  /// In en, this message translates to:
  /// **'Contest pass'**
  String get planContest;

  /// No description provided for @planExpires.
  ///
  /// In en, this message translates to:
  /// **'Access until {date}'**
  String planExpires(String date);

  /// No description provided for @premiumUntilForever.
  ///
  /// In en, this message translates to:
  /// **'Active subscription'**
  String get premiumUntilForever;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach is a subscription'**
  String get paywallTitle;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Arcade contests stay free. Subscribe to use Coach, or win a daily, weekly, or monthly contest for a time-limited pass. If you would rather spend time than money, rewarded ads will give you a fair shot in those contests.'**
  String get paywallBody;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeHint.
  ///
  /// In en, this message translates to:
  /// **'Store billing comes later. This grants a 30-day premium pass so the rest of the app can be built against a real access flag.'**
  String get subscribeHint;

  /// No description provided for @contestCta.
  ///
  /// In en, this message translates to:
  /// **'Back to arcade'**
  String get contestCta;

  /// No description provided for @exported.
  ///
  /// In en, this message translates to:
  /// **'Account export copied'**
  String get exported;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is wrong.'**
  String get invalidCredentials;

  /// No description provided for @emailTaken.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account.'**
  String get emailTaken;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm this account.'**
  String get confirmEmail;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get genericError;

  /// No description provided for @coachLocked.
  ///
  /// In en, this message translates to:
  /// **'Subscription required'**
  String get coachLocked;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String accountEmail(String email);

  /// No description provided for @localAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Demo account stored on this device. Connect Supabase to use a cloud account.'**
  String get localAccountNote;

  /// No description provided for @cloudAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Cloud account. Export and delete apply to your server records.'**
  String get cloudAccountNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
