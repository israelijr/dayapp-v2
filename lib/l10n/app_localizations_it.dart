// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get deviceDefault => 'Lingua del dispositivo';

  @override
  String get defaultLabel => 'Predefinito';

  @override
  String get english => 'Inglese';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get french => 'Francese';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portoghese';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get errorInitializingApp =>
      'Errore durante l\'inizializzazione dell\'applicazione';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Sicurezza';

  @override
  String get themeAndScheme => 'Tema e schema';

  @override
  String get themeRelva => 'Erba';

  @override
  String get themeOutono => 'Giardino Botanico';

  @override
  String get themeCeu => 'Cielo';

  @override
  String get themeConfort => 'Comfort';

  @override
  String get themeSunset => 'Tramonto';

  @override
  String get themeMidnightGalaxy => 'Galassia di Mezzanotte';

  @override
  String get themeDefaultLightDescription => 'Tema chiaro predefinito';

  @override
  String get themeDefaultDarkDescription => 'Tema scuro predefinito';

  @override
  String get themeFollowSystemDescription => 'Segui il tema del sistema';

  @override
  String get themeCustomSchemesTitle => 'Schemi personalizzati';

  @override
  String get themeRelvaLight => 'Relva (Chiaro)';

  @override
  String get themeRelvaDark => 'Relva (Scuro)';

  @override
  String get themeOutonoLight => 'Giardino Botanico (Chiaro)';

  @override
  String get themeOutonoDark => 'Giardino Botanico (Scuro)';

  @override
  String get themeRelvaLightDescription => 'Toni verdi e naturali';

  @override
  String get themeRelvaDarkDescription => 'Versione scura dello schema Relva';

  @override
  String get themeOutonoLightDescription =>
      'Toni freschi e organici da giardino';

  @override
  String get themeOutonoDarkDescription =>
      'Versione scura dello schema Giardino Botanico';

  @override
  String get themeRemoveScheme => 'Rimuovi schema';

  @override
  String get themeRemoveSchemeDescription =>
      'Torna allo schema tema predefinito';

  @override
  String get timeAtConnector => 'alle';

  @override
  String get timeAgoNow => 'adesso';

  @override
  String timeAgoMinutes(int count) {
    return '$count min fa';
  }

  @override
  String timeAgoHours(int count) {
    return '${count}h fa';
  }

  @override
  String timeAgoDays(int count) {
    return '$count giorno/i fa';
  }

  @override
  String get backup => 'Backup';

  @override
  String get enabled => 'Abilitato';

  @override
  String get disabled => 'Disabilitato';

  @override
  String get confirm => 'Conferma';

  @override
  String get pinUnlock => 'Sblocco PIN';

  @override
  String get changePin => 'Cambia PIN';

  @override
  String get enableBiometrics => 'Accesso biometrico';

  @override
  String get information => 'Informazioni';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get configurePin => 'Configura PIN';

  @override
  String get biometrics => 'Biometria';

  @override
  String get backgroundLock => 'Blocco in background';

  @override
  String get backgroundLockDialogPrompt =>
      'Dopo quanto tempo in background l\'app dovrebbe bloccarsi?';

  @override
  String get backgroundLockTimeLabel => 'Tempo';

  @override
  String get backgroundLockDialogResult => 'Risultato:';

  @override
  String get backgroundLockSuggestions => 'Suggerimenti:';

  @override
  String get backgroundLockImmediateHint => '0 = immediato';

  @override
  String get backgroundLockNever => 'Non bloccare';

  @override
  String get backgroundLockImmediately => 'Immediatamente';

  @override
  String backgroundLockSeconds(int count) {
    return '$count secondi';
  }

  @override
  String get backgroundLockOneMinute => '1 minuto';

  @override
  String backgroundLockMinutes(int count) {
    return '$count minuti';
  }

  @override
  String get backgroundLockOneHour => '1 ora';

  @override
  String backgroundLockHours(int count) {
    return '$count ore';
  }

  @override
  String get statistics => 'Statistiche';

  @override
  String get noStoriesYetTitle => 'Ancora nessuna storia';

  @override
  String get noStoriesYetSubtitle =>
      'Inizia a registrare le tue giornate per vedere le statistiche';

  @override
  String get trends => 'Tendenze';

  @override
  String get last30Days => 'Ultimi 30 giorni';

  @override
  String get activityByWeekday => 'Attività per giorno della settimana';

  @override
  String get streaksTitle => 'Serie';

  @override
  String get longestStreakPrefix => 'Serie più lunga:';

  @override
  String get tableOfMoods => 'Tabella degli umori';

  @override
  String get moodCount => 'Conteggio umore';

  @override
  String get topTags => 'Tag popolari';

  @override
  String get storiesLabel => 'Storie';

  @override
  String get activeDaysLabel => 'Giorni attivi';

  @override
  String get avgPerDayLabel => 'Media/giorno';

  @override
  String get mediaLabel => 'Media';

  @override
  String get manageGroups => 'Gestisci gruppi';

  @override
  String get trash => 'Cestino';

  @override
  String get help => 'Aiuto';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutScreenAboutDayAppTitle => 'Informazioni su DayApp';

  @override
  String get aboutScreenAboutDayAppDescription =>
      'DayApp è un\'app di diario personale moderna e sicura che ti permette di registrare le tue storie, ricordi e pensieri in modo organizzato e privato. Con un\'interfaccia intuitiva e funzionalità avanzate, DayApp ti aiuta a preservare le tue esperienze più significative.';

  @override
  String get aboutScreenFeaturesTitle => 'Funzionalità';

  @override
  String get aboutScreenFeatureRichEditorTitle => 'Editor ricco';

  @override
  String get aboutScreenFeatureRichEditorDescription =>
      'Crea storie con formattazione avanzata, immagini, video e audio';

  @override
  String get aboutScreenFeatureSmartOrganizationTitle =>
      'Organizzazione intelligente';

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Categorizza le tue storie in gruppi tematici personalizzati';

  @override
  String get aboutScreenFeatureAdvancedSearchTitle => 'Ricerca avanzata';

  @override
  String get aboutScreenFeatureAdvancedSearchDescription =>
      'Trova rapidamente qualsiasi storia per contenuto o data';

  @override
  String get aboutScreenFeatureSecureBackupTitle => 'Backup sicuro';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Proteggi i tuoi dati con backup automatici e manuali';

  @override
  String get aboutScreenFeatureTotalPrivacyTitle => 'Privacy totale';

  @override
  String get aboutScreenFeatureTotalPrivacyDescription =>
      'I tuoi dati sono archiviati localmente e crittografati';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceTitle => 'Interfaccia adattiva';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceDescription =>
      'Temi chiari e scuri con layout personalizzabili';

  @override
  String get aboutScreenVersionTitle => 'Versione';

  @override
  String aboutScreenVersionBuild(String version, String build) {
    return 'Versione $version (Build $build)';
  }

  @override
  String aboutScreenVersionShort(String version) {
    return 'Versione $version';
  }

  @override
  String get aboutScreenDevelopmentTitle => 'Sviluppo';

  @override
  String get aboutScreenDevelopmentDescription =>
      'Costruito con cura per offrire la migliore esperienza nella registrazione di ricordi personali.';

  @override
  String get aboutScreenPrivacySecurityTitle => 'Privacy e sicurezza';

  @override
  String get aboutScreenPrivacyLocalDataTitle => 'Dati locali';

  @override
  String get aboutScreenPrivacyLocalDataDescription =>
      'Tutte le tue storie sono archiviate solo sul tuo dispositivo';

  @override
  String get aboutScreenPrivacyEncryptionTitle => 'Crittografia';

  @override
  String get aboutScreenPrivacyEncryptionDescription =>
      'Il contenuto sensibile è protetto con crittografia avanzata';

  @override
  String get aboutScreenPrivacyNoTrackingTitle => 'Nessun tracciamento';

  @override
  String get aboutScreenPrivacyNoTrackingDescription =>
      'Non raccogliamo dati personali né monitoriamo il tuo utilizzo';

  @override
  String get aboutScreenPrivacyPinSecurityTitle => 'PIN di sicurezza';

  @override
  String get aboutScreenPrivacyPinSecurityDescription =>
      'Proteggi l\'accesso all\'app con PIN o dati biometrici';

  @override
  String get aboutScreenContactSupportTitle => 'Contatto e supporto';

  @override
  String get aboutScreenContactSupportDescription =>
      'Per domande, suggerimenti o supporto tecnico:';

  @override
  String get aboutScreenSupportEmailSubject => 'Supporto DayApp';

  @override
  String aboutScreenSupportEmailBody(String version) {
    return 'Ciao, ho bisogno di aiuto con DayApp...\n\nVersione: $version\n';
  }

  @override
  String get aboutScreenAcknowledgementsTitle => 'Ringraziamenti';

  @override
  String get aboutScreenAcknowledgementsDescription =>
      'Grazie per aver scelto DayApp per registrare i tuoi ricordi più preziosi. La tua fiducia e i tuoi feedback sono essenziali per continuare a migliorare.';

  @override
  String get aboutScreenHeaderSubtitle => 'Il tuo diario personale';

  @override
  String get aboutScreenCopyright =>
      '© 2026 DayApp. Tutti i diritti riservati.';

  @override
  String get logout => 'Disconnetti';

  @override
  String get createAccount => 'Crea account';

  @override
  String get name => 'Nome';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get createAccountButton => 'Crea account';

  @override
  String get alreadyHaveAccount => 'Hai già un account? Accedi';

  @override
  String get needHelp => 'Hai bisogno di aiuto?';

  @override
  String get currentPinLabel => 'PIN attuale';

  @override
  String get newPinLabel => 'Nuovo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get enterCurrentPin => 'Inserisci il PIN attuale';

  @override
  String get enterPin => 'Inserisci il PIN';

  @override
  String get pinLengthError => 'Il PIN deve essere composto da 4 a 8 cifre';

  @override
  String get pinsDoNotMatch => 'I PIN non corrispondono';

  @override
  String get pinIncorrect => 'PIN attuale errato';

  @override
  String get pinChangedSuccess => 'PIN modificato con successo!';

  @override
  String get pinConfiguredSuccess => 'PIN configurato con successo!';

  @override
  String get informYourEmail => 'Inserisci la tua e-mail.';

  @override
  String get invalidEmail => 'Inserisci un\'e-mail valida.';

  @override
  String get emailNotFound => 'E-mail non trovata. Controlla e riprova.';

  @override
  String codeSent(Object email) {
    return 'Codice inviato a $email! Controlla la tua casella.';
  }

  @override
  String get codeMustBe6 => 'Il codice deve essere di 6 cifre.';

  @override
  String get codeVerified =>
      'Codice verificato! Imposta la tua nuova password.';

  @override
  String get codeInvalid => 'Codice non valido o scaduto. Riprova.';

  @override
  String get enterNewPassword => 'Inserisci la nuova password.';

  @override
  String get passwordResetSuccess =>
      'Password reimpostata con successo! Accedi con la nuova password.';

  @override
  String get errorResetPassword =>
      'Errore durante la reimpostazione della password. Riprova.';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono.';

  @override
  String get resendCodeSuccess =>
      'Nuovo codice inviato! Controlla la tua casella.';

  @override
  String get resendCodeError =>
      'Errore durante il reinvio del codice. Riprova.';

  @override
  String get passwordMinLength =>
      'La password deve essere di almeno 6 caratteri.';

  @override
  String get unlock => 'Sblocca';

  @override
  String get fullName => 'Nome completo';

  @override
  String get birthDate => 'Data di nascita';

  @override
  String get almostReady => 'quasi pronto...';

  @override
  String get optionalData => 'I campi seguenti sono facoltativi';

  @override
  String get birthDateFormat => 'Data di nascita (GG/MM/AAAA)';

  @override
  String get invalidBirthDate => 'Data di nascita non valida (usa GG/MM/AAAA)';

  @override
  String get userNotFound => 'Utente non trovato.';

  @override
  String get create => 'Crea';

  @override
  String get nameRequired => 'Il nome è obbligatorio';

  @override
  String get nameMinLength => 'Il nome deve essere di almeno 2 caratteri';

  @override
  String get emailRequired => 'L\'e-mail è obbligatoria';

  @override
  String get emailInvalid => 'Inserisci un\'e-mail valida';

  @override
  String get welcomeBack => 'Bentornato!';

  @override
  String get accessAccount => 'Accedi al tuo account';

  @override
  String get enterPassword => 'Inserisci la tua password';

  @override
  String get signIn => 'Accedi';

  @override
  String get forgotPassword => 'Password dimenticata';

  @override
  String get noAccountCreateHere => 'Non hai un account? Creane uno qui.';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get biometricsEnabledSuccess => 'Biometria abilitata con successo!';

  @override
  String get biometricLoginError => 'Errore durante l\'accesso biometrico.';

  @override
  String get invalidCredentials => 'E-mail o password non valide.';

  @override
  String get profileUpdatedSuccess => 'Profilo aggiornato con successo!';

  @override
  String get profileUpdateError =>
      'Errore durante l\'aggiornamento del profilo. Riprova.';

  @override
  String get unlockAppReason => 'Sblocca l\'app per continuare';

  @override
  String get fillEmailAndPassword => 'Compila e-mail e password';

  @override
  String get emailOrPasswordIncorrect => 'E-mail o password errate';

  @override
  String get noEmailRegistered =>
      'Nessuna e-mail registrata. Configurala nelle impostazioni.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Controlla la tua e-mail a $email o usa il codice mostrato';
  }

  @override
  String get errorGeneratingCode =>
      'Errore durante la generazione del codice. Riprova.';

  @override
  String get errorSendingCode => 'Errore durante l\'invio del codice. Riprova.';

  @override
  String get enterRecoveryCodePrompt =>
      'Inserisci il codice inviato alla tua e-mail:';

  @override
  String get recoveryCodeLabel => 'Codice di recupero (6 cifre)';

  @override
  String get enterPasswordToContinue =>
      'Inserisci la tua password per continuare';

  @override
  String get enterPinToContinue => 'Inserisci il tuo PIN per continuare';

  @override
  String get useBiometricsToContinue =>
      'Usa i tuoi dati biometrici per continuare';

  @override
  String get usePin => 'Usa PIN';

  @override
  String get noStoriesHere => 'Nessuna storia da visualizzare qui.';

  @override
  String get storiesGroupedOrArchived => 'Sono raggruppate o archiviate.';

  @override
  String get useBiometrics => 'Usa biometria';

  @override
  String get unlockWithBiometrics => 'Sblocca con biometria';

  @override
  String get useAccountPassword => 'Usa la password dell\'account';

  @override
  String get forgotPin => 'PIN dimenticato';

  @override
  String get unlockTitle => 'Sblocca l\'app';

  @override
  String get search => 'Cerca';

  @override
  String get searchStoriesTitle => 'Cerca le tue storie';

  @override
  String get searchStoriesSubtitle =>
      'Usa i filtri sopra per trovare i tuoi ricordi.';

  @override
  String unsavedBackups(Object count) {
    return 'Hai $count storia/e senza backup.';
  }

  @override
  String get backupRecommendation =>
      'Consigliamo di eseguire un backup per evitare la perdita di dati.';

  @override
  String get cancel => 'Annulla';

  @override
  String get restore => 'Ripristina';

  @override
  String get delete => 'Elimina';

  @override
  String get deleted => 'Eliminato';

  @override
  String get performBackup => 'Esegui backup ora';

  @override
  String get deleteStoryTitle => 'Elimina storia';

  @override
  String get deleteStoryConfirm => 'Vuoi spostare questa storia nel cestino?';

  @override
  String get deleteLabel => 'Elimina';

  @override
  String get movedToTrash => 'Storia spostata nel cestino';

  @override
  String errorDeletingStory(Object error) {
    return 'Errore durante l\'eliminazione della storia: $error';
  }

  @override
  String get noRecordsThisDay => 'Nessuna registrazione per questo giorno';

  @override
  String get storyUngrouped => 'Storia senza gruppo';

  @override
  String get save => 'Salva';

  @override
  String get confirmDeletion => 'Conferma eliminazione';

  @override
  String get groupDeletedSuccess => 'Gruppo eliminato con successo';

  @override
  String get noGroupsFound => 'Nessun gruppo trovato';

  @override
  String get shareError => 'Impossibile condividere';

  @override
  String get cannotDeletePhoto => 'Impossibile eliminare questa foto';

  @override
  String get deletePhotoTitle => 'Elimina foto';

  @override
  String get deletePhotoConfirm => 'Vuoi davvero eliminare questa foto?';

  @override
  String get deleteGroupTitle => 'Elimina gruppo';

  @override
  String get share => 'Condividi';

  @override
  String get scrapbookTemplateLabel => 'Scrapbook';

  @override
  String get polaroidTemplateLabel => 'Polaroid';

  @override
  String get home => 'Home';

  @override
  String get groups => 'Gruppi';

  @override
  String get myStories => 'Le mie storie';

  @override
  String get record => 'registrazione';

  @override
  String get records => 'registrazioni';

  @override
  String get filterText => 'Testo';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get searchHintTag => 'Digita un tag...';

  @override
  String get searchHintText => 'Cerca nel titolo o nella descrizione...';

  @override
  String get clearSearchTooltip => 'Cancella ricerca';

  @override
  String get clear => 'Cancella';

  @override
  String get tapToSelectEmoji => 'Tocca per selezionare un emoji:';

  @override
  String get selectEmoji => 'Seleziona emoji';

  @override
  String get tapToChangeEmoji => 'Tocca per cambiare';

  @override
  String get searchButton => 'Cerca';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get recordVideoLabel => 'Registra un video';

  @override
  String get recordAudioLabel => 'Registra audio';

  @override
  String get continueLabel => 'Continua';

  @override
  String get dontShowAgain => 'Non mostrare più';

  @override
  String get laterLabel => 'Più tardi';

  @override
  String get configureLabel => 'Configura';

  @override
  String get imageCopiedBase64 => 'Immagine copiata negli appunti (base64)';

  @override
  String get newGroup => 'Nuovo gruppo';

  @override
  String get editGroup => 'Modifica gruppo';

  @override
  String get chooseIcon => 'Scegli icona';

  @override
  String groupDeleteWarning(Object count) {
    return 'Questo gruppo ha $count storia/e collegata/e. Se eliminato, queste storie torneranno alla schermata principale (senza gruppo). Continuare?';
  }

  @override
  String get unarchive => 'Ripristina archivio';

  @override
  String get group => 'Gruppo';

  @override
  String get selectGroup => 'Seleziona gruppo';

  @override
  String get selectLabel => 'Seleziona';

  @override
  String get existingGroups => 'Gruppi esistenti';

  @override
  String get createNewGroup => 'Crea nuovo gruppo';

  @override
  String get groupNameLabel => 'Nome del gruppo';

  @override
  String get createAndSelect => 'Crea e seleziona';

  @override
  String get manageBackups => 'Gestisci backup';

  @override
  String get createAndShareBackup => 'Crea e condividi backup';

  @override
  String get restoreFromFile => 'Ripristina da file';

  @override
  String get backupNotAvailableWeb => 'Backup non disponibile sul web';

  @override
  String get backupNotAvailableDetail =>
      'La funzionalità di backup richiede l\'accesso al file system, disponibile solo su Android, iOS e versioni desktop.';

  @override
  String get backupInfoTitle => 'Informazioni sul backup';

  @override
  String get backupInfoDetails =>
      'Il backup completo include:\n• Database (storie, testi, foto, audio)\n• File video\n\nViene creato un file ZIP che puoi salvare dove vuoi:\n• OneDrive\n• Google Drive\n• E-mail\n• Qualsiasi altra posizione';

  @override
  String get backupComplete => 'Backup completo';

  @override
  String get backupZipSubtitle => 'File ZIP con tutti i tuoi dati';

  @override
  String get backupZipExplanation =>
      'Genera un file ZIP che puoi salvare su OneDrive, Google Drive, via e-mail o in qualsiasi altra posizione.';

  @override
  String get backupLinuxExplanation =>
      'Scegli una cartella e il backup ZIP verrà salvato direttamente al suo interno.';

  @override
  String get restoreSectionTitle => 'Ripristina backup';

  @override
  String get restoreSectionDescription =>
      'Seleziona un file di backup (ZIP) precedentemente creato per ripristinare tutti i tuoi dati.';

  @override
  String get backupShareSubject => 'Backup DayApp';

  @override
  String backupDeleteConfirm(String fileName) {
    return 'Sei sicuro di voler eliminare questo backup?\n\n$fileName';
  }

  @override
  String backupShareError(String message) {
    return 'Errore durante la condivisione del backup: $message';
  }

  @override
  String backupDeleteError(String message) {
    return 'Errore durante l\'eliminazione del backup: $message';
  }

  @override
  String get processing => 'Elaborazione in corso...';

  @override
  String get pleaseWait => 'Attendere prego...';

  @override
  String get backupStarting => 'Avvio del backup...';

  @override
  String get backupCreatedSuccess =>
      'File di backup creato! Usa il menu di condivisione per salvarlo.';

  @override
  String backupError(Object message) {
    return 'Errore durante la creazione del backup: $message';
  }

  @override
  String get restoreStarting => 'Avvio del ripristino...';

  @override
  String get restoreSuccess => 'Ripristino completato con successo!';

  @override
  String restoreError(Object message) {
    return 'Errore durante il ripristino: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Conferma ripristino';

  @override
  String get restoreConfirmContent =>
      'Tutti i dati attuali saranno sostituiti dal backup.\n\nQuesta azione non può essere annullata. Vuoi continuare?';

  @override
  String get restoreSuccessTitle => '✅ Ripristino completato';

  @override
  String get restoreSuccessContent =>
      'Il backup è stato ripristinato con successo!\n\nTutte le tue storie sono state ripristinate allo stato del backup.\n\nDevi effettuare nuovamente l\'accesso per completare il processo.';

  @override
  String get helpAboutTitle => 'Informazioni su DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp è un\'app di diario personale che ti permette di registrare le tue storie, ricordi e pensieri in modo organizzato e sicuro.';

  @override
  String get helpNavigationTitle => 'Navigazione principale';

  @override
  String get helpHomeItemDesc =>
      'Visualizza le tue storie come schede, elenco o nel calendario.';

  @override
  String get helpHomeDoubleTapDesc =>
      'Doppio tocco su una storia per visualizzarla.';

  @override
  String get helpHomeAttachmentsDesc => 'Tocca gli allegati per visualizzarli.';

  @override
  String get helpHomeSwipeRightDesc =>
      'Scorri la scheda verso destra per archiviare la storia. La storia viene spostata nella scheda Gruppi / Archiviate.';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Scorri la scheda verso sinistra per associarla a un gruppo. La storia viene spostata nella scheda Gruppi / Le mie storie.';

  @override
  String get helpHomeCalendarIconDesc =>
      'Tocca l\'icona del calendario per visualizzare le tue storie in quel formato.';

  @override
  String get helpHomeChapterIconDesc =>
      'Tocca l\'icona Capitolo per organizzare le tue storie in capitoli o ricevere suggerimenti automatici (Premium) per la creazione di capitoli.';

  @override
  String get helpGroupsNavDesc =>
      'Organizza le tue storie in gruppi tematici. Crea gruppi personalizzati per categorizzare i tuoi ricordi. Visualizza le tue storie archiviate.';

  @override
  String get helpSearchItemDesc =>
      'Trova rapidamente storie per titolo, contenuto, tag o data.';

  @override
  String get helpCreatingTitle => 'Creare storie';

  @override
  String get helpNewStoryDesc =>
      'Tocca il pulsante flottante (+ Nuova storia) per creare una nuova storia. Aggiungi titolo, testo, immagini, video e audio.';

  @override
  String get helpTextEditorTitle => 'Editor di testo';

  @override
  String get helpTextEditorDesc =>
      'Usa la formattazione ricca: grassetto, corsivo, elenchi, link e altro.';

  @override
  String get helpChaptersDesc =>
      'Organizza la tua storia in capitoli unendo altre storie sullo stesso argomento.';

  @override
  String get helpMediaDesc =>
      'Aggiungi foto dalla galleria o dalla fotocamera, registra video o audio direttamente nell\'app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associa ogni storia a uno o più gruppi per una migliore organizzazione.';

  @override
  String get helpCalendarDesc =>
      'Visualizza le tue storie organizzate per data. Tocca una data per vedere tutte le storie di quel giorno.';

  @override
  String get helpCreateGroupTitle => 'Crea gruppo';

  @override
  String get helpCreateGroupDesc =>
      'Vai a \"Gruppi\" nel menu laterale per creare nuovi gruppi con colori ed emoticon personalizzati.';

  @override
  String get helpEditGroupTitle => 'Modifica gruppo';

  @override
  String get helpEditGroupDesc =>
      'Tocca un gruppo per modificare nome, emoticon o eliminarlo.';

  @override
  String get helpGroupsAssocTitle => 'Associa ai gruppi';

  @override
  String get helpDeleteGroupTitle => 'Elimina gruppo';

  @override
  String get helpDeleteGroupDesc =>
      'Elimina un gruppo senza eliminare le sue storie.';

  @override
  String get helpInsightsTitle => 'Insights';

  @override
  String get helpInsightsDesc =>
      'Ricevi insights basati sulle tue storie nella schermata principale.\nAlcuni insights sono disponibili solo nella versione Premium.\nAccedi alla cronologia degli insights nel menu laterale.';

  @override
  String get helpBackupSecurityTitle => 'Backup e sicurezza';

  @override
  String get helpAutomaticBackupTitle => 'Backup automatico';

  @override
  String get helpAutomaticBackupDesc =>
      'Configura il backup automatico (Premium) nelle Impostazioni. Il backup verrà creato al momento del logout.';

  @override
  String get helpManualBackupTitle => 'Backup manuale';

  @override
  String get helpManualBackupDesc =>
      'Vai a \"Gestisci backup completo\" nelle Impostazioni per creare un backup completo con tutti i media.';

  @override
  String get helpRestoreTitle => 'Ripristina';

  @override
  String get helpRestoreDesc =>
      'Usa \"Ripristina da file\" per recuperare i dati da un backup precedente.';

  @override
  String get helpPinSecurityTitle => 'PIN di sicurezza';

  @override
  String get helpPinSecurityDesc =>
      'Imposta un PIN da 4 a 8 cifre per proteggere l\'accesso all\'app.';

  @override
  String get helpBiometricsDesc =>
      'Usa l\'impronta digitale o il riconoscimento facciale per sbloccare rapidamente l\'app, se disponibile sul tuo dispositivo.';

  @override
  String get helpPasswordUnlockTitle => 'Sblocco con password';

  @override
  String get helpPasswordUnlockDesc =>
      'Oltre al PIN e alla biometria, puoi sbloccare l\'app usando la password del tuo account. Utile se dimentichi il PIN o se la biometria fallisce.';

  @override
  String get helpBackgroundLockDesc =>
      'Quando l\'app viene minimizzata o passi a un\'altra app, si blocca automaticamente dopo il tempo configurato. Puoi impostare il tempo liberamente nelle impostazioni (secondi, minuti o ore).';

  @override
  String get helpLockExceptionsTitle => 'Eccezioni al blocco';

  @override
  String get helpLockExceptionsDesc =>
      'L\'app non si blocca quando usi funzionalità interne che aprono altre app — come scegliere foto dalla galleria, registrare video, scegliere la posizione del backup o condividere storie.';

  @override
  String get helpPinRecoveryTitle => 'Recupero PIN';

  @override
  String get helpPinRecoveryDesc =>
      'Hai dimenticato il PIN? Usa l\'opzione \"PIN dimenticato\" nella schermata di blocco. Un codice di recupero verrà inviato all\'e-mail registrata.';

  @override
  String get helpThemeDesc =>
      'Passa tra temi chiari, scuri, automatici e altri disponibili nella versione Premium.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configura come si comporterà la notifica di promemoria dell\'app durante la creazione di storie con date future.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Definisci per quanto tempo l\'app può restare in background prima di essere bloccata. Puoi usare valori in secondi, minuti o ore, con piena libertà.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc =>
      'Gestisci le impostazioni di backup e ripristino.';

  @override
  String get helpTrashDesc =>
      'Le storie eliminate rimangono nel cestino per 30 giorni. Accedi al \"Cestino\" nel menu laterale per recuperarle o eliminarle definitivamente.';

  @override
  String get helpStatisticsDesc =>
      'Visualizza statistiche sull\'utilizzo del diario: numero di storie, parole scritte, gruppi principali, ecc.';

  @override
  String get helpTipsTitle => 'Consigli d\'uso';

  @override
  String get helpOrganizationTipTitle => 'Organizzazione';

  @override
  String get helpOrganizationTipDesc =>
      'Usa i gruppi per categorizzare le tue storie per temi, sentimenti o periodi della vita.';

  @override
  String get helpSearchTipTitle => 'Ricerca';

  @override
  String get helpSearchTipDesc =>
      'Usa la funzione di ricerca per trovare rapidamente vecchie storie.';

  @override
  String get helpBackupTipTitle => 'Backup regolare';

  @override
  String get helpBackupTipDesc =>
      'Esegui backup regolarmente, specialmente prima di aggiornamenti o cambi di dispositivo.';

  @override
  String get helpPrivacyTipTitle => 'Privacy';

  @override
  String get helpPrivacyTipDesc =>
      'Le tue storie sono archiviate localmente e crittografate. Imposta un PIN per una protezione aggiuntiva.';

  @override
  String get helpSupportTitle => 'Supporto';

  @override
  String get helpSupportDesc =>
      'Per domande o problemi, contattaci tramite l\'e-mail di supporto o controlla gli aggiornamenti dell\'app.';

  @override
  String get errorCreateAccount =>
      'Errore durante la creazione dell\'account. Riprova.';

  @override
  String get errorShare => 'Errore durante la condivisione';

  @override
  String errorPlayAudio(Object message) {
    return 'Errore durante la riproduzione dell\'audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Errore durante la selezione dei video: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Errore durante la selezione del file: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Errore durante la registrazione del video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Errore durante l\'avvio della registrazione: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Errore durante la pausa della registrazione: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Errore durante la ripresa della registrazione: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Errore durante l\'arresto della registrazione: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Errore durante la selezione degli audio: $message';
  }

  @override
  String get errorLoadVideo => 'Errore durante il caricamento del video';

  @override
  String get errorSelectImage => 'Errore durante la selezione dell\'immagine';

  @override
  String get imagePickerTitleMultiple => 'Aggiungi foto';

  @override
  String get imagePickerTitleSingle => 'Aggiungi foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Scegli un\'opzione (la galleria consente più foto):';

  @override
  String get imagePickerChooseOptionSingle => 'Scegli un\'opzione:';

  @override
  String get imagePickerGalleryMultiple => 'Seleziona dalla galleria';

  @override
  String get imagePickerGallerySingle => 'Scegli dalla galleria';

  @override
  String get imagePickerTakePhoto => 'Scatta una foto';

  @override
  String get audioPickerTitleMultiple => 'Aggiungi audio';

  @override
  String get audioPickerTitleSingle => 'Aggiungi audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Scegli un\'opzione (i file consentono più audio):';

  @override
  String get audioPickerChooseOptionSingle => 'Scegli un\'opzione:';

  @override
  String get audioPickerSelectFilesMultiple => 'Seleziona file audio';

  @override
  String get audioPickerSelectFilesSingle => 'Scegli file audio';

  @override
  String get audioPickerRecord => 'Registra audio';

  @override
  String get videoPickerTitleMultiple => 'Aggiungi video';

  @override
  String get videoPickerTitleSingle => 'Aggiungi video';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Scegli un\'opzione (i file consentono più video):';

  @override
  String get videoPickerChooseOptionSingle => 'Scegli un\'opzione:';

  @override
  String get videoPickerSelectFilesMultiple => 'Seleziona file video';

  @override
  String get videoPickerSelectFilesSingle => 'Scegli file video';

  @override
  String get videoPickerRecord => 'Registra video';

  @override
  String get successVideoAdded => 'Video aggiunto con successo!';

  @override
  String successVideosAdded(Object count) {
    return '$count video aggiunti con successo!';
  }

  @override
  String get startRecording => 'Avvia registrazione';

  @override
  String get recordingPaused => 'Registrazione in pausa';

  @override
  String get recording => 'Registrazione...';

  @override
  String get readyToRecord => 'Pronto per registrare';

  @override
  String get notificationDialogTitle => 'Pianifica notifica';

  @override
  String get notificationDialogPrompt =>
      'Quando vorresti essere notificato di questa voce?';

  @override
  String get emailAlreadyRegistered => 'E-mail già registrata.';

  @override
  String get successNotificationScheduled =>
      'Notifica pianificata con successo';

  @override
  String notificationReminderTitle(Object title) {
    return 'Promemoria: $title';
  }

  @override
  String get notificationReminderBody => 'Hai una voce programmata';

  @override
  String get successImageAdded => 'Immagine aggiunta con successo!';

  @override
  String successImagesAdded(Object count) {
    return '$count immagini aggiunte con successo!';
  }

  @override
  String errorSearch(Object message) {
    return 'Errore durante la ricerca: $message';
  }

  @override
  String get successStoryRestored => 'Storia ripristinata con successo';

  @override
  String get successStoryDeletedPermanently =>
      'Storia eliminata definitivamente';

  @override
  String get trashAlreadyEmpty => 'Il cestino è già vuoto';

  @override
  String get successVideoRecorded => 'Video registrato con successo!';

  @override
  String get permissionMicrophoneDenied => 'Permesso microfono non concesso';

  @override
  String errorSelectImages(Object message) {
    return 'Errore durante la selezione delle immagini: $message';
  }

  @override
  String get successPhotoCaptured => 'Foto acquisita con successo!';

  @override
  String get restoreStoriesTitle => 'Ripristina storie';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Vuoi ripristinare $count storia/e selezionata/e?';
  }

  @override
  String get restoreLabel => 'Ripristina';

  @override
  String get permanentlyDeleteTitle => 'Elimina definitivamente';

  @override
  String get permanentlyDeleteConfirm =>
      'Questa azione non può essere annullata. Vuoi davvero eliminare definitivamente questa storia?';

  @override
  String get permanentlyDeleteLabel => 'Elimina definitivamente';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Vuoi rimuovere il gruppo \"$name\" dalle tue storie?';
  }

  @override
  String get recoverPinTitle => 'Recupera PIN';

  @override
  String get recoverPinDescription =>
      'Invieremo un codice di recupero alla tua e-mail registrata.';

  @override
  String get sendCode => 'Invia codice';

  @override
  String get emptyTrashTitle => 'Svuota cestino';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Vuoi eliminare definitivamente tutte le $count storia/e nel cestino? Questa azione non può essere annullata.';
  }

  @override
  String get emptyTrashLabel => 'Svuota cestino';

  @override
  String errorTakePhoto(Object message) {
    return 'Errore durante lo scatto della foto: $message';
  }

  @override
  String get notifications => 'Notifiche';

  @override
  String get entryNotifications => 'Notifiche delle voci';

  @override
  String get entryNotificationsInfo =>
      'Le voci con una data almeno 2 ore in anticipo possono avere notifiche pianificate.';

  @override
  String get backgroundRestrictionsWarningTitle =>
      'Notifiche e app in background';

  @override
  String get backgroundRestrictionsWarningDesc =>
      'Alcuni sistemi mettono in stand-by aggressivamente le app in background per risparmiare batteria, il che può bloccare le notifiche pianificate dell\'app. Per garantire un corretto funzionamento, apri le impostazioni dell\'app sul tuo dispositivo e:\n• Disabilita \'Sospendi attività app se inutilizzata\' (o opzione simile).\n• Imposta le restrizioni della batteria su \'Non limitata\' (il consumo in background è trascurabile).';

  @override
  String get defaultAdvanceTitle => 'Anticipo predefinito';

  @override
  String get notificationAdvanceTitle => 'Anticipo notifica';

  @override
  String get notificationAdvancePrompt =>
      'Con quanto anticipo vorresti essere notificato?';

  @override
  String get notificationAdvanceDefault => 'Anticipo predefinito';

  @override
  String get notificationScheduleModeTitle => 'Modalità di pianificazione (QA)';

  @override
  String get notificationScheduleModeInexact =>
      'Non esatta (compatibile con Play)';

  @override
  String get automaticBackup => 'Backup automatico';

  @override
  String get manageCompleteBackup => 'Gestisci backup completo';

  @override
  String get backupWithVideosZip => 'Backup con video in file ZIP';

  @override
  String get backupOnLogoutDescription => 'Il backup verrà creato al logout';

  @override
  String get automaticBackupInfo =>
      'Al logout, verrà creato un backup e puoi scegliere dove salvarlo (cartella locale, Google Drive, ecc.).';

  @override
  String get automaticBackupInfoLocal =>
      'Al logout, un backup viene automaticamente salvato localmente sul tuo dispositivo. Puoi esportarlo su cloud storage in seguito se necessario.';

  @override
  String get incrementalBackupTitle => 'Cartella di backup';

  @override
  String get incrementalBackupDescription =>
      'Le storie vengono automaticamente salvate in questa cartella ogni volta che ne salvi una.';

  @override
  String get incrementalBackupFolderNotSet => 'Cartella non configurata';

  @override
  String get incrementalBackupFolderConfigured => 'Cartella configurata';

  @override
  String get incrementalBackupSelectFolder => 'Seleziona cartella';

  @override
  String get incrementalBackupChangeFolder => 'Cambia cartella';

  @override
  String get incrementalBackupChangingFolder =>
      'Copia dei file nella nuova cartella...';

  @override
  String get incrementalBackupFolderChanged => 'Cartella di backup aggiornata.';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Cartella di backup non configurata. Le storie non saranno salvate finché non configuri una cartella nelle Impostazioni.';

  @override
  String get incrementalBackupSyncDone => 'Salvato';

  @override
  String get backupSetupTitle => 'Configura cartella di backup';

  @override
  String get backupSetupContent =>
      'Scegli una cartella dove le tue storie verranno salvate automaticamente. Questo garantisce che i tuoi dati siano sempre al sicuro.';

  @override
  String get backupSavedToFolder =>
      'Salvataggio del backup nella cartella configurata...';

  @override
  String get biometricsNotAvailable => 'Non disponibile su questo dispositivo';

  @override
  String get biometricsDisabled => 'Biometria disabilitata';

  @override
  String get biometricConfiguredInfo =>
      'La biometria è configurata. Puoi accedere con l\'impronta digitale o il riconoscimento facciale.';

  @override
  String get biometricAuthFailed => 'Autenticazione biometrica fallita';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Conferma la tua identità per abilitare la biometria';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarFormatMonth => 'Mese';

  @override
  String get calendarFormatTwoWeeks => '2 settimane';

  @override
  String get calendarFormatWeek => 'Settimana';

  @override
  String get groupExists => 'Il gruppo esiste già';

  @override
  String get enterGroupName => 'Inserisci un nome per il gruppo';

  @override
  String get archivedTitle => 'Archiviato';

  @override
  String get toggleToIcons => 'Passa alla visualizzazione icone';

  @override
  String get toggleToCards => 'Passa alla visualizzazione schede';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get editTip => 'Modifica - doppio tocco';

  @override
  String get exportPdf => 'Esporta PDF';

  @override
  String get close => 'Chiudi';

  @override
  String get newStory => 'Nuova storia';

  @override
  String get noArchivedStories => 'Nessuna storia archiviata.';

  @override
  String get edit => 'Modifica';

  @override
  String previewTitle(Object title) {
    return 'Anteprima - $title';
  }

  @override
  String get archiveLabel => 'Archivia';

  @override
  String get storyArchived => 'Storia archiviata';

  @override
  String get undo => 'Annulla';

  @override
  String get ungroup => 'Rimuovi dal gruppo';

  @override
  String noStoriesInGroup(Object group) {
    return 'Nessuna storia nel gruppo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Errore durante l\'esportazione PDF: $error';
  }

  @override
  String get titleRequired => 'Il titolo è obbligatorio!';

  @override
  String errorSavingStory(Object error) {
    return 'Errore durante il salvataggio della storia: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Titolo e descrizione sono obbligatori per l\'esportazione.';

  @override
  String get exportHistory => 'Esporta storia';

  @override
  String get exportHistoryPrompt =>
      'Vuoi salvare prima di esportare o solo visualizzare in anteprima?';

  @override
  String get preview => 'Anteprima';

  @override
  String get saveAndExport => 'Salva ed esporta';

  @override
  String get untitled => 'Senza titolo';

  @override
  String errorLoadingFile(Object error) {
    return 'Errore durante il caricamento del file: $error';
  }

  @override
  String get discard => 'Ignora';

  @override
  String get discardStoryTitle => 'Ignorare la storia?';

  @override
  String get unsavedStoryPrompt =>
      'Hai una nuova storia non salvata. Uscire senza salvare?';

  @override
  String get changeDateTooltip => 'Cambia data';

  @override
  String get storyTitleLabel => 'Titolo';

  @override
  String get storyTitleHint => 'Inserisci il titolo';

  @override
  String get descriptionLabel => 'Descrizione';

  @override
  String get descriptionHint => 'Scrivi la tua storia...';

  @override
  String get tagsLabel => 'Tag';

  @override
  String get photosSection => 'Foto';

  @override
  String get audiosSection => 'Audio';

  @override
  String get videosSection => 'Video';

  @override
  String get importTxtTooltip => 'Importa .txt';

  @override
  String get expandTooltip => 'Espandi';

  @override
  String get photoTooltip => 'Foto';

  @override
  String get videoTooltip => 'Video';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Modifica descrizione';

  @override
  String get editStory => 'Modifica storia';

  @override
  String get discardChangesTitle => 'Ignorare le modifiche?';

  @override
  String get discardChangesPrompt =>
      'Hai modifiche non salvate. Uscire senza salvare?';

  @override
  String get archivedStateLabel => 'Archiviato';

  @override
  String get archiveSubtitle => 'Nascondi dalla schermata principale';

  @override
  String get chooseEmoji => 'Scegli un emoji';

  @override
  String get emojiGroupSentimentos => 'Sentimenti';

  @override
  String get emojiGroupAnimais => 'Animali';

  @override
  String get emojiGroupVegetais => 'Piante';

  @override
  String get emojiGroupCeu => 'Cielo';

  @override
  String get emojiGroupObjetos => 'Oggetti';

  @override
  String get emojiGroupAlimentos => 'Cibo';

  @override
  String get emojiGroupLugares => 'Luoghi';

  @override
  String get emojiGroupSimbolos => 'Simboli';

  @override
  String get moodQuestion => 'Come ti sei sentito in questa storia?';

  @override
  String get moodVeryDifficult => 'Molto difficile';

  @override
  String get moodDifficult => 'Difficile';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodGood => 'Bene';

  @override
  String get moodVeryGood => 'Molto bene';

  @override
  String get energyQuestion => 'Come era la tua energia?';

  @override
  String get energyLow => 'Bassa';

  @override
  String get energyNormal => 'Normale';

  @override
  String get energyHigh => 'Alta';

  @override
  String get tagsHint => 'Digita e premi Invio o virgola';

  @override
  String get addTag => 'Aggiungi tag';

  @override
  String get tagLongPressHint => 'Pressione lunga per rinominare';

  @override
  String get renameTagTitle => 'Rinomina tag';

  @override
  String get renameTagWarning =>
      'La rinomina influenzerà tutte le storie che usano questo tag.';

  @override
  String get tagNameLabel => 'Nome tag';

  @override
  String get insightDiscovery => 'Scoperta';

  @override
  String get insightPattern => 'Schema trovato';

  @override
  String get insightTrend => '📈 Tendenza';

  @override
  String get insightMonthlySummary => '📊 Il tuo mese in storie';

  @override
  String insightBestWeekday(String weekday) {
    return '$weekday è di solito il tuo giorno più positivo.';
  }

  @override
  String insightPositiveTag(String tag) {
    return 'Le storie con tag #$tag tendono ad avere un umore migliore.';
  }

  @override
  String get insightTrendPositive =>
      'Il tuo umore è migliorato negli ultimi 7 giorni rispetto agli ultimi 30 giorni.';

  @override
  String insightMonthlySummaryText(int entries, String mood, String energy) {
    return 'Voci: $entries\nUmore med.: $mood\nEnergia med.: $energy';
  }

  @override
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  ) {
    return 'Voci: $entries\nUmore med.: $mood\nEnergia med.: $energy\nTag principale: #$tag';
  }

  @override
  String get insightSeeStories => 'Vedi storie';

  @override
  String get weekdaySunday => 'Domenica';

  @override
  String get weekdayMonday => 'Lunedì';

  @override
  String get weekdayTuesday => 'Martedì';

  @override
  String get weekdayWednesday => 'Mercoledì';

  @override
  String get weekdayThursday => 'Giovedì';

  @override
  String get weekdayFriday => 'Venerdì';

  @override
  String get weekdaySaturday => 'Sabato';

  @override
  String get insightDismiss => 'Ignora';

  @override
  String get insightStoryBalanceTitle => 'Equilibrio storie';

  @override
  String get insightStoryBalancePositive =>
      'Hai registrato più storie positive negli ultimi 10 giorni. Continua così!';

  @override
  String get insightStoryBalanceDifficult =>
      'Hai registrato più storie difficili negli ultimi 10 giorni. Prenditi cura di te!';

  @override
  String get insightWritingTimeTitle => 'Orario di scrittura';

  @override
  String get insightWritingTimeMorning =>
      'Hai scritto di più al mattino questa settimana.';

  @override
  String get insightWritingTimeAfternoon =>
      'Hai scritto di più nel pomeriggio questa settimana.';

  @override
  String get insightWritingTimeNight =>
      'Hai scritto di più la notte questa settimana.';

  @override
  String get insightEnergyChartTitle => 'Energia — Ultimi 7 giorni';

  @override
  String get insightEnergyChartSubtitle =>
      'La tua tendenza energetica questa settimana';

  @override
  String get insightPremiumRequired =>
      'Questa è una funzionalità Premium. Aggiorna per sbloccare questo insight.';

  @override
  String get insightPremiumCTA => 'Aggiorna';

  @override
  String get insightDevModeActive =>
      'Modalità sviluppatore: tutti gli insight visibili';

  @override
  String get backupProgressCreating => 'Creazione del file di backup...';

  @override
  String get backupProgressCopyingDb => 'Copia del database...';

  @override
  String get backupProgressCopyingVideos => 'Copia dei video...';

  @override
  String backupProgressCopyingVideo(int current, int total) {
    return 'Copia del video $current/$total...';
  }

  @override
  String get backupProgressCopyingPhotos => 'Copia delle foto...';

  @override
  String backupProgressCopyingPhoto(int current, int total) {
    return 'Copia della foto $current/$total...';
  }

  @override
  String get backupProgressCopyingAudios => 'Copia degli audio...';

  @override
  String backupProgressCopyingAudio(int current, int total) {
    return 'Copia dell\'audio $current/$total...';
  }

  @override
  String get backupProgressCreatingMetadata => 'Creazione dei metadati...';

  @override
  String get backupProgressCompressing => 'Compressione dei file...';

  @override
  String get backupProgressSuccess => 'Backup creato con successo!';

  @override
  String get backupShareText => 'Backup completo DayApp con database e video';

  @override
  String get errorBackupDbNotFound => 'Database non trovato.';

  @override
  String get errorBackupFileNotFound => 'File di backup non trovato.';

  @override
  String errorBackupDbNotFoundInFile(int count) {
    return 'Database non trovato nel file di backup. File estratti: $count';
  }

  @override
  String get restoreProgressExtracting => 'Estrazione del file di backup...';

  @override
  String restoreProgressZipContains(int count) {
    return 'Lo ZIP contiene $count file...';
  }

  @override
  String get restoreProgressBackingUpCurrent =>
      'Backup del database attuale...';

  @override
  String get restoreProgressClosingDb =>
      'Chiusura delle connessioni al database...';

  @override
  String get restoreProgressRestoringDb => 'Ripristino del database...';

  @override
  String get restoreProgressCopyingRestoredDb =>
      'Copia del database ripristinato...';

  @override
  String get restoreProgressRestoringVideos => 'Ripristino dei video...';

  @override
  String restoreProgressRestoringVideo(int current, int total) {
    return 'Ripristino del video $current/$total...';
  }

  @override
  String get restoreProgressRestoringPhotos => 'Ripristino delle foto...';

  @override
  String restoreProgressRestoringPhoto(int current, int total) {
    return 'Ripristino della foto $current/$total...';
  }

  @override
  String get restoreProgressRestoringAudios => 'Ripristino degli audio...';

  @override
  String restoreProgressRestoringAudio(int current, int total) {
    return 'Ripristino dell\'audio $current/$total...';
  }

  @override
  String get restoreProgressReinitializingDb =>
      'Reinizializzazione del database...';

  @override
  String restoreProgressDbStats(int active, int deleted) {
    return 'Database ripristinato: $active attivi, $deleted nel cestino.';
  }

  @override
  String get resendCodeButton => 'Invia nuovo codice';

  @override
  String codeExpiresIn(int minutes) {
    return 'Il codice scade tra $minutes minuti';
  }

  @override
  String get backToStart => 'Torna all\'inizio';

  @override
  String get code => 'Codice';

  @override
  String get pin => 'PIN';

  @override
  String get enterCode => 'Inserisci codice';

  @override
  String get codeCheckDescription =>
      'Inserisci il codice a 6 cifre che è stato inviato alla tua e-mail.';

  @override
  String get defineNewPin =>
      'Definisci un nuovo PIN sicuro per il tuo account.';

  @override
  String get sendCodeButton => 'Invia codice';

  @override
  String get verifyCode => 'Verifica codice';

  @override
  String get resetPin => 'Reimposta PIN';

  @override
  String get storyPreviewMoodVeryDifficultNarrative =>
      'Questa è stata una storia molto difficile';

  @override
  String get storyPreviewMoodDifficultNarrative =>
      'Questa è stata una storia difficile';

  @override
  String get storyPreviewMoodNeutralNarrative =>
      'È stato neutro in termini di sentimento';

  @override
  String get storyPreviewMoodGoodNarrative => 'Una buona storia';

  @override
  String get storyPreviewMoodVeryGoodNarrative => 'Una storia molto buona';

  @override
  String get storyPreviewEnergyLowNarrative => 'Ero con energia bassa';

  @override
  String get storyPreviewEnergyNormalNarrative => 'La mia energia era normale';

  @override
  String get storyPreviewEnergyHighNarrative => 'Ero con energia molto alta';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get premiumFeature => 'Funzionalità Premium';

  @override
  String get freePlan => 'Gratuito';

  @override
  String get currentPlan => 'Piano attuale';

  @override
  String get premiumDebugTitle => 'Debug Premium';

  @override
  String get premiumDebugSubtitle =>
      'Solo sviluppo — non visibile in produzione';

  @override
  String get premiumDebugActivate => 'Attiva Premium (debug)';

  @override
  String get premiumDebugDeactivate => 'Disattiva Premium (torna a Gratuito)';

  @override
  String premiumDebugStatus(String plan) {
    return 'Stato: $plan';
  }

  @override
  String premiumDebugSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String get premiumDebugWarning =>
      'Questa schermata è disponibile solo nelle versioni di debug. Non apparirà in produzione.';

  @override
  String get premiumDebugFeatures => 'Funzionalità controllate dal piano';

  @override
  String get premiumDebugNoSource => 'nessuno';

  @override
  String get autoBackupPremiumRequired =>
      'I backup automatici sono una funzionalità Premium. Aggiorna per accedere ai backup salvati, ai punti di ripristino e alla gestione dello storage.';

  @override
  String autoBackupStorageInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backup · $size',
      one: '1 backup · $size',
      zero: 'Nessun backup salvato',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Capitoli';

  @override
  String get collectionsTitle => 'Collezioni';

  @override
  String get collectionsSubtitle =>
      'I tuoi momenti organizzati in capitoli e gruppi, come una biblioteca di vita.';

  @override
  String get groupsTabLabel => 'Gruppi';

  @override
  String get chapterShortcutToggle =>
      'Mostra/nascondi la scheda capitoli nella Home';

  @override
  String get chaptersHomeCardTitle => 'La tua vita per capitoli';

  @override
  String get chaptersHomeCardSubtitle =>
      'Le tue storie custodiscono momenti. I tuoi capitoli rivelano il percorso.';

  @override
  String get chaptersPremiumRequired =>
      'I capitoli e i suggerimenti automatici sono funzionalità Premium.';

  @override
  String get themePremiumRequired =>
      'I temi personalizzati sono una funzionalità Premium.';

  @override
  String get chapterSuggestions => 'Capitoli suggeriti';

  @override
  String get chapterCreated => 'Capitolo creato con successo.';

  @override
  String get chapterEditTitle => 'Modifica capitolo';

  @override
  String get chapterDescriptionHint =>
      'Inserisci una descrizione per questo capitolo (facoltativo)';

  @override
  String get chapterUpdated => 'Capitolo aggiornato con successo.';

  @override
  String get chapterDeleteConfirmTitle => 'Elimina capitolo';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return 'Eliminare il capitolo “$title”? Le storie collegate non verranno eliminate.';
  }

  @override
  String get chapterDeleted => 'Capitolo eliminato con successo.';

  @override
  String get chapterCreateManual => 'Crea capitolo manualmente';

  @override
  String get chapterCreateTitle => 'Crea Capitolo';

  @override
  String get chapterTitle => 'Titolo';

  @override
  String get chapterTitleHint => 'Es: Cambio di lavoro';

  @override
  String get chapterDescription => 'Descrizione';

  @override
  String get chapterPhoto => 'Foto del capitolo';

  @override
  String get chapterPhotoActionLabel => 'Foto del Capitolo';

  @override
  String get chapterAddPhoto => 'Aggiungi foto';

  @override
  String get chapterChangePhoto => 'Cambia foto';

  @override
  String get chapterRemovePhoto => 'Rimuovi foto';

  @override
  String get chapterSelectEntries =>
      'Seleziona storie correlate (titolo + data)';

  @override
  String get chapterMinimumEntries => 'Minimo: 3 storie per capitolo.';

  @override
  String chapterPeriod(String start, String end) {
    return 'Storie dal $start - $end';
  }

  @override
  String chapterEntriesCount(int count) {
    return 'Storie: $count';
  }

  @override
  String chapterAverageMood(String mood) {
    return 'Umore medio: $mood';
  }

  @override
  String chapterTopTags(String tags) {
    return 'Tag principali: $tags';
  }

  @override
  String get chapterCreateFromSuggestion => 'Crea capitolo';

  @override
  String get chapterViewSuggestions => 'Vedi suggerimenti';

  @override
  String get chapterCreateMyLabel => 'Crea il mio Capitolo';

  @override
  String get chapterIgnoreLabel => 'Ignora';

  @override
  String chapterSuggestionMoreStories(int count) {
    return 'e $count altra/e storia/e';
  }

  @override
  String get chapterNoItems => 'Il tuo prossimo capitolo inizia qui.';

  @override
  String get chapterFilterAll => 'Tutti';

  @override
  String get chapterFilterAutomatic => 'Automatici';

  @override
  String get chapterFilterManual => 'Manuali';

  @override
  String get chapterNoSearchResults =>
      'Nessun capitolo corrispondente ai filtri attuali.';

  @override
  String get chapterSortLabel => 'Ordina per';

  @override
  String get chapterSortNewest => 'Periodo più recente';

  @override
  String get chapterSortOldest => 'Periodo più vecchio';

  @override
  String get chapterSortTitle => 'Titolo';

  @override
  String get chapterSortStories => 'Più storie';

  @override
  String chapterEntriesAndMood(int count, String mood) {
    return '$count storie - umore med. $mood';
  }

  @override
  String get chapterOpenLabel => 'Apri';

  @override
  String get chapterIntroSubtitle =>
      'Organizza le tue storie in modo significativo e rivivi i tuoi ricordi in ordine';

  @override
  String get chapterIntroGroupTitle => 'Unisci momenti collegati';

  @override
  String get chapterIntroGroupBody =>
      'Riunisci più post in un unico capitolo per seguire l\'intero percorso di un tema o momento speciale.';

  @override
  String get chapterIntroTimelineTitle =>
      'Rivivi la tua storia dall\'inizio alla fine';

  @override
  String get chapterIntroTimelineBody =>
      'Sfoglia i ricordi in ordine cronologico e guarda come ogni momento si è evoluto nel tempo.';

  @override
  String get chapterIntroPhaseTitle => 'Un capitolo per ogni fase';

  @override
  String get chapterIntroPhaseBody =>
      'Viaggi, università, famiglia, lavoro, sogni, obiettivi o ricordi speciali. Decidi tu come raccontare la tua storia.';

  @override
  String get chapterIntroCtaTitle => 'Pronto a organizzare i tuoi ricordi?';

  @override
  String get chapterIntroCtaBody =>
      'Inizia creando subito il tuo primo capitolo';

  @override
  String get chapterIntroShowOnOpen =>
      'Mostra questa schermata all\'apertura dei Capitoli';

  @override
  String get chapterLinkSectionTitle => 'Capitoli';

  @override
  String get chapterLinkConfigure => 'Configura';

  @override
  String get chapterLinkDialogTitle => 'Aggiungi questa storia ai capitoli';

  @override
  String get chapterLinkModeNone => 'Non aggiungere';

  @override
  String get chapterLinkModeExisting => 'Aggiungi a un capitolo esistente';

  @override
  String get chapterLinkModeNew => 'Crea nuovo capitolo';

  @override
  String get chapterSelectExistingLabel => 'Seleziona capitolo';

  @override
  String get chapterSelectExistingRequired =>
      'Seleziona un capitolo esistente.';

  @override
  String get chapterTitleRequired => 'Il titolo del capitolo è obbligatorio.';

  @override
  String get chapterMinimumRelatedWithCurrent =>
      'Seleziona almeno 2 storie correlate. Con quella corrente, il minimo è 3.';

  @override
  String get chapterLinkSummaryNone => 'Non collegata a nessun capitolo.';

  @override
  String get chapterLinkSummaryExisting =>
      'Verrà aggiunto a un capitolo esistente al salvataggio.';

  @override
  String chapterLinkSummaryNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuovo capitolo con $count storie',
      one: 'Nuovo capitolo con 1 storia',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get homeHeaderLargeCards => 'Visualizza in schede grandi';

  @override
  String get homeHeaderCompactCards => 'Visualizza in schede compatte';

  @override
  String get homeHeaderOpenCalendarTooltip => 'Apri calendario';

  @override
  String get homeGreetingMorning => 'Buongiorno';

  @override
  String get homeGreetingAfternoon => 'Buon pomeriggio';

  @override
  String get homeGreetingEvening => 'Buonasera';

  @override
  String get homeStoriesSubtitle => 'Ecco le tue storie';

  @override
  String get homeShowAllStoriesLabel => 'Visualizza tutto';

  @override
  String get insightHistoryTitle => 'Cronologia insight';

  @override
  String get insightHistoryEmpty => 'Nessun insight registrato ancora.';

  @override
  String get insightHistoryClearAll => 'Cancella cronologia';

  @override
  String get insightHistoryClearConfirm =>
      'Cancellare tutta la cronologia degli insight? Questa azione non può essere annullata.';

  @override
  String insightHistorySeenOn(String date) {
    return 'Visto il $date';
  }

  @override
  String get insightHistoryFilterAll => 'Tutti';

  @override
  String get insightHistoryFilterFree => 'Gratuito';

  @override
  String get insightHistoryFilterPremium => 'Premium';

  @override
  String get insightHistorySearch => 'Cerca insight';

  @override
  String get pdfBackgroundColor => 'Colore di sfondo';

  @override
  String get pdfBackgroundNone => 'Nessuno';

  @override
  String get pdfBackgroundBeige => 'Beige/crema';

  @override
  String get pdfBackgroundBlue => 'Azzurro';

  @override
  String get pdfBackgroundGreen => 'Verde chiaro';

  @override
  String get pdfBackgroundGray => 'Grigio chiaro';

  @override
  String get exportPdfPremiumRequired =>
      'L\'esportazione in PDF è una funzionalità Premium. Aggiorna il tuo piano per accedervi.';

  @override
  String get changeEmail => 'Cambia e-mail';

  @override
  String get changePassword => 'Cambia password';

  @override
  String get currentPassword => 'Password attuale';

  @override
  String get wrongCurrentPassword => 'La password attuale è errata.';

  @override
  String get passwordChangedSuccess => 'Password modificata con successo.';

  @override
  String get emailChangedSuccess => 'E-mail modificata con successo.';

  @override
  String get newPasswordMinLength =>
      'La nuova password deve essere di almeno 4 caratteri.';

  @override
  String get fillAllFields => 'Compila tutti i campi.';

  @override
  String get backupInfoDialogTitle => 'Informazioni sul backup';

  @override
  String get backupInfoDialogContent =>
      '📦  Cosa è incluso nel backup\n• Tutte le tue storie (testi, foto, audio, video)\n• Database dell\'app\n• Foto dei capitoli\n\n📂  Come conservare il backup\nDopo la creazione, usa il menu di condivisione per salvare il file dove preferisci — OneDrive, Google Drive, e-mail o qualsiasi altro servizio.';

  @override
  String get backupPasswordDialogTitle => 'Proteggi il tuo backup';

  @override
  String get backupPasswordDescription =>
      'Imposta una password per crittografare il tuo file di backup. Il contenuto sarà protetto e illeggibile per chiunque non abbia questa password.';

  @override
  String get backupPasswordWarningTitle =>
      '⚠️  Importante — leggi prima di continuare';

  @override
  String get backupPasswordWarning =>
      'Questa password è nota solo a te. Non viene memorizzata da nessuna parte nell\'app né sui nostri server.\n\nSe la dimentichi, il file di backup sarà definitivamente inaccessibile — nemmeno il nostro team potrà aiutarti a recuperare i dati.\n\nConserva questa password in un posto sicuro prima di continuare.';

  @override
  String get backupPasswordField => 'Password';

  @override
  String get backupPasswordConfirmField => 'Conferma password';

  @override
  String get backupPasswordMismatch =>
      'Le password non corrispondono. Riprova.';

  @override
  String get backupPasswordTooShort =>
      'La password deve essere di almeno 6 caratteri.';

  @override
  String get backupPasswordEmpty => 'Inserisci una password.';

  @override
  String get backupCreateEncrypted => 'Crea backup crittografato';

  @override
  String get restorePasswordDialogTitle => 'Inserisci la password del backup';

  @override
  String get restorePasswordDescription =>
      'Se hai impostato una password durante la creazione di questo backup, inseriscila qui sotto.\n\nSe il backup è stato creato senza password, lascia il campo vuoto.';

  @override
  String get restorePasswordField =>
      'Password (lascia vuoto se non ne è stata impostata una)';

  @override
  String get restorePasswordWrong =>
      'Password errata o backup illeggibile. Controlla la password e riprova.';

  @override
  String get restoreContinue => 'Continua';
}
