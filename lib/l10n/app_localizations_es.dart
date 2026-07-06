// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get moodEnergyChartTitle => 'Tu Viaje Reciente';

  @override
  String get moodEnergyChartSubtitle => 'Últimos 7 días con registros';

  @override
  String moodEnergyChartTooltip(String date, String mood, String energy) {
    return 'Día $date: Humor $mood / Energía $energy';
  }

  @override
  String get moodEnergyChartTitleLabel => 'Humor y Energía';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get deviceDefault => 'Predeterminado del dispositivo';

  @override
  String get defaultLabel => 'Predeterminado';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portugués';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get errorInitializingApp => 'Error al inicializar la aplicación';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Seguridad';

  @override
  String get themeAndScheme => 'Tema y Esquema';

  @override
  String get themeRelva => 'Hierba';

  @override
  String get themeOutono => 'Jardín Botánico';

  @override
  String get themeCeu => 'Cielo';

  @override
  String get themeConfort => 'Conforto';

  @override
  String get themeSunset => 'Atardecer';

  @override
  String get themeMidnightGalaxy => 'Galaxia de Medianoche';

  @override
  String get themeDefaultLightDescription => 'Tema claro predeterminado';

  @override
  String get themeDefaultDarkDescription => 'Tema oscuro predeterminado';

  @override
  String get themeFollowSystemDescription => 'Seguir tema del sistema';

  @override
  String get themeCustomSchemesTitle => 'Esquemas personalizados';

  @override
  String get themeRelvaLight => 'Relva (Claro)';

  @override
  String get themeRelvaDark => 'Relva (Oscuro)';

  @override
  String get themeOutonoLight => 'Jardín Botánico (Claro)';

  @override
  String get themeOutonoDark => 'Jardín Botánico (Oscuro)';

  @override
  String get themeRelvaLightDescription => 'Tonos verdes y naturales';

  @override
  String get themeRelvaDarkDescription => 'Versión oscura del esquema Relva';

  @override
  String get themeOutonoLightDescription =>
      'Tonos frescos y orgánicos de jardín';

  @override
  String get themeOutonoDarkDescription =>
      'Versión oscura del esquema Jardín Botánico';

  @override
  String get themeRemoveScheme => 'Quitar esquema';

  @override
  String get themeRemoveSchemeDescription =>
      'Volver al esquema predeterminado del tema';

  @override
  String get timeAtConnector => 'a las';

  @override
  String get timeAgoNow => 'ahora';

  @override
  String timeAgoMinutes(int count) {
    return 'hace $count min';
  }

  @override
  String timeAgoHours(int count) {
    return 'hace ${count}h';
  }

  @override
  String timeAgoDays(int count) {
    return 'hace $count día(s)';
  }

  @override
  String get backup => 'Copia de seguridad';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Deshabilitado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get pinUnlock => 'PIN de desbloqueo';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get enableBiometrics => 'Inicio biométrico';

  @override
  String get information => 'Información';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get configurePin => 'Configurar PIN';

  @override
  String get biometrics => 'Biometría';

  @override
  String get backgroundLock => 'Bloqueo en segundo plano';

  @override
  String get backgroundLockDialogPrompt =>
      '¿Después de cuánto tiempo en segundo plano debe bloquearse la aplicación?';

  @override
  String get backgroundLockTimeLabel => 'Tiempo';

  @override
  String get backgroundLockDialogResult => 'Resultado:';

  @override
  String get backgroundLockSuggestions => 'Sugerencias:';

  @override
  String get backgroundLockImmediateHint => '0 = inmediato';

  @override
  String get backgroundLockNever => 'No bloquear';

  @override
  String get backgroundLockImmediately => 'Inmediatamente';

  @override
  String backgroundLockSeconds(int count) {
    return '$count segundos';
  }

  @override
  String get backgroundLockOneMinute => '1 minuto';

  @override
  String backgroundLockMinutes(int count) {
    return '$count minutos';
  }

  @override
  String get backgroundLockOneHour => '1 hora';

  @override
  String backgroundLockHours(int count) {
    return '$count horas';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get noStoriesYetTitle => 'Ninguna historia registrada aún';

  @override
  String get trashEmptyStateMessage => 'Tu papelera está vacía';

  @override
  String get noStoriesYetSubtitle =>
      'Comienza a registrar tus días para ver las estadísticas';

  @override
  String get trends => 'Tendencias';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get activityByWeekday => 'Actividad por día de la semana';

  @override
  String get streaksTitle => 'Rachas';

  @override
  String get longestStreakPrefix => 'Racha más larga:';

  @override
  String get tableOfMoods => 'Tabla de estados de ánimo';

  @override
  String get moodCount => 'Contador de estados';

  @override
  String get topTags => 'Mejores etiquetas';

  @override
  String get storiesLabel => 'Historias';

  @override
  String get activeDaysLabel => 'Días activos';

  @override
  String get avgPerDayLabel => 'Prom/día';

  @override
  String get mediaLabel => 'Medios';

  @override
  String get manageGroups => 'Administrar grupos';

  @override
  String get trash => 'Papelera';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutScreenAboutDayAppTitle => 'Acerca de DayApp';

  @override
  String get aboutScreenAboutDayAppDescription =>
      'DayApp es una aplicación de diario personal moderna y segura que te permite registrar tus historias, recuerdos y pensamientos de forma organizada y privada. Con una interfaz intuitiva y funciones avanzadas, DayApp te ayuda a preservar tus experiencias más importantes.';

  @override
  String get aboutScreenFeaturesTitle => 'Funciones';

  @override
  String get aboutScreenFeatureRichEditorTitle => 'Editor enriquecido';

  @override
  String get aboutScreenFeatureRichEditorDescription =>
      'Crea historias con formato avanzado, imágenes, vídeos y audios';

  @override
  String get aboutScreenFeatureSmartOrganizationTitle =>
      'Organización inteligente';

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Clasifique sus historias en grupos temáticos personalizados y capítulos que hablen sobre usted';

  @override
  String get aboutScreenFeatureAdvancedSearchTitle => 'Búsqueda avanzada';

  @override
  String get aboutScreenFeatureAdvancedSearchDescription =>
      'Encuentra rápidamente cualquier historia por contenido o fecha';

  @override
  String get aboutScreenFeatureSecureBackupTitle => 'Copia de seguridad segura';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Haga una copia de seguridad de sus datos periódicamente.';

  @override
  String get aboutScreenFeatureTotalPrivacyTitle => 'Privacidad total';

  @override
  String get aboutScreenFeatureTotalPrivacyDescription =>
      'Tus datos se almacenan localmente y están cifrados';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceTitle => 'Interfaz adaptable';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceDescription =>
      'Tema claro/oscuro y diseños personalizables';

  @override
  String get aboutScreenVersionTitle => 'Versión';

  @override
  String aboutScreenVersionBuild(String version, String build) {
    return 'Versión $version (Compilación $build)';
  }

  @override
  String aboutScreenVersionShort(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutScreenDevelopmentTitle => 'Desarrollo';

  @override
  String get aboutScreenDevelopmentDescription =>
      'Desarrollado con dedicación para ofrecer la mejor experiencia al registrar recuerdos personales.';

  @override
  String get aboutScreenPrivacySecurityTitle => 'Privacidad y seguridad';

  @override
  String get aboutScreenPrivacyLocalDataTitle => 'Datos locales';

  @override
  String get aboutScreenPrivacyLocalDataDescription =>
      'Todas tus historias se almacenan solo en tu dispositivo';

  @override
  String get aboutScreenPrivacyEncryptionTitle => 'Cifrado';

  @override
  String get aboutScreenPrivacyEncryptionDescription =>
      'El contenido sensible está protegido con cifrado avanzado';

  @override
  String get aboutScreenPrivacyNoTrackingTitle => 'Sin rastreo';

  @override
  String get aboutScreenPrivacyNoTrackingDescription =>
      'No recopilamos datos personales ni rastreamos tu uso';

  @override
  String get aboutScreenPrivacyPinSecurityTitle => 'PIN de seguridad';

  @override
  String get aboutScreenPrivacyPinSecurityDescription =>
      'Protege el acceso a la app con PIN o biometría';

  @override
  String get aboutScreenContactSupportTitle => 'Contacto y soporte';

  @override
  String get aboutScreenContactSupportDescription =>
      'Para consultas, sugerencias o soporte técnico:';

  @override
  String get aboutScreenSupportEmailSubject => 'Soporte de DayApp';

  @override
  String aboutScreenSupportEmailBody(String version) {
    return 'Hola, necesito ayuda con DayApp...\n\nVersión: $version\n';
  }

  @override
  String get aboutScreenAcknowledgementsTitle => 'Agradecimientos';

  @override
  String get aboutScreenAcknowledgementsDescription =>
      'Gracias por elegir DayApp para registrar tus recuerdos más valiosos. Tu confianza y comentarios son esenciales para que sigamos mejorando.';

  @override
  String get aboutScreenHeaderSubtitle => 'Tu diario personal';

  @override
  String get aboutScreenCopyright =>
      '© 2026 DayApp. Todos los derechos reservados.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get name => 'Nombre';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get createAccountButton => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get needHelp => '¿Necesitas ayuda?';

  @override
  String get currentPinLabel => 'PIN actual';

  @override
  String get newPinLabel => 'Nuevo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterCurrentPin => 'Ingrese el PIN actual';

  @override
  String get enterPin => 'Ingrese el PIN';

  @override
  String get pinLengthError => 'El PIN debe tener entre 4 y 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Los PIN no coinciden';

  @override
  String get pinIncorrect => 'PIN actual incorrecto';

  @override
  String get pinChangedSuccess => '¡PIN cambiado con éxito!';

  @override
  String get pinConfiguredSuccess => '¡PIN configurado con éxito!';

  @override
  String get informYourEmail => 'Ingrese su correo electrónico.';

  @override
  String get invalidEmail => 'Ingrese un correo electrónico válido.';

  @override
  String get emailNotFound =>
      'Correo no encontrado. Verifique e inténtelo de nuevo.';

  @override
  String codeSent(Object email) {
    return 'Código enviado a $email! Verifique su bandeja de entrada.';
  }

  @override
  String get codeMustBe6 => 'El código debe tener 6 dígitos.';

  @override
  String get codeVerified => '¡Código verificado! Defina su nueva contraseña.';

  @override
  String get codeInvalid => 'Código inválido o expirado. Intente nuevamente.';

  @override
  String get enterNewPassword => 'Ingrese la nueva contraseña.';

  @override
  String get passwordResetSuccess =>
      '¡Contraseña restablecida con éxito! Inicie sesión con la nueva contraseña.';

  @override
  String get errorResetPassword =>
      'Error al restablecer la contraseña. Intente nuevamente.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get resendCodeSuccess =>
      '¡Nuevo código enviado! Verifique su bandeja de entrada.';

  @override
  String get resendCodeError => 'Error al reenviar código. Intente nuevamente.';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get almostReady => 'casi listo...';

  @override
  String get optionalData => 'Los datos a continuación son opcionales';

  @override
  String get birthDateFormat => 'Fecha de nacimiento (DD/MM/AAAA)';

  @override
  String get invalidBirthDate =>
      'Fecha de nacimiento inválida (use DD/MM/AAAA)';

  @override
  String get userNotFound => 'Usuario no encontrado.';

  @override
  String get create => 'Crear';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get emailRequired => 'Correo electrónico es obligatorio';

  @override
  String get emailInvalid => 'Ingrese un correo electrónico válido';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get accessAccount => 'Accede a tu cuenta';

  @override
  String get enterPassword => 'Ingrese su contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get noAccountCreateHere => '¿No tienes cuenta? Crea una aquí.';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get biometricsEnabledSuccess => '¡Biometría habilitada con éxito!';

  @override
  String get biometricLoginError => 'Error al iniciar sesión con biometría.';

  @override
  String get invalidCredentials => 'Correo electrónico o contraseña inválidos.';

  @override
  String get profileUpdatedSuccess => '¡Perfil actualizado con éxito!';

  @override
  String get profileUpdateError =>
      'Error al actualizar el perfil. Intente nuevamente.';

  @override
  String get unlockAppReason => 'Desbloquee la aplicación para continuar';

  @override
  String get fillEmailAndPassword =>
      'Complete el correo electrónico y la contraseña';

  @override
  String get emailOrPasswordIncorrect => 'Correo o contraseña incorrectos';

  @override
  String get noEmailRegistered =>
      'Ningún correo registrado. Configurelo en las configuraciones.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Verifique su correo en $email o use el código mostrado';
  }

  @override
  String get errorGeneratingCode =>
      'Error al generar código. Intente nuevamente.';

  @override
  String get errorSendingCode => 'Error al enviar código. Intente nuevamente.';

  @override
  String get enterRecoveryCodePrompt =>
      'Ingrese el código enviado a su correo:';

  @override
  String get recoveryCodeLabel => 'Código de recuperación (6 dígitos)';

  @override
  String get enterPasswordToContinue => 'Ingrese su contraseña para continuar';

  @override
  String get enterPinToContinue => 'Ingrese su PIN para continuar';

  @override
  String get useBiometricsToContinue => 'Use su biometría para continuar';

  @override
  String get usePin => 'Usar PIN';

  @override
  String get noStoriesHere => 'No hay historias para mostrar aquí.';

  @override
  String get storiesGroupedOrArchived => 'Están agrupadas o archivadas.';

  @override
  String get useBiometrics => 'Usar biometría';

  @override
  String get unlockWithBiometrics => 'Desbloquear con biometría';

  @override
  String get useAccountPassword => 'Usar contraseña de la cuenta';

  @override
  String get forgotPin => 'Olvidé mi PIN';

  @override
  String get unlockTitle => 'Desbloquee la aplicación';

  @override
  String get search => 'Buscar';

  @override
  String get searchStoriesTitle => 'Busca tus historias';

  @override
  String get searchStoriesSubtitle =>
      'Usa los filtros de arriba para encontrar tus recuerdos.';

  @override
  String unsavedBackups(Object count) {
    return 'Tienes $count historias sin copia de seguridad.';
  }

  @override
  String get backupRecommendation =>
      'Recomendamos hacer una copia de seguridad para evitar perder tus datos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get restore => 'Restaurar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleted => 'Eliminado';

  @override
  String get performBackup => 'Hacer copia de seguridad';

  @override
  String get deleteStoryTitle => 'Eliminar historia';

  @override
  String get deleteStoryConfirm => '¿Desea mover esta historia a la papelera?';

  @override
  String get deleteLabel => 'Eliminar';

  @override
  String get movedToTrash => 'Historia movida a la papelera';

  @override
  String errorDeletingStory(Object error) {
    return 'Error al eliminar historia: $error';
  }

  @override
  String get noRecordsThisDay => 'No hay registros para este día';

  @override
  String get storyUngrouped => 'Historia desagrupada';

  @override
  String get save => 'Guardar';

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get groupDeletedSuccess => 'Grupo eliminado con éxito';

  @override
  String get noGroupsFound => 'Ningún grupo encontrado';

  @override
  String get shareError => 'No se pudo compartir';

  @override
  String get cannotDeletePhoto => 'No es posible eliminar esta foto';

  @override
  String get deletePhotoTitle => 'Eliminar foto';

  @override
  String get deletePhotoConfirm => '¿Desea realmente eliminar esta foto?';

  @override
  String get deleteGroupTitle => 'Eliminar Grupo';

  @override
  String get share => 'Compartir';

  @override
  String get scrapbookTemplateLabel => 'Scrapbook';

  @override
  String get polaroidTemplateLabel => 'Polaroid';

  @override
  String get home => 'Inicio';

  @override
  String get groups => 'Grupos';

  @override
  String get myStories => 'Mis Historias';

  @override
  String get record => 'registro';

  @override
  String get records => 'registros';

  @override
  String get filterText => 'Texto';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get filterDate => 'Período';

  @override
  String get selectDateRange => 'Seleccionar período';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get searchHintTag => 'Escribe una etiqueta...';

  @override
  String get searchHintText => 'Buscar en título o descripción...';

  @override
  String get clearSearchTooltip => 'Limpiar búsqueda';

  @override
  String get clear => 'Limpiar';

  @override
  String get tapToSelectEmoji => 'Toque para seleccionar un emoji:';

  @override
  String get selectEmoji => 'Seleccionar emoji';

  @override
  String get tapToChangeEmoji => 'Toque para cambiar';

  @override
  String get searchButton => 'Buscar';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get takePhoto => 'Tomar una foto';

  @override
  String get recordVideoLabel => 'Grabar un vídeo';

  @override
  String get recordAudioLabel => 'Grabar audio';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get dontShowAgain => 'No mostrar de nuevo';

  @override
  String get laterLabel => 'Más tarde';

  @override
  String get configureLabel => 'Configurar';

  @override
  String get imageCopiedBase64 => 'Imagen copiada al portapapeles (base64)';

  @override
  String get newGroup => 'Nuevo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Seleccionar ícono';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tiene $count historia(s) vinculada(s). Si se elimina, esas historias volverán a la pantalla principal (sin grupo). ¿Continuar?';
  }

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get group => 'Grupo';

  @override
  String get selectGroup => 'Seleccionar Grupo';

  @override
  String get selectLabel => 'Seleccionar';

  @override
  String get existingGroups => 'Grupos Existentes';

  @override
  String get createNewGroup => 'Crear Nuevo Grupo';

  @override
  String get groupNameLabel => 'Nombre del Grupo';

  @override
  String get groupNameMaxLengthHint => 'Máximo de 15 caracteres.';

  @override
  String get groupNameTooLong =>
      'El nombre del grupo debe tener como máximo 15 caracteres.';

  @override
  String get createAndSelect => 'Crear y Seleccionar';

  @override
  String get manageBackups => 'Administrar copia de seguridad';

  @override
  String get createAndShareBackup => 'Crear y compartir copia de seguridad';

  @override
  String get restoreFromFile => 'Restaurar desde archivo';

  @override
  String get backupNotAvailableWeb =>
      'Copia de seguridad no disponible en la web';

  @override
  String get backupNotAvailableDetail =>
      'La función de copia de seguridad requiere acceso al sistema de archivos, disponible solo en las versiones de Android, iOS y escritorio.';

  @override
  String get backupInfoTitle => 'Sobre la copia de seguridad';

  @override
  String get backupInfoDetails =>
      'La copia de seguridad completa incluye:\n• Base de datos (historias, textos, fotos, audios)\n• Archivos de vídeo\n\nSe creará un archivo ZIP y puedes guardarlo donde quieras:\n• OneDrive\n• Google Drive\n• Correo electrónico\n• Cualquier otra ubicación';

  @override
  String get backupComplete => 'Copia de seguridad completa';

  @override
  String get backupZipSubtitle => 'Archivo ZIP con todos tus datos';

  @override
  String get backupZipExplanation =>
      'Genera un archivo ZIP que puede guardar en su dispositivo, OneDrive, Google Drive, correo electrónico o cualquier otra ubicación en la nube, excepto aplicaciones de mensajería.';

  @override
  String get backupLinuxExplanation =>
      'Elige una carpeta y el ZIP de copia de seguridad se guardará directamente en ella.';

  @override
  String get restoreSectionTitle => 'Restaurar copia de seguridad';

  @override
  String get restoreSectionDescription =>
      'Selecciona un archivo de copia de seguridad (ZIP) creado previamente para restaurar todos tus datos.';

  @override
  String lastBackupLabel(String fileName) {
    return 'Última copia de seguridad: $fileName';
  }

  @override
  String get backupShareSubject => 'Copia de seguridad de DayApp';

  @override
  String backupDeleteConfirm(String fileName) {
    return '¿Seguro que quieres eliminar esta copia de seguridad?\n\n$fileName';
  }

  @override
  String backupShareError(String message) {
    return 'Error al compartir la copia de seguridad: $message';
  }

  @override
  String backupDeleteError(String message) {
    return 'Error al eliminar la copia de seguridad: $message';
  }

  @override
  String get processing => 'Procesando...';

  @override
  String get pleaseWait => 'Por favor espera...';

  @override
  String get backupStarting => 'Iniciando copia de seguridad...';

  @override
  String get backupCreatedSuccess => '¡Archivo de copia de seguridad creado!';

  @override
  String backupError(Object message) {
    return 'Error al crear copia de seguridad: $message';
  }

  @override
  String get restoreStarting => 'Iniciando restauración...';

  @override
  String get restoreSuccess => '¡Restauración completada con éxito!';

  @override
  String restoreError(Object message) {
    return 'Error al restaurar: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirmar restauración';

  @override
  String get restoreConfirmContent =>
      'Todos los datos actuales serán reemplazados por la copia de seguridad.\n\nEsta acción no se puede deshacer. ¿Deseas continuar?';

  @override
  String get restoreSuccessTitle => '✅ Restauración completada';

  @override
  String get restoreSuccessContent =>
      '¡La copia de seguridad se restauró con éxito!\n\nTodas tus historias se han restaurado al estado del backup.\n\nNecesitas iniciar sesión nuevamente para completar el proceso.';

  @override
  String get helpAboutTitle => 'Sobre el DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp es una aplicación de diario personal que te permite registrar tus historias, recuerdos y pensamientos de forma organizada y segura.';

  @override
  String get helpNavigationTitle => 'Navegación Principal';

  @override
  String get helpHomeItemDesc =>
      'Vea las últimas 5 o todas las historias en tarjetas grandes o más pequeñas o en el calendario';

  @override
  String get helpHomeDoubleTapDesc =>
      'Toca dos veces una historia para visualizarla.';

  @override
  String get helpHomeAttachmentsDesc =>
      'Toca los archivos adjuntos para verlos.';

  @override
  String get helpHomeSwipeRightDesc =>
      'Arrastre la tarjeta hacia la derecha para Archivar la historia. La historia se mueve a la pestaña Colecciones/Grupos/Archivados.';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Arrastra la tarjeta hacia la izquierda para asociarla con un Grupo. La historia se mueve a la pestaña Colecciones/Grupos/Archivados.';

  @override
  String get helpHomeCalendarIconDesc =>
      'Toca el ícono de calendario para ver tus historias en ese formato.';

  @override
  String get helpHomeChapterIconDesc =>
      'Organiza tus historias en Capítulos y Grupos Temáticos. Crea capítulos y cuenta tu historia completa. Crea grupos personalizados para categorizar tus recuerdos.';

  @override
  String get helpGroupsNavDesc =>
      'Organiza tus historias en Capítulos y Grupos Temáticos. Crea capítulos y cuenta tu historia completa. Crea grupos personalizados para categorizar tus recuerdos.';

  @override
  String get helpSearchItemDesc =>
      'Encuentra historias rápidamente por título, contenido, etiqueta o fecha.';

  @override
  String get helpCreatingTitle => 'Creando Historias';

  @override
  String get helpNewStoryDesc =>
      'Toca el botón flotante (+ Nueva Historia) para crear una nueva historia. Añade título, texto, imágenes, vídeos y audios.';

  @override
  String get helpTextEditorTitle => 'Editor de Texto';

  @override
  String get helpTextEditorDesc =>
      'Usa formato enriquecido: negrita, cursiva, listas, enlaces y más.';

  @override
  String get helpChaptersDesc =>
      'Organiza tu historia en capítulos juntando otras historias sobre el mismo tema.';

  @override
  String get helpMediaDesc =>
      'Agrega fotos de la galería o cámara, graba vídeos o audios directamente en la aplicación.';

  @override
  String get helpGroupsAssocDesc =>
      'Asocia cada historia con uno o más grupos para una mejor organización.';

  @override
  String get helpCalendarDesc =>
      'Visualiza tus historias organizadas por fecha. Toca una fecha para ver todas las historias de ese día.';

  @override
  String get helpCreateGroupTitle => 'Crear Grupo';

  @override
  String get helpCreateGroupDesc =>
      'Ve a \"Grupos\" en el menú lateral para crear nuevos grupos con colores y emoticons personalizados.';

  @override
  String get helpEditGroupTitle => 'Editar Grupo';

  @override
  String get helpEditGroupDesc =>
      'Toca un grupo para editar nombre, emoticon o eliminar.';

  @override
  String get helpGroupsAssocTitle => 'Asociar a Grupos';

  @override
  String get helpDeleteGroupTitle => 'Eliminar Grupo';

  @override
  String get helpDeleteGroupDesc =>
      'Elimina un Grupo sin que las historias también sean eliminadas.';

  @override
  String get helpInsightsTitle => 'Insights';

  @override
  String get helpInsightsDesc =>
      'Recibe insights basados en tus historias en la pantalla principal.\nAlgunos insights solo están disponibles en la versión Premium.\nAccede al historial de insights en el menú lateral.';

  @override
  String get helpBackupSecurityTitle => 'Copia de seguridad y seguridad';

  @override
  String get helpAutomaticBackupTitle => 'Automatic Backup';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure automatic backup (Premium) in Settings. The backup will be created when you log out.';

  @override
  String get helpManualBackupTitle => 'Respaldo';

  @override
  String get helpManualBackupDesc =>
      'Ve a \"Administrar copia de seguridad completa\" en Configuración para crear una copia completa con todos los medios.';

  @override
  String get helpRestoreTitle => 'Restaurar';

  @override
  String get helpRestoreDesc =>
      'Usa \"Restaurar desde archivo\" para recuperar datos de una copia anterior.';

  @override
  String get helpPinSecurityTitle => 'PIN de seguridad';

  @override
  String get helpPinSecurityDesc =>
      'Configura un PIN de 4 a 8 dígitos para proteger el acceso a la app.';

  @override
  String get helpBiometricsDesc =>
      'Usa huella para desbloquear la app rápidamente, si está disponible en tu dispositivo.';

  @override
  String get helpPasswordUnlockTitle => 'Desbloqueo por contraseña';

  @override
  String get helpPasswordUnlockDesc =>
      'Además de PIN y biometría, puedes desbloquear la app usando tu contraseña de cuenta. Útil si olvidas el PIN o la biometría falla.';

  @override
  String get helpBackgroundLockDesc =>
      'Cuando la app se minimiza o cambias a otra app, se bloquea automáticamente después del tiempo configurado. Puedes establecer el tiempo libremente en la configuración (segundos, minutos u horas).';

  @override
  String get helpLockExceptionsTitle => 'Excepciones de bloqueo';

  @override
  String get helpLockExceptionsDesc =>
      'La app no se bloquea cuando usas funciones internas que abren otras apps, como seleccionar fotos de la galería, grabar vídeos, elegir ubicación de backup o compartir historias.';

  @override
  String get helpPinRecoveryTitle => 'Recuperación de PIN';

  @override
  String get helpPinRecoveryDesc =>
      '¿Olvidaste tu PIN? Usa la opción \"Olvidé mi PIN\" en la pantalla de bloqueo. Se enviará un código de recuperación al correo registrado.';

  @override
  String get helpThemeDesc =>
      'Alterna entre temas claro, oscuro, automático y otros disponibles en la versión Premium.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configura cómo se comportará la notificación de recordatorio al crear historias con fechas futuras.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Define cuánto tiempo la app puede permanecer en segundo plano antes de bloquearse. Puedes usar valores en segundos, minutos u horas, con total libertad.';

  @override
  String get helpBackupSettingTitle => 'Copia de seguridad';

  @override
  String get helpBackupSettingDesc =>
      'Administra opciones de copia de seguridad y restauración.';

  @override
  String get helpTrashDesc =>
      'Las historias eliminadas permanecen en la papelera durante 30 días. Accede a \"Papelera\" en el menú lateral para recuperar o eliminar permanentemente.';

  @override
  String get helpStatisticsDesc =>
      'Visualiza estadísticas sobre el uso del diario: número de historias, palabras escritas, grupos más usados, etc.';

  @override
  String get helpTipsTitle => 'Consejos de uso';

  @override
  String get helpOrganizationTipTitle => 'Organización';

  @override
  String get helpOrganizationTipDesc =>
      'Utilice Grupos para categorizar sus historias por temas y Capítulos para contar la historia completa.';

  @override
  String get helpSearchTipTitle => 'Búsqueda';

  @override
  String get helpSearchTipDesc =>
      'Usa la función de búsqueda para encontrar historias antiguas rápidamente.';

  @override
  String get helpBackupTipTitle => 'Copia de seguridad regular';

  @override
  String get helpBackupTipDesc =>
      'Realiza copias regularmente, especialmente antes de actualizaciones o cambios de dispositivo.';

  @override
  String get helpPrivacyTipTitle => 'Privacidad';

  @override
  String get helpPrivacyTipDesc =>
      'Tus historias se almacenan localmente y están cifradas. Configura un PIN para protección adicional.';

  @override
  String get helpSupportTitle => 'Soporte';

  @override
  String get helpSupportDesc =>
      'Para dudas o problemas, contáctanos por correo de soporte o revisa las actualizaciones de la app.';

  @override
  String get errorCreateAccount =>
      'Error al crear la cuenta. Por favor, inténtalo de nuevo.';

  @override
  String get errorShare => 'Error al compartir';

  @override
  String errorPlayAudio(Object message) {
    return 'Error al reproducir audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Error al seleccionar videos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Error al seleccionar archivo: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Error al grabar video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Error al iniciar la grabación: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Error al pausar la grabación: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Error al reanudar la grabación: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Error al detener la grabación: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Error al seleccionar audios: $message';
  }

  @override
  String get errorLoadVideo => 'Error al cargar video';

  @override
  String get errorSelectImage => 'Error al seleccionar imagen';

  @override
  String get imagePickerTitleMultiple => 'Agregar Fotos';

  @override
  String get imagePickerTitleSingle => 'Agregar Foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Elige una opción (la galería permite varias fotos):';

  @override
  String get imagePickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get imagePickerGalleryMultiple => 'Seleccionar de la galería';

  @override
  String get imagePickerGallerySingle => 'Buscar en la galería';

  @override
  String get imagePickerTakePhoto => 'Tomar una foto';

  @override
  String get audioPickerTitleMultiple => 'Agregar Audios';

  @override
  String get audioPickerTitleSingle => 'Agregar Audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Elige una opción (los archivos permiten varios audios):';

  @override
  String get audioPickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get audioPickerSelectFilesMultiple => 'Seleccionar archivos de audio';

  @override
  String get audioPickerSelectFilesSingle => 'Buscar archivo de audio';

  @override
  String get audioPickerRecord => 'Grabar audio';

  @override
  String get videoPickerTitleMultiple => 'Agregar Videos';

  @override
  String get videoPickerTitleSingle => 'Agregar Video';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Elige una opción (los archivos permiten varios videos):';

  @override
  String get videoPickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get videoPickerSelectFilesMultiple => 'Seleccionar archivos de video';

  @override
  String get videoPickerSelectFilesSingle => 'Buscar archivo de video';

  @override
  String get videoPickerRecord => 'Grabar video';

  @override
  String get successVideoAdded => '¡Video agregado con éxito!';

  @override
  String successVideosAdded(Object count) {
    return '¡$count videos agregados con éxito!';
  }

  @override
  String get startRecording => 'Comenzar grabación';

  @override
  String get recordingPaused => 'Grabación pausada';

  @override
  String get recording => 'Grabando...';

  @override
  String get readyToRecord => 'Listo para grabar';

  @override
  String get notificationDialogTitle => 'Programar notificación';

  @override
  String get notificationDialogPrompt =>
      '¿Cuándo te gustaría ser notificado sobre esta entrada?';

  @override
  String get emailAlreadyRegistered => 'E-mail ya registrado.';

  @override
  String get successNotificationScheduled =>
      'Notificación programada con éxito';

  @override
  String notificationReminderTitle(Object title) {
    return 'Recordatorio: $title';
  }

  @override
  String get notificationReminderBody => 'Tienes una entrada programada';

  @override
  String get successImageAdded => '¡Imagen agregada con éxito!';

  @override
  String successImagesAdded(Object count) {
    return '¡$count imágenes agregadas con éxito!';
  }

  @override
  String errorSearch(Object message) {
    return 'Error en la búsqueda: $message';
  }

  @override
  String get successStoryRestored => 'Historia restaurada con éxito';

  @override
  String get successStoryDeletedPermanently =>
      'Historia eliminada permanentemente';

  @override
  String get trashAlreadyEmpty => 'La papelera ya está vacía';

  @override
  String get successVideoRecorded => '¡Video grabado con éxito!';

  @override
  String get permissionMicrophoneDenied => 'Permiso de micrófono no concedido';

  @override
  String errorSelectImages(Object message) {
    return 'Error al seleccionar imágenes: $message';
  }

  @override
  String get successPhotoCaptured => '¡Foto capturada con éxito!';

  @override
  String get restoreStoriesTitle => 'Restaurar historias';

  @override
  String restoreStoriesConfirm(Object count) {
    return '¿Desea restaurar $count historia(s) seleccionada(s)?';
  }

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get permanentlyDeleteTitle => 'Eliminar permanentemente';

  @override
  String get permanentlyDeleteConfirm =>
      'Esta acción no se puede deshacer. ¿Realmente desea eliminar esta historia permanentemente?';

  @override
  String get permanentlyDeleteLabel => 'Eliminar permanentemente';

  @override
  String deleteGroupConfirm(Object name) {
    return '¿Desea eliminar el grupo \"$name\" de sus historias?';
  }

  @override
  String get recoverPinTitle => 'Recuperar PIN';

  @override
  String get recoverPinDescription =>
      'Enviaremos un código de recuperación a su correo electrónico registrado.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get emptyTrashTitle => 'Empty trash';

  @override
  String emptyTrashConfirm(Object count) {
    return '¿Desea eliminar permanentemente $count historia(s) de la papelera?';
  }

  @override
  String get emptyTrashLabel => 'Empty trash';

  @override
  String errorTakePhoto(Object message) {
    return 'Error al tomar foto: $message';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get entryNotifications => 'Notificaciones de entradas';

  @override
  String get entryNotificationsInfo =>
      'Las entradas con fecha al menos 3 horas por delante pueden tener notificaciones programadas.';

  @override
  String get backgroundRestrictionsWarningTitle =>
      'Notificaciones y Segundo Plano';

  @override
  String get backgroundRestrictionsWarningDesc =>
      'Algunos sistemas reducen drásticamente las actividades en segundo plano para ahorrar energía, lo que puede bloquear las notificaciones programadas. Para asegurar el funcionamiento correcto, abre las configuraciones de la aplicación en tu dispositivo y:\n• Desactiva la opción \'Pausar actividad de la app cuando no se usa\' (o similar).\n• Define las restricciones de batería como \'Sin restricciones\' (no te preocupes, el consumo de batería en segundo plano es insignificante).';

  @override
  String get defaultAdvanceTitle => 'Antelación predeterminada';

  @override
  String get notificationAdvanceTitle => 'Antelación de la notificación';

  @override
  String get notificationAdvancePrompt =>
      '¿Con cuánto tiempo de antelación desea ser notificado?';

  @override
  String get notificationAdvanceDefault => 'Antelación predeterminada';

  @override
  String get notificationScheduleModeTitle => 'Modo de programación (QA)';

  @override
  String get notificationScheduleModeInexact =>
      'Inexacto (compatible con Play)';

  @override
  String get automaticBackup => 'Copia de seguridad automática';

  @override
  String get manageCompleteBackup => 'Administrar copia de seguridad completa';

  @override
  String get backupWithVideosZip =>
      'Copia de seguridad con videos en archivo ZIP';

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
  String get incrementalBackupTitle => 'Carpeta de Backup';

  @override
  String get incrementalBackupDescription =>
      'Tus historias se respaldan automáticamente en esta carpeta cada vez que guardas una.';

  @override
  String get incrementalBackupFolderNotSet => 'Carpeta no configurada';

  @override
  String get incrementalBackupFolderConfigured => 'Carpeta configurada';

  @override
  String get incrementalBackupSelectFolder => 'Seleccionar Carpeta';

  @override
  String get incrementalBackupChangeFolder => 'Cambiar Carpeta';

  @override
  String get incrementalBackupChangingFolder =>
      'Copiando archivos a la nueva carpeta...';

  @override
  String get incrementalBackupFolderChanged => 'Carpeta de copia actualizada.';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Carpeta de copia no configurada. Las historias no se respaldarán hasta que configures una carpeta en Ajustes.';

  @override
  String get incrementalBackupSyncDone => 'Respaldado';

  @override
  String get backupSetupTitle => 'Configurar Carpeta de Copia de Seguridad';

  @override
  String get backupSetupContent =>
      'Elige una carpeta donde tus historias se respaldarán automáticamente. Esto garantiza que tus datos siempre estén seguros.';

  @override
  String get backupSavedToFolder =>
      'Guardando copia en la carpeta configurada...';

  @override
  String get biometricsNotAvailable => 'No disponible en este dispositivo';

  @override
  String get biometricsDisabled => 'Biometría deshabilitada';

  @override
  String get biometricConfiguredInfo =>
      'La biometría está configurada. Puede iniciar sesión usando su huella dactilar.';

  @override
  String get biometricAuthFailed => 'Error en la autenticación biométrica';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirme su identidad para habilitar la biometría';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarFormatMonth => 'Mes';

  @override
  String get calendarFormatTwoWeeks => '2 Semanas';

  @override
  String get calendarFormatWeek => 'Semana';

  @override
  String get groupExists => 'El grupo ya existe';

  @override
  String get enterGroupName => 'Ingrese un nombre para el grupo';

  @override
  String get archivedTitle => 'Archivados';

  @override
  String get toggleToIcons => 'Cambiar a vista de iconos';

  @override
  String get toggleToCards => 'Cambiar a vista de tarjetas';

  @override
  String get menu => 'Menú';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editTip => 'Editar - doble toque';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get close => 'Cerrar';

  @override
  String get newStory => 'Nueva historia';

  @override
  String get newStoryHere => 'Nueva historia aquí';

  @override
  String get noArchivedStories => 'No hay historias archivadas.';

  @override
  String get edit => 'Editar';

  @override
  String previewTitle(Object title) {
    return 'Previsualización - $title';
  }

  @override
  String get archiveLabel => 'Archiv ar';

  @override
  String get storyArchived => 'Historia archivada';

  @override
  String get undo => 'Deshacer';

  @override
  String get ungroup => 'Desagrupar';

  @override
  String noStoriesInGroup(Object group) {
    return 'No hay historias en el grupo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Error al exportar PDF: $error';
  }

  @override
  String get titleRequired => '¡El título es obligatorio!';

  @override
  String errorSavingStory(Object error) {
    return 'Error al guardar la historia: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'El título y la descripción son obligatorios para exportar.';

  @override
  String get exportHistory => 'Exportar historia';

  @override
  String get exportHistoryPrompt =>
      '¿Desea guardar antes de exportar o solo ver una vista previa?';

  @override
  String get preview => 'Vista previa';

  @override
  String get saveAndExport => 'Guardar y exportar';

  @override
  String get untitled => 'Sin título';

  @override
  String errorLoadingFile(Object error) {
    return 'Error al cargar el archivo: $error';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get discardStoryTitle => '¿Descartar historia?';

  @override
  String get unsavedStoryPrompt =>
      'Tiene una historia nueva sin guardar. ¿Salir sin guardar?';

  @override
  String get changeDateTooltip => 'Cambiar fecha';

  @override
  String get storyTitleLabel => 'Título';

  @override
  String get storyTitleHint => 'Ingrese el título';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get descriptionHint => 'Escribe tu historia...';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get photosSection => 'Fotos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Videos';

  @override
  String get importTxtTooltip => 'Importar .txt';

  @override
  String get expandTooltip => 'Expandir';

  @override
  String get photoTooltip => 'Foto';

  @override
  String get videoTooltip => 'Vídeo';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Editar Descripción';

  @override
  String get editStory => 'Editar historia';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesPrompt =>
      'Tiene cambios sin guardar. ¿Salir sin guardar?';

  @override
  String get archivedStateLabel => 'Archivado';

  @override
  String get archivedStoryPrefixLabel => 'Archivada';

  @override
  String get archiveSubtitle => 'Ocultar de la pantalla principal';

  @override
  String get chooseEmoji => 'Elige un emoji';

  @override
  String get emojiGroupSentimentos => 'Sentimientos';

  @override
  String get emojiGroupAnimais => 'Animales';

  @override
  String get emojiGroupVegetais => 'Plantas';

  @override
  String get emojiGroupCeu => 'Cielo';

  @override
  String get emojiGroupObjetos => 'Objetos';

  @override
  String get emojiGroupAlimentos => 'Alimentos';

  @override
  String get emojiGroupLugares => 'Lugares';

  @override
  String get emojiGroupSimbolos => 'Símbolos';

  @override
  String get moodQuestion => '¿Cómo te sentiste en esta historia?';

  @override
  String get moodVeryDifficult => 'Muy difícil';

  @override
  String get moodDifficult => 'Difícil';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodGood => 'Bueno';

  @override
  String get moodVeryGood => 'Muy bueno';

  @override
  String get energyQuestion => '¿Cómo estaba tu energía?';

  @override
  String get energyLow => 'Baja';

  @override
  String get energyNormal => 'Normal';

  @override
  String get energyHigh => 'Alta';

  @override
  String get tagsHint => 'Escribe y presiona Enter o coma';

  @override
  String get addTag => 'Agregar etiqueta';

  @override
  String get tagLongPressHint => 'Mantén presionado para renombrar';

  @override
  String get renameTagTitle => 'Renombrar etiqueta';

  @override
  String get renameTagWarning =>
      'Renombrar afectará todas las historias que usen esta etiqueta.';

  @override
  String get tagNameLabel => 'Nombre de la etiqueta';

  @override
  String get insightDiscovery => 'Descubrimiento';

  @override
  String get insightPattern => 'Patrón encontrado';

  @override
  String get insightTrend => '📈 Tendencia';

  @override
  String get insightMonthlySummary => '📊 Tu mes en historias';

  @override
  String insightBestWeekday(String weekday) {
    return '$weekday suele ser tu día más positivo.';
  }

  @override
  String insightPositiveTag(String tag) {
    return 'Las historias con la etiqueta #$tag tienden a tener mejor estado de ánimo.';
  }

  @override
  String get insightTrendPositive =>
      'Tu estado de ánimo mejoró en los últimos 7 días comparado con los últimos 30 días.';

  @override
  String insightMonthlySummaryText(int entries, String mood, String energy) {
    return 'Entradas: $entries\nEstado de ánimo promedio: $mood\nEnergía promedio: $energy';
  }

  @override
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  ) {
    return 'Entradas: $entries\nEstado de ánimo promedio: $mood\nEnergía promedio: $energy\nEtiqueta más frecuente: #$tag';
  }

  @override
  String get insightSeeStories => 'Ver historias';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get insightDismiss => 'Descartar';

  @override
  String get insightStoryBalanceTitle => 'Equilibrio de Historias';

  @override
  String get insightStoryBalancePositive =>
      'Registraste más historias positivas en los últimos 10 días. ¡Sígue así!';

  @override
  String get insightStoryBalanceDifficult =>
      'Registraste más historias difíciles en los últimos 10 días. ¡Cuídate!';

  @override
  String get insightWritingTimeTitle => 'Horario de Escritura';

  @override
  String get insightWritingTimeMorning =>
      'Escribiste más por la mañana esta semana.';

  @override
  String get insightWritingTimeAfternoon =>
      'Escribiste más por la tarde esta semana.';

  @override
  String get insightWritingTimeNight =>
      'Escribiste más por la noche esta semana.';

  @override
  String get insightEnergyChartTitle => 'Energía — 7 Días';

  @override
  String get insightEnergyChartSubtitle =>
      'Tu evolución de energía esta semana';

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
      'Función Premium. Actualiza para desbloquear este insight.';

  @override
  String get insightPremiumCTA => 'Ver Premium';

  @override
  String get insightDevModeActive => 'Modo dev: todos los insights visibles';

  @override
  String get backupProgressCreating =>
      'Creando archivo de copia de seguridad...';

  @override
  String get backupProgressCopyingDb => 'Copiando base de datos...';

  @override
  String get backupProgressCopyingVideos => 'Copiando videos...';

  @override
  String backupProgressCopyingVideo(int current, int total) {
    return 'Copiando video $current/$total...';
  }

  @override
  String get backupProgressCopyingPhotos => 'Copiando fotos...';

  @override
  String backupProgressCopyingPhoto(int current, int total) {
    return 'Copiando foto $current/$total...';
  }

  @override
  String get backupProgressCopyingAudios => 'Copiando audios...';

  @override
  String backupProgressCopyingAudio(int current, int total) {
    return 'Copiando audio $current/$total...';
  }

  @override
  String get backupProgressCreatingMetadata => 'Creando metadatos...';

  @override
  String get backupProgressCompressing => 'Comprimiendo archivos...';

  @override
  String get backupProgressSuccess => '¡Copia de seguridad creada con éxito!';

  @override
  String get backupShareText =>
      'Copia de seguridad completa de DayApp con base de datos y videos';

  @override
  String get errorBackupDbNotFound => 'Base de datos no encontrada.';

  @override
  String get errorBackupFileNotFound =>
      'Archivo de copia de seguridad no encontrado.';

  @override
  String errorBackupDbNotFoundInFile(int count) {
    return 'Base de datos no encontrada en el archivo de copia de seguridad. Archivos extraídos: $count';
  }

  @override
  String get restoreProgressExtracting =>
      'Extrayendo archivo de copia de seguridad...';

  @override
  String restoreProgressZipContains(int count) {
    return 'El ZIP contiene $count archivos...';
  }

  @override
  String get restoreProgressBackingUpCurrent =>
      'Haciendo copia de la base de datos actual...';

  @override
  String get restoreProgressClosingDb =>
      'Cerrando conexiones de la base de datos...';

  @override
  String get restoreProgressRestoringDb => 'Restaurando base de datos...';

  @override
  String get restoreProgressCopyingRestoredDb =>
      'Copiando base de datos restaurada...';

  @override
  String get restoreProgressRestoringVideos => 'Restaurando videos...';

  @override
  String restoreProgressRestoringVideo(int current, int total) {
    return 'Restaurando video $current/$total...';
  }

  @override
  String get restoreProgressRestoringPhotos => 'Restaurando fotos...';

  @override
  String restoreProgressRestoringPhoto(int current, int total) {
    return 'Restaurando foto $current/$total...';
  }

  @override
  String get restoreProgressRestoringAudios => 'Restaurando audios...';

  @override
  String restoreProgressRestoringAudio(int current, int total) {
    return 'Restaurando audio $current/$total...';
  }

  @override
  String get restoreProgressReinitializingDb => 'Reiniciando base de datos...';

  @override
  String restoreProgressDbStats(int active, int deleted) {
    return 'Base de datos restaurada: $active activas, $deleted en la papelera.';
  }

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String codeExpiresIn(int minutes) {
    return 'El código expira en $minutes minutos';
  }

  @override
  String get backToStart => 'Volver al inicio';

  @override
  String get code => 'Código';

  @override
  String get pin => 'PIN';

  @override
  String get enterCode => 'Ingrese el código';

  @override
  String get codeCheckDescription =>
      'Ingrese el código de 6 dígitos que fue enviado a su correo electrónico.';

  @override
  String get defineNewPin => 'Defina un nuevo PIN seguro para su cuenta.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get verifyCode => 'Verificar código';

  @override
  String get resetPin => 'Restablecer PIN';

  @override
  String get storyPreviewMoodVeryDifficultNarrative =>
      'Esta fue una historia muy difícil';

  @override
  String get storyPreviewMoodDifficultNarrative =>
      'Esta fue una historia difícil';

  @override
  String get storyPreviewMoodNeutralNarrative =>
      'Fue neutro en términos de sentimiento';

  @override
  String get storyPreviewMoodGoodNarrative => 'Una buena historia';

  @override
  String get storyPreviewMoodVeryGoodNarrative => 'Una historia muy buena';

  @override
  String get storyPreviewEnergyLowNarrative => 'Yo estaba con la energía baja';

  @override
  String get storyPreviewEnergyNormalNarrative => 'Mi energía estaba normal';

  @override
  String get storyPreviewEnergyHighNarrative =>
      'Estaba con la energía bien alta';

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
  String get premiumFeature => 'Función de la versión Premium';

  @override
  String get premiumFeatureInfo =>
      'This feature is available in the Premium version.';

  @override
  String get freePlan => 'Gratis';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get premiumDebugTitle => 'Debug Premium';

  @override
  String get premiumDebugSubtitle =>
      'Solo en desarrollo — no visible en producción';

  @override
  String get premiumDebugActivate => 'Activar Premium (debug)';

  @override
  String get premiumDebugDeactivate => 'Desactivar Premium (volver a Free)';

  @override
  String premiumDebugStatus(String plan) {
    return 'Estado: $plan';
  }

  @override
  String premiumDebugSource(String source) {
    return 'Origen: $source';
  }

  @override
  String get premiumDebugWarning =>
      'Esta pantalla solo está disponible en builds de debug. No aparecerá en producción.';

  @override
  String get premiumDebugFeatures => 'Funcionalidades controladas por el plan';

  @override
  String get premiumDebugNoSource => 'ninguna';

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
  String get chaptersTitle => 'Capítulos';

  @override
  String get collectionsTitle => 'Colecciones';

  @override
  String get collectionsSubtitle =>
      'Tus momentos organizados en capítulos y grupos, como una biblioteca de vida.';

  @override
  String get groupsTabLabel => 'Grupos';

  @override
  String get chapterShortcutToggle =>
      'Mostrar/ocultar tarjeta de capítulos en Inicio';

  @override
  String get chaptersHomeCardTitle => 'Tu vida por capítulos';

  @override
  String get chaptersHomeCardSubtitle =>
      'Tus historias guardan momentos. Tus capítulos revelan el camino.';

  @override
  String get chaptersPremiumRequired =>
      'Capítulos y sugerencias automáticas son funciones Premium.';

  @override
  String get themePremiumRequired =>
      'Los temas personalizados son una función Premium.';

  @override
  String get chapterSuggestions => 'Capítulos sugeridos';

  @override
  String get chapterCreated => 'Capítulo creado con éxito.';

  @override
  String get chapterEditTitle => 'Editar capítulo';

  @override
  String get chapterDescriptionHint =>
      'Ingrese una descripción para este capítulo (opcional)';

  @override
  String get chapterUpdated => 'Capítulo actualizado con éxito.';

  @override
  String get chapterDeleteConfirmTitle => 'Eliminar capítulo';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return '¿Eliminar el capítulo “$title”? Las historias vinculadas no serán eliminadas.';
  }

  @override
  String get chapterDeleted => 'Capítulo eliminado con éxito.';

  @override
  String get chapterCreateManual => 'Crear capítulo manualmente';

  @override
  String get chapterCreateTitle => 'Crear Capítulo';

  @override
  String get chapterTitle => 'Título';

  @override
  String get chapterTitleHint => 'Ej: Cambio de trabajo';

  @override
  String get chapterDescription => 'Descripción';

  @override
  String get chapterPhoto => 'Foto del capítulo';

  @override
  String get chapterPhotoActionLabel => 'Foto del Capítulo';

  @override
  String get chapterAddPhoto => 'Agregar foto';

  @override
  String get chapterChangePhoto => 'Cambiar foto';

  @override
  String get chapterRemovePhoto => 'Eliminar foto';

  @override
  String get chapterSelectEntries =>
      'Selecciona al menos 1 historia relacionada';

  @override
  String get chapterMinimumEntries => 'Mínimo: 1 historia por capítulo.';

  @override
  String get groupSelectStories =>
      'Selecciona al menos 1 historia para este grupo';

  @override
  String get groupMinimumStories => 'Mínimo: 1 historia por grupo.';

  @override
  String chapterPeriod(String start, String end) {
    return 'Historias de $start - $end';
  }

  @override
  String chapterEntriesCount(int count) {
    return 'Historias: $count';
  }

  @override
  String chapterAverageMood(String mood) {
    return 'Estado de ánimo promedio: $mood';
  }

  @override
  String chapterTopTags(String tags) {
    return 'Etiquetas principales: $tags';
  }

  @override
  String get chapterCreateFromSuggestion => 'Crear capítulo';

  @override
  String get chapterViewSuggestions => 'Ver sugerencias';

  @override
  String get chapterCreateMyLabel => 'Crear mi Capítulo';

  @override
  String get chapterIgnoreLabel => 'Ignorar';

  @override
  String chapterSuggestionMoreStories(int count) {
    return 'y $count historia(s) más';
  }

  @override
  String get chapterNoItems => 'Tu próximo capítulo empieza aquí.';

  @override
  String get chapterFilterAll => 'Todos';

  @override
  String get chapterFilterAutomatic => 'Automáticos';

  @override
  String get chapterFilterManual => 'Manuales';

  @override
  String get chapterNoSearchResults =>
      'Ningún capítulo coincide con los filtros actuales.';

  @override
  String get chapterSortLabel => 'Ordenar por';

  @override
  String get chapterSortNewest => 'Período más reciente';

  @override
  String get chapterSortOldest => 'Período más antiguo';

  @override
  String get chapterSortTitle => 'Título';

  @override
  String get chapterSortStories => 'Más historias';

  @override
  String chapterEntriesAndMood(int count, String mood) {
    return '$count historias - ánimo promedio $mood';
  }

  @override
  String get chapterOpenLabel => 'Abrir';

  @override
  String get chapterIntroSubtitle =>
      'Organiza tus historias de forma significativa y revive tus recuerdos en orden';

  @override
  String get chapterIntroGroupTitle => 'Une momentos conectados';

  @override
  String get chapterIntroGroupBody =>
      'Reúne varias publicaciones en un solo capítulo para seguir toda la trayectoria de un tema o momento especial.';

  @override
  String get chapterIntroTimelineTitle =>
      'Revive tu historia de principio a fin';

  @override
  String get chapterIntroTimelineBody =>
      'Navega por los recuerdos en orden cronológico y observa cómo cada momento evolucionó con el tiempo.';

  @override
  String get chapterIntroPhaseTitle => 'Un capítulo para cada etapa';

  @override
  String get chapterIntroPhaseBody =>
      'Viajes, universidad, familia, trabajo, sueños, metas o recuerdos especiales. Tú decides cómo contar tu historia.';

  @override
  String get chapterIntroCtaTitle => '¿Listo para organizar tus recuerdos?';

  @override
  String get chapterIntroCtaBody => 'Empieza creando tu primer capítulo ahora';

  @override
  String get chapterIntroShowOnOpen =>
      'Mostrar esta pantalla al abrir Capítulos';

  @override
  String get chapterLinkSectionTitle => 'Capítulos';

  @override
  String get chapterLinkConfigure => 'Configurar';

  @override
  String get chapterLinkDialogTitle => 'Agregar esta historia a capítulos';

  @override
  String get chapterLinkModeNone => 'No agregar';

  @override
  String get chapterLinkModeExisting => 'Agregar a capítulo existente';

  @override
  String get chapterLinkModeNew => 'Crear nuevo capítulo';

  @override
  String get chapterSelectExistingLabel => 'Seleccionar capítulo';

  @override
  String get chapterSelectExistingRequired =>
      'Selecciona un capítulo existente.';

  @override
  String get chapterTitleRequired => 'El título del capítulo es obligatorio.';

  @override
  String get chapterMinimumRelatedWithCurrent =>
      'Selecciona al menos 2 historias relacionadas. Con la historia actual, el mínimo es 3.';

  @override
  String get chapterLinkSummaryNone => 'Sin vínculo con capítulos.';

  @override
  String get chapterLinkSummaryExisting =>
      'Se agregará a un capítulo existente al guardar.';

  @override
  String chapterLinkSummaryNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuevo capítulo con $count historias',
      one: 'Nuevo capítulo con 1 historia',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get homeHeaderLargeCards => 'Ver en tarjetas grandes';

  @override
  String get homeHeaderCompactCards => 'Ver en tarjetas compactas';

  @override
  String get homeHeaderOpenCalendarTooltip => 'Ver calendario';

  @override
  String get homeGreetingMorning => 'Buenos días';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes';

  @override
  String get homeGreetingEvening => 'Buenas noches';

  @override
  String get homeStoriesSubtitle => 'Aquí están tus historias';

  @override
  String get homeShowAllStoriesLabel => 'Ver todas';

  @override
  String get insightHistoryTitle => 'Historial de Insights';

  @override
  String get insightHistoryEmpty => 'Aún no hay insights registrados.';

  @override
  String get insightHistoryClearAll => 'Limpiar historial';

  @override
  String get insightHistoryClearConfirm =>
      '¿Limpiar todo el historial de insights? Esta acción no se puede deshacer.';

  @override
  String insightHistorySeenOn(String date) {
    return 'Visto el $date';
  }

  @override
  String get insightHistoryFilterAll => 'Todos';

  @override
  String get insightHistoryFilterFree => 'Free';

  @override
  String get insightHistoryFilterPremium => 'Premium';

  @override
  String get insightHistorySearch => 'Buscar insights';

  @override
  String get pdfBackgroundColor => 'Color de fondo';

  @override
  String get pdfBackgroundNone => 'Sin color';

  @override
  String get pdfBackgroundBeige => 'Beige/crema';

  @override
  String get pdfBackgroundBlue => 'Azul pálido';

  @override
  String get pdfBackgroundGreen => 'Verde pálido';

  @override
  String get pdfBackgroundGray => 'Gris claro';

  @override
  String get exportPdfPremiumRequired =>
      'Exportar Capítulo es una función Premium. Actualiza tu plan para acceder.';

  @override
  String get changeEmail => 'Cambiar Correo';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get wrongCurrentPassword => 'La contraseña actual es incorrecta.';

  @override
  String get passwordChangedSuccess => 'Contraseña cambiada correctamente.';

  @override
  String get emailChangedSuccess => 'Correo cambiado correctamente.';

  @override
  String get newPasswordMinLength =>
      'La nueva contraseña debe tener al menos 6 caracteres.';

  @override
  String get fillAllFields => 'Por favor, rellene todos los campos.';

  @override
  String get backupInfoDialogTitle => 'Sobre la copia de seguridad';

  @override
  String get backupInfoDialogContent =>
      '📦  Qué incluye la copia de seguridad\n• Todas tus historias (textos, fotos, audios, vídeos)\n• Base de datos de la app\n• Fotos de capítulos\n\n📂  Cómo guardar tu copia de seguridad\nTras la creación, usa el menú de compartir para guardar el archivo donde quieras — OneDrive, Google Drive, correo electrónico u otro servicio.';

  @override
  String get backupPasswordDialogTitle => 'Protege tu copia de seguridad';

  @override
  String get backupPasswordDescription =>
      'Define una contraseña para cifrar el archivo de copia de seguridad. El contenido quedará protegido e ilegible para quien no tenga esta contraseña.';

  @override
  String get backupPasswordWarningTitle =>
      '⚠️  Importante — lee antes de continuar';

  @override
  String get backupPasswordWarning =>
      'Esta contraseña solo la conoces tú. No se almacena en ningún lugar de la app ni en nuestros servidores.\n\nSi la olvidas, el archivo de copia de seguridad quedará permanentemente inaccesible — ni nuestro equipo podrá ayudarte a recuperar los datos.\n\nGuarda esta contraseña en un lugar seguro antes de continuar.';

  @override
  String get backupPasswordField => 'Contraseña';

  @override
  String get backupPasswordConfirmField => 'Confirmar contraseña';

  @override
  String get backupPasswordMismatch =>
      'Las contraseñas no coinciden. Por favor, inténtalo de nuevo.';

  @override
  String get backupPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get backupPasswordEmpty => 'Por favor, ingresa una contraseña.';

  @override
  String get backupCreateEncrypted => 'Crear copia cifrada';

  @override
  String get restorePasswordDialogTitle =>
      'Ingresa la contraseña de la copia de seguridad';

  @override
  String get restorePasswordDescription =>
      'Si definiste una contraseña al crear esta copia de seguridad, ingrésala a continuación.\n\nSi la copia fue creada sin contraseña, deja el campo en blanco.';

  @override
  String get restorePasswordField =>
      'Contraseña (deja en blanco si no se definió)';

  @override
  String get restorePasswordWrong =>
      'Contraseña incorrecta o copia de seguridad ilegible. Verifica la contraseña e inténtalo de nuevo.';

  @override
  String get restoreContinue => 'Continuar';

  @override
  String get chapterExportPhotoSelectionTitle => 'Elegir fotos para exportar';

  @override
  String get chapterExportPhotoSelectionSubtitle =>
      'Puedes seleccionar hasta 1 foto por historia. También puedes dejarla sin foto.';

  @override
  String get chapterExportNoPhotoOption => 'Sin foto';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String codeExpiresMinutes(int count) {
    return 'El código expira en $count minutos';
  }

  @override
  String get codeLabel => 'Código';

  @override
  String get informRegisteredEmail =>
      'Ingrese su correo electrónico registrado';

  @override
  String get newPasswordMinLengthLabel =>
      'Nueva contraseña (mínimo 6 caracteres)';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get informYourEmailTitle => 'Ingrese su correo electrónico';

  @override
  String get enterCodeTitle => 'Ingrese el código';

  @override
  String get newPasswordTitle => 'Nueva contraseña';

  @override
  String get emailStepSubtitle =>
      'Enviaremos un código de recuperación al correo electrónico registrado en su cuenta.';

  @override
  String get codeStepSubtitle =>
      'Ingrese el código de 6 dígitos que fue enviado a su correo electrónico.';

  @override
  String get passwordStepSubtitle =>
      'Defina una nueva contraseña segura para su cuenta.';

  @override
  String get sendCodeButtonLabel => 'Enviar código';

  @override
  String get verifyCodeButtonLabel => 'Verificar código';

  @override
  String get resetPasswordButtonLabel => 'Restablecer contraseña';

  @override
  String get birthDateCannotBeFuture =>
      'La fecha de nacimiento no puede ser en el futuro.';

  @override
  String get birthDateMinAge => 'Debes tener al menos 14 años de edad.';

  @override
  String get successAudioAdded => '¡Audio agregado con éxito!';

  @override
  String get photoDeleted => 'Foto eliminada';

  @override
  String get videoSavedSuccess => 'Video guardado con éxito';

  @override
  String get videoPlaybackNotAvailableWindows =>
      'Reproducción de video no disponible en Windows';

  @override
  String get supportEmailSubjectLogin => 'Soporte DayApp - Login';

  @override
  String get supportEmailBodyLogin =>
      'Hola, necesito ayuda con el inicio de sesión en DayApp...';

  @override
  String successAudiosAdded(int count) {
    return '$count audios agregados con éxito!';
  }

  @override
  String sizeLabel(String size) {
    return 'Tamaño: $size MB';
  }

  @override
  String durationLabel(String duration) {
    return 'Duración: $duration';
  }

  @override
  String get editDoubleTapHint => 'Editar - 2 toques';

  @override
  String deleteGroupWarningText(String groupName) {
    return '¿Desea eliminar el grupo \"$groupName\"? Las historias de este grupo no se eliminarán, solo se quitarán del grupo.';
  }

  @override
  String createdOn(String date) {
    return 'Creado el $date';
  }

  @override
  String get editorPlaceholder => 'Escribe aquí...';

  @override
  String get aboutFlutterDesc => 'Framework para desarrollo multiplataforma';

  @override
  String get aboutDartDesc => 'Lenguaje de programación moderno y eficiente';

  @override
  String get aboutSqliteDesc => 'Base de datos local robusta y confiable';

  @override
  String get aboutProviderDesc => 'Gestión de estado reactivo';

  @override
  String get aboutMaterial3Title => 'Material Design 3';

  @override
  String get aboutMaterial3Desc => 'Design system moderno y accesible';

  @override
  String get aboutScreenTechnologiesTitle => 'Tecnologías';

  @override
  String get insightMood7Days => 'Humor — 7 Días';

  @override
  String get insightMoodVariationThisWeek =>
      'Tu variación de humor esta semana';

  @override
  String chapterExportPartLabel(int index, int total) {
    return 'Parte $index de $total';
  }

  @override
  String chapterExportSplitExplanation(int parts) {
    return 'Para garantizar un mejor rendimiento y compatibilidad al enviar, este capítulo se dividió en $parts archivos.';
  }

  @override
  String get chapterTitleDuplicateTitle => 'Título Duplicado';

  @override
  String get chapterTitleDuplicateMessage =>
      'Ya existe un capítulo con este título. Por favor, elija otro título.';

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
  String get invalidBackupFilenameTitle => 'Nombre de archivo inválido';

  @override
  String invalidBackupFilenameMessage(String fileName) {
    return 'El archivo seleccionado \'$fileName\' no es un archivo de copia de seguridad estándar.\n\nPor favor, seleccione un archivo de copia de seguridad válido.';
  }

  @override
  String get restoreFailedTitle => 'Fallo en la restauración';

  @override
  String get restoreFailedMessage =>
      'El archivo seleccionado no es una copia de seguridad de DayApp. ¿Desea intentarlo de nuevo?';

  @override
  String get backupFailedMessage =>
      'Ocurrió un error al crear la copia de seguridad. ¿Desea intentarlo de nuevo?';

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
  String get backupFailedTitle => 'Fallo en la copia de seguridad';

  @override
  String homeGreetingPhrase(String name, String greeting) {
    return '¡Hola, $name! $greeting.';
  }

  @override
  String homeGreetingPhraseNoName(String greeting) {
    return '¡Hola! $greeting.';
  }

  @override
  String get homeGreetingSubtitle =>
      '\"¿Cómo está tu día? ¿Vamos a registrar?\"';

  @override
  String get startNewStoryPlaceholder => 'Comenzar una nueva historia...';

  @override
  String get viewAllStoriesLabel => 'Ver todas las historias';

  @override
  String get continuaLabel => 'Continúa';

  @override
  String get continuaQuestion => '¿Esta historia continúa?';

  @override
  String get continuaNo => 'No';

  @override
  String get continuaDontKnow => 'No lo sé';

  @override
  String get continuaMaybe => 'Quizás';

  @override
  String get continuaYes => 'Sí';
}
