// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get deviceDefault => 'Device default';

  @override
  String get defaultLabel => 'Default';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get italian => 'Italian';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get tryAgain => 'Try again';

  @override
  String get errorInitializingApp => 'Error initializing app';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get security => 'Security';

  @override
  String get themeAndScheme => 'Theme and Scheme';

  @override
  String get themeRelva => 'Grass';

  @override
  String get themeOutono => 'Botanical Garden';

  @override
  String get themeCeu => 'Sky';

  @override
  String get themeConfort => 'Comfort';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeMidnightGalaxy => 'Midnight Galaxy';

  @override
  String get themeDefaultLightDescription => 'Default light theme';

  @override
  String get themeDefaultDarkDescription => 'Default dark theme';

  @override
  String get themeFollowSystemDescription => 'Follow system theme';

  @override
  String get themeCustomSchemesTitle => 'Custom Schemes';

  @override
  String get themeRelvaLight => 'Relva (Light)';

  @override
  String get themeRelvaDark => 'Relva (Dark)';

  @override
  String get themeOutonoLight => 'Botanical Garden (Light)';

  @override
  String get themeOutonoDark => 'Botanical Garden (Dark)';

  @override
  String get themeRelvaLightDescription => 'Green and natural tones';

  @override
  String get themeRelvaDarkDescription => 'Dark version of the Relva scheme';

  @override
  String get themeOutonoLightDescription => 'Fresh and organic garden tones';

  @override
  String get themeOutonoDarkDescription =>
      'Dark version of the Botanical Garden scheme';

  @override
  String get themeRemoveScheme => 'Remove Scheme';

  @override
  String get themeRemoveSchemeDescription =>
      'Go back to the default theme scheme';

  @override
  String get timeAtConnector => 'at';

  @override
  String get timeAgoNow => 'just now';

  @override
  String timeAgoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String timeAgoHours(int count) {
    return '${count}h ago';
  }

  @override
  String timeAgoDays(int count) {
    return '$count day(s) ago';
  }

  @override
  String get backup => 'Backup';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get confirm => 'Confirm';

  @override
  String get pinUnlock => 'Unlock PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get enableBiometrics => 'Biometric login';

  @override
  String get information => 'Information';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get configurePin => 'Configure PIN';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get backgroundLock => 'Background lock';

  @override
  String get backgroundLockDialogPrompt =>
      'How long should the app be locked after being in background?';

  @override
  String get backgroundLockTimeLabel => 'Time';

  @override
  String get backgroundLockDialogResult => 'Result:';

  @override
  String get backgroundLockSuggestions => 'Suggestions:';

  @override
  String get backgroundLockImmediateHint => '0 = immediate';

  @override
  String get backgroundLockNever => 'Don\'t lock';

  @override
  String get backgroundLockImmediately => 'Immediately';

  @override
  String backgroundLockSeconds(int count) {
    return '$count seconds';
  }

  @override
  String get backgroundLockOneMinute => '1 minute';

  @override
  String backgroundLockMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get backgroundLockOneHour => '1 hour';

  @override
  String backgroundLockHours(int count) {
    return '$count hours';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get noStoriesYetTitle => 'No stories yet';

  @override
  String get noStoriesYetSubtitle =>
      'Start recording your days to see statistics';

  @override
  String get trends => 'Trends';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get activityByWeekday => 'Activity by weekday';

  @override
  String get streaksTitle => 'Streaks';

  @override
  String get longestStreakPrefix => 'Longest streak:';

  @override
  String get tableOfMoods => 'Mood table';

  @override
  String get moodCount => 'Mood count';

  @override
  String get topTags => 'Top tags';

  @override
  String get storiesLabel => 'Stories';

  @override
  String get activeDaysLabel => 'Active days';

  @override
  String get avgPerDayLabel => 'Avg/day';

  @override
  String get mediaLabel => 'Media';

  @override
  String get manageGroups => 'Manage groups';

  @override
  String get trash => 'Trash';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get aboutScreenAboutDayAppTitle => 'About DayApp';

  @override
  String get aboutScreenAboutDayAppDescription =>
      'DayApp is a modern and secure personal journal app that lets you record your stories, memories, and thoughts in an organized and private way. With an intuitive interface and advanced features, DayApp helps you preserve your most meaningful experiences.';

  @override
  String get aboutScreenFeaturesTitle => 'Features';

  @override
  String get aboutScreenFeatureRichEditorTitle => 'Rich Editor';

  @override
  String get aboutScreenFeatureRichEditorDescription =>
      'Create stories with advanced formatting, images, videos, and audio';

  @override
  String get aboutScreenFeatureSmartOrganizationTitle => 'Smart Organization';

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Categorize your stories into custom themed groups and Chapters that tell about you';

  @override
  String get aboutScreenFeatureAdvancedSearchTitle => 'Advanced Search';

  @override
  String get aboutScreenFeatureAdvancedSearchDescription =>
      'Quickly find any story by content or date';

  @override
  String get aboutScreenFeatureSecureBackupTitle => 'Secure Backup';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Back up your data regularly.';

  @override
  String get aboutScreenFeatureTotalPrivacyTitle => 'Total Privacy';

  @override
  String get aboutScreenFeatureTotalPrivacyDescription =>
      'Your data is stored locally and encrypted';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceTitle => 'Adaptive Interface';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceDescription =>
      'Light and dark themes with customizable layouts';

  @override
  String get aboutScreenVersionTitle => 'Version';

  @override
  String aboutScreenVersionBuild(String version, String build) {
    return 'Version $version (Build $build)';
  }

  @override
  String aboutScreenVersionShort(String version) {
    return 'Version $version';
  }

  @override
  String get aboutScreenDevelopmentTitle => 'Development';

  @override
  String get aboutScreenDevelopmentDescription =>
      'Built with care to offer the best experience for recording personal memories.';

  @override
  String get aboutScreenPrivacySecurityTitle => 'Privacy and Security';

  @override
  String get aboutScreenPrivacyLocalDataTitle => 'Local Data';

  @override
  String get aboutScreenPrivacyLocalDataDescription =>
      'All your stories are stored only on your device';

  @override
  String get aboutScreenPrivacyEncryptionTitle => 'Encryption';

  @override
  String get aboutScreenPrivacyEncryptionDescription =>
      'Sensitive content is protected with advanced encryption';

  @override
  String get aboutScreenPrivacyNoTrackingTitle => 'No Tracking';

  @override
  String get aboutScreenPrivacyNoTrackingDescription =>
      'We do not collect personal data or track your usage';

  @override
  String get aboutScreenPrivacyPinSecurityTitle => 'Security PIN';

  @override
  String get aboutScreenPrivacyPinSecurityDescription =>
      'Protect app access with PIN or biometrics';

  @override
  String get aboutScreenContactSupportTitle => 'Contact and Support';

  @override
  String get aboutScreenContactSupportDescription =>
      'For questions, suggestions, or technical support:';

  @override
  String get aboutScreenSupportEmailSubject => 'DayApp Support';

  @override
  String aboutScreenSupportEmailBody(String version) {
    return 'Hello, I need help with DayApp...\n\nVersion: $version\n';
  }

  @override
  String get aboutScreenAcknowledgementsTitle => 'Acknowledgments';

  @override
  String get aboutScreenAcknowledgementsDescription =>
      'Thank you for choosing DayApp to record your most precious memories. Your trust and feedback are essential for us to keep improving.';

  @override
  String get aboutScreenHeaderSubtitle => 'Your Personal Diary';

  @override
  String get aboutScreenCopyright => '© 2026 DayApp. All rights reserved.';

  @override
  String get logout => 'Logout';

  @override
  String get createAccount => 'Create account';

  @override
  String get name => 'Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get needHelp => 'Need help?';

  @override
  String get currentPinLabel => 'Current PIN';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pinLengthError => 'PIN must be between 4 and 8 digits';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get pinIncorrect => 'Current PIN incorrect';

  @override
  String get pinChangedSuccess => 'PIN changed successfully!';

  @override
  String get pinConfiguredSuccess => 'PIN configured successfully!';

  @override
  String get informYourEmail => 'Enter your email.';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get emailNotFound => 'Email not found. Check and try again.';

  @override
  String codeSent(Object email) {
    return 'Code sent to $email! Check your inbox.';
  }

  @override
  String get codeMustBe6 => 'The code must be 6 digits.';

  @override
  String get codeVerified => 'Code verified! Set your new password.';

  @override
  String get codeInvalid => 'Invalid or expired code. Try again.';

  @override
  String get enterNewPassword => 'Enter the new password.';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully! Log in with the new password.';

  @override
  String get errorResetPassword => 'Error resetting password. Try again.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get resendCodeSuccess => 'New code sent! Check your inbox.';

  @override
  String get resendCodeError => 'Error resending code. Try again.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get unlock => 'Unlock';

  @override
  String get fullName => 'Full name';

  @override
  String get birthDate => 'Birth date';

  @override
  String get almostReady => 'almost ready...';

  @override
  String get optionalData => 'The fields below are optional';

  @override
  String get birthDateFormat => 'Birth date (DD/MM/YYYY)';

  @override
  String get invalidBirthDate => 'Invalid birth date (use DD/MM/YYYY)';

  @override
  String get userNotFound => 'User not found.';

  @override
  String get create => 'Create';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get accessAccount => 'Access your account';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign in';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get noAccountCreateHere => 'No account? Create one here.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get biometricsEnabledSuccess => 'Biometrics enabled successfully!';

  @override
  String get biometricLoginError => 'Error logging in with biometrics.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdateError => 'Error updating profile. Try again.';

  @override
  String get unlockAppReason => 'Unlock the app to continue';

  @override
  String get fillEmailAndPassword => 'Fill in email and password';

  @override
  String get emailOrPasswordIncorrect => 'Email or password incorrect';

  @override
  String get noEmailRegistered =>
      'No email registered. Configure it in settings.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Check your email at $email or use the displayed code';
  }

  @override
  String get errorGeneratingCode => 'Error generating code. Try again.';

  @override
  String get errorSendingCode => 'Error sending code. Try again.';

  @override
  String get enterRecoveryCodePrompt => 'Enter the code sent to your email:';

  @override
  String get recoveryCodeLabel => 'Recovery code (6 digits)';

  @override
  String get enterPasswordToContinue => 'Enter your password to continue';

  @override
  String get enterPinToContinue => 'Enter your PIN to continue';

  @override
  String get useBiometricsToContinue => 'Use your biometrics to continue';

  @override
  String get usePin => 'Use PIN';

  @override
  String get noStoriesHere => 'No stories to display here.';

  @override
  String get storiesGroupedOrArchived => 'They are either grouped or archived.';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get unlockWithBiometrics => 'Unlock with Biometrics';

  @override
  String get useAccountPassword => 'Use account password';

  @override
  String get forgotPin => 'Forgot my PIN';

  @override
  String get unlockTitle => 'Unlock the App';

  @override
  String get search => 'Search';

  @override
  String get searchStoriesTitle => 'Search your stories';

  @override
  String get searchStoriesSubtitle =>
      'Use the filters above to find your memories.';

  @override
  String unsavedBackups(Object count) {
    return 'You have $count stories not backed up.';
  }

  @override
  String get backupRecommendation =>
      'We recommend backing up to avoid losing your data.';

  @override
  String get cancel => 'Cancel';

  @override
  String get restore => 'Restore';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String get performBackup => 'Backup now';

  @override
  String get deleteStoryTitle => 'Delete story';

  @override
  String get deleteStoryConfirm =>
      'Do you want to move this story to the trash?';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get movedToTrash => 'Story moved to trash';

  @override
  String errorDeletingStory(Object error) {
    return 'Error deleting story: $error';
  }

  @override
  String get noRecordsThisDay => 'No records for this day';

  @override
  String get storyUngrouped => 'Story ungrouped';

  @override
  String get save => 'Save';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String get groupDeletedSuccess => 'Group deleted successfully';

  @override
  String get noGroupsFound => 'No groups found';

  @override
  String get shareError => 'Could not share';

  @override
  String get cannotDeletePhoto => 'Cannot delete this photo';

  @override
  String get deletePhotoTitle => 'Delete photo';

  @override
  String get deletePhotoConfirm => 'Do you really want to delete this photo?';

  @override
  String get deleteGroupTitle => 'Delete Group';

  @override
  String get share => 'Share';

  @override
  String get scrapbookTemplateLabel => 'Scrapbook';

  @override
  String get polaroidTemplateLabel => 'Polaroid';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Groups';

  @override
  String get myStories => 'My Stories';

  @override
  String get record => 'record';

  @override
  String get records => 'records';

  @override
  String get filterText => 'Text';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get searchHintTag => 'Type a tag...';

  @override
  String get searchHintText => 'Search in title or description...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get clear => 'Clear';

  @override
  String get tapToSelectEmoji => 'Tap to select an emoji:';

  @override
  String get selectEmoji => 'Select emoji';

  @override
  String get tapToChangeEmoji => 'Tap to change';

  @override
  String get searchButton => 'Search';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get recordVideoLabel => 'Record a video';

  @override
  String get recordAudioLabel => 'Record audio';

  @override
  String get continueLabel => 'Continue';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get laterLabel => 'Later';

  @override
  String get configureLabel => 'Configure';

  @override
  String get imageCopiedBase64 => 'Image copied to clipboard (base64)';

  @override
  String get newGroup => 'New Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String groupDeleteWarning(Object count) {
    return 'This group has $count story(ies) linked. If deleted, those stories will return to the home screen (no group). Continue?';
  }

  @override
  String get unarchive => 'Unarchive';

  @override
  String get group => 'Group';

  @override
  String get selectGroup => 'Select Group';

  @override
  String get selectLabel => 'Select';

  @override
  String get existingGroups => 'Existing Groups';

  @override
  String get createNewGroup => 'Create New Group';

  @override
  String get groupNameLabel => 'Group Name';

  @override
  String get createAndSelect => 'Create and Select';

  @override
  String get manageBackups => 'Manage Backup';

  @override
  String get createAndShareBackup => 'Create and Share Backup';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get backupNotAvailableWeb => 'Backup not available on web';

  @override
  String get backupNotAvailableDetail =>
      'The backup feature requires file system access, available only on Android, iOS and desktop versions.';

  @override
  String get backupInfoTitle => 'About Backup';

  @override
  String get backupInfoDetails =>
      'The complete backup includes:\n• Database (stories, texts, photos, audios)\n• Video files\n\nA ZIP file will be created and you can save it wherever you want:\n• OneDrive\n• Google Drive\n• Email\n• Any other location';

  @override
  String get backupComplete => 'Complete Backup';

  @override
  String get backupZipSubtitle => 'ZIP file with all your data';

  @override
  String get backupZipExplanation =>
      'Generates a ZIP file that you can save to your device, OneDrive, Google Drive, email, or any other cloud location, except messaging apps.';

  @override
  String get backupLinuxExplanation =>
      'Choose a folder and the backup ZIP will be saved directly to it.';

  @override
  String get restoreSectionTitle => 'Restore Backup';

  @override
  String get restoreSectionDescription =>
      'Select a backup file (ZIP) previously created to restore all your data.';

  @override
  String get backupShareSubject => 'DayApp Backup';

  @override
  String backupDeleteConfirm(String fileName) {
    return 'Are you sure you want to delete this backup?\n\n$fileName';
  }

  @override
  String backupShareError(String message) {
    return 'Error sharing backup: $message';
  }

  @override
  String backupDeleteError(String message) {
    return 'Error deleting backup: $message';
  }

  @override
  String get processing => 'Processing...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get backupStarting => 'Starting backup...';

  @override
  String get backupCreatedSuccess => 'Backup file created!';

  @override
  String backupError(Object message) {
    return 'Error creating backup: $message';
  }

  @override
  String get restoreStarting => 'Starting restore...';

  @override
  String get restoreSuccess => 'Restore completed successfully!';

  @override
  String restoreError(Object message) {
    return 'Error restoring: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirm Restore';

  @override
  String get restoreConfirmContent =>
      'All current data will be replaced by the backup.\n\nThis action cannot be undone. Do you wish to continue?';

  @override
  String get restoreSuccessTitle => '✅ Restore Completed';

  @override
  String get restoreSuccessContent =>
      'The backup was restored successfully!\n\nAll your stories have been restored to the backup state.\n\nYou need to log in again to complete the process.';

  @override
  String get helpAboutTitle => 'About DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp is a personal diary app that lets you record your stories, memories and thoughts in an organized and secure way.';

  @override
  String get helpNavigationTitle => 'Main Navigation';

  @override
  String get helpHomeItemDesc =>
      'View the last 5 or all stories on large or smaller cards or in the calendar';

  @override
  String get helpHomeDoubleTapDesc => 'Double tap a story to view it.';

  @override
  String get helpHomeAttachmentsDesc => 'Tap attachments to view them.';

  @override
  String get helpHomeSwipeRightDesc =>
      'Drag the card to the right to Archive the story. The story is moved to the Collections / Groups / Archived tab';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Drag the card to the left to associate it with a Group. The story is moved to the Collections / Groups / Archived tab';

  @override
  String get helpHomeCalendarIconDesc =>
      'Tap the calendar icon to view your stories in that format.';

  @override
  String get helpHomeChapterIconDesc =>
      'Organize your stories into Chapters and Thematic Groups. Create Chapters and tell your complete story. Create custom Groups to categorize your memories.';

  @override
  String get helpGroupsNavDesc =>
      'Organize your stories into Chapters and Thematic Groups. Create Chapters and tell your complete story. Create custom Groups to categorize your memories.';

  @override
  String get helpSearchItemDesc =>
      'Quickly find stories by title, content, tag or date.';

  @override
  String get helpCreatingTitle => 'Creating Stories';

  @override
  String get helpNewStoryDesc =>
      'Tap the floating button (+ New Story) to create a new story. Add title, text, images, videos and audios.';

  @override
  String get helpTextEditorTitle => 'Text Editor';

  @override
  String get helpTextEditorDesc =>
      'Use rich formatting: bold, italic, lists, links and more.';

  @override
  String get helpChaptersDesc =>
      'Organize your story into chapters by joining other stories on the same topic.';

  @override
  String get helpMediaDesc =>
      'Add photos from the gallery or camera, record videos or audios directly in the app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associate each story with one or more groups for better organization.';

  @override
  String get helpCalendarDesc =>
      'View your stories organized by date. Tap a date to see all stories for that day.';

  @override
  String get helpCreateGroupTitle => 'Create Group';

  @override
  String get helpCreateGroupDesc =>
      'Go to \"Groups\" in the side menu to create new groups with custom colors and emoticons.';

  @override
  String get helpEditGroupTitle => 'Edit Group';

  @override
  String get helpEditGroupDesc =>
      'Tap a group to edit name, emoticon or delete.';

  @override
  String get helpGroupsAssocTitle => 'Associate to Groups';

  @override
  String get helpDeleteGroupTitle => 'Delete Group';

  @override
  String get helpDeleteGroupDesc =>
      'Delete a Group without deleting its stories.';

  @override
  String get helpInsightsTitle => 'Insights';

  @override
  String get helpInsightsDesc =>
      'Receive insights based on your stories on the home screen.\nSome insights are only available in the Premium version.\nAccess the insights history in the side menu.';

  @override
  String get helpBackupSecurityTitle => 'Backup & Security';

  @override
  String get helpAutomaticBackupTitle => 'Automatic Backup';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure automatic backup (Premium) in Settings. The backup will be created when you log out.';

  @override
  String get helpManualBackupTitle => 'Backup';

  @override
  String get helpManualBackupDesc =>
      'Go to \"Manage Complete Backup\" in Settings to create a full backup with all media.';

  @override
  String get helpRestoreTitle => 'Restore';

  @override
  String get helpRestoreDesc =>
      'Use \"Restore from File\" to recover data from a previous backup.';

  @override
  String get helpPinSecurityTitle => 'Security PIN';

  @override
  String get helpPinSecurityDesc =>
      'Set a 4- to 8-digit PIN to protect app access.';

  @override
  String get helpBiometricsDesc =>
      'Use fingerprint or facial recognition to unlock the app quickly, if available on your device.';

  @override
  String get helpPasswordUnlockTitle => 'Password Unlock';

  @override
  String get helpPasswordUnlockDesc =>
      'In addition to PIN and biometrics, you can unlock the app using your account password. Useful if you forget the PIN or biometrics fail.';

  @override
  String get helpBackgroundLockDesc =>
      'When the app is minimized or you switch to another app, it locks automatically after the configured time. You can set the time freely in settings (seconds, minutes or hours).';

  @override
  String get helpLockExceptionsTitle => 'Lock Exceptions';

  @override
  String get helpLockExceptionsDesc =>
      'The app does not lock when you use internal features that open other apps—such as picking photos from the gallery, recording videos, choosing backup location or sharing stories.';

  @override
  String get helpPinRecoveryTitle => 'PIN Recovery';

  @override
  String get helpPinRecoveryDesc =>
      'Forgot your PIN? Use the \"Forgot my PIN\" option on the lock screen. A recovery code will be sent to the registered email.';

  @override
  String get helpThemeDesc =>
      'Toggle between light, dark, automatic themes and others available in the Premium version.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configure how the app\'s reminder notification will behave when creating stories with future dates.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Define how long the app can stay in the background before being locked. You may use values in seconds, minutes or hours, with full freedom.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc => 'Manage backup and restore settings.';

  @override
  String get helpTrashDesc =>
      'Deleted stories stay in the trash for 30 days. Access \"Trash\" in the side menu to recover or permanently delete.';

  @override
  String get helpStatisticsDesc =>
      'View statistics about your diary usage: number of stories, words written, top groups, etc.';

  @override
  String get helpTipsTitle => 'Usage Tips';

  @override
  String get helpOrganizationTipTitle => 'Organization';

  @override
  String get helpOrganizationTipDesc =>
      'Use Groups to categorize your stories by themes, and Chapters to tell the whole story.';

  @override
  String get helpSearchTipTitle => 'Search';

  @override
  String get helpSearchTipDesc =>
      'Use the search function to quickly find old stories.';

  @override
  String get helpBackupTipTitle => 'Regular Backup';

  @override
  String get helpBackupTipDesc =>
      'Back up regularly, especially before updates or device changes.';

  @override
  String get helpPrivacyTipTitle => 'Privacy';

  @override
  String get helpPrivacyTipDesc =>
      'Your stories are stored locally and encrypted. Set a PIN for additional protection.';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportDesc =>
      'For questions or issues, contact us via support email or check app updates.';

  @override
  String get errorCreateAccount => 'Error creating account. Please try again.';

  @override
  String get errorShare => 'Error sharing';

  @override
  String errorPlayAudio(Object message) {
    return 'Error playing audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Error selecting videos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Error selecting file: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Error recording video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Error starting recording: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Error pausing recording: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Error resuming recording: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Error stopping recording: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Error selecting audios: $message';
  }

  @override
  String get errorLoadVideo => 'Error loading video';

  @override
  String get errorSelectImage => 'Error selecting image';

  @override
  String get imagePickerTitleMultiple => 'Add Photos';

  @override
  String get imagePickerTitleSingle => 'Add Photo';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Choose an option (gallery allows multiple photos):';

  @override
  String get imagePickerChooseOptionSingle => 'Choose an option:';

  @override
  String get imagePickerGalleryMultiple => 'Select from gallery';

  @override
  String get imagePickerGallerySingle => 'Pick from gallery';

  @override
  String get imagePickerTakePhoto => 'Take a photo';

  @override
  String get audioPickerTitleMultiple => 'Add Audios';

  @override
  String get audioPickerTitleSingle => 'Add Audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Choose an option (files allow multiple audios):';

  @override
  String get audioPickerChooseOptionSingle => 'Choose an option:';

  @override
  String get audioPickerSelectFilesMultiple => 'Select audio files';

  @override
  String get audioPickerSelectFilesSingle => 'Pick audio file';

  @override
  String get audioPickerRecord => 'Record audio';

  @override
  String get videoPickerTitleMultiple => 'Add Videos';

  @override
  String get videoPickerTitleSingle => 'Add Video';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Choose an option (files allow multiple videos):';

  @override
  String get videoPickerChooseOptionSingle => 'Choose an option:';

  @override
  String get videoPickerSelectFilesMultiple => 'Select video files';

  @override
  String get videoPickerSelectFilesSingle => 'Pick video file';

  @override
  String get videoPickerRecord => 'Record video';

  @override
  String get successVideoAdded => 'Video added successfully!';

  @override
  String successVideosAdded(Object count) {
    return '$count videos added successfully!';
  }

  @override
  String get startRecording => 'Start recording';

  @override
  String get recordingPaused => 'Recording paused';

  @override
  String get recording => 'Recording...';

  @override
  String get readyToRecord => 'Ready to record';

  @override
  String get notificationDialogTitle => 'Schedule Notification';

  @override
  String get notificationDialogPrompt =>
      'When would you like to be notified about this entry?';

  @override
  String get emailAlreadyRegistered => 'E-mail already registered.';

  @override
  String get successNotificationScheduled =>
      'Notification scheduled successfully';

  @override
  String notificationReminderTitle(Object title) {
    return 'Reminder: $title';
  }

  @override
  String get notificationReminderBody => 'You have a scheduled entry';

  @override
  String get successImageAdded => 'Image added successfully!';

  @override
  String successImagesAdded(Object count) {
    return '$count images added successfully!';
  }

  @override
  String errorSearch(Object message) {
    return 'Error during search: $message';
  }

  @override
  String get successStoryRestored => 'Story restored successfully';

  @override
  String get successStoryDeletedPermanently => 'Story permanently deleted';

  @override
  String get trashAlreadyEmpty => 'Trash is already empty';

  @override
  String get successVideoRecorded => 'Video recorded successfully!';

  @override
  String get permissionMicrophoneDenied => 'Microphone permission not granted';

  @override
  String errorSelectImages(Object message) {
    return 'Error selecting images: $message';
  }

  @override
  String get successPhotoCaptured => 'Photo captured successfully!';

  @override
  String get restoreStoriesTitle => 'Restore stories';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Do you want to restore $count selected story(ies)?';
  }

  @override
  String get restoreLabel => 'Restore';

  @override
  String get permanentlyDeleteTitle => 'Permanently delete';

  @override
  String get permanentlyDeleteConfirm =>
      'This action cannot be undone. Do you really want to permanently delete this story?';

  @override
  String get permanentlyDeleteLabel => 'Permanently delete';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Do you want to remove the group \"$name\" from your stories?';
  }

  @override
  String get recoverPinTitle => 'Recover PIN';

  @override
  String get recoverPinDescription =>
      'We will send a recovery code to your registered email.';

  @override
  String get sendCode => 'Send Code';

  @override
  String get emptyTrashTitle => 'Empty trash';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Do you want to permanently delete all $count story(ies) in the trash? This action cannot be undone.';
  }

  @override
  String get emptyTrashLabel => 'Empty trash';

  @override
  String errorTakePhoto(Object message) {
    return 'Error taking photo: $message';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get entryNotifications => 'Entry notifications';

  @override
  String get entryNotificationsInfo =>
      'Entries with a date at least 3 hours ahead may have scheduled notifications.';

  @override
  String get backgroundRestrictionsWarningTitle =>
      'Notifications & Background Apps';

  @override
  String get backgroundRestrictionsWarningDesc =>
      'Some systems aggressively sleep background apps to save battery, which may block the app\'s scheduled notifications. To ensure proper functioning, open the app\'s settings on your device and:\n• Disable \'Pause app activity if unused\' (or similar option).\n• Set battery restrictions to \'Unrestricted\' (don\'t worry, background battery consumption is negligible).';

  @override
  String get defaultAdvanceTitle => 'Default advance';

  @override
  String get notificationAdvanceTitle => 'Notification advance';

  @override
  String get notificationAdvancePrompt =>
      'How much notice would you like before being notified?';

  @override
  String get notificationAdvanceDefault => 'Default advance';

  @override
  String get notificationScheduleModeTitle => 'Scheduling mode (QA)';

  @override
  String get notificationScheduleModeInexact => 'Inexact (Play-compliant)';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get manageCompleteBackup => 'Manage full backup';

  @override
  String get backupWithVideosZip => 'Backup with videos in ZIP file';

  @override
  String get backupOnLogoutDescription =>
      'Backup will be created when you log out';

  @override
  String get automaticBackupInfo =>
      'When you log out, a backup will be created and you can choose where to save it (local folder, Google Drive, etc).';

  @override
  String get automaticBackupInfoLocal =>
      'On logout, a backup is automatically saved locally on your device. You can later export it to cloud storage if needed.';

  @override
  String get incrementalBackupTitle => 'Backup Folder';

  @override
  String get incrementalBackupDescription =>
      'Stories are automatically backed up to this folder whenever you save one.';

  @override
  String get incrementalBackupFolderNotSet => 'Folder not configured';

  @override
  String get incrementalBackupFolderConfigured => 'Folder configured';

  @override
  String get incrementalBackupSelectFolder => 'Select Folder';

  @override
  String get incrementalBackupChangeFolder => 'Change Folder';

  @override
  String get incrementalBackupChangingFolder =>
      'Copying files to new folder...';

  @override
  String get incrementalBackupFolderChanged => 'Backup folder updated.';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Backup folder not set. Stories will not be backed up until you configure a folder in Settings.';

  @override
  String get incrementalBackupSyncDone => 'Backed up';

  @override
  String get backupSetupTitle => 'Set Up Backup Folder';

  @override
  String get backupSetupContent =>
      'Choose a folder where your stories will be backed up automatically. This ensures your data is always safe.';

  @override
  String get backupSavedToFolder => 'Saving backup to configured folder...';

  @override
  String get biometricsNotAvailable => 'Not available on this device';

  @override
  String get biometricsDisabled => 'Biometrics disabled';

  @override
  String get biometricConfiguredInfo =>
      'Biometrics is configured. You can log in using your fingerprint or face recognition.';

  @override
  String get biometricAuthFailed => 'Biometric authentication failed';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirm your identity to enable biometrics';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarFormatMonth => 'Month';

  @override
  String get calendarFormatTwoWeeks => '2 Weeks';

  @override
  String get calendarFormatWeek => 'Week';

  @override
  String get groupExists => 'Group already exists';

  @override
  String get enterGroupName => 'Enter a name for the group';

  @override
  String get archivedTitle => 'Archived';

  @override
  String get toggleToIcons => 'Switch to icon view';

  @override
  String get toggleToCards => 'Switch to card view';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editTip => 'Edit - double tap';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get close => 'Close';

  @override
  String get newStory => 'New Story';

  @override
  String get noArchivedStories => 'No archived stories.';

  @override
  String get edit => 'Edit';

  @override
  String previewTitle(Object title) {
    return 'Preview - $title';
  }

  @override
  String get archiveLabel => 'Archive';

  @override
  String get storyArchived => 'Story archived';

  @override
  String get undo => 'Undo';

  @override
  String get ungroup => 'Ungroup';

  @override
  String noStoriesInGroup(Object group) {
    return 'No stories in group $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String get titleRequired => 'Title is required!';

  @override
  String errorSavingStory(Object error) {
    return 'Error saving story: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Title and description are required to export.';

  @override
  String get exportHistory => 'Export Story';

  @override
  String get exportHistoryPrompt =>
      'Do you want to save before exporting or just preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Save and export';

  @override
  String get untitled => 'Untitled';

  @override
  String errorLoadingFile(Object error) {
    return 'Error loading file: $error';
  }

  @override
  String get discard => 'Discard';

  @override
  String get discardStoryTitle => 'Discard story?';

  @override
  String get unsavedStoryPrompt =>
      'You have a new unsaved story. Leave without saving?';

  @override
  String get changeDateTooltip => 'Change date';

  @override
  String get storyTitleLabel => 'Title';

  @override
  String get storyTitleHint => 'Enter the title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Write your story...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Photos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Videos';

  @override
  String get importTxtTooltip => 'Import .txt';

  @override
  String get expandTooltip => 'Expand';

  @override
  String get photoTooltip => 'Photo';

  @override
  String get videoTooltip => 'Video';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Edit Description';

  @override
  String get editStory => 'Edit Story';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesPrompt =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get archivedStateLabel => 'Archived';

  @override
  String get archiveSubtitle => 'Hide from home screen';

  @override
  String get chooseEmoji => 'Choose an emoji';

  @override
  String get emojiGroupSentimentos => 'Feelings';

  @override
  String get emojiGroupAnimais => 'Animals';

  @override
  String get emojiGroupVegetais => 'Plants';

  @override
  String get emojiGroupCeu => 'Sky';

  @override
  String get emojiGroupObjetos => 'Objects';

  @override
  String get emojiGroupAlimentos => 'Food';

  @override
  String get emojiGroupLugares => 'Places';

  @override
  String get emojiGroupSimbolos => 'Symbols';

  @override
  String get moodQuestion => 'How did you feel in this story?';

  @override
  String get moodVeryDifficult => 'Very difficult';

  @override
  String get moodDifficult => 'Difficult';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodGood => 'Good';

  @override
  String get moodVeryGood => 'Very good';

  @override
  String get energyQuestion => 'How was your energy?';

  @override
  String get energyLow => 'Low';

  @override
  String get energyNormal => 'Normal';

  @override
  String get energyHigh => 'High';

  @override
  String get tagsHint => 'Type and press Enter or comma';

  @override
  String get addTag => 'Add tag';

  @override
  String get tagLongPressHint => 'Long press to rename';

  @override
  String get renameTagTitle => 'Rename tag';

  @override
  String get renameTagWarning =>
      'Renaming will affect all stories that use this tag.';

  @override
  String get tagNameLabel => 'Tag name';

  @override
  String get insightDiscovery => 'Discovery';

  @override
  String get insightPattern => 'Pattern found';

  @override
  String get insightTrend => '📈 Trend';

  @override
  String get insightMonthlySummary => '📊 Your month in stories';

  @override
  String insightBestWeekday(String weekday) {
    return '$weekday is usually your most positive day.';
  }

  @override
  String insightPositiveTag(String tag) {
    return 'Stories tagged #$tag tend to have a better mood.';
  }

  @override
  String get insightTrendPositive =>
      'Your mood has been improving over the last 7 days compared to the last 30 days.';

  @override
  String insightMonthlySummaryText(int entries, String mood, String energy) {
    return 'Entries: $entries\nAvg mood: $mood\nAvg energy: $energy';
  }

  @override
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  ) {
    return 'Entries: $entries\nAvg mood: $mood\nAvg energy: $energy\nTop tag: #$tag';
  }

  @override
  String get insightSeeStories => 'See stories';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get insightDismiss => 'Dismiss';

  @override
  String get insightStoryBalanceTitle => 'Story Balance';

  @override
  String get insightStoryBalancePositive =>
      'You recorded more positive stories in the last 10 days. Keep it up!';

  @override
  String get insightStoryBalanceDifficult =>
      'You recorded more difficult stories in the last 10 days. Take care of yourself!';

  @override
  String get insightWritingTimeTitle => 'Writing Time';

  @override
  String get insightWritingTimeMorning =>
      'You wrote more in the morning this week.';

  @override
  String get insightWritingTimeAfternoon =>
      'You wrote more in the afternoon this week.';

  @override
  String get insightWritingTimeNight => 'You wrote more at night this week.';

  @override
  String get insightEnergyChartTitle => 'Energy — Last 7 Days';

  @override
  String get insightEnergyChartSubtitle => 'Your energy trend this week';

  @override
  String get insightChapterEngagementTitle => 'Memorable Chapter';

  @override
  String insightChapterEngagementDesc(String chapter_title, int count) {
    return 'Your chapter \"$chapter_title\" is the most complete so far, with $count stories recorded.';
  }

  @override
  String get insightChapterHappiestTitle => 'Happy Chapter';

  @override
  String insightChapterHappiestDesc(
    String chapter_title,
    String moodEmoji,
    String moodAvg,
  ) {
    return 'The chapter \"$chapter_title\" was a very positive phase, with average mood $moodEmoji ($moodAvg).';
  }

  @override
  String get insightWritingLengthTitle => 'Deep Reflections';

  @override
  String get insightWritingLengthTip =>
      'Your recent reflections are quite brief. Try writing in more detail about how you felt today.';

  @override
  String insightWritingLengthCongrats(int count) {
    return 'Congratulations on writing in detail recently ($count words)! Deepening your memories helps clear the mind.';
  }

  @override
  String get insightPremiumRequired =>
      'This is a Premium feature. Upgrade to unlock this insight.';

  @override
  String get insightPremiumCTA => 'Upgrade';

  @override
  String get insightDevModeActive => 'Dev mode: all insights visible';

  @override
  String get backupProgressCreating => 'Creating backup file...';

  @override
  String get backupProgressCopyingDb => 'Copying database...';

  @override
  String get backupProgressCopyingVideos => 'Copying videos...';

  @override
  String backupProgressCopyingVideo(int current, int total) {
    return 'Copying video $current/$total...';
  }

  @override
  String get backupProgressCopyingPhotos => 'Copying photos...';

  @override
  String backupProgressCopyingPhoto(int current, int total) {
    return 'Copying photo $current/$total...';
  }

  @override
  String get backupProgressCopyingAudios => 'Copying audios...';

  @override
  String backupProgressCopyingAudio(int current, int total) {
    return 'Copying audio $current/$total...';
  }

  @override
  String get backupProgressCreatingMetadata => 'Creating metadata...';

  @override
  String get backupProgressCompressing => 'Compressing files...';

  @override
  String get backupProgressSuccess => 'Backup created successfully!';

  @override
  String get backupShareText =>
      'Complete DayApp backup with database and videos';

  @override
  String get errorBackupDbNotFound => 'Database not found.';

  @override
  String get errorBackupFileNotFound => 'Backup file not found.';

  @override
  String errorBackupDbNotFoundInFile(int count) {
    return 'Database not found in backup file. Extracted files: $count';
  }

  @override
  String get restoreProgressExtracting => 'Extracting backup file...';

  @override
  String restoreProgressZipContains(int count) {
    return 'ZIP contains $count files...';
  }

  @override
  String get restoreProgressBackingUpCurrent =>
      'Backing up current database...';

  @override
  String get restoreProgressClosingDb => 'Closing database connections...';

  @override
  String get restoreProgressRestoringDb => 'Restoring database...';

  @override
  String get restoreProgressCopyingRestoredDb => 'Copying restored database...';

  @override
  String get restoreProgressRestoringVideos => 'Restoring videos...';

  @override
  String restoreProgressRestoringVideo(int current, int total) {
    return 'Restoring video $current/$total...';
  }

  @override
  String get restoreProgressRestoringPhotos => 'Restoring photos...';

  @override
  String restoreProgressRestoringPhoto(int current, int total) {
    return 'Restoring photo $current/$total...';
  }

  @override
  String get restoreProgressRestoringAudios => 'Restoring audios...';

  @override
  String restoreProgressRestoringAudio(int current, int total) {
    return 'Restoring audio $current/$total...';
  }

  @override
  String get restoreProgressReinitializingDb => 'Reinitializing database...';

  @override
  String restoreProgressDbStats(int active, int deleted) {
    return 'Database restored: $active active, $deleted in trash.';
  }

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String codeExpiresIn(int minutes) {
    return 'Code expires in $minutes minutes';
  }

  @override
  String get backToStart => 'Back to start';

  @override
  String get code => 'Code';

  @override
  String get pin => 'PIN';

  @override
  String get enterCode => 'Enter code';

  @override
  String get codeCheckDescription =>
      'Enter the 6-digit code that was sent to your email.';

  @override
  String get defineNewPin => 'Define a new secure PIN for your account.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get storyPreviewMoodVeryDifficultNarrative =>
      'This was a very difficult story';

  @override
  String get storyPreviewMoodDifficultNarrative => 'This was a difficult story';

  @override
  String get storyPreviewMoodNeutralNarrative =>
      'It was neutral in terms of feeling';

  @override
  String get storyPreviewMoodGoodNarrative => 'A good story';

  @override
  String get storyPreviewMoodVeryGoodNarrative => 'A very good story';

  @override
  String get storyPreviewEnergyLowNarrative => 'I was feeling low on energy';

  @override
  String get storyPreviewEnergyNormalNarrative => 'My energy was normal';

  @override
  String get storyPreviewEnergyHighNarrative =>
      'I was feeling very high energy';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get premiumVersion => 'Premium Version';

  @override
  String get premiumScreenTitle => 'DayApp Premium';

  @override
  String get premiumScreenSubtitle =>
      'Unlock the full potential of your diary and preserve your memories with exclusive features.';

  @override
  String get premiumScreenRestore => 'Restore purchases';

  @override
  String get premiumScreenPurchaseButton => 'Get Lifetime Premium';

  @override
  String get premiumScreenFeaturesTitle => 'What you get with Premium:';

  @override
  String get premiumFeatureShareHistory => 'Share stories as custom images';

  @override
  String get premiumFeatureShareChapter => 'Export chapters to HTML';

  @override
  String get premiumFeatureAutoSuggestions =>
      'Smart automatic chapter suggestions';

  @override
  String get premiumFeatureMonthlyInsights =>
      'Detailed monthly insights and summaries';

  @override
  String get premiumFeatureWeeklyMood => '7-day mood evolution chart';

  @override
  String get premiumFeatureCustomThemes =>
      'Access to all exclusive themes and colors';

  @override
  String get premiumFeature => 'Premium feature';

  @override
  String get premiumFeatureInfo =>
      'This feature is available in the Premium version.';

  @override
  String get freePlan => 'Free';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get premiumDebugTitle => 'Premium Debug';

  @override
  String get premiumDebugSubtitle =>
      'Development only — not visible in production';

  @override
  String get premiumDebugActivate => 'Activate Premium (debug)';

  @override
  String get premiumDebugDeactivate => 'Deactivate Premium (return to Free)';

  @override
  String premiumDebugStatus(String plan) {
    return 'Status: $plan';
  }

  @override
  String premiumDebugSource(String source) {
    return 'Source: $source';
  }

  @override
  String get premiumDebugWarning =>
      'This screen is only available in debug builds. It will not appear in production.';

  @override
  String get premiumDebugFeatures => 'Features controlled by plan';

  @override
  String get premiumDebugNoSource => 'none';

  @override
  String get autoBackupPremiumRequired =>
      'Automatic backups are a Premium feature. Upgrade to access saved backups, restore points and storage management.';

  @override
  String autoBackupStorageInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backups · $size',
      one: '1 backup · $size',
      zero: 'No backups saved',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Chapters';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsSubtitle =>
      'Your moments organized into chapters and groups, like a life library.';

  @override
  String get groupsTabLabel => 'Groups';

  @override
  String get chapterShortcutToggle => 'Show/hide chapters card on Home';

  @override
  String get chaptersHomeCardTitle => 'Your life by chapters';

  @override
  String get chaptersHomeCardSubtitle =>
      'Your stories hold moments. Your chapters reveal the journey.';

  @override
  String get chaptersPremiumRequired =>
      'Chapters and automatic suggestions are Premium features.';

  @override
  String get themePremiumRequired => 'Custom themes are a Premium feature.';

  @override
  String get chapterSuggestions => 'Suggested chapters';

  @override
  String get chapterCreated => 'Chapter created successfully.';

  @override
  String get chapterEditTitle => 'Edit chapter';

  @override
  String get chapterDescriptionHint =>
      'Enter a description for this chapter (optional)';

  @override
  String get chapterUpdated => 'Chapter updated successfully.';

  @override
  String get chapterDeleteConfirmTitle => 'Delete chapter';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return 'Delete chapter “$title”? The linked stories will not be deleted.';
  }

  @override
  String get chapterDeleted => 'Chapter deleted successfully.';

  @override
  String get chapterCreateManual => 'Create chapter manually';

  @override
  String get chapterCreateTitle => 'Create Chapter';

  @override
  String get chapterTitle => 'Title';

  @override
  String get chapterTitleHint => 'Ex: Job change';

  @override
  String get chapterDescription => 'Description';

  @override
  String get chapterPhoto => 'Chapter photo';

  @override
  String get chapterPhotoActionLabel => 'Chapter Photo';

  @override
  String get chapterAddPhoto => 'Add photo';

  @override
  String get chapterChangePhoto => 'Change photo';

  @override
  String get chapterRemovePhoto => 'Remove photo';

  @override
  String get chapterSelectEntries => 'Select at least 1 related story';

  @override
  String get chapterMinimumEntries => 'Minimum: 1 story per chapter.';

  @override
  String chapterPeriod(String start, String end) {
    return 'Stories from $start - $end';
  }

  @override
  String chapterEntriesCount(int count) {
    return 'Stories: $count';
  }

  @override
  String chapterAverageMood(String mood) {
    return 'Average mood: $mood';
  }

  @override
  String chapterTopTags(String tags) {
    return 'Top tags: $tags';
  }

  @override
  String get chapterCreateFromSuggestion => 'Create chapter';

  @override
  String get chapterViewSuggestions => 'View suggestions';

  @override
  String get chapterCreateMyLabel => 'Create my Chapter';

  @override
  String get chapterIgnoreLabel => 'Ignore';

  @override
  String chapterSuggestionMoreStories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ies',
      one: 'y',
    );
    return 'and $count more stor$_temp0';
  }

  @override
  String get chapterNoItems => 'Your next chapter starts here.';

  @override
  String get chapterFilterAll => 'All';

  @override
  String get chapterFilterAutomatic => 'Automatic';

  @override
  String get chapterFilterManual => 'Manual';

  @override
  String get chapterNoSearchResults =>
      'No chapters matched the current filters.';

  @override
  String get chapterSortLabel => 'Sort by';

  @override
  String get chapterSortNewest => 'Newest period';

  @override
  String get chapterSortOldest => 'Oldest period';

  @override
  String get chapterSortTitle => 'Title';

  @override
  String get chapterSortStories => 'Most stories';

  @override
  String chapterEntriesAndMood(int count, String mood) {
    return '$count stories - avg mood $mood';
  }

  @override
  String get chapterOpenLabel => 'Open';

  @override
  String get chapterIntroSubtitle =>
      'Organize your stories with meaning and relive your memories in order';

  @override
  String get chapterIntroGroupTitle => 'Bring connected moments together';

  @override
  String get chapterIntroGroupBody =>
      'Gather multiple posts into one chapter to follow the full trajectory of a special theme or moment.';

  @override
  String get chapterIntroTimelineTitle =>
      'Relive your story from beginning to end';

  @override
  String get chapterIntroTimelineBody =>
      'Browse memories in chronological order and see how each moment evolved over time.';

  @override
  String get chapterIntroPhaseTitle => 'One chapter for each phase';

  @override
  String get chapterIntroPhaseBody =>
      'Trips, college, family, work, dreams, goals, or special memories. You decide how to tell your story.';

  @override
  String get chapterIntroCtaTitle => 'Ready to organize your memories?';

  @override
  String get chapterIntroCtaBody => 'Start by creating your first chapter now';

  @override
  String get chapterIntroShowOnOpen => 'Show this screen when opening Chapters';

  @override
  String get chapterLinkSectionTitle => 'Chapters';

  @override
  String get chapterLinkConfigure => 'Configure';

  @override
  String get chapterLinkDialogTitle => 'Add this story to chapters';

  @override
  String get chapterLinkModeNone => 'Do not add';

  @override
  String get chapterLinkModeExisting => 'Add to existing chapter';

  @override
  String get chapterLinkModeNew => 'Create new chapter';

  @override
  String get chapterSelectExistingLabel => 'Select chapter';

  @override
  String get chapterSelectExistingRequired => 'Select an existing chapter.';

  @override
  String get chapterTitleRequired => 'Chapter title is required.';

  @override
  String get chapterMinimumRelatedWithCurrent =>
      'Select at least 2 related stories. With the current one, the minimum is 3.';

  @override
  String get chapterLinkSummaryNone => 'Not linked to any chapter.';

  @override
  String get chapterLinkSummaryExisting =>
      'Will be added to an existing chapter when saving.';

  @override
  String chapterLinkSummaryNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'New chapter with $count stories',
      one: 'New chapter with 1 story',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String get homeHeaderLargeCards => 'View in large cards';

  @override
  String get homeHeaderCompactCards => 'View in compact cards';

  @override
  String get homeHeaderOpenCalendarTooltip => 'Open calendar';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeStoriesSubtitle => 'Here are your stories';

  @override
  String get homeShowAllStoriesLabel => 'Show all';

  @override
  String get insightHistoryTitle => 'Insight History';

  @override
  String get insightHistoryEmpty => 'No insights recorded yet.';

  @override
  String get insightHistoryClearAll => 'Clear history';

  @override
  String get insightHistoryClearConfirm =>
      'Clear all insight history? This action cannot be undone.';

  @override
  String insightHistorySeenOn(String date) {
    return 'Seen on $date';
  }

  @override
  String get insightHistoryFilterAll => 'All';

  @override
  String get insightHistoryFilterFree => 'Free';

  @override
  String get insightHistoryFilterPremium => 'Premium';

  @override
  String get insightHistorySearch => 'Search insights';

  @override
  String get pdfBackgroundColor => 'Background color';

  @override
  String get pdfBackgroundNone => 'None';

  @override
  String get pdfBackgroundBeige => 'Beige/cream';

  @override
  String get pdfBackgroundBlue => 'Pale blue';

  @override
  String get pdfBackgroundGreen => 'Pale green';

  @override
  String get pdfBackgroundGray => 'Light gray';

  @override
  String get exportPdfPremiumRequired =>
      'Exporting Chapter is a Premium feature. Upgrade your plan to access it.';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get wrongCurrentPassword => 'Current password is incorrect.';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get emailChangedSuccess => 'Email changed successfully.';

  @override
  String get newPasswordMinLength =>
      'New password must be at least 6 characters.';

  @override
  String get fillAllFields => 'Please fill in all fields.';

  @override
  String get backupInfoDialogTitle => 'About backup';

  @override
  String get backupInfoDialogContent =>
      '📦  What is included in the backup\n• All your stories (texts, photos, audios, videos)\n• App database\n• Chapter photos\n\n📂  How to store your backup\nAfter creation, use the share menu to save the file wherever you like — OneDrive, Google Drive, e-mail or any other service.';

  @override
  String get backupPasswordDialogTitle => 'Protect your backup';

  @override
  String get backupPasswordDescription =>
      'Set a password to encrypt your backup file. The contents will be protected and unreadable to anyone who does not have this password.';

  @override
  String get backupPasswordWarningTitle =>
      '⚠️  Important — read before continuing';

  @override
  String get backupPasswordWarning =>
      'This password is known only to you. It is not stored anywhere in the app or on our servers.\n\nIf you forget it, the backup file will be permanently inaccessible — not even our team will be able to help you recover the data.\n\nStore this password in a safe place before proceeding.';

  @override
  String get backupPasswordField => 'Password';

  @override
  String get backupPasswordConfirmField => 'Confirm password';

  @override
  String get backupPasswordMismatch =>
      'The passwords do not match. Please try again.';

  @override
  String get backupPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get backupPasswordEmpty => 'Please enter a password.';

  @override
  String get backupCreateEncrypted => 'Create encrypted backup';

  @override
  String get restorePasswordDialogTitle => 'Enter the backup password';

  @override
  String get restorePasswordDescription =>
      'If you set a password when creating this backup, enter it below.\n\nIf the backup was created without a password, leave the field blank.';

  @override
  String get restorePasswordField => 'Password (leave blank if none was set)';

  @override
  String get restorePasswordWrong =>
      'Incorrect password or unreadable backup. Check the password and try again.';

  @override
  String get restoreContinue => 'Continue';

  @override
  String get chapterExportPhotoSelectionTitle => 'Choose photos for export';

  @override
  String get chapterExportPhotoSelectionSubtitle =>
      'You can select up to 1 photo per story. Keeping none is also allowed.';

  @override
  String get chapterExportNoPhotoOption => 'No photo';

  @override
  String get resendCode => 'Resend code';

  @override
  String codeExpiresMinutes(int count) {
    return 'Code expires in $count minutes';
  }

  @override
  String get codeLabel => 'Code';

  @override
  String get informRegisteredEmail => 'Enter your registered email';

  @override
  String get newPasswordMinLengthLabel => 'New password (minimum 6 characters)';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get informYourEmailTitle => 'Enter your email';

  @override
  String get enterCodeTitle => 'Enter code';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get emailStepSubtitle =>
      'We will send a recovery code to the email registered in your account.';

  @override
  String get codeStepSubtitle =>
      'Enter the 6-digit code that was sent to your email.';

  @override
  String get passwordStepSubtitle =>
      'Set a secure new password for your account.';

  @override
  String get sendCodeButtonLabel => 'Send code';

  @override
  String get verifyCodeButtonLabel => 'Verify code';

  @override
  String get resetPasswordButtonLabel => 'Reset password';

  @override
  String get birthDateCannotBeFuture => 'Birth date cannot be in the future.';

  @override
  String get birthDateMinAge => 'You must be at least 14 years old.';

  @override
  String get successAudioAdded => 'Audio added successfully!';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String get videoSavedSuccess => 'Video saved successfully';

  @override
  String get videoPlaybackNotAvailableWindows =>
      'Video playback not available on Windows';

  @override
  String get supportEmailSubjectLogin => 'DayApp Support - Login';

  @override
  String get supportEmailBodyLogin =>
      'Hello, I need help with logging into DayApp...';

  @override
  String successAudiosAdded(int count) {
    return '$count audios added successfully!';
  }

  @override
  String sizeLabel(String size) {
    return 'Size: $size MB';
  }

  @override
  String durationLabel(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get editDoubleTapHint => 'Edit - 2 taps';

  @override
  String deleteGroupWarningText(String groupName) {
    return 'Do you want to delete the group \"$groupName\"? Stories in this group will not be deleted, only removed from the group.';
  }

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }

  @override
  String get editorPlaceholder => 'Type here...';

  @override
  String get aboutFlutterDesc => 'Framework for multiplatform development';

  @override
  String get aboutDartDesc => 'Modern and efficient programming language';

  @override
  String get aboutSqliteDesc => 'Robust and reliable local database';

  @override
  String get aboutProviderDesc => 'Reactive state management';

  @override
  String get aboutMaterial3Title => 'Material Design 3';

  @override
  String get aboutMaterial3Desc => 'Modern and accessible design system';

  @override
  String get aboutScreenTechnologiesTitle => 'Technologies';

  @override
  String get insightMood7Days => 'Mood — Last 7 Days';

  @override
  String get insightMoodVariationThisWeek => 'Your mood variation this week';

  @override
  String chapterExportPartLabel(int index, int total) {
    return 'Part $index of $total';
  }

  @override
  String chapterExportSplitExplanation(int parts) {
    return 'To ensure better performance and compatibility when sharing, this chapter was split into $parts files.';
  }

  @override
  String get chapterTitleDuplicateTitle => 'Duplicate Title';

  @override
  String get chapterTitleDuplicateMessage =>
      'A chapter with this title already exists. Please choose another title.';

  @override
  String get pwdCriteriaMinLength => 'Minimum of 8 characters';

  @override
  String get pwdCriteriaUppercase => '1 uppercase letter';

  @override
  String get pwdCriteriaLowercase => '1 lowercase letter';

  @override
  String get pwdCriteriaNumber => '1 number';

  @override
  String get pwdCriteriaSpecial => '1 special character';
}
