import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// Label for appTitle
  ///
  /// In en, this message translates to:
  /// **'DayApp'**
  String get appTitle;

  /// No description provided for @howMuchWeHaveDoneTogether.
  ///
  /// In en, this message translates to:
  /// **'How much we have done together'**
  String get howMuchWeHaveDoneTogether;

  /// No description provided for @chaptersLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersLabel;

  /// No description provided for @groupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsLabel;

  /// Text displayed when clicking the statistics chart
  ///
  /// In en, this message translates to:
  /// **'Stories written this week: {count}'**
  String storiesThisWeek(int count);

  /// No description provided for @tapChartToSeeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Tap the chart to see this week\'s progress'**
  String get tapChartToSeeWeekly;

  /// No description provided for @moodEnergyChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Recent Journey'**
  String get moodEnergyChartTitle;

  /// No description provided for @moodEnergyChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days with records'**
  String get moodEnergyChartSubtitle;

  /// Tooltip showing the mood and energy summary for a day on the chart
  ///
  /// In en, this message translates to:
  /// **'Day {date}: Mood {mood} / Energy {energy}'**
  String moodEnergyChartTooltip(String date, String mood, String energy);

  /// No description provided for @moodEnergyChartTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood & Energy'**
  String get moodEnergyChartTitleLabel;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label shown in language selection to use the device's default language
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get deviceDefault;

  /// Label used to indicate the default option, e.g. in chips
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// Label for english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Label for spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Label for french
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Label for italian
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// Label for portuguese
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// Label for tryAgain
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Message shown when the app fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Error initializing app'**
  String get errorInitializingApp;

  /// Label for theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @themeAndScheme.
  ///
  /// In en, this message translates to:
  /// **'Theme and Scheme'**
  String get themeAndScheme;

  /// No description provided for @themeRelva.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get themeRelva;

  /// No description provided for @themeOutono.
  ///
  /// In en, this message translates to:
  /// **'Botanical Garden'**
  String get themeOutono;

  /// No description provided for @themeCeu.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get themeCeu;

  /// No description provided for @themeConfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get themeConfort;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeMidnightGalaxy.
  ///
  /// In en, this message translates to:
  /// **'Midnight Galaxy'**
  String get themeMidnightGalaxy;

  /// No description provided for @themeDefaultLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Default light theme'**
  String get themeDefaultLightDescription;

  /// No description provided for @themeDefaultDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Default dark theme'**
  String get themeDefaultDarkDescription;

  /// No description provided for @themeFollowSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow system theme'**
  String get themeFollowSystemDescription;

  /// No description provided for @themeCustomSchemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Schemes'**
  String get themeCustomSchemesTitle;

  /// No description provided for @themeRelvaLight.
  ///
  /// In en, this message translates to:
  /// **'Relva (Light)'**
  String get themeRelvaLight;

  /// No description provided for @themeRelvaDark.
  ///
  /// In en, this message translates to:
  /// **'Relva (Dark)'**
  String get themeRelvaDark;

  /// No description provided for @themeOutonoLight.
  ///
  /// In en, this message translates to:
  /// **'Botanical Garden (Light)'**
  String get themeOutonoLight;

  /// No description provided for @themeOutonoDark.
  ///
  /// In en, this message translates to:
  /// **'Botanical Garden (Dark)'**
  String get themeOutonoDark;

  /// No description provided for @themeRelvaLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Green and natural tones'**
  String get themeRelvaLightDescription;

  /// No description provided for @themeRelvaDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark version of the Relva scheme'**
  String get themeRelvaDarkDescription;

  /// No description provided for @themeOutonoLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Fresh and organic garden tones'**
  String get themeOutonoLightDescription;

  /// No description provided for @themeOutonoDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark version of the Botanical Garden scheme'**
  String get themeOutonoDarkDescription;

  /// No description provided for @themeRemoveScheme.
  ///
  /// In en, this message translates to:
  /// **'Remove Scheme'**
  String get themeRemoveScheme;

  /// No description provided for @themeRemoveSchemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Go back to the default theme scheme'**
  String get themeRemoveSchemeDescription;

  /// No description provided for @timeAtConnector.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get timeAtConnector;

  /// No description provided for @timeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeAgoNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String timeAgoDays(int count);

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for pinUnlock
  ///
  /// In en, this message translates to:
  /// **'Unlock PIN'**
  String get pinUnlock;

  /// Label for changePin
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Label for enableBiometrics
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get enableBiometrics;

  /// Label for information
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Label for email
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// Label for password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for configurePin
  ///
  /// In en, this message translates to:
  /// **'Configure PIN'**
  String get configurePin;

  /// Label for biometrics
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// Label for backgroundLock
  ///
  /// In en, this message translates to:
  /// **'Background lock'**
  String get backgroundLock;

  /// Prompt asking how long the app should be locked after being in background
  ///
  /// In en, this message translates to:
  /// **'How long should the app be locked after being in background?'**
  String get backgroundLockDialogPrompt;

  /// No description provided for @backgroundLockTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get backgroundLockTimeLabel;

  /// No description provided for @backgroundLockDialogResult.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get backgroundLockDialogResult;

  /// No description provided for @backgroundLockSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions:'**
  String get backgroundLockSuggestions;

  /// No description provided for @backgroundLockImmediateHint.
  ///
  /// In en, this message translates to:
  /// **'0 = immediate'**
  String get backgroundLockImmediateHint;

  /// No description provided for @backgroundLockNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lock'**
  String get backgroundLockNever;

  /// No description provided for @backgroundLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get backgroundLockImmediately;

  /// No description provided for @backgroundLockSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String backgroundLockSeconds(int count);

  /// No description provided for @backgroundLockOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get backgroundLockOneMinute;

  /// No description provided for @backgroundLockMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String backgroundLockMinutes(int count);

  /// No description provided for @backgroundLockOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get backgroundLockOneHour;

  /// No description provided for @backgroundLockHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String backgroundLockHours(int count);

  /// Label for statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @noStoriesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYetTitle;

  /// No description provided for @trashEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Your trash is empty'**
  String get trashEmptyStateMessage;

  /// No description provided for @noStoriesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start recording your days to see statistics'**
  String get noStoriesYetSubtitle;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @activityByWeekday.
  ///
  /// In en, this message translates to:
  /// **'Activity by weekday'**
  String get activityByWeekday;

  /// No description provided for @streaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaksTitle;

  /// No description provided for @longestStreakPrefix.
  ///
  /// In en, this message translates to:
  /// **'Longest streak:'**
  String get longestStreakPrefix;

  /// No description provided for @tableOfMoods.
  ///
  /// In en, this message translates to:
  /// **'Mood table'**
  String get tableOfMoods;

  /// No description provided for @moodCount.
  ///
  /// In en, this message translates to:
  /// **'Mood count'**
  String get moodCount;

  /// No description provided for @topTags.
  ///
  /// In en, this message translates to:
  /// **'Top tags'**
  String get topTags;

  /// No description provided for @storiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storiesLabel;

  /// No description provided for @activeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysLabel;

  /// No description provided for @avgPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg/day'**
  String get avgPerDayLabel;

  /// No description provided for @mediaLabel.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// Label for manageGroups
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get manageGroups;

  /// Label for trash
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// Label for help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Label for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutScreenAboutDayAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About DayApp'**
  String get aboutScreenAboutDayAppTitle;

  /// No description provided for @aboutScreenAboutDayAppDescription.
  ///
  /// In en, this message translates to:
  /// **'DayApp is a modern and secure personal journal app that lets you record your stories, memories, and thoughts in an organized and private way. With an intuitive interface and advanced features, DayApp helps you preserve your most meaningful experiences.'**
  String get aboutScreenAboutDayAppDescription;

  /// No description provided for @aboutScreenFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aboutScreenFeaturesTitle;

  /// No description provided for @aboutScreenFeatureRichEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Rich Editor'**
  String get aboutScreenFeatureRichEditorTitle;

  /// No description provided for @aboutScreenFeatureRichEditorDescription.
  ///
  /// In en, this message translates to:
  /// **'Create stories with advanced formatting, images, videos, and audio'**
  String get aboutScreenFeatureRichEditorDescription;

  /// No description provided for @aboutScreenFeatureSmartOrganizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Organization'**
  String get aboutScreenFeatureSmartOrganizationTitle;

  /// No description provided for @aboutScreenFeatureSmartOrganizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Categorize your stories into custom themed groups and Chapters that tell about you'**
  String get aboutScreenFeatureSmartOrganizationDescription;

  /// No description provided for @aboutScreenFeatureAdvancedSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get aboutScreenFeatureAdvancedSearchTitle;

  /// No description provided for @aboutScreenFeatureAdvancedSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly find any story by content or date'**
  String get aboutScreenFeatureAdvancedSearchDescription;

  /// No description provided for @aboutScreenFeatureSecureBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Backup'**
  String get aboutScreenFeatureSecureBackupTitle;

  /// No description provided for @aboutScreenFeatureSecureBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Back up your data regularly.'**
  String get aboutScreenFeatureSecureBackupDescription;

  /// No description provided for @aboutScreenFeatureTotalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Privacy'**
  String get aboutScreenFeatureTotalPrivacyTitle;

  /// No description provided for @aboutScreenFeatureTotalPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally and encrypted'**
  String get aboutScreenFeatureTotalPrivacyDescription;

  /// No description provided for @aboutScreenFeatureAdaptiveInterfaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Interface'**
  String get aboutScreenFeatureAdaptiveInterfaceTitle;

  /// No description provided for @aboutScreenFeatureAdaptiveInterfaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Light and dark themes with customizable layouts'**
  String get aboutScreenFeatureAdaptiveInterfaceDescription;

  /// No description provided for @aboutScreenVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutScreenVersionTitle;

  /// About screen app version and build label
  ///
  /// In en, this message translates to:
  /// **'Version {version} (Build {build})'**
  String aboutScreenVersionBuild(String version, String build);

  /// Short app version shown in about header
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutScreenVersionShort(String version);

  /// No description provided for @aboutScreenDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get aboutScreenDevelopmentTitle;

  /// No description provided for @aboutScreenDevelopmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Built with care to offer the best experience for recording personal memories.'**
  String get aboutScreenDevelopmentDescription;

  /// No description provided for @aboutScreenPrivacySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Security'**
  String get aboutScreenPrivacySecurityTitle;

  /// No description provided for @aboutScreenPrivacyLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Data'**
  String get aboutScreenPrivacyLocalDataTitle;

  /// No description provided for @aboutScreenPrivacyLocalDataDescription.
  ///
  /// In en, this message translates to:
  /// **'All your stories are stored only on your device'**
  String get aboutScreenPrivacyLocalDataDescription;

  /// No description provided for @aboutScreenPrivacyEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get aboutScreenPrivacyEncryptionTitle;

  /// No description provided for @aboutScreenPrivacyEncryptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Sensitive content is protected with advanced encryption'**
  String get aboutScreenPrivacyEncryptionDescription;

  /// No description provided for @aboutScreenPrivacyNoTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'No Tracking'**
  String get aboutScreenPrivacyNoTrackingTitle;

  /// No description provided for @aboutScreenPrivacyNoTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'We do not collect personal data or track your usage'**
  String get aboutScreenPrivacyNoTrackingDescription;

  /// No description provided for @aboutScreenPrivacyPinSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security PIN'**
  String get aboutScreenPrivacyPinSecurityTitle;

  /// No description provided for @aboutScreenPrivacyPinSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect app access with PIN or biometrics'**
  String get aboutScreenPrivacyPinSecurityDescription;

  /// No description provided for @aboutScreenContactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact and Support'**
  String get aboutScreenContactSupportTitle;

  /// No description provided for @aboutScreenContactSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'For questions, suggestions, or technical support:'**
  String get aboutScreenContactSupportDescription;

  /// No description provided for @aboutScreenSupportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'DayApp Support'**
  String get aboutScreenSupportEmailSubject;

  /// Support e-mail body prefilled on about screen
  ///
  /// In en, this message translates to:
  /// **'Hello, I need help with DayApp...\n\nVersion: {version}\n'**
  String aboutScreenSupportEmailBody(String version);

  /// No description provided for @aboutScreenAcknowledgementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgments'**
  String get aboutScreenAcknowledgementsTitle;

  /// No description provided for @aboutScreenAcknowledgementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Thank you for choosing DayApp to record your most precious memories. Your trust and feedback are essential for us to keep improving.'**
  String get aboutScreenAcknowledgementsDescription;

  /// No description provided for @aboutScreenHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Diary'**
  String get aboutScreenHeaderSubtitle;

  /// No description provided for @aboutScreenCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 DayApp. All rights reserved.'**
  String get aboutScreenCopyright;

  /// Label for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for createAccount
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Label for name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for confirmPassword
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Label for createAccountButton
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// Label for alreadyHaveAccount
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccount;

  /// Label for needHelp
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// Label for currentPinLabel
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPinLabel;

  /// Label for newPinLabel
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPinLabel;

  /// Label for pinLabel
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// Label for confirmPin
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// Label for enterCurrentPin
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// Label for enterPin
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Message for pinLengthError
  ///
  /// In en, this message translates to:
  /// **'PIN must be between 4 and 8 digits'**
  String get pinLengthError;

  /// Message for pinsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// Message for pinIncorrect
  ///
  /// In en, this message translates to:
  /// **'Current PIN incorrect'**
  String get pinIncorrect;

  /// Message for pinChangedSuccess
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully!'**
  String get pinChangedSuccess;

  /// Message for pinConfiguredSuccess
  ///
  /// In en, this message translates to:
  /// **'PIN configured successfully!'**
  String get pinConfiguredSuccess;

  /// Message for informYourEmail
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get informYourEmail;

  /// Message for invalidEmail
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// Message for emailNotFound
  ///
  /// In en, this message translates to:
  /// **'Email not found. Check and try again.'**
  String get emailNotFound;

  /// Message shown when a verification code is sent
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}! Check your inbox.'**
  String codeSent(Object email);

  /// Message for codeMustBe6
  ///
  /// In en, this message translates to:
  /// **'The code must be 6 digits.'**
  String get codeMustBe6;

  /// Message for codeVerified
  ///
  /// In en, this message translates to:
  /// **'Code verified! Set your new password.'**
  String get codeVerified;

  /// Message for codeInvalid
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Try again.'**
  String get codeInvalid;

  /// Message for enterNewPassword
  ///
  /// In en, this message translates to:
  /// **'Enter the new password.'**
  String get enterNewPassword;

  /// Message for passwordResetSuccess
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Log in with the new password.'**
  String get passwordResetSuccess;

  /// Message for errorResetPassword
  ///
  /// In en, this message translates to:
  /// **'Error resetting password. Try again.'**
  String get errorResetPassword;

  /// Message for passwordsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Message for resendCodeSuccess
  ///
  /// In en, this message translates to:
  /// **'New code sent! Check your inbox.'**
  String get resendCodeSuccess;

  /// Message for resendCodeError
  ///
  /// In en, this message translates to:
  /// **'Error resending code. Try again.'**
  String get resendCodeError;

  /// Message for passwordMinLength
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// Label for unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Label for fullName
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// Label for birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @almostReady.
  ///
  /// In en, this message translates to:
  /// **'almost ready...'**
  String get almostReady;

  /// No description provided for @optionalData.
  ///
  /// In en, this message translates to:
  /// **'The fields below are optional'**
  String get optionalData;

  /// No description provided for @birthDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Birth date (DD/MM/YYYY)'**
  String get birthDateFormat;

  /// No description provided for @invalidBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid birth date (use DD/MM/YYYY)'**
  String get invalidBirthDate;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Message for nameRequired
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Message for nameMinLength
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Message for emailRequired
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Message for emailInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// Label for welcomeBack
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Label for accessAccount
  ///
  /// In en, this message translates to:
  /// **'Access your account'**
  String get accessAccount;

  /// Label for enterPassword
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Label for signIn
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Label for forgotPassword
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// Label for noAccountCreateHere
  ///
  /// In en, this message translates to:
  /// **'No account? Create one here.'**
  String get noAccountCreateHere;

  /// Label for privacyPolicy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Message for biometricsEnabledSuccess
  ///
  /// In en, this message translates to:
  /// **'Biometrics enabled successfully!'**
  String get biometricsEnabledSuccess;

  /// Message for biometricLoginError
  ///
  /// In en, this message translates to:
  /// **'Error logging in with biometrics.'**
  String get biometricLoginError;

  /// Message for invalidCredentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// Message for profileUpdatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// Message for profileUpdateError
  ///
  /// In en, this message translates to:
  /// **'Error updating profile. Try again.'**
  String get profileUpdateError;

  /// Message for unlockAppReason
  ///
  /// In en, this message translates to:
  /// **'Unlock the app to continue'**
  String get unlockAppReason;

  /// Message for fillEmailAndPassword
  ///
  /// In en, this message translates to:
  /// **'Fill in email and password'**
  String get fillEmailAndPassword;

  /// Message for emailOrPasswordIncorrect
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect'**
  String get emailOrPasswordIncorrect;

  /// Message for noEmailRegistered
  ///
  /// In en, this message translates to:
  /// **'No email registered. Configure it in settings.'**
  String get noEmailRegistered;

  /// Prompt to check email or enter code
  ///
  /// In en, this message translates to:
  /// **'Check your email at {email} or use the displayed code'**
  String checkEmailOrUseCode(Object email);

  /// Message for errorGeneratingCode
  ///
  /// In en, this message translates to:
  /// **'Error generating code. Try again.'**
  String get errorGeneratingCode;

  /// Message for errorSendingCode
  ///
  /// In en, this message translates to:
  /// **'Error sending code. Try again.'**
  String get errorSendingCode;

  /// Label for enterRecoveryCodePrompt
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email:'**
  String get enterRecoveryCodePrompt;

  /// Label for recovery code input field
  ///
  /// In en, this message translates to:
  /// **'Recovery code (6 digits)'**
  String get recoveryCodeLabel;

  /// Label for enterPasswordToContinue
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get enterPasswordToContinue;

  /// Label for enterPinToContinue
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get enterPinToContinue;

  /// Label for useBiometricsToContinue
  ///
  /// In en, this message translates to:
  /// **'Use your biometrics to continue'**
  String get useBiometricsToContinue;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @noStoriesHere.
  ///
  /// In en, this message translates to:
  /// **'No stories to display here.'**
  String get noStoriesHere;

  /// No description provided for @storiesGroupedOrArchived.
  ///
  /// In en, this message translates to:
  /// **'They are either grouped or archived.'**
  String get storiesGroupedOrArchived;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @useAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Use account password'**
  String get useAccountPassword;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot my PIN'**
  String get forgotPin;

  /// Label for unlockTitle
  ///
  /// In en, this message translates to:
  /// **'Unlock the App'**
  String get unlockTitle;

  /// Label for search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your stories'**
  String get searchStoriesTitle;

  /// No description provided for @searchStoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the filters above to find your memories.'**
  String get searchStoriesSubtitle;

  /// No description provided for @unsavedBackups.
  ///
  /// In en, this message translates to:
  /// **'You have {count} stories not backed up.'**
  String unsavedBackups(Object count);

  /// Label for backupRecommendation
  ///
  /// In en, this message translates to:
  /// **'We recommend backing up to avoid losing your data.'**
  String get backupRecommendation;

  /// Label for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Label for performBackup
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get performBackup;

  /// Label for deleteStoryTitle
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get deleteStoryTitle;

  /// Message for deleteStoryConfirm
  ///
  /// In en, this message translates to:
  /// **'Do you want to move this story to the trash?'**
  String get deleteStoryConfirm;

  /// Label for deleteLabel
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// Message for movedToTrash
  ///
  /// In en, this message translates to:
  /// **'Story moved to trash'**
  String get movedToTrash;

  /// Error message when deleting story fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting story: {error}'**
  String errorDeletingStory(Object error);

  /// Message when there are no records on given day
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get noRecordsThisDay;

  /// Label showing story is ungrouped
  ///
  /// In en, this message translates to:
  /// **'Story ungrouped'**
  String get storyUngrouped;

  /// Generic save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// Snackbar message when a group is deleted
  ///
  /// In en, this message translates to:
  /// **'Group deleted successfully'**
  String get groupDeletedSuccess;

  /// Displayed when no groups are found
  ///
  /// In en, this message translates to:
  /// **'No groups found'**
  String get noGroupsFound;

  /// Error message when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Could not share'**
  String get shareError;

  /// Error shown when photo deletion fails
  ///
  /// In en, this message translates to:
  /// **'Cannot delete this photo'**
  String get cannotDeletePhoto;

  /// Dialog title for photo deletion
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhotoTitle;

  /// Confirmation text for deleting a photo
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this photo?'**
  String get deletePhotoConfirm;

  /// Dialog title for group deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroupTitle;

  /// Label for share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for the Scrapbook story share template
  ///
  /// In en, this message translates to:
  /// **'Scrapbook'**
  String get scrapbookTemplateLabel;

  /// Label for the Polaroid story share template
  ///
  /// In en, this message translates to:
  /// **'Polaroid'**
  String get polaroidTemplateLabel;

  /// Label for home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Label for groups tab
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Title shown on the groups/archived stories screen
  ///
  /// In en, this message translates to:
  /// **'My Stories'**
  String get myStories;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @filterText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get filterText;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @filterEmoticon.
  ///
  /// In en, this message translates to:
  /// **'Emoticon'**
  String get filterEmoticon;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get filterDate;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @searchHintTag.
  ///
  /// In en, this message translates to:
  /// **'Type a tag...'**
  String get searchHintTag;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search in title or description...'**
  String get searchHintText;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @tapToSelectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Tap to select an emoji:'**
  String get tapToSelectEmoji;

  /// No description provided for @selectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Select emoji'**
  String get selectEmoji;

  /// No description provided for @tapToChangeEmoji.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChangeEmoji;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @recordVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'Record a video'**
  String get recordVideoLabel;

  /// No description provided for @recordAudioLabel.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get recordAudioLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @laterLabel.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterLabel;

  /// No description provided for @configureLabel.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configureLabel;

  /// Snackbar when image copied
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard (base64)'**
  String get imageCopiedBase64;

  /// Label for creating new group
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// Label for editing a group
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// Prompt to choose icon
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get chooseIcon;

  /// Warning shown when deleting a group with stories
  ///
  /// In en, this message translates to:
  /// **'This group has {count} story(ies) linked. If deleted, those stories will return to the home screen (no group). Continue?'**
  String groupDeleteWarning(Object count);

  /// Label for unarchive
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// Label for group
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @existingGroups.
  ///
  /// In en, this message translates to:
  /// **'Existing Groups'**
  String get existingGroups;

  /// No description provided for @createNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createNewGroup;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameLabel;

  /// No description provided for @groupNameMaxLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Maximum 15 characters.'**
  String get groupNameMaxLengthHint;

  /// No description provided for @groupNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Group name must be at most 15 characters.'**
  String get groupNameTooLong;

  /// No description provided for @createAndSelect.
  ///
  /// In en, this message translates to:
  /// **'Create and Select'**
  String get createAndSelect;

  /// No description provided for @manageBackups.
  ///
  /// In en, this message translates to:
  /// **'Manage Backup'**
  String get manageBackups;

  /// No description provided for @createAndShareBackup.
  ///
  /// In en, this message translates to:
  /// **'Create and Share Backup'**
  String get createAndShareBackup;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get restoreFromFile;

  /// No description provided for @backupNotAvailableWeb.
  ///
  /// In en, this message translates to:
  /// **'Backup not available on web'**
  String get backupNotAvailableWeb;

  /// No description provided for @backupNotAvailableDetail.
  ///
  /// In en, this message translates to:
  /// **'The backup feature requires file system access, available only on Android, iOS and desktop versions.'**
  String get backupNotAvailableDetail;

  /// No description provided for @backupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Backup'**
  String get backupInfoTitle;

  /// No description provided for @backupInfoDetails.
  ///
  /// In en, this message translates to:
  /// **'The complete backup includes:\n• Database (stories, texts, photos, audios)\n• Video files\n\nA ZIP file will be created and you can save it wherever you want:\n• OneDrive\n• Google Drive\n• Email\n• Any other location'**
  String get backupInfoDetails;

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Backup'**
  String get backupComplete;

  /// No description provided for @backupZipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ZIP file with all your data'**
  String get backupZipSubtitle;

  /// No description provided for @backupZipExplanation.
  ///
  /// In en, this message translates to:
  /// **'Generates a ZIP file that you can save to your device, OneDrive, Google Drive, email, or any other cloud location, except messaging apps.'**
  String get backupZipExplanation;

  /// Explanation shown on the backup card when running on Linux desktop
  ///
  /// In en, this message translates to:
  /// **'Choose a folder and the backup ZIP will be saved directly to it.'**
  String get backupLinuxExplanation;

  /// No description provided for @restoreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreSectionTitle;

  /// No description provided for @restoreSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a backup file (ZIP) previously created to restore all your data.'**
  String get restoreSectionDescription;

  /// Label showing the filename of the last backup
  ///
  /// In en, this message translates to:
  /// **'Last backup: {fileName}'**
  String lastBackupLabel(String fileName);

  /// Subject used when sharing a manual backup file
  ///
  /// In en, this message translates to:
  /// **'DayApp Backup'**
  String get backupShareSubject;

  /// No description provided for @backupDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup?\n\n{fileName}'**
  String backupDeleteConfirm(String fileName);

  /// No description provided for @backupShareError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing backup: {message}'**
  String backupShareError(String message);

  /// No description provided for @backupDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting backup: {message}'**
  String backupDeleteError(String message);

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @backupStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting backup...'**
  String get backupStarting;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup file created!'**
  String get backupCreatedSuccess;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Error creating backup: {message}'**
  String backupError(Object message);

  /// No description provided for @restoreStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting restore...'**
  String get restoreStarting;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore completed successfully!'**
  String get restoreSuccess;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring: {message}'**
  String restoreError(Object message);

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Confirm Restore'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'All current data will be replaced by the backup.\n\nThis action cannot be undone. Do you wish to continue?'**
  String get restoreConfirmContent;

  /// No description provided for @restoreSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'✅ Restore Completed'**
  String get restoreSuccessTitle;

  /// No description provided for @restoreSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'The backup was restored successfully!\n\nAll your stories have been restored to the backup state.\n\nYou need to log in again to complete the process.'**
  String get restoreSuccessContent;

  /// No description provided for @helpAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About DayApp'**
  String get helpAboutTitle;

  /// No description provided for @helpAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'DayApp is a personal diary app that lets you record your stories, memories and thoughts in an organized and secure way.'**
  String get helpAboutDescription;

  /// No description provided for @helpNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Main Navigation'**
  String get helpNavigationTitle;

  /// No description provided for @helpHomeItemDesc.
  ///
  /// In en, this message translates to:
  /// **'View the last 5 or all stories on large or smaller cards or in the calendar'**
  String get helpHomeItemDesc;

  /// No description provided for @helpHomeDoubleTapDesc.
  ///
  /// In en, this message translates to:
  /// **'Double tap a story to view it.'**
  String get helpHomeDoubleTapDesc;

  /// No description provided for @helpHomeAttachmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap attachments to view them.'**
  String get helpHomeAttachmentsDesc;

  /// No description provided for @helpHomeSwipeRightDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag the card to the right to Archive the story. The story is moved to the Collections / Groups / Archived tab'**
  String get helpHomeSwipeRightDesc;

  /// No description provided for @helpHomeSwipeLeftDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag the card to the left to associate it with a Group. The story is moved to the Collections / Groups / Archived tab'**
  String get helpHomeSwipeLeftDesc;

  /// No description provided for @helpHomeCalendarIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the calendar icon to view your stories in that format.'**
  String get helpHomeCalendarIconDesc;

  /// No description provided for @helpHomeChapterIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your stories into Chapters and Thematic Groups. Create Chapters and tell your complete story. Create custom Groups to categorize your memories.'**
  String get helpHomeChapterIconDesc;

  /// No description provided for @helpGroupsNavDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your stories into Chapters and Thematic Groups. Create Chapters and tell your complete story. Create custom Groups to categorize your memories.'**
  String get helpGroupsNavDesc;

  /// No description provided for @helpSearchItemDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly find stories by title, content, tag or date.'**
  String get helpSearchItemDesc;

  /// No description provided for @helpCreatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating Stories'**
  String get helpCreatingTitle;

  /// No description provided for @helpNewStoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the floating button (+ New Story) to create a new story. Add title, text, images, videos and audios.'**
  String get helpNewStoryDesc;

  /// No description provided for @helpTextEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get helpTextEditorTitle;

  /// No description provided for @helpTextEditorDesc.
  ///
  /// In en, this message translates to:
  /// **'Use rich formatting: bold, italic, lists, links and more.'**
  String get helpTextEditorDesc;

  /// No description provided for @helpChaptersDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your story into chapters by joining other stories on the same topic.'**
  String get helpChaptersDesc;

  /// No description provided for @helpMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Add photos from the gallery or camera, record videos or audios directly in the app.'**
  String get helpMediaDesc;

  /// No description provided for @helpGroupsAssocDesc.
  ///
  /// In en, this message translates to:
  /// **'Associate each story with one or more groups for better organization.'**
  String get helpGroupsAssocDesc;

  /// No description provided for @helpCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'View your stories organized by date. Tap a date to see all stories for that day.'**
  String get helpCalendarDesc;

  /// No description provided for @helpCreateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get helpCreateGroupTitle;

  /// No description provided for @helpCreateGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Groups\" in the side menu to create new groups with custom colors and emoticons.'**
  String get helpCreateGroupDesc;

  /// No description provided for @helpEditGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get helpEditGroupTitle;

  /// No description provided for @helpEditGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap a group to edit name, emoticon or delete.'**
  String get helpEditGroupDesc;

  /// No description provided for @helpGroupsAssocTitle.
  ///
  /// In en, this message translates to:
  /// **'Associate to Groups'**
  String get helpGroupsAssocTitle;

  /// No description provided for @helpDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get helpDeleteGroupTitle;

  /// No description provided for @helpDeleteGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete a Group without deleting its stories.'**
  String get helpDeleteGroupDesc;

  /// No description provided for @helpInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get helpInsightsTitle;

  /// No description provided for @helpInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive insights based on your stories on the home screen.\nSome insights are only available in the Premium version.\nAccess the insights history in the side menu.'**
  String get helpInsightsDesc;

  /// No description provided for @helpBackupSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Security'**
  String get helpBackupSecurityTitle;

  /// No description provided for @helpAutomaticBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get helpAutomaticBackupTitle;

  /// No description provided for @helpAutomaticBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure automatic backup (Premium) in Settings. The backup will be created when you log out.'**
  String get helpAutomaticBackupDesc;

  /// No description provided for @helpManualBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get helpManualBackupTitle;

  /// No description provided for @helpManualBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Go to \"Manage Complete Backup\" in Settings to create a full backup with all media.'**
  String get helpManualBackupDesc;

  /// No description provided for @helpRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get helpRestoreTitle;

  /// No description provided for @helpRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Use \"Restore from File\" to recover data from a previous backup.'**
  String get helpRestoreDesc;

  /// No description provided for @helpPinSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security PIN'**
  String get helpPinSecurityTitle;

  /// No description provided for @helpPinSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a 4- to 8-digit PIN to protect app access.'**
  String get helpPinSecurityDesc;

  /// No description provided for @helpBiometricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint to unlock the app quickly, if available on your device.'**
  String get helpBiometricsDesc;

  /// No description provided for @helpPasswordUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Unlock'**
  String get helpPasswordUnlockTitle;

  /// No description provided for @helpPasswordUnlockDesc.
  ///
  /// In en, this message translates to:
  /// **'In addition to PIN and biometrics, you can unlock the app using your account password. Useful if you forget the PIN or biometrics fail.'**
  String get helpPasswordUnlockDesc;

  /// No description provided for @helpBackgroundLockDesc.
  ///
  /// In en, this message translates to:
  /// **'When the app is minimized or you switch to another app, it locks automatically after the configured time. You can set the time freely in settings (seconds, minutes or hours).'**
  String get helpBackgroundLockDesc;

  /// No description provided for @helpLockExceptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Exceptions'**
  String get helpLockExceptionsTitle;

  /// No description provided for @helpLockExceptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'The app does not lock when you use internal features that open other apps—such as picking photos from the gallery, recording videos, choosing backup location or sharing stories.'**
  String get helpLockExceptionsDesc;

  /// No description provided for @helpPinRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN Recovery'**
  String get helpPinRecoveryTitle;

  /// No description provided for @helpPinRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN? Use the \"Forgot my PIN\" option on the lock screen. A recovery code will be sent to the registered email.'**
  String get helpPinRecoveryDesc;

  /// No description provided for @helpThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light, dark, automatic themes and others available in the Premium version.'**
  String get helpThemeDesc;

  /// No description provided for @helpNotificationsSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure how the app\'s reminder notification will behave when creating stories with future dates.'**
  String get helpNotificationsSettingsDesc;

  /// No description provided for @helpBackgroundLockSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Define how long the app can stay in the background before being locked. You may use values in seconds, minutes or hours, with full freedom.'**
  String get helpBackgroundLockSettingsDesc;

  /// No description provided for @helpBackupSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get helpBackupSettingTitle;

  /// No description provided for @helpBackupSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage backup and restore settings.'**
  String get helpBackupSettingDesc;

  /// No description provided for @helpTrashDesc.
  ///
  /// In en, this message translates to:
  /// **'Deleted stories stay in the trash for 30 days. Access \"Trash\" in the side menu to recover or permanently delete.'**
  String get helpTrashDesc;

  /// No description provided for @helpStatisticsDesc.
  ///
  /// In en, this message translates to:
  /// **'View statistics about your diary usage: number of stories, words written, top groups, etc.'**
  String get helpStatisticsDesc;

  /// No description provided for @helpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get helpTipsTitle;

  /// No description provided for @helpOrganizationTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get helpOrganizationTipTitle;

  /// No description provided for @helpOrganizationTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Groups to categorize your stories by themes, and Chapters to tell the whole story.'**
  String get helpOrganizationTipDesc;

  /// No description provided for @helpSearchTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get helpSearchTipTitle;

  /// No description provided for @helpSearchTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the search function to quickly find old stories.'**
  String get helpSearchTipDesc;

  /// No description provided for @helpBackupTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Regular Backup'**
  String get helpBackupTipTitle;

  /// No description provided for @helpBackupTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Back up regularly, especially before updates or device changes.'**
  String get helpBackupTipDesc;

  /// No description provided for @helpPrivacyTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get helpPrivacyTipTitle;

  /// No description provided for @helpPrivacyTipDesc.
  ///
  /// In en, this message translates to:
  /// **'Your stories are stored locally and encrypted. Set a PIN for additional protection.'**
  String get helpPrivacyTipDesc;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'For questions or issues, contact us via support email or check app updates.'**
  String get helpSupportDesc;

  /// Displayed when account creation fails
  ///
  /// In en, this message translates to:
  /// **'Error creating account. Please try again.'**
  String get errorCreateAccount;

  /// Displayed when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorShare;

  /// No description provided for @errorPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {message}'**
  String errorPlayAudio(Object message);

  /// No description provided for @errorSelectVideos.
  ///
  /// In en, this message translates to:
  /// **'Error selecting videos: {message}'**
  String errorSelectVideos(Object message);

  /// No description provided for @errorSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {message}'**
  String errorSelectFile(Object message);

  /// No description provided for @errorRecordVideo.
  ///
  /// In en, this message translates to:
  /// **'Error recording video: {message}'**
  String errorRecordVideo(Object message);

  /// No description provided for @errorStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Error starting recording: {message}'**
  String errorStartRecording(Object message);

  /// No description provided for @errorPauseRecording.
  ///
  /// In en, this message translates to:
  /// **'Error pausing recording: {message}'**
  String errorPauseRecording(Object message);

  /// No description provided for @errorResumeRecording.
  ///
  /// In en, this message translates to:
  /// **'Error resuming recording: {message}'**
  String errorResumeRecording(Object message);

  /// No description provided for @errorStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Error stopping recording: {message}'**
  String errorStopRecording(Object message);

  /// No description provided for @errorSelectAudios.
  ///
  /// In en, this message translates to:
  /// **'Error selecting audios: {message}'**
  String errorSelectAudios(Object message);

  /// Displayed when video fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading video'**
  String get errorLoadVideo;

  /// Displayed when image selection fails
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectImage;

  /// No description provided for @imagePickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get imagePickerTitleMultiple;

  /// No description provided for @imagePickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get imagePickerTitleSingle;

  /// No description provided for @imagePickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (gallery allows multiple photos):'**
  String get imagePickerChooseOptionMultiple;

  /// No description provided for @imagePickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get imagePickerChooseOptionSingle;

  /// No description provided for @imagePickerGalleryMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get imagePickerGalleryMultiple;

  /// No description provided for @imagePickerGallerySingle.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get imagePickerGallerySingle;

  /// No description provided for @imagePickerTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get imagePickerTakePhoto;

  /// No description provided for @audioPickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Audios'**
  String get audioPickerTitleMultiple;

  /// No description provided for @audioPickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Audio'**
  String get audioPickerTitleSingle;

  /// No description provided for @audioPickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (files allow multiple audios):'**
  String get audioPickerChooseOptionMultiple;

  /// No description provided for @audioPickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get audioPickerChooseOptionSingle;

  /// No description provided for @audioPickerSelectFilesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select audio files'**
  String get audioPickerSelectFilesMultiple;

  /// No description provided for @audioPickerSelectFilesSingle.
  ///
  /// In en, this message translates to:
  /// **'Pick audio file'**
  String get audioPickerSelectFilesSingle;

  /// No description provided for @audioPickerRecord.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get audioPickerRecord;

  /// No description provided for @videoPickerTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Add Videos'**
  String get videoPickerTitleMultiple;

  /// No description provided for @videoPickerTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get videoPickerTitleSingle;

  /// No description provided for @videoPickerChooseOptionMultiple.
  ///
  /// In en, this message translates to:
  /// **'Choose an option (files allow multiple videos):'**
  String get videoPickerChooseOptionMultiple;

  /// No description provided for @videoPickerChooseOptionSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose an option:'**
  String get videoPickerChooseOptionSingle;

  /// No description provided for @videoPickerSelectFilesMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select video files'**
  String get videoPickerSelectFilesMultiple;

  /// No description provided for @videoPickerSelectFilesSingle.
  ///
  /// In en, this message translates to:
  /// **'Pick video file'**
  String get videoPickerSelectFilesSingle;

  /// No description provided for @videoPickerRecord.
  ///
  /// In en, this message translates to:
  /// **'Record video'**
  String get videoPickerRecord;

  /// No description provided for @successVideoAdded.
  ///
  /// In en, this message translates to:
  /// **'Video added successfully!'**
  String get successVideoAdded;

  /// No description provided for @successVideosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} videos added successfully!'**
  String successVideosAdded(Object count);

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @recordingPaused.
  ///
  /// In en, this message translates to:
  /// **'Recording paused'**
  String get recordingPaused;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @readyToRecord.
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get readyToRecord;

  /// Title for the notification scheduling dialog
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get notificationDialogTitle;

  /// Prompt asking when the user wants to be notified
  ///
  /// In en, this message translates to:
  /// **'When would you like to be notified about this entry?'**
  String get notificationDialogPrompt;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'E-mail already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @successNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled successfully'**
  String get successNotificationScheduled;

  /// Title used for entry reminder notifications
  ///
  /// In en, this message translates to:
  /// **'Reminder: {title}'**
  String notificationReminderTitle(Object title);

  /// Body text for entry reminder notifications
  ///
  /// In en, this message translates to:
  /// **'You have a scheduled entry'**
  String get notificationReminderBody;

  /// No description provided for @successImageAdded.
  ///
  /// In en, this message translates to:
  /// **'Image added successfully!'**
  String get successImageAdded;

  /// No description provided for @successImagesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} images added successfully!'**
  String successImagesAdded(Object count);

  /// No description provided for @errorSearch.
  ///
  /// In en, this message translates to:
  /// **'Error during search: {message}'**
  String errorSearch(Object message);

  /// No description provided for @successStoryRestored.
  ///
  /// In en, this message translates to:
  /// **'Story restored successfully'**
  String get successStoryRestored;

  /// No description provided for @successStoryDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Story permanently deleted'**
  String get successStoryDeletedPermanently;

  /// No description provided for @trashAlreadyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is already empty'**
  String get trashAlreadyEmpty;

  /// No description provided for @successVideoRecorded.
  ///
  /// In en, this message translates to:
  /// **'Video recorded successfully!'**
  String get successVideoRecorded;

  /// No description provided for @permissionMicrophoneDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission not granted'**
  String get permissionMicrophoneDenied;

  /// No description provided for @errorSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Error selecting images: {message}'**
  String errorSelectImages(Object message);

  /// No description provided for @successPhotoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully!'**
  String get successPhotoCaptured;

  /// No description provided for @restoreStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore stories'**
  String get restoreStoriesTitle;

  /// No description provided for @restoreStoriesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore {count} selected story(ies)?'**
  String restoreStoriesConfirm(Object count);

  /// No description provided for @restoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreLabel;

  /// No description provided for @permanentlyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDeleteTitle;

  /// Confirmation when permanently deleting a story
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Do you really want to permanently delete this story?'**
  String get permanentlyDeleteConfirm;

  /// No description provided for @permanentlyDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDeleteLabel;

  /// Confirmation when deleting a group
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove the group \"{name}\" from your stories?'**
  String deleteGroupConfirm(Object name);

  /// Label for recoverPinTitle
  ///
  /// In en, this message translates to:
  /// **'Recover PIN'**
  String get recoverPinTitle;

  /// No description provided for @recoverPinDescription.
  ///
  /// In en, this message translates to:
  /// **'We will send a recovery code to your registered email.'**
  String get recoverPinDescription;

  /// Label for sendCode
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrashTitle;

  /// No description provided for @emptyTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to permanently delete all {count} story(ies) in the trash? This action cannot be undone.'**
  String emptyTrashConfirm(Object count);

  /// No description provided for @emptyTrashLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrashLabel;

  /// No description provided for @errorTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo: {message}'**
  String errorTakePhoto(Object message);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @entryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Entry notifications'**
  String get entryNotifications;

  /// No description provided for @entryNotificationsInfo.
  ///
  /// In en, this message translates to:
  /// **'Entries with a date at least 3 hours ahead may have scheduled notifications.'**
  String get entryNotificationsInfo;

  /// No description provided for @backgroundRestrictionsWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Background Apps'**
  String get backgroundRestrictionsWarningTitle;

  /// No description provided for @backgroundRestrictionsWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Some systems aggressively sleep background apps to save battery, which may block the app\'s scheduled notifications. To ensure proper functioning, open the app\'s settings on your device and:\n• Disable \'Pause app activity if unused\' (or similar option).\n• Set battery restrictions to \'Unrestricted\' (don\'t worry, background battery consumption is negligible).'**
  String get backgroundRestrictionsWarningDesc;

  /// No description provided for @defaultAdvanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Default advance'**
  String get defaultAdvanceTitle;

  /// No description provided for @notificationAdvanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification advance'**
  String get notificationAdvanceTitle;

  /// No description provided for @notificationAdvancePrompt.
  ///
  /// In en, this message translates to:
  /// **'How much notice would you like before being notified?'**
  String get notificationAdvancePrompt;

  /// No description provided for @notificationAdvanceDefault.
  ///
  /// In en, this message translates to:
  /// **'Default advance'**
  String get notificationAdvanceDefault;

  /// No description provided for @notificationScheduleModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduling mode (QA)'**
  String get notificationScheduleModeTitle;

  /// No description provided for @notificationScheduleModeInexact.
  ///
  /// In en, this message translates to:
  /// **'Inexact (Play-compliant)'**
  String get notificationScheduleModeInexact;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// No description provided for @manageCompleteBackup.
  ///
  /// In en, this message translates to:
  /// **'Manage full backup'**
  String get manageCompleteBackup;

  /// No description provided for @backupWithVideosZip.
  ///
  /// In en, this message translates to:
  /// **'Backup with videos in ZIP file'**
  String get backupWithVideosZip;

  /// No description provided for @backupOnLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup will be created when you log out'**
  String get backupOnLogoutDescription;

  /// No description provided for @automaticBackupInfo.
  ///
  /// In en, this message translates to:
  /// **'When you log out, a backup will be created and you can choose where to save it (local folder, Google Drive, etc).'**
  String get automaticBackupInfo;

  /// No description provided for @automaticBackupInfoLocal.
  ///
  /// In en, this message translates to:
  /// **'On logout, a backup is automatically saved locally on your device. You can later export it to cloud storage if needed.'**
  String get automaticBackupInfoLocal;

  /// Section title for backup folder configuration
  ///
  /// In en, this message translates to:
  /// **'Backup Folder'**
  String get incrementalBackupTitle;

  /// Description under the backup section
  ///
  /// In en, this message translates to:
  /// **'Stories are automatically backed up to this folder whenever you save one.'**
  String get incrementalBackupDescription;

  /// Subtitle shown when no backup folder has been selected
  ///
  /// In en, this message translates to:
  /// **'Folder not configured'**
  String get incrementalBackupFolderNotSet;

  /// Subtitle shown when a backup folder has been selected
  ///
  /// In en, this message translates to:
  /// **'Folder configured'**
  String get incrementalBackupFolderConfigured;

  /// Button label to open SAF folder picker
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get incrementalBackupSelectFolder;

  /// Button label to change the currently configured backup folder
  ///
  /// In en, this message translates to:
  /// **'Change Folder'**
  String get incrementalBackupChangeFolder;

  /// Progress message shown while migrating backup files to a new folder
  ///
  /// In en, this message translates to:
  /// **'Copying files to new folder...'**
  String get incrementalBackupChangingFolder;

  /// Snackbar message when folder change is successful
  ///
  /// In en, this message translates to:
  /// **'Backup folder updated.'**
  String get incrementalBackupFolderChanged;

  /// Warning shown when saving a story but no backup folder is configured
  ///
  /// In en, this message translates to:
  /// **'Backup folder not set. Stories will not be backed up until you configure a folder in Settings.'**
  String get incrementalBackupWarningNoFolder;

  /// Tooltip/label for the sync-done icon shown briefly after saving a story
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get incrementalBackupSyncDone;

  /// Dialog title for first-time backup folder setup prompt
  ///
  /// In en, this message translates to:
  /// **'Set Up Backup Folder'**
  String get backupSetupTitle;

  /// Dialog content for first-time backup folder setup prompt
  ///
  /// In en, this message translates to:
  /// **'Choose a folder where your stories will be backed up automatically. This ensures your data is always safe.'**
  String get backupSetupContent;

  /// Progress message shown while copying the backup zip to the configured folder
  ///
  /// In en, this message translates to:
  /// **'Saving backup to configured folder...'**
  String get backupSavedToFolder;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricsNotAvailable;

  /// No description provided for @biometricsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics disabled'**
  String get biometricsDisabled;

  /// No description provided for @biometricConfiguredInfo.
  ///
  /// In en, this message translates to:
  /// **'Biometrics is configured. You can log in using your fingerprint.'**
  String get biometricConfiguredInfo;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricAuthFailed;

  /// No description provided for @confirmIdentityToEnableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to enable biometrics'**
  String get confirmIdentityToEnableBiometrics;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarFormatMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarFormatMonth;

  /// No description provided for @calendarFormatTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get calendarFormatTwoWeeks;

  /// No description provided for @calendarFormatWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarFormatWeek;

  /// No description provided for @groupExists.
  ///
  /// In en, this message translates to:
  /// **'Group already exists'**
  String get groupExists;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the group'**
  String get enterGroupName;

  /// Label for archivedTitle
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedTitle;

  /// Label for toggleToIcons
  ///
  /// In en, this message translates to:
  /// **'Switch to icon view'**
  String get toggleToIcons;

  /// Label for toggleToCards
  ///
  /// In en, this message translates to:
  /// **'Switch to card view'**
  String get toggleToCards;

  /// Label for menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Label for editProfile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Label for editTip
  ///
  /// In en, this message translates to:
  /// **'Edit - double tap'**
  String get editTip;

  /// Label for exportPdf
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// Label for close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for newStory
  ///
  /// In en, this message translates to:
  /// **'New Story'**
  String get newStory;

  /// Label for newStoryHere
  ///
  /// In en, this message translates to:
  /// **'New Story Here'**
  String get newStoryHere;

  /// Label for noArchivedStories
  ///
  /// In en, this message translates to:
  /// **'No archived stories.'**
  String get noArchivedStories;

  /// Label for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview - {title}'**
  String previewTitle(Object title);

  /// Label for archiveLabel
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveLabel;

  /// Message for storyArchived
  ///
  /// In en, this message translates to:
  /// **'Story archived'**
  String get storyArchived;

  /// Label for undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Label for ungroup
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get ungroup;

  /// No description provided for @noStoriesInGroup.
  ///
  /// In en, this message translates to:
  /// **'No stories in group {group}'**
  String noStoriesInGroup(Object group);

  /// No description provided for @exportPdfError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF: {error}'**
  String exportPdfError(Object error);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required!'**
  String get titleRequired;

  /// No description provided for @errorSavingStory.
  ///
  /// In en, this message translates to:
  /// **'Error saving story: {error}'**
  String errorSavingStory(Object error);

  /// No description provided for @exportPdfFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and description are required to export.'**
  String get exportPdfFieldsRequired;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export Story'**
  String get exportHistory;

  /// No description provided for @exportHistoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save before exporting or just preview?'**
  String get exportHistoryPrompt;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @saveAndExport.
  ///
  /// In en, this message translates to:
  /// **'Save and export'**
  String get saveAndExport;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @errorLoadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error loading file: {error}'**
  String errorLoadingFile(Object error);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discardStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard story?'**
  String get discardStoryTitle;

  /// No description provided for @unsavedStoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have a new unsaved story. Leave without saving?'**
  String get unsavedStoryPrompt;

  /// No description provided for @changeDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDateTooltip;

  /// No description provided for @storyTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get storyTitleLabel;

  /// No description provided for @storyTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the title'**
  String get storyTitleHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your story...'**
  String get descriptionHint;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @photosSection.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosSection;

  /// No description provided for @audiosSection.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audiosSection;

  /// No description provided for @videosSection.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosSection;

  /// No description provided for @importTxtTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import .txt'**
  String get importTxtTooltip;

  /// No description provided for @expandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandTooltip;

  /// No description provided for @photoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTooltip;

  /// No description provided for @videoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTooltip;

  /// No description provided for @audioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioTooltip;

  /// No description provided for @emojiTooltip.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emojiTooltip;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// No description provided for @editStory.
  ///
  /// In en, this message translates to:
  /// **'Edit Story'**
  String get editStory;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get discardChangesPrompt;

  /// No description provided for @archivedStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStateLabel;

  /// No description provided for @archivedStoryPrefixLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStoryPrefixLabel;

  /// No description provided for @archiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide from home screen'**
  String get archiveSubtitle;

  /// Title of the emoji selection modal
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get chooseEmoji;

  /// Emoji group: feelings/emotions
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get emojiGroupSentimentos;

  /// Emoji group: animals
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get emojiGroupAnimais;

  /// Emoji group: plants/vegetables
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get emojiGroupVegetais;

  /// Emoji group: sky/nature
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get emojiGroupCeu;

  /// Emoji group: objects
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get emojiGroupObjetos;

  /// Emoji group: food
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get emojiGroupAlimentos;

  /// Emoji group: places
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get emojiGroupLugares;

  /// Emoji group: symbols
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get emojiGroupSimbolos;

  /// Question asking the user about their mood/feeling
  ///
  /// In en, this message translates to:
  /// **'How did you feel in this story?'**
  String get moodQuestion;

  /// Mood option: very difficult
  ///
  /// In en, this message translates to:
  /// **'Very difficult'**
  String get moodVeryDifficult;

  /// Mood option: difficult
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get moodDifficult;

  /// Mood option: neutral
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// Mood option: good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// Mood option: very good
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get moodVeryGood;

  /// Question asking the user about their energy level
  ///
  /// In en, this message translates to:
  /// **'How was your energy?'**
  String get energyQuestion;

  /// Energy level: low
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get energyLow;

  /// Energy level: normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get energyNormal;

  /// Energy level: high
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get energyHigh;

  /// Hint text for the tags input field
  ///
  /// In en, this message translates to:
  /// **'Type and press Enter or comma'**
  String get tagsHint;

  /// Tooltip for the add tag button
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// Tooltip shown on tag chips
  ///
  /// In en, this message translates to:
  /// **'Long press to rename'**
  String get tagLongPressHint;

  /// Title of the rename tag dialog
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get renameTagTitle;

  /// Warning shown when renaming a tag
  ///
  /// In en, this message translates to:
  /// **'Renaming will affect all stories that use this tag.'**
  String get renameTagWarning;

  /// Label for the tag name text field
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameLabel;

  /// Title of the best-weekday insight card
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get insightDiscovery;

  /// Title of the positive-tag insight card
  ///
  /// In en, this message translates to:
  /// **'Pattern found'**
  String get insightPattern;

  /// Title of the mood trend insight card
  ///
  /// In en, this message translates to:
  /// **'📈 Trend'**
  String get insightTrend;

  /// Title of the monthly summary insight card
  ///
  /// In en, this message translates to:
  /// **'📊 Your month in stories'**
  String get insightMonthlySummary;

  /// Body text of the best-weekday insight
  ///
  /// In en, this message translates to:
  /// **'{weekday} is usually your most positive day.'**
  String insightBestWeekday(String weekday);

  /// Body text of the positive-tag insight
  ///
  /// In en, this message translates to:
  /// **'Stories tagged #{tag} tend to have a better mood.'**
  String insightPositiveTag(String tag);

  /// Body text of the positive trend insight
  ///
  /// In en, this message translates to:
  /// **'Your mood has been improving over the last 7 days compared to the last 30 days.'**
  String get insightTrendPositive;

  /// Body text of the monthly summary insight (without tag line)
  ///
  /// In en, this message translates to:
  /// **'Entries: {entries}\nAvg mood: {mood}\nAvg energy: {energy}'**
  String insightMonthlySummaryText(int entries, String mood, String energy);

  /// Body text of the monthly summary insight with top tag
  ///
  /// In en, this message translates to:
  /// **'Entries: {entries}\nAvg mood: {mood}\nAvg energy: {energy}\nTop tag: #{tag}'**
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  );

  /// Action button on insight cards that have a related tag
  ///
  /// In en, this message translates to:
  /// **'See stories'**
  String get insightSeeStories;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// Day of the week
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// Tooltip and label for the X button to dismiss an insight
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get insightDismiss;

  /// Title of the story balance insight
  ///
  /// In en, this message translates to:
  /// **'Story Balance'**
  String get insightStoryBalanceTitle;

  /// Insight description when positive stories prevail
  ///
  /// In en, this message translates to:
  /// **'You recorded more positive stories in the last 10 days. Keep it up!'**
  String get insightStoryBalancePositive;

  /// Insight description when difficult stories prevail
  ///
  /// In en, this message translates to:
  /// **'You recorded more difficult stories in the last 10 days. Take care of yourself!'**
  String get insightStoryBalanceDifficult;

  /// Title of the writing time-of-day insight
  ///
  /// In en, this message translates to:
  /// **'Writing Time'**
  String get insightWritingTimeTitle;

  /// Insight: user writes more in the morning
  ///
  /// In en, this message translates to:
  /// **'You wrote more in the morning this week.'**
  String get insightWritingTimeMorning;

  /// Insight: user writes more in the afternoon
  ///
  /// In en, this message translates to:
  /// **'You wrote more in the afternoon this week.'**
  String get insightWritingTimeAfternoon;

  /// Insight: user writes more at night
  ///
  /// In en, this message translates to:
  /// **'You wrote more at night this week.'**
  String get insightWritingTimeNight;

  /// Title of the weekly energy chart insight (Premium)
  ///
  /// In en, this message translates to:
  /// **'Energy — Last 7 Days'**
  String get insightEnergyChartTitle;

  /// Subtitle of the energy chart insight card
  ///
  /// In en, this message translates to:
  /// **'Your energy trend this week'**
  String get insightEnergyChartSubtitle;

  /// Title of the insight for chapter with most stories
  ///
  /// In en, this message translates to:
  /// **'Memorable Chapter'**
  String get insightChapterEngagementTitle;

  /// Description of the insight for chapter with most stories
  ///
  /// In en, this message translates to:
  /// **'Your chapter \"{chapter_title}\" is the most complete so far, with {count} stories recorded.'**
  String insightChapterEngagementDesc(String chapter_title, int count);

  /// Title of the insight for chapter with highest average mood
  ///
  /// In en, this message translates to:
  /// **'Happy Chapter'**
  String get insightChapterHappiestTitle;

  /// Description of the happiest chapter insight
  ///
  /// In en, this message translates to:
  /// **'The chapter \"{chapter_title}\" was a very positive phase, with average mood {moodEmoji} ({moodAvg}).'**
  String insightChapterHappiestDesc(
    String chapter_title,
    String moodEmoji,
    String moodAvg,
  );

  /// Title of the premium insight about people present on radiant days
  ///
  /// In en, this message translates to:
  /// **'Wellness Circle'**
  String get insightWellnessCircleTitle;

  /// Description of the premium wellness circle insight
  ///
  /// In en, this message translates to:
  /// **'People who are present on your most radiant days: {names}.'**
  String insightWellnessCircleDescription(String names);

  /// Title of the premium insight about places with positive mood
  ///
  /// In en, this message translates to:
  /// **'Peaceful Places'**
  String get insightPeacefulPlacesTitle;

  /// Description of the premium peaceful places insight
  ///
  /// In en, this message translates to:
  /// **'Where your mood stays more positive: {places}.'**
  String insightPeacefulPlacesDescription(String places);

  /// Title of the premium insight about low mood and energy
  ///
  /// In en, this message translates to:
  /// **'Take a Deep Breath'**
  String get insightBreatheDeepTitle;

  /// Description of the premium take a deep breath insight
  ///
  /// In en, this message translates to:
  /// **'Where your energy and mood are low: {places}.'**
  String insightBreatheDeepDescription(String places);

  /// Title of the insight encouraging detailed writing
  ///
  /// In en, this message translates to:
  /// **'Deep Reflections'**
  String get insightWritingLengthTitle;

  /// Description encouraging longer entries
  ///
  /// In en, this message translates to:
  /// **'Your recent reflections are quite brief. Try writing in more detail about how you felt today.'**
  String get insightWritingLengthTip;

  /// Description congratulating the user for a long entry
  ///
  /// In en, this message translates to:
  /// **'Congratulations on writing in detail recently ({count} words)! Deepening your memories helps clear the mind.'**
  String insightWritingLengthCongrats(int count);

  /// Message shown on locked Premium insights
  ///
  /// In en, this message translates to:
  /// **'This is a Premium feature. Upgrade to unlock this insight.'**
  String get insightPremiumRequired;

  /// CTA button to see Premium plans
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get insightPremiumCTA;

  /// Banner shown in development mode when all insights are forced visible
  ///
  /// In en, this message translates to:
  /// **'Dev mode: all insights visible'**
  String get insightDevModeActive;

  /// Progress message: creating backup file
  ///
  /// In en, this message translates to:
  /// **'Creating backup file...'**
  String get backupProgressCreating;

  /// Progress message: copying database
  ///
  /// In en, this message translates to:
  /// **'Copying database...'**
  String get backupProgressCopyingDb;

  /// Progress message: copying videos
  ///
  /// In en, this message translates to:
  /// **'Copying videos...'**
  String get backupProgressCopyingVideos;

  /// Progress message: copying a single video
  ///
  /// In en, this message translates to:
  /// **'Copying video {current}/{total}...'**
  String backupProgressCopyingVideo(int current, int total);

  /// Progress message: copying photos
  ///
  /// In en, this message translates to:
  /// **'Copying photos...'**
  String get backupProgressCopyingPhotos;

  /// Progress message: copying a single photo
  ///
  /// In en, this message translates to:
  /// **'Copying photo {current}/{total}...'**
  String backupProgressCopyingPhoto(int current, int total);

  /// Progress message: copying audios
  ///
  /// In en, this message translates to:
  /// **'Copying audios...'**
  String get backupProgressCopyingAudios;

  /// Progress message: copying a single audio
  ///
  /// In en, this message translates to:
  /// **'Copying audio {current}/{total}...'**
  String backupProgressCopyingAudio(int current, int total);

  /// Progress message: creating metadata
  ///
  /// In en, this message translates to:
  /// **'Creating metadata...'**
  String get backupProgressCreatingMetadata;

  /// Progress message: compressing files
  ///
  /// In en, this message translates to:
  /// **'Compressing files...'**
  String get backupProgressCompressing;

  /// Progress message: backup created successfully
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully!'**
  String get backupProgressSuccess;

  /// Text shown in the share sheet when sharing backup
  ///
  /// In en, this message translates to:
  /// **'Complete DayApp backup with database and videos'**
  String get backupShareText;

  /// Error thrown when the database file is missing during backup
  ///
  /// In en, this message translates to:
  /// **'Database not found.'**
  String get errorBackupDbNotFound;

  /// Error thrown when the backup ZIP file is missing
  ///
  /// In en, this message translates to:
  /// **'Backup file not found.'**
  String get errorBackupFileNotFound;

  /// Error thrown when the database is missing inside the backup ZIP
  ///
  /// In en, this message translates to:
  /// **'Database not found in backup file. Extracted files: {count}'**
  String errorBackupDbNotFoundInFile(int count);

  /// Progress message: extracting ZIP
  ///
  /// In en, this message translates to:
  /// **'Extracting backup file...'**
  String get restoreProgressExtracting;

  /// Progress message: how many files the ZIP has
  ///
  /// In en, this message translates to:
  /// **'ZIP contains {count} files...'**
  String restoreProgressZipContains(int count);

  /// Progress message: backing up current DB before restore
  ///
  /// In en, this message translates to:
  /// **'Backing up current database...'**
  String get restoreProgressBackingUpCurrent;

  /// Progress message: closing DB connections
  ///
  /// In en, this message translates to:
  /// **'Closing database connections...'**
  String get restoreProgressClosingDb;

  /// Progress message: restoring database
  ///
  /// In en, this message translates to:
  /// **'Restoring database...'**
  String get restoreProgressRestoringDb;

  /// Progress message: copying restored DB
  ///
  /// In en, this message translates to:
  /// **'Copying restored database...'**
  String get restoreProgressCopyingRestoredDb;

  /// Progress message: restoring videos
  ///
  /// In en, this message translates to:
  /// **'Restoring videos...'**
  String get restoreProgressRestoringVideos;

  /// Progress message: restoring a single video
  ///
  /// In en, this message translates to:
  /// **'Restoring video {current}/{total}...'**
  String restoreProgressRestoringVideo(int current, int total);

  /// Progress message: restoring photos
  ///
  /// In en, this message translates to:
  /// **'Restoring photos...'**
  String get restoreProgressRestoringPhotos;

  /// Progress message: restoring a single photo
  ///
  /// In en, this message translates to:
  /// **'Restoring photo {current}/{total}...'**
  String restoreProgressRestoringPhoto(int current, int total);

  /// Progress message: restoring audios
  ///
  /// In en, this message translates to:
  /// **'Restoring audios...'**
  String get restoreProgressRestoringAudios;

  /// Progress message: restoring a single audio
  ///
  /// In en, this message translates to:
  /// **'Restoring audio {current}/{total}...'**
  String restoreProgressRestoringAudio(int current, int total);

  /// Progress message: reinitializing database after restore
  ///
  /// In en, this message translates to:
  /// **'Reinitializing database...'**
  String get restoreProgressReinitializingDb;

  /// Progress message showing how many stories were restored
  ///
  /// In en, this message translates to:
  /// **'Database restored: {active} active, {deleted} in trash.'**
  String restoreProgressDbStats(int active, int deleted);

  /// Button to resend recovery code via email
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeButton;

  /// Message showing how many minutes until recovery code expires
  ///
  /// In en, this message translates to:
  /// **'Code expires in {minutes} minutes'**
  String codeExpiresIn(int minutes);

  /// Button to go back to the first step of recovery
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backToStart;

  /// Label for recovery code
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Label for PIN field
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// Title for entering recovery code
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// Description for code verification step
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code that was sent to your email.'**
  String get codeCheckDescription;

  /// Description for setting new PIN
  ///
  /// In en, this message translates to:
  /// **'Define a new secure PIN for your account.'**
  String get defineNewPin;

  /// Button to send recovery code
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// Button to verify recovery code
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// Button to reset PIN
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// Narrative text for mood level 1 in story preview
  ///
  /// In en, this message translates to:
  /// **'This was a very difficult story'**
  String get storyPreviewMoodVeryDifficultNarrative;

  /// Narrative text for mood level 2 in story preview
  ///
  /// In en, this message translates to:
  /// **'This was a difficult story'**
  String get storyPreviewMoodDifficultNarrative;

  /// Narrative text for mood level 3 in story preview
  ///
  /// In en, this message translates to:
  /// **'It was neutral in terms of feeling'**
  String get storyPreviewMoodNeutralNarrative;

  /// Narrative text for mood level 4 in story preview
  ///
  /// In en, this message translates to:
  /// **'A good story'**
  String get storyPreviewMoodGoodNarrative;

  /// Narrative text for mood level 5 in story preview
  ///
  /// In en, this message translates to:
  /// **'A very good story'**
  String get storyPreviewMoodVeryGoodNarrative;

  /// Narrative text for energy level 1 in story preview
  ///
  /// In en, this message translates to:
  /// **'I was feeling low on energy'**
  String get storyPreviewEnergyLowNarrative;

  /// Narrative text for energy level 2 in story preview
  ///
  /// In en, this message translates to:
  /// **'My energy was normal'**
  String get storyPreviewEnergyNormalNarrative;

  /// Narrative text for energy level 3 in story preview
  ///
  /// In en, this message translates to:
  /// **'I was feeling very high energy'**
  String get storyPreviewEnergyHighNarrative;

  /// Label for Premium plan
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// Label for the premium version option in settings
  ///
  /// In en, this message translates to:
  /// **'Premium Version'**
  String get premiumVersion;

  /// No description provided for @premiumScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'DayApp Premium'**
  String get premiumScreenTitle;

  /// No description provided for @premiumScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of your diary and preserve your memories with exclusive features.'**
  String get premiumScreenSubtitle;

  /// No description provided for @premiumScreenRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get premiumScreenRestore;

  /// No description provided for @premiumScreenPurchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime Premium'**
  String get premiumScreenPurchaseButton;

  /// No description provided for @premiumScreenFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get with Premium:'**
  String get premiumScreenFeaturesTitle;

  /// No description provided for @premiumFeatureShareHistory.
  ///
  /// In en, this message translates to:
  /// **'Share stories as custom images'**
  String get premiumFeatureShareHistory;

  /// No description provided for @premiumFeatureShareChapter.
  ///
  /// In en, this message translates to:
  /// **'Export chapters to HTML'**
  String get premiumFeatureShareChapter;

  /// No description provided for @premiumFeatureAutoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Smart automatic chapter suggestions'**
  String get premiumFeatureAutoSuggestions;

  /// No description provided for @premiumFeatureMonthlyInsights.
  ///
  /// In en, this message translates to:
  /// **'Detailed monthly insights and summaries'**
  String get premiumFeatureMonthlyInsights;

  /// No description provided for @premiumFeatureWeeklyMood.
  ///
  /// In en, this message translates to:
  /// **'7-day mood evolution chart'**
  String get premiumFeatureWeeklyMood;

  /// No description provided for @premiumFeatureCustomThemes.
  ///
  /// In en, this message translates to:
  /// **'Access to all exclusive themes and colors'**
  String get premiumFeatureCustomThemes;

  /// Short snackbar message when user taps a locked Premium feature
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumFeature;

  /// Detailed message explaining the feature is Premium
  ///
  /// In en, this message translates to:
  /// **'This feature is available in the Premium version.'**
  String get premiumFeatureInfo;

  /// Label for Free plan
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// Label showing the current plan
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlan;

  /// Title of the hidden premium debug screen
  ///
  /// In en, this message translates to:
  /// **'Premium Debug'**
  String get premiumDebugTitle;

  /// Subtitle of the hidden premium debug screen
  ///
  /// In en, this message translates to:
  /// **'Development only — not visible in production'**
  String get premiumDebugSubtitle;

  /// Button to activate premium in debug mode
  ///
  /// In en, this message translates to:
  /// **'Activate Premium (debug)'**
  String get premiumDebugActivate;

  /// Button to deactivate premium in debug mode
  ///
  /// In en, this message translates to:
  /// **'Deactivate Premium (return to Free)'**
  String get premiumDebugDeactivate;

  /// Current premium status line
  ///
  /// In en, this message translates to:
  /// **'Status: {plan}'**
  String premiumDebugStatus(String plan);

  /// Source that activated premium
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String premiumDebugSource(String source);

  /// Warning shown on the debug premium screen
  ///
  /// In en, this message translates to:
  /// **'This screen is only available in debug builds. It will not appear in production.'**
  String get premiumDebugWarning;

  /// Section title listing features per plan
  ///
  /// In en, this message translates to:
  /// **'Features controlled by plan'**
  String get premiumDebugFeatures;

  /// Shown when no premium source is recorded
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get premiumDebugNoSource;

  /// Message shown to Free users in the auto backup section
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are a Premium feature. Upgrade to access saved backups, restore points and storage management.'**
  String get autoBackupPremiumRequired;

  /// Backup count and total size shown in settings
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No backups saved} =1{1 backup · {size}} other{{count} backups · {size}}}'**
  String autoBackupStorageInfo(int count, String size);

  /// Title for chapters screen and quick access
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersTitle;

  /// Header title for the Collections screen
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsTitle;

  /// Header subtitle for the Collections screen
  ///
  /// In en, this message translates to:
  /// **'Your moments organized into chapters and groups, like a life library.'**
  String get collectionsSubtitle;

  /// Label for the groups tab inside the Collections screen
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTabLabel;

  /// Tooltip for toggling chapter shortcut card visibility
  ///
  /// In en, this message translates to:
  /// **'Show/hide chapters card on Home'**
  String get chapterShortcutToggle;

  /// Title of chapters shortcut card shown on Home
  ///
  /// In en, this message translates to:
  /// **'Your life by chapters'**
  String get chaptersHomeCardTitle;

  /// Subtitle of chapters shortcut card on Home
  ///
  /// In en, this message translates to:
  /// **'Your stories hold moments. Your chapters reveal the journey.'**
  String get chaptersHomeCardSubtitle;

  /// Message shown when chapters feature is locked for Free users
  ///
  /// In en, this message translates to:
  /// **'Chapters and automatic suggestions are Premium features.'**
  String get chaptersPremiumRequired;

  /// Message shown when a premium theme is selected by a Free user
  ///
  /// In en, this message translates to:
  /// **'Custom themes are a Premium feature.'**
  String get themePremiumRequired;

  /// Section title for automatic chapter suggestions
  ///
  /// In en, this message translates to:
  /// **'Suggested chapters'**
  String get chapterSuggestions;

  /// Success message after creating a chapter
  ///
  /// In en, this message translates to:
  /// **'Chapter created successfully.'**
  String get chapterCreated;

  /// Title of chapter edit dialog
  ///
  /// In en, this message translates to:
  /// **'Edit chapter'**
  String get chapterEditTitle;

  /// Placeholder for chapter description field
  ///
  /// In en, this message translates to:
  /// **'Enter a description for this chapter (optional)'**
  String get chapterDescriptionHint;

  /// Success message after updating chapter
  ///
  /// In en, this message translates to:
  /// **'Chapter updated successfully.'**
  String get chapterUpdated;

  /// Title of chapter deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete chapter'**
  String get chapterDeleteConfirmTitle;

  /// Message for chapter deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete chapter “{title}”? The linked stories will not be deleted.'**
  String chapterDeleteConfirmMessage(String title);

  /// Success message after deleting chapter
  ///
  /// In en, this message translates to:
  /// **'Chapter deleted successfully.'**
  String get chapterDeleted;

  /// Button to create chapter manually
  ///
  /// In en, this message translates to:
  /// **'Create chapter manually'**
  String get chapterCreateManual;

  /// Title of the manual chapter creation screen
  ///
  /// In en, this message translates to:
  /// **'Create Chapter'**
  String get chapterCreateTitle;

  /// Label for chapter title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get chapterTitle;

  /// Hint for chapter title field
  ///
  /// In en, this message translates to:
  /// **'Ex: Job change'**
  String get chapterTitleHint;

  /// Label for chapter description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get chapterDescription;

  /// Label for chapter photo section
  ///
  /// In en, this message translates to:
  /// **'Chapter photo'**
  String get chapterPhoto;

  /// Label for the command button to choose chapter photo
  ///
  /// In en, this message translates to:
  /// **'Chapter Photo'**
  String get chapterPhotoActionLabel;

  /// Button to add a chapter photo
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get chapterAddPhoto;

  /// Button to change chapter photo
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get chapterChangePhoto;

  /// Button to remove chapter photo
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get chapterRemovePhoto;

  /// Label for selecting stories to compose a chapter
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 related story'**
  String get chapterSelectEntries;

  /// Validation message for minimum stories in a chapter
  ///
  /// In en, this message translates to:
  /// **'Minimum: 1 story per chapter.'**
  String get chapterMinimumEntries;

  /// Label for selecting stories to compose a group
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 story for this group'**
  String get groupSelectStories;

  /// Validation message for minimum stories in a group
  ///
  /// In en, this message translates to:
  /// **'Minimum: 1 story per group.'**
  String get groupMinimumStories;

  /// Period label for chapter
  ///
  /// In en, this message translates to:
  /// **'Stories from {start} - {end}'**
  String chapterPeriod(String start, String end);

  /// Count of stories in chapter
  ///
  /// In en, this message translates to:
  /// **'Stories: {count}'**
  String chapterEntriesCount(int count);

  /// Average mood metric in chapter
  ///
  /// In en, this message translates to:
  /// **'Average mood: {mood}'**
  String chapterAverageMood(String mood);

  /// Top tags listed in chapter summary
  ///
  /// In en, this message translates to:
  /// **'Top tags: {tags}'**
  String chapterTopTags(String tags);

  /// Button to accept suggestion and create chapter
  ///
  /// In en, this message translates to:
  /// **'Create chapter'**
  String get chapterCreateFromSuggestion;

  /// Button to view suggested chapter groups
  ///
  /// In en, this message translates to:
  /// **'View suggestions'**
  String get chapterViewSuggestions;

  /// Main button label to create a manual chapter
  ///
  /// In en, this message translates to:
  /// **'Create my Chapter'**
  String get chapterCreateMyLabel;

  /// Button to ignore chapter suggestion
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get chapterIgnoreLabel;

  /// Footer of suggestion preview indicating how many stories were omitted
  ///
  /// In en, this message translates to:
  /// **'and {count} more stor{count, plural, =1{y} other{ies}}'**
  String chapterSuggestionMoreStories(int count);

  /// Empty state text for chapters list
  ///
  /// In en, this message translates to:
  /// **'Your next chapter starts here.'**
  String get chapterNoItems;

  /// Filter to show all chapters
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chapterFilterAll;

  /// Filter to show only automatic chapters
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get chapterFilterAutomatic;

  /// Filter to show only manual chapters
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get chapterFilterManual;

  /// Empty state when search or filter finds no chapters
  ///
  /// In en, this message translates to:
  /// **'No chapters matched the current filters.'**
  String get chapterNoSearchResults;

  /// Label for chapter sort selector
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get chapterSortLabel;

  /// Option to sort chapters by newest period
  ///
  /// In en, this message translates to:
  /// **'Newest period'**
  String get chapterSortNewest;

  /// Option to sort chapters by oldest period
  ///
  /// In en, this message translates to:
  /// **'Oldest period'**
  String get chapterSortOldest;

  /// Option to sort chapters by title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get chapterSortTitle;

  /// Option to sort chapters by story count
  ///
  /// In en, this message translates to:
  /// **'Most stories'**
  String get chapterSortStories;

  /// Short chapter list subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} stories - avg mood {mood}'**
  String chapterEntriesAndMood(int count, String mood);

  /// Button label to open chapters screen
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get chapterOpenLabel;

  /// Subtitle of the chapters intro screen
  ///
  /// In en, this message translates to:
  /// **'Organize your stories with meaning and relive your memories in order'**
  String get chapterIntroSubtitle;

  /// Title of the first intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'Bring connected moments together'**
  String get chapterIntroGroupTitle;

  /// Body of the first intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'Gather multiple posts into one chapter to follow the full trajectory of a special theme or moment.'**
  String get chapterIntroGroupBody;

  /// Title of the second intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'Relive your story from beginning to end'**
  String get chapterIntroTimelineTitle;

  /// Body of the second intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'Browse memories in chronological order and see how each moment evolved over time.'**
  String get chapterIntroTimelineBody;

  /// Title of the third intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'One chapter for each phase'**
  String get chapterIntroPhaseTitle;

  /// Body of the third intro block for chapters
  ///
  /// In en, this message translates to:
  /// **'Trips, college, family, work, dreams, goals, or special memories. You decide how to tell your story.'**
  String get chapterIntroPhaseBody;

  /// Title of the final call-to-action on chapters intro
  ///
  /// In en, this message translates to:
  /// **'Ready to organize your memories?'**
  String get chapterIntroCtaTitle;

  /// Subtitle of the final call-to-action on chapters intro
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first chapter now'**
  String get chapterIntroCtaBody;

  /// Checkbox to control whether intro appears when opening Chapters
  ///
  /// In en, this message translates to:
  /// **'Show this screen when opening Chapters'**
  String get chapterIntroShowOnOpen;

  /// Section title for linking a story to chapters
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapterLinkSectionTitle;

  /// Button label to configure chapter linking
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get chapterLinkConfigure;

  /// Dialog title for chapter linking in create/edit story
  ///
  /// In en, this message translates to:
  /// **'Add this story to chapters'**
  String get chapterLinkDialogTitle;

  /// Option to not link story to any chapter
  ///
  /// In en, this message translates to:
  /// **'Do not add'**
  String get chapterLinkModeNone;

  /// Option to link story to an existing chapter
  ///
  /// In en, this message translates to:
  /// **'Add to existing chapter'**
  String get chapterLinkModeExisting;

  /// Option to create a new chapter while saving story
  ///
  /// In en, this message translates to:
  /// **'Create new chapter'**
  String get chapterLinkModeNew;

  /// Label for existing chapter dropdown
  ///
  /// In en, this message translates to:
  /// **'Select chapter'**
  String get chapterSelectExistingLabel;

  /// Validation message when existing chapter is not selected
  ///
  /// In en, this message translates to:
  /// **'Select an existing chapter.'**
  String get chapterSelectExistingRequired;

  /// Validation message when chapter title is empty
  ///
  /// In en, this message translates to:
  /// **'Chapter title is required.'**
  String get chapterTitleRequired;

  /// Validation/help text for minimum related stories when creating chapter from create/edit flow
  ///
  /// In en, this message translates to:
  /// **'Select at least 2 related stories. With the current one, the minimum is 3.'**
  String get chapterMinimumRelatedWithCurrent;

  /// Summary text when no chapter linking is configured
  ///
  /// In en, this message translates to:
  /// **'Not linked to any chapter.'**
  String get chapterLinkSummaryNone;

  /// Summary text when linking to existing chapter is configured
  ///
  /// In en, this message translates to:
  /// **'Will be added to an existing chapter when saving.'**
  String get chapterLinkSummaryExisting;

  /// Summary text when creating new chapter from create/edit flow
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{New chapter with 1 story} other{New chapter with {count} stories}}'**
  String chapterLinkSummaryNew(int count);

  /// Generic label for overflow menu with additional options
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// Tooltip/label to display stories in large cards on Home
  ///
  /// In en, this message translates to:
  /// **'View in large cards'**
  String get homeHeaderLargeCards;

  /// Tooltip/label to display stories in compact cards on Home
  ///
  /// In en, this message translates to:
  /// **'View in compact cards'**
  String get homeHeaderCompactCards;

  /// Tooltip for calendar button in Home header
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get homeHeaderOpenCalendarTooltip;

  /// Morning greeting shown on the Home welcome card
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// Afternoon greeting shown on the Home welcome card
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// Evening greeting shown on the Home welcome card
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// Subtitle text shown below the welcome greeting on Home
  ///
  /// In en, this message translates to:
  /// **'Here are your stories'**
  String get homeStoriesSubtitle;

  /// Label for the Home switch that shows all stories
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get homeShowAllStoriesLabel;

  /// Title of the insight history screen
  ///
  /// In en, this message translates to:
  /// **'Insight History'**
  String get insightHistoryTitle;

  /// Empty state message on insight history screen
  ///
  /// In en, this message translates to:
  /// **'No insights recorded yet.'**
  String get insightHistoryEmpty;

  /// Button to clear all insight history
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get insightHistoryClearAll;

  /// Confirmation dialog body for clearing insight history
  ///
  /// In en, this message translates to:
  /// **'Clear all insight history? This action cannot be undone.'**
  String get insightHistoryClearConfirm;

  /// Label showing when an insight was seen
  ///
  /// In en, this message translates to:
  /// **'Seen on {date}'**
  String insightHistorySeenOn(String date);

  /// Filter chip label: show all insight types
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get insightHistoryFilterAll;

  /// Filter chip label: show only free tier insights
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get insightHistoryFilterFree;

  /// Filter chip label: show only premium insights
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get insightHistoryFilterPremium;

  /// Hint text for the search field on insight history screen
  ///
  /// In en, this message translates to:
  /// **'Search insights'**
  String get insightHistorySearch;

  /// Label for the PDF background color selector
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get pdfBackgroundColor;

  /// Option: no background color in the PDF
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get pdfBackgroundNone;

  /// Option: beige/cream background color in the PDF
  ///
  /// In en, this message translates to:
  /// **'Beige/cream'**
  String get pdfBackgroundBeige;

  /// Option: pale blue background color in the PDF
  ///
  /// In en, this message translates to:
  /// **'Pale blue'**
  String get pdfBackgroundBlue;

  /// Option: pale green background color in the PDF
  ///
  /// In en, this message translates to:
  /// **'Pale green'**
  String get pdfBackgroundGreen;

  /// Option: light gray background color in the PDF
  ///
  /// In en, this message translates to:
  /// **'Light gray'**
  String get pdfBackgroundGray;

  /// SnackBar shown when a Free user tries to export to PDF
  ///
  /// In en, this message translates to:
  /// **'Exporting Chapter is a Premium feature. Upgrade your plan to access it.'**
  String get exportPdfPremiumRequired;

  /// Button/title to change the user email
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// Button/title to change the user password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Label for the current password field
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Error shown when current password verification fails
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get wrongCurrentPassword;

  /// Success message after password change
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// Success message after email change
  ///
  /// In en, this message translates to:
  /// **'Email changed successfully.'**
  String get emailChangedSuccess;

  /// Validation error when new password is too short (min 6 chars)
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters.'**
  String get newPasswordMinLength;

  /// Error shown when one or more required fields are empty
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFields;

  /// Title of the backup info dialog
  ///
  /// In en, this message translates to:
  /// **'About backup'**
  String get backupInfoDialogTitle;

  /// Full content of the backup info dialog
  ///
  /// In en, this message translates to:
  /// **'📦  What is included in the backup\n• All your stories (texts, photos, audios, videos)\n• App database\n• Chapter photos\n\n📂  How to store your backup\nAfter creation, use the share menu to save the file wherever you like — OneDrive, Google Drive, e-mail or any other service.'**
  String get backupInfoDialogContent;

  /// Title of the export password dialog
  ///
  /// In en, this message translates to:
  /// **'Protect your backup'**
  String get backupPasswordDialogTitle;

  /// Description shown in the export password dialog
  ///
  /// In en, this message translates to:
  /// **'Set a password to encrypt your backup file. The contents will be protected and unreadable to anyone who does not have this password.'**
  String get backupPasswordDescription;

  /// Title of the warning section in the export password dialog
  ///
  /// In en, this message translates to:
  /// **'⚠️  Important — read before continuing'**
  String get backupPasswordWarningTitle;

  /// Warning text shown in the export password dialog
  ///
  /// In en, this message translates to:
  /// **'This password is known only to you. It is not stored anywhere in the app or on our servers.\n\nIf you forget it, the backup file will be permanently inaccessible — not even our team will be able to help you recover the data.\n\nStore this password in a safe place before proceeding.'**
  String get backupPasswordWarning;

  /// Label for the password field in the export password dialog
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupPasswordField;

  /// Label for the confirm password field in the export password dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPasswordConfirmField;

  /// Validation error when passwords do not match
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match. Please try again.'**
  String get backupPasswordMismatch;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get backupPasswordTooShort;

  /// Validation error when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get backupPasswordEmpty;

  /// Button label to create the encrypted backup
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get backupCreateEncrypted;

  /// Title of the restore password dialog
  ///
  /// In en, this message translates to:
  /// **'Enter the backup password'**
  String get restorePasswordDialogTitle;

  /// Description shown in the restore password dialog
  ///
  /// In en, this message translates to:
  /// **'If you set a password when creating this backup, enter it below.\n\nIf the backup was created without a password, leave the field blank.'**
  String get restorePasswordDescription;

  /// Label for the password field in the restore password dialog
  ///
  /// In en, this message translates to:
  /// **'Password (leave blank if none was set)'**
  String get restorePasswordField;

  /// Error shown when the restore password is incorrect
  ///
  /// In en, this message translates to:
  /// **'Incorrect password or unreadable backup. Check the password and try again.'**
  String get restorePasswordWrong;

  /// Button label to continue with restore
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get restoreContinue;

  /// Title of dialog where user selects one photo per story before PDF export
  ///
  /// In en, this message translates to:
  /// **'Choose photos for export'**
  String get chapterExportPhotoSelectionTitle;

  /// Guidance shown in photo selection dialog before chapter export
  ///
  /// In en, this message translates to:
  /// **'You can select up to 1 photo per story. Keeping none is also allowed.'**
  String get chapterExportPhotoSelectionSubtitle;

  /// Option label for exporting a story without any photo
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get chapterExportNoPhotoOption;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeExpiresMinutes.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {count} minutes'**
  String codeExpiresMinutes(int count);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @informRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email'**
  String get informRegisteredEmail;

  /// No description provided for @newPasswordMinLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'New password (minimum 6 characters)'**
  String get newPasswordMinLengthLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @informYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get informYourEmailTitle;

  /// No description provided for @enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCodeTitle;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordTitle;

  /// No description provided for @emailStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a recovery code to the email registered in your account.'**
  String get emailStepSubtitle;

  /// No description provided for @codeStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code that was sent to your email.'**
  String get codeStepSubtitle;

  /// No description provided for @passwordStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a secure new password for your account.'**
  String get passwordStepSubtitle;

  /// No description provided for @sendCodeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButtonLabel;

  /// No description provided for @verifyCodeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCodeButtonLabel;

  /// No description provided for @resetPasswordButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButtonLabel;

  /// No description provided for @birthDateCannotBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Birth date cannot be in the future.'**
  String get birthDateCannotBeFuture;

  /// No description provided for @birthDateMinAge.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 14 years old.'**
  String get birthDateMinAge;

  /// No description provided for @successAudioAdded.
  ///
  /// In en, this message translates to:
  /// **'Audio added successfully!'**
  String get successAudioAdded;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @videoSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video saved successfully'**
  String get videoSavedSuccess;

  /// No description provided for @videoPlaybackNotAvailableWindows.
  ///
  /// In en, this message translates to:
  /// **'Video playback not available on Windows'**
  String get videoPlaybackNotAvailableWindows;

  /// No description provided for @supportEmailSubjectLogin.
  ///
  /// In en, this message translates to:
  /// **'DayApp Support - Login'**
  String get supportEmailSubjectLogin;

  /// No description provided for @supportEmailBodyLogin.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need help with logging into DayApp...'**
  String get supportEmailBodyLogin;

  /// No description provided for @successAudiosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} audios added successfully!'**
  String successAudiosAdded(int count);

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size} MB'**
  String sizeLabel(String size);

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String durationLabel(String duration);

  /// No description provided for @editDoubleTapHint.
  ///
  /// In en, this message translates to:
  /// **'Edit - 2 taps'**
  String get editDoubleTapHint;

  /// No description provided for @deleteGroupWarningText.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the group \"{groupName}\"? Stories in this group will not be deleted, only removed from the group.'**
  String deleteGroupWarningText(String groupName);

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOn(String date);

  /// No description provided for @editorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type here...'**
  String get editorPlaceholder;

  /// No description provided for @aboutFlutterDesc.
  ///
  /// In en, this message translates to:
  /// **'Framework for multiplatform development'**
  String get aboutFlutterDesc;

  /// No description provided for @aboutDartDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern and efficient programming language'**
  String get aboutDartDesc;

  /// No description provided for @aboutSqliteDesc.
  ///
  /// In en, this message translates to:
  /// **'Robust and reliable local database'**
  String get aboutSqliteDesc;

  /// No description provided for @aboutProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Reactive state management'**
  String get aboutProviderDesc;

  /// No description provided for @aboutMaterial3Title.
  ///
  /// In en, this message translates to:
  /// **'Material Design 3'**
  String get aboutMaterial3Title;

  /// No description provided for @aboutMaterial3Desc.
  ///
  /// In en, this message translates to:
  /// **'Modern and accessible design system'**
  String get aboutMaterial3Desc;

  /// No description provided for @aboutScreenTechnologiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Technologies'**
  String get aboutScreenTechnologiesTitle;

  /// No description provided for @insightMood7Days.
  ///
  /// In en, this message translates to:
  /// **'Mood — Last 7 Days'**
  String get insightMood7Days;

  /// No description provided for @insightMoodVariationThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Your mood variation this week'**
  String get insightMoodVariationThisWeek;

  /// Label for chapter export split parts
  ///
  /// In en, this message translates to:
  /// **'Part {index} of {total}'**
  String chapterExportPartLabel(int index, int total);

  /// Information shown when export is split
  ///
  /// In en, this message translates to:
  /// **'To ensure better performance and compatibility when sharing, this chapter was split into {parts} files.'**
  String chapterExportSplitExplanation(int parts);

  /// Title shown in error dialog when trying to use a chapter title that already exists
  ///
  /// In en, this message translates to:
  /// **'Duplicate Title'**
  String get chapterTitleDuplicateTitle;

  /// Message shown in error dialog when trying to use a chapter title that already exists
  ///
  /// In en, this message translates to:
  /// **'A chapter with this title already exists. Please choose another title.'**
  String get chapterTitleDuplicateMessage;

  /// Password criteria: minimum 8 characters
  ///
  /// In en, this message translates to:
  /// **'Minimum of 8 characters'**
  String get pwdCriteriaMinLength;

  /// Password criteria: 1 uppercase letter
  ///
  /// In en, this message translates to:
  /// **'1 uppercase letter'**
  String get pwdCriteriaUppercase;

  /// Password criteria: 1 lowercase letter
  ///
  /// In en, this message translates to:
  /// **'1 lowercase letter'**
  String get pwdCriteriaLowercase;

  /// Password criteria: 1 number
  ///
  /// In en, this message translates to:
  /// **'1 number'**
  String get pwdCriteriaNumber;

  /// Password criteria: 1 special character
  ///
  /// In en, this message translates to:
  /// **'1 special character'**
  String get pwdCriteriaSpecial;

  /// Title of the dialog when the backup file name is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid Filename'**
  String get invalidBackupFilenameTitle;

  /// Message of the dialog when the backup file name is invalid
  ///
  /// In en, this message translates to:
  /// **'The selected file \'{fileName}\' is not a standard backup file.\n\nPlease choose a valid backup file.'**
  String invalidBackupFilenameMessage(String fileName);

  /// Title of the dialog when the backup restore operation fails
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreFailedTitle;

  /// Message of the dialog when the backup restore operation fails
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a DayApp backup. Do you want to try again?'**
  String get restoreFailedMessage;

  /// Message of the dialog when the backup creation operation fails
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the backup. Do you want to try again?'**
  String get backupFailedMessage;

  /// Rótulo do campo de pessoas na barra de metadados
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get pessoasLabel;

  /// Rótulo do campo de local na barra de metadados
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get localLabel;

  /// Dica de preenchimento para adicionar pessoas
  ///
  /// In en, this message translates to:
  /// **'Type and press Enter or comma'**
  String get pessoasHint;

  /// Dica de preenchimento para adicionar o local
  ///
  /// In en, this message translates to:
  /// **'Type location'**
  String get localHint;

  /// Tooltip do botão de adicionar pessoa
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPessoa;

  /// Título da seção de pessoas vinculadas à história
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get pessoasSection;

  /// Título da seção de local vinculado à história
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get localSection;

  /// Título do modal para adicionar pessoas
  ///
  /// In en, this message translates to:
  /// **'Who were you with?'**
  String get comQuemTitle;

  /// Título do modal para adicionar local
  ///
  /// In en, this message translates to:
  /// **'Where were you?'**
  String get ondeTitle;

  /// Tooltip para o botão de pessoas
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get pessoasTooltip;

  /// Tooltip para o botão de local
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get localTooltip;

  /// Instrução para renomear nos chips de pessoa
  ///
  /// In en, this message translates to:
  /// **'Press and hold to rename'**
  String get pessoaLongPressHint;

  /// Título do diálogo de renomear pessoa
  ///
  /// In en, this message translates to:
  /// **'Rename person'**
  String get renamePessoaTitle;

  /// Aviso mostrado ao renomear uma pessoa
  ///
  /// In en, this message translates to:
  /// **'Renaming will affect all stories containing this person.'**
  String get renamePessoaWarning;

  /// Rótulo do campo de texto para o nome da pessoa
  ///
  /// In en, this message translates to:
  /// **'Person name'**
  String get pessoaNameLabel;

  /// Label for the mood column
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodLabel;

  /// Label for the energy column
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energyLabel;

  /// Title of the dialog when the backup creation operation fails
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backupFailedTitle;

  /// No description provided for @homeGreetingPhrase.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! {greeting}.'**
  String homeGreetingPhrase(String name, String greeting);

  /// No description provided for @homeGreetingPhraseNoName.
  ///
  /// In en, this message translates to:
  /// **'Hello! {greeting}.'**
  String homeGreetingPhraseNoName(String greeting);

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'\"How is your day? Let\'s record it?\"'**
  String get homeGreetingSubtitle;

  /// No description provided for @startNewStoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Start a new story...'**
  String get startNewStoryPlaceholder;

  /// No description provided for @viewAllStoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'View all stories'**
  String get viewAllStoriesLabel;

  /// No description provided for @continuaLabel.
  ///
  /// In en, this message translates to:
  /// **'Continues'**
  String get continuaLabel;

  /// No description provided for @continuaQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does this story continue?'**
  String get continuaQuestion;

  /// No description provided for @continuaNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get continuaNo;

  /// No description provided for @continuaDontKnow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know'**
  String get continuaDontKnow;

  /// No description provided for @continuaMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get continuaMaybe;

  /// No description provided for @continuaYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get continuaYes;

  /// Chip shown at the top of the continuity hook card
  ///
  /// In en, this message translates to:
  /// **'📖 Open story'**
  String get continuityHookBadge;

  /// Hook text G-01: Post-Tension (mood ≤ 2 + energy = 3)
  ///
  /// In en, this message translates to:
  /// **'Looking back at what you wrote a few days ago, how do you see that situation today?'**
  String get continuityHookG01;

  /// Hook text G-02: Contextual closure (fallback with emotional signal for YES stories)
  ///
  /// In en, this message translates to:
  /// **'Remember the episode you reported recently? How did things unfold since then?'**
  String get continuityHookG02;

  /// Hook text G-03: Expression (emotional extremes + text < 15 words)
  ///
  /// In en, this message translates to:
  /// **'You wrote a very brief entry. Would you like to try to say more about it?'**
  String get continuityHookG03;

  /// Hook text for MAYBE status (continua=3)
  ///
  /// In en, this message translates to:
  /// **'Do you think that situation from a few days ago is still happening?'**
  String get continuityHookTalvez;

  /// Hook text for NOT SURE status (continua=2)
  ///
  /// In en, this message translates to:
  /// **'How do you see today what you wrote that day?'**
  String get continuityHookNaoSei;

  /// Primary button on the continuity card to create a follow-up story
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuityHookBtnContinue;

  /// Secondary button to expand the status options on the continuity card
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get continuityHookBtnOptions;

  /// Title of the Free limit reached notice
  ///
  /// In en, this message translates to:
  /// **'Exclusive feature'**
  String get continuityHookFreeLimitTitle;

  /// Body of the Free limit notice for the continuity feature
  ///
  /// In en, this message translates to:
  /// **'You have already used your 3 free stories with continuity tracking. Upgrade to Premium and write unlimited narratives.'**
  String get continuityHookFreeLimitBody;

  /// Title of the debug section for the hook engine in PremiumDebugScreen
  ///
  /// In en, this message translates to:
  /// **'Hook Engine (Debug)'**
  String get continuityHookDebugSectionTitle;

  /// Label for the clock accelerator toggle in debug
  ///
  /// In en, this message translates to:
  /// **'Clock Accelerator'**
  String get continuityHookDebugAcceleratorLabel;

  /// Subtitle for the clock accelerator toggle
  ///
  /// In en, this message translates to:
  /// **'Ignores the 2/3/4-day time windows'**
  String get continuityHookDebugAcceleratorSubtitle;

  /// Button to reset the Free lifetime counter in debug
  ///
  /// In en, this message translates to:
  /// **'Reset Free Stories Counter'**
  String get continuityHookDebugResetCounters;

  /// Button to force a reload of the continuity card in debug
  ///
  /// In en, this message translates to:
  /// **'Force Reload Card'**
  String get continuityHookDebugForceReload;

  /// Feature label for story continuity in the PremiumDebugScreen feature list
  ///
  /// In en, this message translates to:
  /// **'Story Continuity (≤3 Free · Unlimited Premium)'**
  String get continuityHookFeatureLabel;

  /// Generic message for YES stories with no emotional signal (mood=3, energy=2)
  ///
  /// In en, this message translates to:
  /// **'Time to continue this story'**
  String get continuityHookGenericSim;

  /// Generic message for MAYBE stories with no emotional signal
  ///
  /// In en, this message translates to:
  /// **'Maybe you\'d like to continue this story'**
  String get continuityHookGenericTalvez;

  /// Generic message for NOT SURE stories with no emotional signal
  ///
  /// In en, this message translates to:
  /// **'Have you decided whether you want to continue this story?'**
  String get continuityHookGenericNaoSei;

  /// Button to close the continuity cycle in Phase 2 of the card
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get continuityStatusClose;
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
      <String>['en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
