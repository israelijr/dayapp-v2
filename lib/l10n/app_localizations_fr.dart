// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get howMuchWeHaveDoneTogether =>
      'Tout ce que nous avons fait ensemble';

  @override
  String get chaptersLabel => 'Chapitres';

  @override
  String get groupsLabel => 'Groupes';

  @override
  String storiesThisWeek(int count) {
    return 'Histoires racontées cette semaine: $count';
  }

  @override
  String get tapChartToSeeWeekly =>
      'Appuyez sur le graphique pour voir la semaine';

  @override
  String get moodEnergyChartTitle => 'Votre Voyage Récent';

  @override
  String get moodEnergyChartSubtitle => '7 derniers jours avec enregistrements';

  @override
  String moodEnergyChartTooltip(String date, String mood, String energy) {
    return 'Jour $date : Humeur $mood / Énergie $energy';
  }

  @override
  String get moodEnergyChartTitleLabel => 'Humeur et Énergie';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get deviceDefault => 'Langue du système';

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get english => 'Anglais';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get italian => 'Italien';

  @override
  String get portuguese => 'Portugais';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get errorInitializingApp =>
      'Erreur lors de l\'initialisation de l\'application';

  @override
  String get theme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get security => 'Sécurité';

  @override
  String get themeAndScheme => 'Thème et schéma';

  @override
  String get themeRelva => 'Herbe';

  @override
  String get themeOutono => 'Jardin botanique';

  @override
  String get themeCeu => 'Ciel';

  @override
  String get themeConfort => 'Confort';

  @override
  String get themeSunset => 'Coucher de soleil';

  @override
  String get themeMidnightGalaxy => 'Galaxie de Minuit';

  @override
  String get themeDefaultLightDescription => 'Thème clair par défaut';

  @override
  String get themeDefaultDarkDescription => 'Thème sombre par défaut';

  @override
  String get themeFollowSystemDescription => 'Suivre le thème du système';

  @override
  String get themeCustomSchemesTitle => 'Schémas personnalisés';

  @override
  String get themeRelvaLight => 'Relva (Clair)';

  @override
  String get themeRelvaDark => 'Relva (Sombre)';

  @override
  String get themeOutonoLight => 'Jardin botanique (Clair)';

  @override
  String get themeOutonoDark => 'Jardin botanique (Sombre)';

  @override
  String get themeRelvaLightDescription => 'Tons verts et naturels';

  @override
  String get themeRelvaDarkDescription => 'Version sombre du schéma Relva';

  @override
  String get themeOutonoLightDescription =>
      'Tons frais et organiques de jardin';

  @override
  String get themeOutonoDarkDescription =>
      'Version sombre du schéma Jardin botanique';

  @override
  String get themeRemoveScheme => 'Supprimer le schéma';

  @override
  String get themeRemoveSchemeDescription =>
      'Revenir au schéma de thème par défaut';

  @override
  String get timeAtConnector => 'à';

  @override
  String get timeAgoNow => 'à l\'instant';

  @override
  String timeAgoMinutes(int count) {
    return 'il y a $count min';
  }

  @override
  String timeAgoHours(int count) {
    return 'il y a ${count}h';
  }

  @override
  String timeAgoDays(int count) {
    return 'il y a $count jour(s)';
  }

  @override
  String get backup => 'Sauvegarde';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get confirm => 'Confirmer';

  @override
  String get pinUnlock => 'Déverrouillage PIN';

  @override
  String get changePin => 'Changer le PIN';

  @override
  String get enableBiometrics => 'Connexion biométrique';

  @override
  String get information => 'Informations';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get configurePin => 'Configurer le PIN';

  @override
  String get biometrics => 'Biométrie';

  @override
  String get backgroundLock => 'Verrouillage en arrière-plan';

  @override
  String get backgroundLockDialogPrompt =>
      'Combien de temps après la mise en arrière-plan l\'application doit-elle se verrouiller ?';

  @override
  String get backgroundLockTimeLabel => 'Durée';

  @override
  String get backgroundLockDialogResult => 'Résultat :';

  @override
  String get backgroundLockSuggestions => 'Suggestions :';

  @override
  String get backgroundLockImmediateHint => '0 = immédiat';

  @override
  String get backgroundLockNever => 'Ne pas verrouiller';

  @override
  String get backgroundLockImmediately => 'Immédiatement';

  @override
  String backgroundLockSeconds(int count) {
    return '$count secondes';
  }

  @override
  String get backgroundLockOneMinute => '1 minute';

  @override
  String backgroundLockMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get backgroundLockOneHour => '1 heure';

  @override
  String backgroundLockHours(int count) {
    return '$count heures';
  }

  @override
  String get statistics => 'Statistiques';

  @override
  String get noStoriesYetTitle => 'Pas encore d\'histoires';

  @override
  String get trashEmptyStateMessage => 'Votre corbeille est vide';

  @override
  String get noStoriesYetSubtitle =>
      'Commencez à enregistrer vos journées pour voir les statistiques';

  @override
  String get trends => 'Tendances';

  @override
  String get last30Days => '30 derniers jours';

  @override
  String get activityByWeekday => 'Activité par jour de la semaine';

  @override
  String get streaksTitle => 'Séries';

  @override
  String get longestStreakPrefix => 'Plus longue série :';

  @override
  String get tableOfMoods => 'Tableau des humeurs';

  @override
  String get moodCount => 'Nombre d\'humeurs';

  @override
  String get topTags => 'Étiquettes populaires';

  @override
  String get storiesLabel => 'Histoires';

  @override
  String get activeDaysLabel => 'Jours actifs';

  @override
  String get avgPerDayLabel => 'Moy/jour';

  @override
  String get mediaLabel => 'Médias';

  @override
  String get manageGroups => 'Gérer les groupes';

  @override
  String get trash => 'Corbeille';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get aboutScreenAboutDayAppTitle => 'À propos de DayApp';

  @override
  String get aboutScreenAboutDayAppDescription =>
      'DayApp est une application de journal personnel moderne et sécurisée qui vous permet d\'enregistrer vos histoires, souvenirs et pensées de manière organisée et privée. Avec une interface intuitive et des fonctionnalités avancées, DayApp vous aide à préserver vos expériences les plus significatives.';

  @override
  String get aboutScreenFeaturesTitle => 'Fonctionnalités';

  @override
  String get aboutScreenFeatureRichEditorTitle => 'Éditeur riche';

  @override
  String get aboutScreenFeatureRichEditorDescription =>
      'Créez des histoires avec une mise en forme avancée, des images, vidéos et audios';

  @override
  String get aboutScreenFeatureSmartOrganizationTitle =>
      'Organisation intelligente';

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Classez vos histoires en groupes thématiques personnalisés et en chapitres qui parlent de vous';

  @override
  String get aboutScreenFeatureAdvancedSearchTitle => 'Recherche avancée';

  @override
  String get aboutScreenFeatureAdvancedSearchDescription =>
      'Trouvez rapidement n\'importe quelle histoire par contenu ou date';

  @override
  String get aboutScreenFeatureSecureBackupTitle => 'Sauvegarde sécurisée';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Sauvegardez régulièrement vos données.';

  @override
  String get aboutScreenFeatureTotalPrivacyTitle => 'Confidentialité totale';

  @override
  String get aboutScreenFeatureTotalPrivacyDescription =>
      'Vos données sont stockées localement et chiffrées';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceTitle => 'Interface adaptative';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceDescription =>
      'Thèmes clairs et sombres avec mises en page personnalisables';

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
  String get aboutScreenDevelopmentTitle => 'Développement';

  @override
  String get aboutScreenDevelopmentDescription =>
      'Construit avec soin pour offrir la meilleure expérience pour enregistrer des souvenirs personnels.';

  @override
  String get aboutScreenPrivacySecurityTitle => 'Confidentialité et sécurité';

  @override
  String get aboutScreenPrivacyLocalDataTitle => 'Données locales';

  @override
  String get aboutScreenPrivacyLocalDataDescription =>
      'Toutes vos histoires sont stockées uniquement sur votre appareil';

  @override
  String get aboutScreenPrivacyEncryptionTitle => 'Chiffrement';

  @override
  String get aboutScreenPrivacyEncryptionDescription =>
      'Le contenu sensible est protégé par un chiffrement avancé';

  @override
  String get aboutScreenPrivacyNoTrackingTitle => 'Pas de suivi';

  @override
  String get aboutScreenPrivacyNoTrackingDescription =>
      'Nous ne collectons pas de données personnelles ni ne suivons votre utilisation';

  @override
  String get aboutScreenPrivacyPinSecurityTitle => 'PIN de sécurité';

  @override
  String get aboutScreenPrivacyPinSecurityDescription =>
      'Protégez l\'accès à l\'application avec un PIN ou des données biométriques';

  @override
  String get aboutScreenContactSupportTitle => 'Contact et support';

  @override
  String get aboutScreenContactSupportDescription =>
      'Pour les questions, suggestions ou support technique :';

  @override
  String get aboutScreenSupportEmailSubject => 'Support DayApp';

  @override
  String aboutScreenSupportEmailBody(String version) {
    return 'Bonjour, j\'ai besoin d\'aide avec DayApp...\n\nVersion : $version\n';
  }

  @override
  String get aboutScreenAcknowledgementsTitle => 'Remerciements';

  @override
  String get aboutScreenAcknowledgementsDescription =>
      'Merci d\'avoir choisi DayApp pour enregistrer vos souvenirs les plus précieux. Votre confiance et vos retours sont essentiels pour que nous continuions à nous améliorer.';

  @override
  String get aboutScreenHeaderSubtitle => 'Votre journal personnel';

  @override
  String get aboutScreenCopyright => '© 2026 DayApp. Tous droits réservés.';

  @override
  String get logout => 'Déconnexion';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get name => 'Nom';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get createAccountButton => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get needHelp => 'Besoin d\'aide ?';

  @override
  String get currentPinLabel => 'PIN actuel';

  @override
  String get newPinLabel => 'Nouveau PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmer le PIN';

  @override
  String get enterCurrentPin => 'Entrez le PIN actuel';

  @override
  String get enterPin => 'Entrez le PIN';

  @override
  String get pinLengthError => 'Le PIN doit comporter entre 4 et 8 chiffres';

  @override
  String get pinsDoNotMatch => 'Les PIN ne correspondent pas';

  @override
  String get pinIncorrect => 'PIN actuel incorrect';

  @override
  String get pinChangedSuccess => 'PIN modifié avec succès !';

  @override
  String get pinConfiguredSuccess => 'PIN configuré avec succès !';

  @override
  String get informYourEmail => 'Entrez votre e-mail.';

  @override
  String get invalidEmail => 'Entrez un e-mail valide.';

  @override
  String get emailNotFound => 'E-mail introuvable. Vérifiez et réessayez.';

  @override
  String codeSent(Object email) {
    return 'Code envoyé à $email ! Vérifiez votre boîte de réception.';
  }

  @override
  String get codeMustBe6 => 'Le code doit comporter 6 chiffres.';

  @override
  String get codeVerified =>
      'Code vérifié ! Définissez votre nouveau mot de passe.';

  @override
  String get codeInvalid => 'Code invalide ou expiré. Réessayez.';

  @override
  String get enterNewPassword => 'Entrez le nouveau mot de passe.';

  @override
  String get passwordResetSuccess =>
      'Mot de passe réinitialisé avec succès ! Connectez-vous avec le nouveau mot de passe.';

  @override
  String get errorResetPassword =>
      'Erreur lors de la réinitialisation du mot de passe. Réessayez.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get resendCodeSuccess =>
      'Nouveau code envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get resendCodeError => 'Erreur lors du renvoi du code. Réessayez.';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit comporter au moins 6 caractères.';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get fullName => 'Nom complet';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get almostReady => 'presque prêt...';

  @override
  String get optionalData => 'Les champs ci-dessous sont facultatifs';

  @override
  String get birthDateFormat => 'Date de naissance (JJ/MM/AAAA)';

  @override
  String get invalidBirthDate =>
      'Date de naissance invalide (utilisez JJ/MM/AAAA)';

  @override
  String get userNotFound => 'Utilisateur introuvable.';

  @override
  String get create => 'Créer';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get nameMinLength => 'Le nom doit comporter au moins 2 caractères';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get emailInvalid => 'Entrez un e-mail valide';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get accessAccount => 'Accédez à votre compte';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get noAccountCreateHere => 'Pas de compte ? Créez-en un ici.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get biometricsEnabledSuccess => 'Biométrie activée avec succès !';

  @override
  String get biometricLoginError => 'Erreur lors de la connexion biométrique.';

  @override
  String get invalidCredentials => 'E-mail ou mot de passe invalide.';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès !';

  @override
  String get profileUpdateError =>
      'Erreur lors de la mise à jour du profil. Réessayez.';

  @override
  String get unlockAppReason => 'Déverrouillez l\'application pour continuer';

  @override
  String get fillEmailAndPassword => 'Remplissez l\'e-mail et le mot de passe';

  @override
  String get emailOrPasswordIncorrect => 'E-mail ou mot de passe incorrect';

  @override
  String get noEmailRegistered =>
      'Aucun e-mail enregistré. Configurez-le dans les paramètres.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Vérifiez votre e-mail à $email ou utilisez le code affiché';
  }

  @override
  String get errorGeneratingCode =>
      'Erreur lors de la génération du code. Réessayez.';

  @override
  String get errorSendingCode => 'Erreur lors de l\'envoi du code. Réessayez.';

  @override
  String get enterRecoveryCodePrompt =>
      'Entrez le code envoyé à votre e-mail :';

  @override
  String get recoveryCodeLabel => 'Code de récupération (6 chiffres)';

  @override
  String get enterPasswordToContinue =>
      'Entrez votre mot de passe pour continuer';

  @override
  String get enterPinToContinue => 'Entrez votre PIN pour continuer';

  @override
  String get useBiometricsToContinue =>
      'Utilisez vos données biométriques pour continuer';

  @override
  String get usePin => 'Utiliser le PIN';

  @override
  String get noStoriesHere => 'Pas d\'histoires à afficher ici.';

  @override
  String get storiesGroupedOrArchived =>
      'Elles sont soit groupées soit archivées.';

  @override
  String get useBiometrics => 'Utiliser la biométrie';

  @override
  String get unlockWithBiometrics => 'Déverrouiller avec la biométrie';

  @override
  String get useAccountPassword => 'Utiliser le mot de passe du compte';

  @override
  String get forgotPin => 'PIN oublié';

  @override
  String get unlockTitle => 'Déverrouiller l\'application';

  @override
  String get search => 'Rechercher';

  @override
  String get searchStoriesTitle => 'Recherchez vos histoires';

  @override
  String get searchStoriesSubtitle =>
      'Utilisez les filtres ci-dessus pour retrouver vos souvenirs.';

  @override
  String unsavedBackups(Object count) {
    return 'Vous avez $count histoire(s) sans sauvegarde.';
  }

  @override
  String get backupRecommendation =>
      'Nous recommandons de sauvegarder pour éviter de perdre vos données.';

  @override
  String get cancel => 'Annuler';

  @override
  String get restore => 'Restaurer';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleted => 'Supprimé';

  @override
  String get performBackup => 'Sauvegarder maintenant';

  @override
  String get deleteStoryTitle => 'Supprimer l\'histoire';

  @override
  String get deleteStoryConfirm =>
      'Voulez-vous déplacer cette histoire vers la corbeille ?';

  @override
  String get deleteLabel => 'Supprimer';

  @override
  String get movedToTrash => 'Histoire déplacée vers la corbeille';

  @override
  String errorDeletingStory(Object error) {
    return 'Erreur lors de la suppression de l\'histoire : $error';
  }

  @override
  String get noRecordsThisDay => 'Aucun enregistrement pour ce jour';

  @override
  String get storyUngrouped => 'Histoire sans groupe';

  @override
  String get save => 'Enregistrer';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get groupDeletedSuccess => 'Groupe supprimé avec succès';

  @override
  String get noGroupsFound => 'Aucun groupe trouvé';

  @override
  String get shareError => 'Impossible de partager';

  @override
  String get cannotDeletePhoto => 'Impossible de supprimer cette photo';

  @override
  String get deletePhotoTitle => 'Supprimer la photo';

  @override
  String get deletePhotoConfirm =>
      'Voulez-vous vraiment supprimer cette photo ?';

  @override
  String get deleteGroupTitle => 'Supprimer le groupe';

  @override
  String get share => 'Partager';

  @override
  String get scrapbookTemplateLabel => 'Scrapbook';

  @override
  String get polaroidTemplateLabel => 'Polaroid';

  @override
  String get home => 'Accueil';

  @override
  String get groups => 'Groupes';

  @override
  String get myStories => 'Mes histoires';

  @override
  String get record => 'enregistrement';

  @override
  String get records => 'enregistrements';

  @override
  String get filterText => 'Texte';

  @override
  String get filterTag => 'Étiquette';

  @override
  String get filterEmoticon => 'Émoticône';

  @override
  String get filterDate => 'Période';

  @override
  String get selectDateRange => 'Sélectionner une période';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get searchHintTag => 'Tapez une étiquette...';

  @override
  String get searchHintText => 'Rechercher dans le titre ou la description...';

  @override
  String get clearSearchTooltip => 'Effacer la recherche';

  @override
  String get clear => 'Effacer';

  @override
  String get tapToSelectEmoji => 'Appuyez pour sélectionner un emoji :';

  @override
  String get selectEmoji => 'Sélectionner un emoji';

  @override
  String get tapToChangeEmoji => 'Appuyez pour changer';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get recordVideoLabel => 'Enregistrer une vidéo';

  @override
  String get recordAudioLabel => 'Enregistrer un audio';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get dontShowAgain => 'Ne plus afficher';

  @override
  String get laterLabel => 'Plus tard';

  @override
  String get configureLabel => 'Configurer';

  @override
  String get imageCopiedBase64 =>
      'Image copiée dans le presse-papiers (base64)';

  @override
  String get newGroup => 'Nouveau groupe';

  @override
  String get editGroup => 'Modifier le groupe';

  @override
  String get chooseIcon => 'Choisir une icône';

  @override
  String groupDeleteWarning(Object count) {
    return 'Ce groupe a $count histoire(s) liée(s). Si supprimé, ces histoires reviendront à l\'écran d\'accueil (sans groupe). Continuer ?';
  }

  @override
  String get unarchive => 'Désarchiver';

  @override
  String get group => 'Groupe';

  @override
  String get selectGroup => 'Sélectionner un groupe';

  @override
  String get selectLabel => 'Sélectionner';

  @override
  String get existingGroups => 'Groupes existants';

  @override
  String get createNewGroup => 'Créer un nouveau groupe';

  @override
  String get groupNameLabel => 'Nom du groupe';

  @override
  String get groupNameMaxLengthHint => 'Maximum 15 caractères.';

  @override
  String get groupNameTooLong =>
      'Le nom du groupe doit comporter au maximum 15 caractères.';

  @override
  String get createAndSelect => 'Créer et sélectionner';

  @override
  String get manageBackups => 'Gérer la sauvegarde';

  @override
  String get createAndShareBackup => 'Créer et partager la sauvegarde';

  @override
  String get restoreFromFile => 'Restaurer depuis un fichier';

  @override
  String get backupNotAvailableWeb => 'Sauvegarde non disponible sur le web';

  @override
  String get backupNotAvailableDetail =>
      'La fonctionnalité de sauvegarde nécessite un accès au système de fichiers, disponible uniquement sur Android, iOS et les versions de bureau.';

  @override
  String get backupInfoTitle => 'À propos de la sauvegarde';

  @override
  String get backupInfoDetails =>
      'La sauvegarde complète comprend :\n• Base de données (histoires, textes, photos, audios)\n• Fichiers vidéo\n\nUn fichier ZIP sera créé et vous pourrez le sauvegarder où vous voulez :\n• OneDrive\n• Google Drive\n• E-mail\n• Tout autre emplacement';

  @override
  String get backupComplete => 'Sauvegarde complète';

  @override
  String get backupZipSubtitle => 'Fichier ZIP avec toutes vos données';

  @override
  String get backupZipExplanation =>
      'Génère un fichier ZIP que vous pouvez enregistrer sur votre appareil, OneDrive, Google Drive, votre courrier électronique ou tout autre emplacement cloud, à l\'exception des applications de messagerie.';

  @override
  String get backupLinuxExplanation =>
      'Choisissez un dossier et le ZIP de sauvegarde y sera enregistré directement.';

  @override
  String get restoreSectionTitle => 'Restaurer la sauvegarde';

  @override
  String get restoreSectionDescription =>
      'Sélectionnez un fichier de sauvegarde (ZIP) précédemment créé pour restaurer toutes vos données.';

  @override
  String lastBackupLabel(String fileName) {
    return 'Dernière sauvegarde : $fileName';
  }

  @override
  String get backupShareSubject => 'Sauvegarde DayApp';

  @override
  String backupDeleteConfirm(String fileName) {
    return 'Êtes-vous sûr de vouloir supprimer cette sauvegarde ?\n\n$fileName';
  }

  @override
  String backupShareError(String message) {
    return 'Erreur lors du partage de la sauvegarde : $message';
  }

  @override
  String backupDeleteError(String message) {
    return 'Erreur lors de la suppression de la sauvegarde : $message';
  }

  @override
  String get processing => 'Traitement en cours...';

  @override
  String get pleaseWait => 'Veuillez patienter...';

  @override
  String get backupStarting => 'Démarrage de la sauvegarde...';

  @override
  String get backupCreatedSuccess => 'Fichier de sauvegarde créé !';

  @override
  String backupError(Object message) {
    return 'Erreur lors de la création de la sauvegarde : $message';
  }

  @override
  String get restoreStarting => 'Démarrage de la restauration...';

  @override
  String get restoreSuccess => 'Restauration terminée avec succès !';

  @override
  String restoreError(Object message) {
    return 'Erreur lors de la restauration : $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirmer la restauration';

  @override
  String get restoreConfirmContent =>
      'Toutes les données actuelles seront remplacées par la sauvegarde.\n\nCette action ne peut pas être annulée. Souhaitez-vous continuer ?';

  @override
  String get restoreSuccessTitle => '✅ Restauration terminée';

  @override
  String get restoreSuccessContent =>
      'La sauvegarde a été restaurée avec succès !\n\nToutes vos histoires ont été restaurées à l\'état de la sauvegarde.\n\nVous devez vous reconnecter pour terminer le processus.';

  @override
  String get helpAboutTitle => 'À propos de DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp est une application de journal personnel qui vous permet d\'enregistrer vos histoires, souvenirs et pensées de manière organisée et sécurisée.';

  @override
  String get helpNavigationTitle => 'Navigation principale';

  @override
  String get helpHomeItemDesc =>
      'Affichez les 5 dernières histoires ou toutes les histoires sur des cartes grandes ou petites ou dans le calendrier';

  @override
  String get helpHomeDoubleTapDesc =>
      'Double-tapez sur une histoire pour la visualiser.';

  @override
  String get helpHomeAttachmentsDesc =>
      'Tapez sur les pièces jointes pour les visualiser.';

  @override
  String get helpHomeSwipeRightDesc =>
      'Faites glisser la carte vers la droite pour archiver l\'histoire. L\'histoire est déplacée vers l\'onglet Collections / Groupes / Archivés';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Faites glisser la carte vers la gauche pour l\'associer à un groupe. L\'histoire est déplacée vers l\'onglet Collections / Groupes / Archivés';

  @override
  String get helpHomeCalendarIconDesc =>
      'Tapez sur l\'icône du calendrier pour afficher vos histoires dans ce format.';

  @override
  String get helpHomeChapterIconDesc =>
      'Organisez vos histoires en chapitres et groupes thématiques. Créez des chapitres et racontez votre histoire complète. Créez des groupes personnalisés pour classer vos souvenirs.';

  @override
  String get helpGroupsNavDesc =>
      'Organisez vos histoires en chapitres et groupes thématiques. Créez des chapitres et racontez votre histoire complète. Créez des groupes personnalisés pour classer vos souvenirs.';

  @override
  String get helpSearchItemDesc =>
      'Trouvez rapidement des histoires par titre, contenu, étiquette ou date.';

  @override
  String get helpCreatingTitle => 'Créer des histoires';

  @override
  String get helpNewStoryDesc =>
      'Tapez sur le bouton flottant (+ Nouvelle histoire) pour créer une nouvelle histoire. Ajoutez un titre, du texte, des images, des vidéos et des audios.';

  @override
  String get helpTextEditorTitle => 'Éditeur de texte';

  @override
  String get helpTextEditorDesc =>
      'Utilisez la mise en forme riche : gras, italique, listes, liens et plus.';

  @override
  String get helpChaptersDesc =>
      'Organisez votre histoire en chapitres en rejoignant d\'autres histoires sur le même sujet.';

  @override
  String get helpMediaDesc =>
      'Ajoutez des photos depuis la galerie ou l\'appareil photo, enregistrez des vidéos ou des audios directement dans l\'application.';

  @override
  String get helpGroupsAssocDesc =>
      'Associez chaque histoire à un ou plusieurs groupes pour une meilleure organisation.';

  @override
  String get helpCalendarDesc =>
      'Affichez vos histoires organisées par date. Tapez sur une date pour voir toutes les histoires de ce jour.';

  @override
  String get helpCreateGroupTitle => 'Créer un groupe';

  @override
  String get helpCreateGroupDesc =>
      'Allez dans \"Groupes\" dans le menu latéral pour créer de nouveaux groupes avec des couleurs et des émoticônes personnalisées.';

  @override
  String get helpEditGroupTitle => 'Modifier un groupe';

  @override
  String get helpEditGroupDesc =>
      'Tapez sur un groupe pour modifier le nom, l\'émoticône ou le supprimer.';

  @override
  String get helpGroupsAssocTitle => 'Associer à des groupes';

  @override
  String get helpDeleteGroupTitle => 'Supprimer un groupe';

  @override
  String get helpDeleteGroupDesc =>
      'Supprimez un groupe sans supprimer ses histoires.';

  @override
  String get helpInsightsTitle => 'Aperçus';

  @override
  String get helpInsightsDesc =>
      'Recevez des aperçus basés sur vos histoires sur l\'écran d\'accueil.\nCertains aperçus sont uniquement disponibles dans la version Premium.\nAccédez à l\'historique des aperçus dans le menu latéral.';

  @override
  String get helpBackupSecurityTitle => 'Sauvegarde et sécurité';

  @override
  String get helpAutomaticBackupTitle => 'Sauvegarde automatique';

  @override
  String get helpAutomaticBackupDesc =>
      'Configurez la sauvegarde automatique (Premium) dans Paramètres. La sauvegarde sera créée lors de la déconnexion.';

  @override
  String get helpManualBackupTitle => 'Sauvegarde';

  @override
  String get helpManualBackupDesc =>
      'Allez dans \"Gérer la sauvegarde complète\" dans Paramètres pour créer une sauvegarde complète avec tous les médias.';

  @override
  String get helpRestoreTitle => 'Restaurer';

  @override
  String get helpRestoreDesc =>
      'Utilisez \"Restaurer depuis un fichier\" pour récupérer les données d\'une sauvegarde précédente.';

  @override
  String get helpPinSecurityTitle => 'PIN de sécurité';

  @override
  String get helpPinSecurityDesc =>
      'Définissez un PIN de 4 à 8 chiffres pour protéger l\'accès à l\'application.';

  @override
  String get helpBiometricsDesc =>
      'Utilisez l\'empreinte digitale pour déverrouiller rapidement l\'application, si disponible sur votre appareil.';

  @override
  String get helpPasswordUnlockTitle => 'Déverrouillage par mot de passe';

  @override
  String get helpPasswordUnlockDesc =>
      'En plus du PIN et de la biométrie, vous pouvez déverrouiller l\'application en utilisant le mot de passe de votre compte. Utile si vous oubliez le PIN ou si la biométrie échoue.';

  @override
  String get helpBackgroundLockDesc =>
      'Lorsque l\'application est minimisée ou que vous passez à une autre application, elle se verrouille automatiquement après le délai configuré. Vous pouvez définir le délai librement dans les paramètres (secondes, minutes ou heures).';

  @override
  String get helpLockExceptionsTitle => 'Exceptions de verrouillage';

  @override
  String get helpLockExceptionsDesc =>
      'L\'application ne se verrouille pas lorsque vous utilisez des fonctions internes qui ouvrent d\'autres applications — comme choisir des photos depuis la galerie, enregistrer des vidéos, choisir l\'emplacement de sauvegarde ou partager des histoires.';

  @override
  String get helpPinRecoveryTitle => 'Récupération du PIN';

  @override
  String get helpPinRecoveryDesc =>
      'Vous avez oublié votre PIN ? Utilisez l\'option \"PIN oublié\" sur l\'écran de verrouillage. Un code de récupération sera envoyé à l\'e-mail enregistré.';

  @override
  String get helpThemeDesc =>
      'Basculez entre les thèmes clair, sombre, automatique et d\'autres disponibles dans la version Premium.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configurez comment la notification de rappel de l\'application se comportera lors de la création d\'histoires avec des dates futures.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Définissez combien de temps l\'application peut rester en arrière-plan avant d\'être verrouillée. Vous pouvez utiliser des valeurs en secondes, minutes ou heures, avec pleine liberté.';

  @override
  String get helpBackupSettingTitle => 'Sauvegarde';

  @override
  String get helpBackupSettingDesc =>
      'Gérez les paramètres de sauvegarde et de restauration.';

  @override
  String get helpTrashDesc =>
      'Les histoires supprimées restent dans la corbeille pendant 30 jours. Accédez à \"Corbeille\" dans le menu latéral pour les récupérer ou les supprimer définitivement.';

  @override
  String get helpStatisticsDesc =>
      'Consultez les statistiques sur votre utilisation du journal : nombre d\'histoires, mots écrits, groupes principaux, etc.';

  @override
  String get helpTipsTitle => 'Conseils d\'utilisation';

  @override
  String get helpOrganizationTipTitle => 'Organisation';

  @override
  String get helpOrganizationTipDesc =>
      'Utilisez des groupes pour classer vos histoires par thèmes et des chapitres pour raconter toute l\'histoire.';

  @override
  String get helpSearchTipTitle => 'Recherche';

  @override
  String get helpSearchTipDesc =>
      'Utilisez la fonction de recherche pour retrouver rapidement d\'anciennes histoires.';

  @override
  String get helpBackupTipTitle => 'Sauvegarde régulière';

  @override
  String get helpBackupTipDesc =>
      'Sauvegardez régulièrement, surtout avant les mises à jour ou les changements d\'appareil.';

  @override
  String get helpPrivacyTipTitle => 'Confidentialité';

  @override
  String get helpPrivacyTipDesc =>
      'Vos histoires sont stockées localement et chiffrées. Définissez un PIN pour une protection supplémentaire.';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportDesc =>
      'Pour les questions ou les problèmes, contactez-nous via l\'e-mail de support ou vérifiez les mises à jour de l\'application.';

  @override
  String get errorCreateAccount =>
      'Erreur lors de la création du compte. Veuillez réessayer.';

  @override
  String get errorShare => 'Erreur lors du partage';

  @override
  String errorPlayAudio(Object message) {
    return 'Erreur lors de la lecture de l\'audio : $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Erreur lors de la sélection des vidéos : $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Erreur lors de la sélection du fichier : $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Erreur lors de l\'enregistrement de la vidéo : $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Erreur lors du démarrage de l\'enregistrement : $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Erreur lors de la mise en pause de l\'enregistrement : $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Erreur lors de la reprise de l\'enregistrement : $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Erreur lors de l\'arrêt de l\'enregistrement : $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Erreur lors de la sélection des audios : $message';
  }

  @override
  String get errorLoadVideo => 'Erreur lors du chargement de la vidéo';

  @override
  String get errorSelectImage => 'Erreur lors de la sélection de l\'image';

  @override
  String get imagePickerTitleMultiple => 'Ajouter des photos';

  @override
  String get imagePickerTitleSingle => 'Ajouter une photo';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Choisissez une option (la galerie permet plusieurs photos) :';

  @override
  String get imagePickerChooseOptionSingle => 'Choisissez une option :';

  @override
  String get imagePickerGalleryMultiple => 'Sélectionner depuis la galerie';

  @override
  String get imagePickerGallerySingle => 'Choisir depuis la galerie';

  @override
  String get imagePickerTakePhoto => 'Prendre une photo';

  @override
  String get audioPickerTitleMultiple => 'Ajouter des audios';

  @override
  String get audioPickerTitleSingle => 'Ajouter un audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Choisissez une option (les fichiers permettent plusieurs audios) :';

  @override
  String get audioPickerChooseOptionSingle => 'Choisissez une option :';

  @override
  String get audioPickerSelectFilesMultiple =>
      'Sélectionner des fichiers audio';

  @override
  String get audioPickerSelectFilesSingle => 'Choisir un fichier audio';

  @override
  String get audioPickerRecord => 'Enregistrer un audio';

  @override
  String get videoPickerTitleMultiple => 'Ajouter des vidéos';

  @override
  String get videoPickerTitleSingle => 'Ajouter une vidéo';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Choisissez une option (les fichiers permettent plusieurs vidéos) :';

  @override
  String get videoPickerChooseOptionSingle => 'Choisissez une option :';

  @override
  String get videoPickerSelectFilesMultiple =>
      'Sélectionner des fichiers vidéo';

  @override
  String get videoPickerSelectFilesSingle => 'Choisir un fichier vidéo';

  @override
  String get videoPickerRecord => 'Enregistrer une vidéo';

  @override
  String get successVideoAdded => 'Vidéo ajoutée avec succès !';

  @override
  String successVideosAdded(Object count) {
    return '$count vidéos ajoutées avec succès !';
  }

  @override
  String get startRecording => 'Démarrer l\'enregistrement';

  @override
  String get recordingPaused => 'Enregistrement en pause';

  @override
  String get recording => 'Enregistrement...';

  @override
  String get readyToRecord => 'Prêt à enregistrer';

  @override
  String get notificationDialogTitle => 'Planifier une notification';

  @override
  String get notificationDialogPrompt =>
      'Quand souhaitez-vous être notifié de cette entrée ?';

  @override
  String get emailAlreadyRegistered => 'E-mail déjà enregistré.';

  @override
  String get successNotificationScheduled =>
      'Notification planifiée avec succès';

  @override
  String notificationReminderTitle(Object title) {
    return 'Rappel : $title';
  }

  @override
  String get notificationReminderBody => 'Vous avez une entrée planifiée';

  @override
  String get successImageAdded => 'Image ajoutée avec succès !';

  @override
  String successImagesAdded(Object count) {
    return '$count images ajoutées avec succès !';
  }

  @override
  String errorSearch(Object message) {
    return 'Erreur lors de la recherche : $message';
  }

  @override
  String get successStoryRestored => 'Histoire restaurée avec succès';

  @override
  String get successStoryDeletedPermanently =>
      'Histoire supprimée définitivement';

  @override
  String get trashAlreadyEmpty => 'La corbeille est déjà vide';

  @override
  String get successVideoRecorded => 'Vidéo enregistrée avec succès !';

  @override
  String get permissionMicrophoneDenied => 'Permission microphone non accordée';

  @override
  String errorSelectImages(Object message) {
    return 'Erreur lors de la sélection des images : $message';
  }

  @override
  String get successPhotoCaptured => 'Photo capturée avec succès !';

  @override
  String get restoreStoriesTitle => 'Restaurer les histoires';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Voulez-vous restaurer $count histoire(s) sélectionnée(s) ?';
  }

  @override
  String get restoreLabel => 'Restaurer';

  @override
  String get permanentlyDeleteTitle => 'Supprimer définitivement';

  @override
  String get permanentlyDeleteConfirm =>
      'Cette action ne peut pas être annulée. Voulez-vous vraiment supprimer définitivement cette histoire ?';

  @override
  String get permanentlyDeleteLabel => 'Supprimer définitivement';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Voulez-vous supprimer le groupe \"$name\" de vos histoires ?';
  }

  @override
  String get recoverPinTitle => 'Récupérer le PIN';

  @override
  String get recoverPinDescription =>
      'Nous enverrons un code de récupération à votre e-mail enregistré.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get emptyTrashTitle => 'Vider la corbeille';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Voulez-vous supprimer définitivement toutes les $count histoire(s) dans la corbeille ? Cette action ne peut pas être annulée.';
  }

  @override
  String get emptyTrashLabel => 'Vider la corbeille';

  @override
  String errorTakePhoto(Object message) {
    return 'Erreur lors de la prise de photo : $message';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get entryNotifications => 'Notifications d\'entrée';

  @override
  String get entryNotificationsInfo =>
      'Les entrées avec une date au moins 3 heures à l\'avance peuvent avoir des notifications planifiées.';

  @override
  String get backgroundRestrictionsWarningTitle =>
      'Notifications et applications en arrière-plan';

  @override
  String get backgroundRestrictionsWarningDesc =>
      'Certains systèmes endorment agressivement les applications en arrière-plan pour économiser la batterie, ce qui peut bloquer les notifications planifiées de l\'application. Pour assurer un bon fonctionnement, ouvrez les paramètres de l\'application sur votre appareil et :\n• Désactivez \'Suspendre l\'activité de l\'application si inutilisée\' (ou une option similaire).\n• Définissez les restrictions de batterie sur \'Non restreint\' (la consommation de batterie en arrière-plan est négligeable).';

  @override
  String get defaultAdvanceTitle => 'Avance par défaut';

  @override
  String get notificationAdvanceTitle => 'Avance de notification';

  @override
  String get notificationAdvancePrompt =>
      'Combien de temps à l\'avance souhaitez-vous être notifié ?';

  @override
  String get notificationAdvanceDefault => 'Avance par défaut';

  @override
  String get notificationScheduleModeTitle => 'Mode de planification (QA)';

  @override
  String get notificationScheduleModeInexact => 'Inexact (compatible Play)';

  @override
  String get automaticBackup => 'Sauvegarde automatique';

  @override
  String get manageCompleteBackup => 'Gérer la sauvegarde complète';

  @override
  String get backupWithVideosZip => 'Sauvegarde avec vidéos en fichier ZIP';

  @override
  String get backupOnLogoutDescription =>
      'La sauvegarde sera créée lors de la déconnexion';

  @override
  String get automaticBackupInfo =>
      'Lors de la déconnexion, une sauvegarde sera créée et vous pouvez choisir où l\'enregistrer (dossier local, Google Drive, etc.).';

  @override
  String get automaticBackupInfoLocal =>
      'Lors de la déconnexion, une sauvegarde est automatiquement enregistrée localement sur votre appareil. Vous pouvez ensuite l\'exporter vers un stockage cloud si nécessaire.';

  @override
  String get incrementalBackupTitle => 'Dossier de sauvegarde';

  @override
  String get incrementalBackupDescription =>
      'Les histoires sont automatiquement sauvegardées dans ce dossier chaque fois que vous en enregistrez une.';

  @override
  String get incrementalBackupFolderNotSet => 'Dossier non configuré';

  @override
  String get incrementalBackupFolderConfigured => 'Dossier configuré';

  @override
  String get incrementalBackupSelectFolder => 'Sélectionner un dossier';

  @override
  String get incrementalBackupChangeFolder => 'Changer de dossier';

  @override
  String get incrementalBackupChangingFolder =>
      'Copie des fichiers vers le nouveau dossier...';

  @override
  String get incrementalBackupFolderChanged =>
      'Dossier de sauvegarde mis à jour.';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Dossier de sauvegarde non configuré. Les histoires ne seront pas sauvegardées jusqu\'à ce que vous configuriez un dossier dans les Paramètres.';

  @override
  String get incrementalBackupSyncDone => 'Sauvegardé';

  @override
  String get backupSetupTitle => 'Configurer le dossier de sauvegarde';

  @override
  String get backupSetupContent =>
      'Choisissez un dossier où vos histoires seront sauvegardées automatiquement. Cela garantit que vos données sont toujours en sécurité.';

  @override
  String get backupSavedToFolder =>
      'Sauvegarde du fichier dans le dossier configuré...';

  @override
  String get biometricsNotAvailable => 'Non disponible sur cet appareil';

  @override
  String get biometricsDisabled => 'Biométrie désactivée';

  @override
  String get biometricConfiguredInfo =>
      'La biométrie est configurée. Vous pouvez vous connecter avec votre empreinte digitale.';

  @override
  String get biometricAuthFailed => 'Échec de l\'authentification biométrique';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirmez votre identité pour activer la biométrie';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarFormatMonth => 'Mois';

  @override
  String get calendarFormatTwoWeeks => '2 semaines';

  @override
  String get calendarFormatWeek => 'Semaine';

  @override
  String get groupExists => 'Le groupe existe déjà';

  @override
  String get enterGroupName => 'Entrez un nom pour le groupe';

  @override
  String get archivedTitle => 'Archivé';

  @override
  String get toggleToIcons => 'Passer à la vue icônes';

  @override
  String get toggleToCards => 'Passer à la vue cartes';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editTip => 'Modifier - double-tapez';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get close => 'Fermer';

  @override
  String get newStory => 'Nouvelle histoire';

  @override
  String get newStoryHere => 'Nouvelle histoire ici';

  @override
  String get noArchivedStories => 'Aucune histoire archivée.';

  @override
  String get edit => 'Modifier';

  @override
  String previewTitle(Object title) {
    return 'Aperçu - $title';
  }

  @override
  String get archiveLabel => 'Archiver';

  @override
  String get storyArchived => 'Histoire archivée';

  @override
  String get undo => 'Annuler';

  @override
  String get ungroup => 'Dégrouper';

  @override
  String noStoriesInGroup(Object group) {
    return 'Aucune histoire dans le groupe $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Erreur lors de l\'export PDF : $error';
  }

  @override
  String get titleRequired => 'Le titre est requis !';

  @override
  String errorSavingStory(Object error) {
    return 'Erreur lors de l\'enregistrement de l\'histoire : $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Le titre et la description sont requis pour l\'export.';

  @override
  String get exportHistory => 'Exporter l\'histoire';

  @override
  String get exportHistoryPrompt =>
      'Voulez-vous enregistrer avant d\'exporter ou juste prévisualiser ?';

  @override
  String get preview => 'Aperçu';

  @override
  String get saveAndExport => 'Enregistrer et exporter';

  @override
  String get untitled => 'Sans titre';

  @override
  String errorLoadingFile(Object error) {
    return 'Erreur lors du chargement du fichier : $error';
  }

  @override
  String get discard => 'Ignorer';

  @override
  String get discardStoryTitle => 'Ignorer l\'histoire ?';

  @override
  String get unsavedStoryPrompt =>
      'Vous avez une nouvelle histoire non enregistrée. Partir sans enregistrer ?';

  @override
  String get changeDateTooltip => 'Changer la date';

  @override
  String get storyTitleLabel => 'Titre';

  @override
  String get storyTitleHint => 'Entrez le titre';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Écrivez votre histoire...';

  @override
  String get tagsLabel => 'Étiquettes';

  @override
  String get photosSection => 'Photos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Vidéos';

  @override
  String get importTxtTooltip => 'Importer .txt';

  @override
  String get expandTooltip => 'Développer';

  @override
  String get photoTooltip => 'Photo';

  @override
  String get videoTooltip => 'Vidéo';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Modifier la description';

  @override
  String get editStory => 'Modifier l\'histoire';

  @override
  String get discardChangesTitle => 'Ignorer les modifications ?';

  @override
  String get discardChangesPrompt =>
      'Vous avez des modifications non enregistrées. Partir sans enregistrer ?';

  @override
  String get archivedStateLabel => 'Archivé';

  @override
  String get archivedStoryPrefixLabel => 'Archivée';

  @override
  String get archiveSubtitle => 'Masquer de l\'écran d\'accueil';

  @override
  String get chooseEmoji => 'Choisir un emoji';

  @override
  String get emojiGroupSentimentos => 'Sentiments';

  @override
  String get emojiGroupAnimais => 'Animaux';

  @override
  String get emojiGroupVegetais => 'Plantes';

  @override
  String get emojiGroupCeu => 'Ciel';

  @override
  String get emojiGroupObjetos => 'Objets';

  @override
  String get emojiGroupAlimentos => 'Nourriture';

  @override
  String get emojiGroupLugares => 'Lieux';

  @override
  String get emojiGroupSimbolos => 'Symboles';

  @override
  String get moodQuestion =>
      'Comment vous êtes-vous senti dans cette histoire ?';

  @override
  String get moodVeryDifficult => 'Très difficile';

  @override
  String get moodDifficult => 'Difficile';

  @override
  String get moodNeutral => 'Neutre';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodVeryGood => 'Très bien';

  @override
  String get energyQuestion => 'Comment était votre énergie ?';

  @override
  String get energyLow => 'Basse';

  @override
  String get energyNormal => 'Normale';

  @override
  String get energyHigh => 'Haute';

  @override
  String get tagsHint => 'Tapez et appuyez sur Entrée ou virgule';

  @override
  String get addTag => 'Ajouter une étiquette';

  @override
  String get tagLongPressHint => 'Appui long pour renommer';

  @override
  String get renameTagTitle => 'Renommer l\'étiquette';

  @override
  String get renameTagWarning =>
      'Le renommage affectera toutes les histoires qui utilisent cette étiquette.';

  @override
  String get tagNameLabel => 'Nom de l\'étiquette';

  @override
  String get insightDiscovery => 'Découverte';

  @override
  String get insightPattern => 'Modèle trouvé';

  @override
  String get insightTrend => '📈 Tendance';

  @override
  String get insightMonthlySummary => '📊 Votre mois en histoires';

  @override
  String insightBestWeekday(String weekday) {
    return '$weekday est généralement votre journée la plus positive.';
  }

  @override
  String insightPositiveTag(String tag) {
    return 'Les histoires étiquetées #$tag ont tendance à avoir une meilleure humeur.';
  }

  @override
  String get insightTrendPositive =>
      'Votre humeur s\'est améliorée au cours des 7 derniers jours par rapport aux 30 derniers jours.';

  @override
  String insightMonthlySummaryText(int entries, String mood, String energy) {
    return 'Entrées : $entries\nHumeur moy. : $mood\nÉnergie moy. : $energy';
  }

  @override
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  ) {
    return 'Entrées : $entries\nHumeur moy. : $mood\nÉnergie moy. : $energy\nÉtiquette principale : #$tag';
  }

  @override
  String get insightSeeStories => 'Voir les histoires';

  @override
  String get weekdaySunday => 'Dimanche';

  @override
  String get weekdayMonday => 'Lundi';

  @override
  String get weekdayTuesday => 'Mardi';

  @override
  String get weekdayWednesday => 'Mercredi';

  @override
  String get weekdayThursday => 'Jeudi';

  @override
  String get weekdayFriday => 'Vendredi';

  @override
  String get weekdaySaturday => 'Samedi';

  @override
  String get insightDismiss => 'Ignorer';

  @override
  String get insightStoryBalanceTitle => 'Équilibre des histoires';

  @override
  String get insightStoryBalancePositive =>
      'Vous avez enregistré plus d\'histoires positives au cours des 10 derniers jours. Continuez ainsi !';

  @override
  String get insightStoryBalanceDifficult =>
      'Vous avez enregistré plus d\'histoires difficiles au cours des 10 derniers jours. Prenez soin de vous !';

  @override
  String get insightWritingTimeTitle => 'Heure d\'écriture';

  @override
  String get insightWritingTimeMorning =>
      'Vous avez plus écrit le matin cette semaine.';

  @override
  String get insightWritingTimeAfternoon =>
      'Vous avez plus écrit l\'après-midi cette semaine.';

  @override
  String get insightWritingTimeNight =>
      'Vous avez plus écrit la nuit cette semaine.';

  @override
  String get insightEnergyChartTitle => 'Énergie — 7 derniers jours';

  @override
  String get insightEnergyChartSubtitle =>
      'Votre tendance énergétique cette semaine';

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
  String get insightWellnessCircleTitle => 'Wellness Circle';

  @override
  String insightWellnessCircleDescription(String names) {
    return 'People who are present on your most radiant days: $names.';
  }

  @override
  String get insightPeacefulPlacesTitle => 'Peaceful Places';

  @override
  String insightPeacefulPlacesDescription(String places) {
    return 'Where your mood stays more positive: $places.';
  }

  @override
  String get insightBreatheDeepTitle => 'Take a Deep Breath';

  @override
  String insightBreatheDeepDescription(String places) {
    return 'Where your energy and mood are low: $places.';
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
      'C\'est une fonctionnalité Premium. Passez à la version supérieure pour débloquer cet aperçu.';

  @override
  String get insightPremiumCTA => 'Mettre à niveau';

  @override
  String get insightDevModeActive =>
      'Mode développeur : tous les aperçus visibles';

  @override
  String get backupProgressCreating => 'Création du fichier de sauvegarde...';

  @override
  String get backupProgressCopyingDb => 'Copie de la base de données...';

  @override
  String get backupProgressCopyingVideos => 'Copie des vidéos...';

  @override
  String backupProgressCopyingVideo(int current, int total) {
    return 'Copie de la vidéo $current/$total...';
  }

  @override
  String get backupProgressCopyingPhotos => 'Copie des photos...';

  @override
  String backupProgressCopyingPhoto(int current, int total) {
    return 'Copie de la photo $current/$total...';
  }

  @override
  String get backupProgressCopyingAudios => 'Copie des audios...';

  @override
  String backupProgressCopyingAudio(int current, int total) {
    return 'Copie de l\'audio $current/$total...';
  }

  @override
  String get backupProgressCreatingMetadata => 'Création des métadonnées...';

  @override
  String get backupProgressCompressing => 'Compression des fichiers...';

  @override
  String get backupProgressSuccess => 'Sauvegarde créée avec succès !';

  @override
  String get backupShareText =>
      'Sauvegarde complète DayApp avec base de données et vidéos';

  @override
  String get errorBackupDbNotFound => 'Base de données introuvable.';

  @override
  String get errorBackupFileNotFound => 'Fichier de sauvegarde introuvable.';

  @override
  String errorBackupDbNotFoundInFile(int count) {
    return 'Base de données introuvable dans le fichier de sauvegarde. Fichiers extraits : $count';
  }

  @override
  String get restoreProgressExtracting =>
      'Extraction du fichier de sauvegarde...';

  @override
  String restoreProgressZipContains(int count) {
    return 'Le ZIP contient $count fichiers...';
  }

  @override
  String get restoreProgressBackingUpCurrent =>
      'Sauvegarde de la base de données actuelle...';

  @override
  String get restoreProgressClosingDb =>
      'Fermeture des connexions à la base de données...';

  @override
  String get restoreProgressRestoringDb =>
      'Restauration de la base de données...';

  @override
  String get restoreProgressCopyingRestoredDb =>
      'Copie de la base de données restaurée...';

  @override
  String get restoreProgressRestoringVideos => 'Restauration des vidéos...';

  @override
  String restoreProgressRestoringVideo(int current, int total) {
    return 'Restauration de la vidéo $current/$total...';
  }

  @override
  String get restoreProgressRestoringPhotos => 'Restauration des photos...';

  @override
  String restoreProgressRestoringPhoto(int current, int total) {
    return 'Restauration de la photo $current/$total...';
  }

  @override
  String get restoreProgressRestoringAudios => 'Restauration des audios...';

  @override
  String restoreProgressRestoringAudio(int current, int total) {
    return 'Restauration de l\'audio $current/$total...';
  }

  @override
  String get restoreProgressReinitializingDb =>
      'Réinitialisation de la base de données...';

  @override
  String restoreProgressDbStats(int active, int deleted) {
    return 'Base de données restaurée : $active actives, $deleted dans la corbeille.';
  }

  @override
  String get resendCodeButton => 'Renvoyer le code';

  @override
  String codeExpiresIn(int minutes) {
    return 'Le code expire dans $minutes minutes';
  }

  @override
  String get backToStart => 'Retour au début';

  @override
  String get code => 'Code';

  @override
  String get pin => 'PIN';

  @override
  String get enterCode => 'Entrer le code';

  @override
  String get codeCheckDescription =>
      'Entrez le code à 6 chiffres qui a été envoyé à votre e-mail.';

  @override
  String get defineNewPin =>
      'Définissez un nouveau PIN sécurisé pour votre compte.';

  @override
  String get sendCodeButton => 'Envoyer le code';

  @override
  String get verifyCode => 'Vérifier le code';

  @override
  String get resetPin => 'Réinitialiser le PIN';

  @override
  String get storyPreviewMoodVeryDifficultNarrative =>
      'C\'était une histoire très difficile';

  @override
  String get storyPreviewMoodDifficultNarrative =>
      'C\'était une histoire difficile';

  @override
  String get storyPreviewMoodNeutralNarrative =>
      'C\'était neutre en termes de ressenti';

  @override
  String get storyPreviewMoodGoodNarrative => 'Une bonne histoire';

  @override
  String get storyPreviewMoodVeryGoodNarrative => 'Une très bonne histoire';

  @override
  String get storyPreviewEnergyLowNarrative => 'J\'avais peu d\'énergie';

  @override
  String get storyPreviewEnergyNormalNarrative => 'Mon énergie était normale';

  @override
  String get storyPreviewEnergyHighNarrative =>
      'J\'étais avec une énergie bien élevée';

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
  String get premiumFeature => 'Fonctionnalité Premium';

  @override
  String get premiumFeatureInfo =>
      'This feature is available in the Premium version.';

  @override
  String get freePlan => 'Gratuit';

  @override
  String get currentPlan => 'Plan actuel';

  @override
  String get premiumDebugTitle => 'Débogage Premium';

  @override
  String get premiumDebugSubtitle =>
      'Développement uniquement — non visible en production';

  @override
  String get premiumDebugActivate => 'Activer Premium (débogage)';

  @override
  String get premiumDebugDeactivate =>
      'Désactiver Premium (retourner à Gratuit)';

  @override
  String premiumDebugStatus(String plan) {
    return 'Statut : $plan';
  }

  @override
  String premiumDebugSource(String source) {
    return 'Source : $source';
  }

  @override
  String get premiumDebugWarning =>
      'Cet écran est uniquement disponible dans les versions de débogage. Il n\'apparaîtra pas en production.';

  @override
  String get premiumDebugFeatures => 'Fonctionnalités contrôlées par le plan';

  @override
  String get premiumDebugNoSource => 'aucun';

  @override
  String get autoBackupPremiumRequired =>
      'Les sauvegardes automatiques sont une fonctionnalité Premium. Mettez à niveau pour accéder aux sauvegardes enregistrées, aux points de restauration et à la gestion du stockage.';

  @override
  String autoBackupStorageInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sauvegardes · $size',
      one: '1 sauvegarde · $size',
      zero: 'Aucune sauvegarde enregistrée',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Chapitres';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsSubtitle =>
      'Vos moments organisés en chapitres et groupes, comme une bibliothèque de vie.';

  @override
  String get groupsTabLabel => 'Groupes';

  @override
  String get chapterShortcutToggle =>
      'Afficher/masquer la carte des chapitres sur l\'accueil';

  @override
  String get chaptersHomeCardTitle => 'Votre vie par chapitres';

  @override
  String get chaptersHomeCardSubtitle =>
      'Vos histoires gardent des moments. Vos chapitres révèlent le parcours.';

  @override
  String get chaptersPremiumRequired =>
      'Les chapitres et les suggestions automatiques sont des fonctionnalités Premium.';

  @override
  String get themePremiumRequired =>
      'Les thèmes personnalisés sont une fonctionnalité Premium.';

  @override
  String get chapterSuggestions => 'Chapitres suggérés';

  @override
  String get chapterCreated => 'Chapitre créé avec succès.';

  @override
  String get chapterEditTitle => 'Modifier le chapitre';

  @override
  String get chapterDescriptionHint =>
      'Entrez une description pour ce chapitre (facultatif)';

  @override
  String get chapterUpdated => 'Chapitre mis à jour avec succès.';

  @override
  String get chapterDeleteConfirmTitle => 'Supprimer le chapitre';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return 'Supprimer le chapitre “$title” ? Les histoires liées ne seront pas supprimées.';
  }

  @override
  String get chapterDeleted => 'Chapitre supprimé avec succès.';

  @override
  String get chapterCreateManual => 'Créer un chapitre manuellement';

  @override
  String get chapterCreateTitle => 'Créer un Chapitre';

  @override
  String get chapterTitle => 'Titre';

  @override
  String get chapterTitleHint => 'Ex : Changement d\'emploi';

  @override
  String get chapterDescription => 'Description';

  @override
  String get chapterPhoto => 'Photo du chapitre';

  @override
  String get chapterPhotoActionLabel => 'Photo du Chapitre';

  @override
  String get chapterAddPhoto => 'Ajouter une photo';

  @override
  String get chapterChangePhoto => 'Changer la photo';

  @override
  String get chapterRemovePhoto => 'Supprimer la photo';

  @override
  String get chapterSelectEntries => 'Sélectionner au moins 1 histoire liée';

  @override
  String get chapterMinimumEntries => 'Minimum : 1 histoire par chapitre.';

  @override
  String get groupSelectStories =>
      'Sélectionnez au moins 1 histoire pour ce groupe';

  @override
  String get groupMinimumStories => 'Minimum : 1 histoire par groupe.';

  @override
  String chapterPeriod(String start, String end) {
    return 'Histoires du $start - $end';
  }

  @override
  String chapterEntriesCount(int count) {
    return 'Histoires : $count';
  }

  @override
  String chapterAverageMood(String mood) {
    return 'Humeur moyenne : $mood';
  }

  @override
  String chapterTopTags(String tags) {
    return 'Étiquettes principales : $tags';
  }

  @override
  String get chapterCreateFromSuggestion => 'Créer un chapitre';

  @override
  String get chapterViewSuggestions => 'Voir les suggestions';

  @override
  String get chapterCreateMyLabel => 'Créer mon Chapitre';

  @override
  String get chapterIgnoreLabel => 'Ignorer';

  @override
  String chapterSuggestionMoreStories(int count) {
    return 'et $count autre(s) histoire(s)';
  }

  @override
  String get chapterNoItems => 'Votre prochain chapitre commence ici.';

  @override
  String get chapterFilterAll => 'Tous';

  @override
  String get chapterFilterAutomatic => 'Automatiques';

  @override
  String get chapterFilterManual => 'Manuels';

  @override
  String get chapterNoSearchResults =>
      'Aucun chapitre ne correspond aux filtres actuels.';

  @override
  String get chapterSortLabel => 'Trier par';

  @override
  String get chapterSortNewest => 'Période la plus récente';

  @override
  String get chapterSortOldest => 'Période la plus ancienne';

  @override
  String get chapterSortTitle => 'Titre';

  @override
  String get chapterSortStories => 'Plus d\'histoires';

  @override
  String chapterEntriesAndMood(int count, String mood) {
    return '$count histoires - humeur moy. $mood';
  }

  @override
  String get chapterOpenLabel => 'Ouvrir';

  @override
  String get chapterIntroSubtitle =>
      'Organisez vos histoires de façon significative et revivez vos souvenirs dans l\'ordre';

  @override
  String get chapterIntroGroupTitle => 'Rassemblez les moments connectés';

  @override
  String get chapterIntroGroupBody =>
      'Regroupez plusieurs publications dans un chapitre unique pour suivre toute la trajectoire d\'un thème ou d\'un moment spécial.';

  @override
  String get chapterIntroTimelineTitle =>
      'Revivez votre histoire du début à la fin';

  @override
  String get chapterIntroTimelineBody =>
      'Parcourez les souvenirs dans l\'ordre chronologique et voyez comment chaque moment a évolué au fil du temps.';

  @override
  String get chapterIntroPhaseTitle => 'Un chapitre pour chaque phase';

  @override
  String get chapterIntroPhaseBody =>
      'Voyages, études, famille, travail, rêves, objectifs ou souvenirs spéciaux. C\'est vous qui décidez comment raconter votre histoire.';

  @override
  String get chapterIntroCtaTitle => 'Prêt à organiser vos souvenirs ?';

  @override
  String get chapterIntroCtaBody =>
      'Commencez par créer votre premier chapitre maintenant';

  @override
  String get chapterIntroShowOnOpen =>
      'Afficher cet écran lors de l\'ouverture des chapitres';

  @override
  String get chapterLinkSectionTitle => 'Chapitres';

  @override
  String get chapterLinkConfigure => 'Configurer';

  @override
  String get chapterLinkDialogTitle => 'Ajouter cette histoire aux chapitres';

  @override
  String get chapterLinkModeNone => 'Ne pas ajouter';

  @override
  String get chapterLinkModeExisting => 'Ajouter à un chapitre existant';

  @override
  String get chapterLinkModeNew => 'Créer un nouveau chapitre';

  @override
  String get chapterSelectExistingLabel => 'Sélectionner un chapitre';

  @override
  String get chapterSelectExistingRequired =>
      'Sélectionnez un chapitre existant.';

  @override
  String get chapterTitleRequired => 'Le titre du chapitre est requis.';

  @override
  String get chapterMinimumRelatedWithCurrent =>
      'Sélectionnez au moins 2 histoires liées. Avec la courante, le minimum est 3.';

  @override
  String get chapterLinkSummaryNone => 'Non lié à un chapitre.';

  @override
  String get chapterLinkSummaryExisting =>
      'Sera ajouté à un chapitre existant lors de l\'enregistrement.';

  @override
  String chapterLinkSummaryNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nouveau chapitre avec $count histoires',
      one: 'Nouveau chapitre avec 1 histoire',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get homeHeaderLargeCards => 'Afficher en grandes cartes';

  @override
  String get homeHeaderCompactCards => 'Afficher en cartes compactes';

  @override
  String get homeHeaderOpenCalendarTooltip => 'Ouvrir le calendrier';

  @override
  String get homeGreetingMorning => 'Bonjour';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi';

  @override
  String get homeGreetingEvening => 'Bonsoir';

  @override
  String get homeStoriesSubtitle => 'Voici vos histoires';

  @override
  String get homeShowAllStoriesLabel => 'Voir tout';

  @override
  String get insightHistoryTitle => 'Historique des aperçus';

  @override
  String get insightHistoryEmpty => 'Aucun aperçu enregistré pour l\'instant.';

  @override
  String get insightHistoryClearAll => 'Effacer l\'historique';

  @override
  String get insightHistoryClearConfirm =>
      'Effacer tout l\'historique des aperçus ? Cette action ne peut pas être annulée.';

  @override
  String insightHistorySeenOn(String date) {
    return 'Vu le $date';
  }

  @override
  String get insightHistoryFilterAll => 'Tous';

  @override
  String get insightHistoryFilterFree => 'Gratuit';

  @override
  String get insightHistoryFilterPremium => 'Premium';

  @override
  String get insightHistorySearch => 'Rechercher des aperçus';

  @override
  String get pdfBackgroundColor => 'Couleur de fond';

  @override
  String get pdfBackgroundNone => 'Aucun';

  @override
  String get pdfBackgroundBeige => 'Beige/crème';

  @override
  String get pdfBackgroundBlue => 'Bleu pâle';

  @override
  String get pdfBackgroundGreen => 'Vert pâle';

  @override
  String get pdfBackgroundGray => 'Gris clair';

  @override
  String get exportPdfPremiumRequired =>
      'L\'exportation de Chapitre est une fonctionnalité Premium. Mettez à niveau votre plan pour y accéder.';

  @override
  String get changeEmail => 'Changer l\'e-mail';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get wrongCurrentPassword => 'Le mot de passe actuel est incorrect.';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès.';

  @override
  String get emailChangedSuccess => 'E-mail modifié avec succès.';

  @override
  String get newPasswordMinLength =>
      'Le nouveau mot de passe doit comporter au moins 6 caractères.';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get backupInfoDialogTitle => 'À propos de la sauvegarde';

  @override
  String get backupInfoDialogContent =>
      '📦  Ce qui est inclus dans la sauvegarde\n• Toutes vos histoires (textes, photos, audios, vidéos)\n• Base de données de l\'application\n• Photos de chapitres\n\n📂  Comment stocker votre sauvegarde\nAprès la création, utilisez le menu de partage pour enregistrer le fichier où vous le souhaitez — OneDrive, Google Drive, e-mail ou tout autre service.';

  @override
  String get backupPasswordDialogTitle => 'Protégez votre sauvegarde';

  @override
  String get backupPasswordDescription =>
      'Définissez un mot de passe pour chiffrer votre fichier de sauvegarde. Le contenu sera protégé et illisible pour quiconque ne possède pas ce mot de passe.';

  @override
  String get backupPasswordWarningTitle =>
      '⚠️  Important — lisez avant de continuer';

  @override
  String get backupPasswordWarning =>
      'Ce mot de passe n\'est connu que de vous. Il n\'est stocké nulle part dans l\'application ni sur nos serveurs.\n\nSi vous l\'oubliez, le fichier de sauvegarde sera définitivement inaccessible — même notre équipe ne pourra pas vous aider à récupérer les données.\n\nStockez ce mot de passe dans un endroit sûr avant de continuer.';

  @override
  String get backupPasswordField => 'Mot de passe';

  @override
  String get backupPasswordConfirmField => 'Confirmer le mot de passe';

  @override
  String get backupPasswordMismatch =>
      'Les mots de passe ne correspondent pas. Veuillez réessayer.';

  @override
  String get backupPasswordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères.';

  @override
  String get backupPasswordEmpty => 'Veuillez entrer un mot de passe.';

  @override
  String get backupCreateEncrypted => 'Créer une sauvegarde chiffrée';

  @override
  String get restorePasswordDialogTitle =>
      'Entrez le mot de passe de sauvegarde';

  @override
  String get restorePasswordDescription =>
      'Si vous avez défini un mot de passe lors de la création de cette sauvegarde, entrez-le ci-dessous.\n\nSi la sauvegarde a été créée sans mot de passe, laissez le champ vide.';

  @override
  String get restorePasswordField =>
      'Mot de passe (laissez vide si aucun n\'a été défini)';

  @override
  String get restorePasswordWrong =>
      'Mot de passe incorrect ou sauvegarde illisible. Vérifiez le mot de passe et réessayez.';

  @override
  String get restoreContinue => 'Continuer';

  @override
  String get chapterExportPhotoSelectionTitle =>
      'Choisir les photos pour l\'export';

  @override
  String get chapterExportPhotoSelectionSubtitle =>
      'Vous pouvez sélectionner jusqu\'à 1 photo par histoire. Vous pouvez aussi ne sélectionner aucune photo.';

  @override
  String get chapterExportNoPhotoOption => 'Sans photo';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String codeExpiresMinutes(int count) {
    return 'Le code expire dans $count minutes';
  }

  @override
  String get codeLabel => 'Code';

  @override
  String get informRegisteredEmail => 'Entrez votre e-mail enregistré';

  @override
  String get newPasswordMinLengthLabel =>
      'Nouveau mot de passe (minimum 6 caractères)';

  @override
  String get confirmNewPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get informYourEmailTitle => 'Entrez votre e-mail';

  @override
  String get enterCodeTitle => 'Entrez le code';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get emailStepSubtitle =>
      'Nous enverrons un code de récupération à l\'adresse e-mail enregistrée sur votre compte.';

  @override
  String get codeStepSubtitle =>
      'Entrez le code à 6 chiffres qui a été envoyé à votre e-mail.';

  @override
  String get passwordStepSubtitle =>
      'Définissez un nouveau mot de passe sécurisé pour votre compte.';

  @override
  String get sendCodeButtonLabel => 'Envoyer le code';

  @override
  String get verifyCodeButtonLabel => 'Vérifier le code';

  @override
  String get resetPasswordButtonLabel => 'Réinitialiser le mot de passe';

  @override
  String get birthDateCannotBeFuture =>
      'La date de naissance ne peut pas être dans le futur.';

  @override
  String get birthDateMinAge => 'Vous devez avoir au moins 14 ans.';

  @override
  String get successAudioAdded => 'Audio ajouté avec succès !';

  @override
  String get photoDeleted => 'Photo supprimée';

  @override
  String get videoSavedSuccess => 'Vidéo enregistrée avec succès';

  @override
  String get videoPlaybackNotAvailableWindows =>
      'Lecture vidéo non disponible sur Windows';

  @override
  String get supportEmailSubjectLogin => 'Support DayApp - Connexion';

  @override
  String get supportEmailBodyLogin =>
      'Bonjour, j\'ai besoin d\'aide pour me connecter à DayApp...';

  @override
  String successAudiosAdded(int count) {
    return '$count audios ajoutés avec succès !';
  }

  @override
  String sizeLabel(String size) {
    return 'Taille : $size Mo';
  }

  @override
  String durationLabel(String duration) {
    return 'Durée : $duration';
  }

  @override
  String get editDoubleTapHint => 'Modifier - 2 clics';

  @override
  String deleteGroupWarningText(String groupName) {
    return 'Voulez-vous supprimer le groupe \"$groupName\" ? Les histoires de ce groupe ne seront pas supprimées, seulement retirées du groupe.';
  }

  @override
  String createdOn(String date) {
    return 'Créé le $date';
  }

  @override
  String get editorPlaceholder => 'Écrivez ici...';

  @override
  String get aboutFlutterDesc =>
      'Framework pour le développement multiplateforme';

  @override
  String get aboutDartDesc => 'Langage de programmation moderne et efficace';

  @override
  String get aboutSqliteDesc => 'Base de données locale robuste et fiable';

  @override
  String get aboutProviderDesc => 'Gestion de l\'état réactif';

  @override
  String get aboutMaterial3Title => 'Material Design 3';

  @override
  String get aboutMaterial3Desc => 'Design system moderne et accessible';

  @override
  String get aboutScreenTechnologiesTitle => 'Technologies';

  @override
  String get insightMood7Days => 'Humeur — 7 derniers jours';

  @override
  String get insightMoodVariationThisWeek =>
      'Votre variation d\'humeur cette semaine';

  @override
  String chapterExportPartLabel(int index, int total) {
    return 'Partie $index sur $total';
  }

  @override
  String chapterExportSplitExplanation(int parts) {
    return 'Pour garantir de meilleures performances et une meilleure compatibilité lors de l\'envoi, ce chapitre a été divisé en $parts fichiers.';
  }

  @override
  String get chapterTitleDuplicateTitle => 'Titre Dupliqué';

  @override
  String get chapterTitleDuplicateMessage =>
      'Un chapitre avec ce titre existe déjà. Veuillez choisir un autre titre.';

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

  @override
  String get invalidBackupFilenameTitle => 'Nom de fichier invalide';

  @override
  String invalidBackupFilenameMessage(String fileName) {
    return 'Le fichier sélectionné \'$fileName\' n\'est pas un fichier de sauvegarde standard.\n\nVeuillez choisir un fichier de sauvegarde valide.';
  }

  @override
  String get restoreFailedTitle => 'Échec de la restauration';

  @override
  String get restoreFailedMessage =>
      'Le fichier sélectionné n\'est pas une sauvegarde de DayApp. Voulez-vous réessayer ?';

  @override
  String get backupFailedMessage =>
      'Une erreur est survenue lors de la création de la sauvegarde. Voulez-vous réessayer ?';

  @override
  String get pessoasLabel => 'People';

  @override
  String get localLabel => 'Location';

  @override
  String get pessoasHint => 'Type and press Enter or comma';

  @override
  String get localHint => 'Type location';

  @override
  String get addPessoa => 'Add person';

  @override
  String get pessoasSection => 'People';

  @override
  String get localSection => 'Location';

  @override
  String get comQuemTitle => 'Who were you with?';

  @override
  String get ondeTitle => 'Where were you?';

  @override
  String get pessoasTooltip => 'People';

  @override
  String get localTooltip => 'Location';

  @override
  String get pessoaLongPressHint => 'Press and hold to rename';

  @override
  String get renamePessoaTitle => 'Rename person';

  @override
  String get renamePessoaWarning =>
      'Renaming will affect all stories containing this person.';

  @override
  String get pessoaNameLabel => 'Person name';

  @override
  String get moodLabel => 'Mood';

  @override
  String get energyLabel => 'Energy';

  @override
  String get backupFailedTitle => 'Échec de la sauvegarde';

  @override
  String homeGreetingPhrase(String name, String greeting) {
    return 'Bonjour, $name ! $greeting.';
  }

  @override
  String homeGreetingPhraseNoName(String greeting) {
    return 'Bonjour ! $greeting.';
  }

  @override
  String get homeGreetingSubtitle =>
      '\"Comment se passe votre journée ? Enregistrons-la ?\"';

  @override
  String get startNewStoryPlaceholder => 'Commencer une nouvelle histoire...';

  @override
  String get viewAllStoriesLabel => 'Voir toutes les histoires';

  @override
  String get continuaLabel => 'Continue';

  @override
  String get continuaQuestion => 'Cette histoire continue-t-elle ?';

  @override
  String get continuaNo => 'Non';

  @override
  String get continuaDontKnow => 'Je ne sais pas';

  @override
  String get continuaMaybe => 'Peut-être';

  @override
  String get continuaYes => 'Oui';

  @override
  String get continuityHookBadge => '📖 Histoire en cours';

  @override
  String get continuityHookG01 =>
      'En relisant ce que vous avez écrit il y a quelques jours, comment voyez-vous cette situation aujourd\'hui ?';

  @override
  String get continuityHookG02 =>
      'Vous souvenez-vous de l\'épisode que vous avez partagé récemment ? Comment les choses ont-elles évolué depuis ?';

  @override
  String get continuityHookG03 =>
      'Vous avez écrit un récit très bref. Souhaitez-vous essayer d\'en parler davantage ?';

  @override
  String get continuityHookTalvez =>
      'Pensez-vous que cette situation d\'il y a quelques jours est encore en cours ?';

  @override
  String get continuityHookNaoSei =>
      'Comment voyez-vous aujourd\'hui ce que vous avez écrit ce jour-là ?';

  @override
  String get continuityHookBtnContinue => 'Continuer';

  @override
  String get continuityHookBtnOptions => 'Options';

  @override
  String get continuityHookFreeLimitTitle => 'Fonctionnalité exclusive';

  @override
  String get continuityHookFreeLimitBody =>
      'Vous avez déjà utilisé vos 3 histoires gratuites avec suivi de continuité. Passez à Premium et écrivez des récits sans limite.';

  @override
  String get continuityHookDebugSectionTitle => 'Moteur de Crochets (Debug)';

  @override
  String get continuityHookDebugAcceleratorLabel => 'Accélérateur d\'Horloge';

  @override
  String get continuityHookDebugAcceleratorSubtitle =>
      'Ignore les fenêtres de temps de 2/3/4 jours';

  @override
  String get continuityHookDebugResetCounters =>
      'Réinitialiser le compteur Free';

  @override
  String get continuityHookDebugForceReload =>
      'Forcer le rechargement de la carte';

  @override
  String get continuityHookFeatureLabel =>
      'Continuité des Histoires (≤3 Free · Illimité Premium)';

  @override
  String get continuityHookGenericSim =>
      'Il est temps de continuer cette histoire';

  @override
  String get continuityHookGenericTalvez =>
      'Peut-être souhaitez-vous continuer cette histoire';

  @override
  String get continuityHookGenericNaoSei =>
      'Avez-vous décidé si vous souhaitez continuer cette histoire ?';

  @override
  String get continuityStatusClose => 'Fermer';

  @override
  String get continuityInfoTitle => 'Histoires Vivantes';

  @override
  String get continuityInfoDesc =>
      '### Histoires Vivantes : Connectez vos souvenirs\nDans DayApp, vous pouvez connecter vos entrées pour suivre le déroulement d\'un événement sur plusieurs jours. En terminant une note, vous pouvez indiquer si cette situation aura d\'autres développements, peut-être même en générant un nouveau Chapitre.\n### Comment ça marche ?\nLors de l\'enregistrement d\'une nouvelle histoire, nous vous demanderons si vous souhaitez continuer cette histoire plus tard. Si vous sélectionnez Oui, Peut-être ou Je ne sais pas, l\'application affichera des rappels automatiques sur l\'écran d\'accueil après quelques jours. C\'est un rappel pratique pour vous aider à mettre à jour ce qui s\'est passé dans une nouvelle note — qui continue l\'histoire — ou dans l\'entrée originale.\n### Votre moment de réflexion :\nSur l\'écran d\'accueil, vous aurez l\'occasion d\'évaluer le statut de votre entrée :\n- Continuer l\'histoire : Choisissez entre en créer une nouvelle ou modifier l\'histoire originale.\n- Fermer le cycle : Si la situation a été résolue ou si vous ne souhaitez plus la suivre, changez simplement le statut à Non pour la retirer de la file de rappels.';

  @override
  String get continuityHookOptionNewStory => 'Nouvelle histoire';

  @override
  String get continuityHookOptionSameStory => 'Même histoire';
}
