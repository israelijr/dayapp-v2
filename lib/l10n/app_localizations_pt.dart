// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get deviceDefault => 'Padrão do dispositivo';

  @override
  String get defaultLabel => 'Padrão';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francês';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get errorInitializingApp => 'Erro ao inicializar o app';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Segurança';

  @override
  String get themeAndScheme => 'Tema e Esquema';

  @override
  String get themeRelva => 'Relva';

  @override
  String get themeOutono => 'Jardim Botânico';

  @override
  String get themeCeu => 'Céu';

  @override
  String get themeConfort => 'Conforto';

  @override
  String get themeSunset => 'Pôr do Sol';

  @override
  String get themeMidnightGalaxy => 'Galáxia da Meia-noite';

  @override
  String get themeDefaultLightDescription => 'Tema claro padrão';

  @override
  String get themeDefaultDarkDescription => 'Tema escuro padrão';

  @override
  String get themeFollowSystemDescription => 'Seguir tema do sistema';

  @override
  String get themeCustomSchemesTitle => 'Esquemas Personalizados';

  @override
  String get themeRelvaLight => 'Relva (Claro)';

  @override
  String get themeRelvaDark => 'Relva (Escuro)';

  @override
  String get themeOutonoLight => 'Jardim Botânico (Claro)';

  @override
  String get themeOutonoDark => 'Jardim Botânico (Escuro)';

  @override
  String get themeRelvaLightDescription => 'Tons verdes e naturais';

  @override
  String get themeRelvaDarkDescription => 'Versão escura do esquema Relva';

  @override
  String get themeOutonoLightDescription =>
      'Tons frescos e orgânicos de jardim';

  @override
  String get themeOutonoDarkDescription =>
      'Versão escura do esquema Jardim Botânico';

  @override
  String get themeRemoveScheme => 'Remover Esquema';

  @override
  String get themeRemoveSchemeDescription => 'Voltar ao esquema padrão do tema';

  @override
  String get timeAtConnector => 'às';

  @override
  String get timeAgoNow => 'agora';

  @override
  String timeAgoMinutes(int count) {
    return '$count min atrás';
  }

  @override
  String timeAgoHours(int count) {
    return '${count}h atrás';
  }

  @override
  String timeAgoDays(int count) {
    return '$count dia(s) atrás';
  }

  @override
  String get backup => 'Backup';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get pinUnlock => 'PIN de Desbloqueio';

  @override
  String get changePin => 'Alterar PIN';

  @override
  String get enableBiometrics => 'Login com Biometria';

  @override
  String get information => 'Informações';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get configurePin => 'Configurar PIN';

  @override
  String get biometrics => 'Biometria';

  @override
  String get backgroundLock => 'Bloqueio em Segundo Plano';

  @override
  String get backgroundLockDialogPrompt =>
      'Após quanto tempo em segundo plano o app deve ser bloqueado?';

  @override
  String get backgroundLockTimeLabel => 'Tempo';

  @override
  String get backgroundLockDialogResult => 'Resultado:';

  @override
  String get backgroundLockSuggestions => 'Sugestões:';

  @override
  String get backgroundLockImmediateHint => '0 = imediato';

  @override
  String get backgroundLockNever => 'Não bloquear';

  @override
  String get backgroundLockImmediately => 'Imediatamente';

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
  String get statistics => 'Estatísticas';

  @override
  String get noStoriesYetTitle => 'Nenhuma história registrada ainda';

  @override
  String get noStoriesYetSubtitle =>
      'Comece a registrar seus dias para ver as estatísticas';

  @override
  String get trends => 'Tendências';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get activityByWeekday => 'Atividade por dia da semana';

  @override
  String get streaksTitle => 'Dias seguidos';

  @override
  String get longestStreakPrefix => 'Sequência mais longa:';

  @override
  String get tableOfMoods => 'Tabela de humores';

  @override
  String get moodCount => 'Contagem de humor';

  @override
  String get topTags => 'Top tags';

  @override
  String get storiesLabel => 'Histórias';

  @override
  String get activeDaysLabel => 'Dias ativos';

  @override
  String get avgPerDayLabel => 'Média/dia';

  @override
  String get mediaLabel => 'Mídias';

  @override
  String get manageGroups => 'Grupos';

  @override
  String get trash => 'Lixeira';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get aboutScreenAboutDayAppTitle => 'Sobre o DayApp';

  @override
  String get aboutScreenAboutDayAppDescription =>
      'O DayApp é um aplicativo de diário pessoal moderno e seguro que permite registrar suas histórias, memórias e pensamentos de forma organizada e privada. Com interface intuitiva e recursos avançados, o DayApp ajuda você a preservar suas experiências mais importantes.';

  @override
  String get aboutScreenFeaturesTitle => 'Funcionalidades';

  @override
  String get aboutScreenFeatureRichEditorTitle => 'Editor Rico';

  @override
  String get aboutScreenFeatureRichEditorDescription =>
      'Crie histórias com formatação avançada, imagens, vídeos e áudios';

  @override
  String get aboutScreenFeatureSmartOrganizationTitle =>
      'Organização Inteligente';

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Categorize suas histórias em grupos temáticos personalizados e Capítulos que contam sobre você';

  @override
  String get aboutScreenFeatureAdvancedSearchTitle => 'Pesquisa Avançada';

  @override
  String get aboutScreenFeatureAdvancedSearchDescription =>
      'Encontre rapidamente qualquer história por conteúdo ou data';

  @override
  String get aboutScreenFeatureSecureBackupTitle => 'Backup Seguro';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Projeta seus dados com backups regulares.';

  @override
  String get aboutScreenFeatureTotalPrivacyTitle => 'Privacidade Total';

  @override
  String get aboutScreenFeatureTotalPrivacyDescription =>
      'Seus dados ficam armazenados localmente e criptografados';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceTitle => 'Interface Adaptável';

  @override
  String get aboutScreenFeatureAdaptiveInterfaceDescription =>
      'Tema claro/escuro e layouts personalizáveis';

  @override
  String get aboutScreenVersionTitle => 'Versão';

  @override
  String aboutScreenVersionBuild(String version, String build) {
    return 'Versão $version (Build $build)';
  }

  @override
  String aboutScreenVersionShort(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutScreenDevelopmentTitle => 'Desenvolvimento';

  @override
  String get aboutScreenDevelopmentDescription =>
      'Desenvolvido com dedicação para oferecer a melhor experiência em registro de memórias pessoais.';

  @override
  String get aboutScreenPrivacySecurityTitle => 'Privacidade e Segurança';

  @override
  String get aboutScreenPrivacyLocalDataTitle => 'Dados Locais';

  @override
  String get aboutScreenPrivacyLocalDataDescription =>
      'Todas as suas histórias ficam armazenadas apenas no seu dispositivo';

  @override
  String get aboutScreenPrivacyEncryptionTitle => 'Criptografia';

  @override
  String get aboutScreenPrivacyEncryptionDescription =>
      'Conteúdo sensível é protegido com criptografia avançada';

  @override
  String get aboutScreenPrivacyNoTrackingTitle => 'Sem Rastreamento';

  @override
  String get aboutScreenPrivacyNoTrackingDescription =>
      'Não coletamos dados pessoais nem rastreamos seu uso';

  @override
  String get aboutScreenPrivacyPinSecurityTitle => 'PIN de Segurança';

  @override
  String get aboutScreenPrivacyPinSecurityDescription =>
      'Proteja o acesso ao app com PIN ou biometria';

  @override
  String get aboutScreenContactSupportTitle => 'Contato e Suporte';

  @override
  String get aboutScreenContactSupportDescription =>
      'Para dúvidas, sugestões ou suporte técnico:';

  @override
  String get aboutScreenSupportEmailSubject => 'Suporte DayApp';

  @override
  String aboutScreenSupportEmailBody(String version) {
    return 'Olá, preciso de ajuda com o DayApp...\n\nVersão: $version\n';
  }

  @override
  String get aboutScreenAcknowledgementsTitle => 'Agradecimentos';

  @override
  String get aboutScreenAcknowledgementsDescription =>
      'Agradecemos por escolher o DayApp para registrar suas memórias mais preciosas. Sua confiança e feedback são essenciais para continuarmos melhorando.';

  @override
  String get aboutScreenHeaderSubtitle => 'Seu Diário Pessoal';

  @override
  String get aboutScreenCopyright =>
      '© 2026 DayApp. Todos os direitos reservados.';

  @override
  String get logout => 'Sair';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get name => 'Nome';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? Faça login';

  @override
  String get needHelp => 'Precisa de ajuda?';

  @override
  String get currentPinLabel => 'PIN atual';

  @override
  String get newPinLabel => 'Novo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterCurrentPin => 'Digite o PIN atual';

  @override
  String get enterPin => 'Digite o PIN';

  @override
  String get pinLengthError => 'O PIN deve ter entre 4 e 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Os PINs não coincidem';

  @override
  String get pinIncorrect => 'PIN atual incorreto';

  @override
  String get pinChangedSuccess => 'PIN alterado com sucesso!';

  @override
  String get pinConfiguredSuccess => 'PIN configurado com sucesso!';

  @override
  String get informYourEmail => 'Informe seu e-mail.';

  @override
  String get invalidEmail => 'Informe um e-mail válido.';

  @override
  String get emailNotFound =>
      'E-mail não encontrado. Verifique e tente novamente.';

  @override
  String codeSent(Object email) {
    return 'Código enviado para $email! Verifique sua caixa de entrada.';
  }

  @override
  String get codeMustBe6 => 'O código deve ter 6 dígitos.';

  @override
  String get codeVerified => 'Código verificado! Defina sua nova senha.';

  @override
  String get codeInvalid => 'Código inválido ou expirado. Tente novamente.';

  @override
  String get enterNewPassword => 'Informe a nova senha.';

  @override
  String get passwordResetSuccess =>
      'Senha redefinida com sucesso! Faça login com a nova senha.';

  @override
  String get errorResetPassword =>
      'Erro ao redefinir a senha. Tente novamente.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get resendCodeSuccess =>
      'Novo código enviado! Verifique sua caixa de entrada.';

  @override
  String get resendCodeError => 'Erro ao reenviar código. Tente novamente.';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get fullName => 'Nome completo';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get almostReady => 'quase pronto...';

  @override
  String get optionalData => 'Os dados abaixo são opcionais';

  @override
  String get birthDateFormat => 'Data de nascimento (DD/MM/AAAA)';

  @override
  String get invalidBirthDate => 'Data de nascimento inválida (use DD/MM/AAAA)';

  @override
  String get userNotFound => 'Usuário não encontrado.';

  @override
  String get create => 'Criar';

  @override
  String get nameRequired => 'Nome é obrigatório';

  @override
  String get nameMinLength => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get emailInvalid => 'Digite um e-mail válido';

  @override
  String get welcomeBack => 'Bem vindo de volta!';

  @override
  String get accessAccount => 'Acesse sua conta';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get signIn => 'Acessar';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get noAccountCreateHere => 'Não tem conta, crie uma aqui.';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get biometricsEnabledSuccess => 'Biometria habilitada com sucesso!';

  @override
  String get biometricLoginError => 'Erro ao fazer login com biometria.';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso!';

  @override
  String get profileUpdateError => 'Erro ao atualizar perfil. Tente novamente.';

  @override
  String get unlockAppReason => 'Desbloqueie o app para continuar';

  @override
  String get fillEmailAndPassword => 'Preencha o e-mail e a senha';

  @override
  String get emailOrPasswordIncorrect => 'E-mail ou senha incorretos';

  @override
  String get noEmailRegistered =>
      'Nenhum e-mail cadastrado. Configure nas configurações.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Verifique seu e-mail em $email ou use o código exibido';
  }

  @override
  String get errorGeneratingCode => 'Erro ao gerar código. Tente novamente.';

  @override
  String get errorSendingCode => 'Erro ao enviar código. Tente novamente.';

  @override
  String get enterRecoveryCodePrompt =>
      'Digite o código que foi enviado para seu e-mail:';

  @override
  String get recoveryCodeLabel => 'Código de recuperação (6 dígitos)';

  @override
  String get enterPasswordToContinue => 'Digite sua senha para continuar';

  @override
  String get enterPinToContinue => 'Digite seu PIN para continuar';

  @override
  String get useBiometricsToContinue => 'Use sua biometria para continuar';

  @override
  String get usePin => 'Usar PIN';

  @override
  String get noStoriesHere => 'Nenhuma história para exibir aqui.';

  @override
  String get storiesGroupedOrArchived => 'Elas estão agrupadas ou arquivadas.';

  @override
  String get useBiometrics => 'Usar biometria';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get useAccountPassword => 'Usar senha da conta';

  @override
  String get forgotPin => 'Esqueci meu PIN';

  @override
  String get unlockTitle => 'Desbloqueie o App';

  @override
  String get search => 'Pesquisar';

  @override
  String get searchStoriesTitle => 'Pesquise suas histórias';

  @override
  String get searchStoriesSubtitle =>
      'Use os filtros acima para encontrar suas memórias.';

  @override
  String unsavedBackups(Object count) {
    return 'Você tem $count histórias sem backup.';
  }

  @override
  String get backupRecommendation =>
      'Recomendamos fazer backup para evitar perder seus dados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get restore => 'Restaurar';

  @override
  String get delete => 'Deletar';

  @override
  String get deleted => 'Deletado';

  @override
  String get performBackup => 'Fazer backup';

  @override
  String get deleteStoryTitle => 'Excluir história';

  @override
  String get deleteStoryConfirm => 'Deseja mover esta história para a lixeira?';

  @override
  String get deleteLabel => 'Excluir';

  @override
  String get movedToTrash => 'História movida para a lixeira';

  @override
  String errorDeletingStory(Object error) {
    return 'Erro ao excluir história: $error';
  }

  @override
  String get noRecordsThisDay => 'Nenhum registro neste dia';

  @override
  String get storyUngrouped => 'História desagrupada';

  @override
  String get save => 'Salvar';

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get groupDeletedSuccess => 'Grupo excluído com sucesso';

  @override
  String get noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get shareError => 'Não foi possível compartilhar';

  @override
  String get cannotDeletePhoto => 'Não é possível excluir esta foto';

  @override
  String get deletePhotoTitle => 'Excluir foto';

  @override
  String get deletePhotoConfirm => 'Deseja realmente excluir esta foto?';

  @override
  String get deleteGroupTitle => 'Excluir Grupo';

  @override
  String get share => 'Compartilhar';

  @override
  String get scrapbookTemplateLabel => 'Scrapbook';

  @override
  String get polaroidTemplateLabel => 'Polaroid';

  @override
  String get home => 'Início';

  @override
  String get groups => 'Grupos';

  @override
  String get myStories => 'Minhas Histórias';

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
  String get searchHintTag => 'Digite uma tag...';

  @override
  String get searchHintText => 'Pesquisar no título ou na descrição...';

  @override
  String get clearSearchTooltip => 'Limpar pesquisa';

  @override
  String get clear => 'Limpar';

  @override
  String get tapToSelectEmoji => 'Toque para selecionar um emoji:';

  @override
  String get selectEmoji => 'Selecionar emoji';

  @override
  String get tapToChangeEmoji => 'Toque para alterar';

  @override
  String get searchButton => 'Buscar';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get takePhoto => 'Tirar uma foto';

  @override
  String get recordVideoLabel => 'Gravar vídeo';

  @override
  String get recordAudioLabel => 'Gravar áudio';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get dontShowAgain => 'Não mostrar novamente';

  @override
  String get laterLabel => 'Mais tarde';

  @override
  String get configureLabel => 'Configurar';

  @override
  String get imageCopiedBase64 =>
      'Imagem copiada para a área de transferência (base64)';

  @override
  String get newGroup => 'Novo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Escolher ícone';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tem $count história(s) vinculada(s). Se excluído, essas histórias voltarão para a tela inicial (sem grupo). Continuar?';
  }

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get group => 'Grupo';

  @override
  String get selectGroup => 'Selecionar Grupo';

  @override
  String get selectLabel => 'Selecionar';

  @override
  String get existingGroups => 'Grupos Existentes';

  @override
  String get createNewGroup => 'Criar Novo Grupo';

  @override
  String get groupNameLabel => 'Nome do Grupo';

  @override
  String get createAndSelect => 'Criar e Selecionar';

  @override
  String get manageBackups => 'Gerenciar Backup';

  @override
  String get createAndShareBackup => 'Criar e Compartilhar Backup';

  @override
  String get restoreFromFile => 'Restaurar de Arquivo';

  @override
  String get backupNotAvailableWeb => 'Backup não disponível na versão web';

  @override
  String get backupNotAvailableDetail =>
      'O recurso de backup requer acesso ao sistema de arquivos, disponível apenas nas versões Android, iOS e Desktop.';

  @override
  String get backupInfoTitle => 'Sobre o Backup';

  @override
  String get backupInfoDetails =>
      'O backup completo inclui:\n• Banco de dados (histórias, textos, fotos, áudios)\n• Arquivos de vídeo\n\nUm arquivo ZIP será criado e você pode salvá-lo onde quiser:\n• OneDrive\n• Google Drive\n• Email\n• Qualquer outro local';

  @override
  String get backupComplete => 'Backup Completo';

  @override
  String get backupZipSubtitle => 'Arquivo ZIP com todos os seus dados';

  @override
  String get backupZipExplanation =>
      'Gera um arquivo ZIP que você pode salvar no seu dispositivo, OneDrive, Google Drive, email ou qualquer outro local na nuvem, exceto apps de mensagens.';

  @override
  String get backupLinuxExplanation =>
      'Escolha uma pasta e o backup ZIP será guardado diretamente nela.';

  @override
  String get restoreSectionTitle => 'Restaurar Backup';

  @override
  String get restoreSectionDescription =>
      'Selecione um arquivo de backup (ZIP) anteriormente criado para restaurar todos os seus dados.';

  @override
  String get backupShareSubject => 'Backup DayApp';

  @override
  String backupDeleteConfirm(String fileName) {
    return 'Tem certeza que deseja deletar este backup?\n\n$fileName';
  }

  @override
  String backupShareError(String message) {
    return 'Erro ao compartilhar backup: $message';
  }

  @override
  String backupDeleteError(String message) {
    return 'Erro ao deletar backup: $message';
  }

  @override
  String get processing => 'Processando...';

  @override
  String get pleaseWait => 'Por favor, aguarde...';

  @override
  String get backupStarting => 'Iniciando backup...';

  @override
  String get backupCreatedSuccess =>
      'Arquivo de backup criado! Use o menu de compartilhamento para salvá-lo.';

  @override
  String backupError(Object message) {
    return 'Erro ao criar backup: $message';
  }

  @override
  String get restoreStarting => 'Iniciando restauração...';

  @override
  String get restoreSuccess => 'Restauração concluída com sucesso!';

  @override
  String restoreError(Object message) {
    return 'Erro ao restaurar: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirmar Restauração';

  @override
  String get restoreConfirmContent =>
      'Todos os dados atuais serão substituídos pelo backup.\n\nEsta ação não pode ser desfeita. Deseja continuar?';

  @override
  String get restoreSuccessTitle => '✅ Restauração Concluída';

  @override
  String get restoreSuccessContent =>
      'O backup foi restaurado com sucesso!\n\nTodas as suas histórias foram restauradas ao estado do backup.\n\nÉ necessário fazer login novamente para completar o processo.';

  @override
  String get helpAboutTitle => 'Sobre o DayApp';

  @override
  String get helpAboutDescription =>
      'O DayApp é um aplicativo de diário pessoal que permite registrar suas histórias, memórias e pensamentos de forma organizada e segura.';

  @override
  String get helpNavigationTitle => 'Navegação Principal';

  @override
  String get helpHomeItemDesc =>
      'Visualize as 5 últimas histórias ou todas em cartões grandes, reduzidos ou no calendário';

  @override
  String get helpHomeDoubleTapDesc =>
      'Dê um toque duplo em uma história para visualizar.';

  @override
  String get helpHomeAttachmentsDesc => 'Toque nos anexos para visualizar.';

  @override
  String get helpHomeSwipeRightDesc =>
      'Arraste o card para a direita para Arquivar a história. A história é movida para a aba Coleções / Grupos / Arquivados';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Arraste o card para a esquerda para associar a um Grupo. A história é movida para a aba Coleções / Grupos / Arquivados';

  @override
  String get helpHomeCalendarIconDesc =>
      'Toque no ícone de calendário para visualizar suas histórias nesse formato.';

  @override
  String get helpHomeChapterIconDesc =>
      'Organize suas histórias em Capítulos e Grupos temáticos. Crie Capítulos e conte sua história completa. Crie Grupos personalizados para categorizar suas memórias.';

  @override
  String get helpGroupsNavDesc =>
      'Organize suas histórias em Capítulos e Grupos temáticos. Crie Capítulos e conte sua história completa. Crie Grupos personalizados para categorizar suas memórias.';

  @override
  String get helpSearchItemDesc =>
      'Encontre histórias rapidamente por título, conteúdo, tag ou data.';

  @override
  String get helpCreatingTitle => 'Criando Histórias';

  @override
  String get helpNewStoryDesc =>
      'Toque no botão flutuante (+ Nova História) para criar uma nova história. Adicione título, texto, imagens, vídeos e áudios.';

  @override
  String get helpTextEditorTitle => 'Editor de Texto';

  @override
  String get helpTextEditorDesc =>
      'Use formatação rica: negrito, itálico, listas, links e muito mais.';

  @override
  String get helpChaptersDesc =>
      'Organize sua história em capítulos juntando outras histórias sobre o mesmo assunto.';

  @override
  String get helpMediaDesc =>
      'Adicione fotos da galeria ou câmera, grave vídeos ou áudios diretamente no app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associe cada história a um ou mais grupos para melhor organização.';

  @override
  String get helpCalendarDesc =>
      'Visualize suas histórias organizadas por data. Toque em uma data para ver todas as histórias daquele dia.';

  @override
  String get helpCreateGroupTitle => 'Criar Grupo';

  @override
  String get helpCreateGroupDesc =>
      'Acesse \"Grupos\" no menu lateral para criar novos grupos com cores e emoticons personalizadas.';

  @override
  String get helpEditGroupTitle => 'Editar Grupo';

  @override
  String get helpEditGroupDesc =>
      'Toque em um grupo para editar nome, emoticon ou excluir.';

  @override
  String get helpGroupsAssocTitle => 'Associar a Grupos';

  @override
  String get helpDeleteGroupTitle => 'Excluir Grupo';

  @override
  String get helpDeleteGroupDesc =>
      'Exclua um Grupo sem que as histórias sejam também excluídas.';

  @override
  String get helpInsightsTitle => 'Insights';

  @override
  String get helpInsightsDesc =>
      'Receba insights baseados em suas histórias na tela inicial.\nAlguns insights estão disponíveis apenas na versão Premium.\nAcesse o histórico de insights no menu lateral.';

  @override
  String get helpBackupSecurityTitle => 'Backup e Segurança';

  @override
  String get helpAutomaticBackupTitle => 'Automatic Backup';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure automatic backup (Premium) in Settings. The backup will be created when you log out.';

  @override
  String get helpManualBackupTitle => 'Backup';

  @override
  String get helpManualBackupDesc =>
      'Acesse \"Gerenciar Backup Completo\" nas Configurações para criar backup completo com todas as mídias.';

  @override
  String get helpRestoreTitle => 'Restauração';

  @override
  String get helpRestoreDesc =>
      'Use \"Restaurar de Arquivo\" para recuperar dados de um backup anterior.';

  @override
  String get helpPinSecurityTitle => 'PIN de Segurança';

  @override
  String get helpPinSecurityDesc =>
      'Configure um PIN de 4 a 8 dígitos para proteger o acesso ao app.';

  @override
  String get helpBiometricsDesc =>
      'Use digital ou reconhecimento facial para desbloquear o app rapidamente, se disponível no dispositivo.';

  @override
  String get helpPasswordUnlockTitle => 'Desbloqueio por Senha';

  @override
  String get helpPasswordUnlockDesc =>
      'Além de PIN e biometria, você pode desbloquear o app usando a senha da sua conta. Útil caso esqueça o PIN ou a biometria falhe.';

  @override
  String get helpBackgroundLockDesc =>
      'Quando o app é minimizado ou você troca para outro app, ele é bloqueado automaticamente após o tempo configurado. Você pode definir o tempo livremente nas configurações (segundos, minutos ou horas).';

  @override
  String get helpLockExceptionsTitle => 'Exceções de Bloqueio';

  @override
  String get helpLockExceptionsDesc =>
      'O app não bloqueia quando você usa recursos internos que abrem outros apps — como selecionar fotos da galeria, gravar vídeos, escolher local de backup ou compartilhar histórias.';

  @override
  String get helpPinRecoveryTitle => 'Recuperação de PIN';

  @override
  String get helpPinRecoveryDesc =>
      'Esqueceu o PIN? Use a opção \"Esqueci meu PIN\" na tela de bloqueio. Um código de recuperação será enviado para o e-mail cadastrado.';

  @override
  String get helpThemeDesc =>
      'Alterne entre temas claro, escuro, automático além de outros disponíveis na versão Premium.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configure como a notificação de lembrete do app irá se comportar ao criar histórias com data futura.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Defina por quanto tempo o app pode ficar em segundo plano antes de ser bloqueado. Você pode usar valores em segundos, minutos ou horas, com total liberdade.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc =>
      'Gerencie configurações de backup e restauração.';

  @override
  String get helpTrashDesc =>
      'Histórias excluídas ficam na lixeira por 30 dias. Acesse \"Lixeira\" no menu lateral para recuperar ou excluir permanentemente.';

  @override
  String get helpStatisticsDesc =>
      'Visualize estatísticas sobre seu uso do diário: número de histórias, palavras escritas, grupos mais usados, etc.';

  @override
  String get helpTipsTitle => 'Dicas de Uso';

  @override
  String get helpOrganizationTipTitle => 'Organização';

  @override
  String get helpOrganizationTipDesc =>
      'Use Grupos para categorizar suas histórias por temas, e Capítulos para contar toda a história.';

  @override
  String get helpSearchTipTitle => 'Pesquisa';

  @override
  String get helpSearchTipDesc =>
      'Use a função de pesquisa para encontrar histórias antigas rapidamente.';

  @override
  String get helpBackupTipTitle => 'Backup Regular';

  @override
  String get helpBackupTipDesc =>
      'Faça backup regularmente, especialmente antes de atualizações ou mudanças no dispositivo.';

  @override
  String get helpPrivacyTipTitle => 'Privacidade';

  @override
  String get helpPrivacyTipDesc =>
      'Suas histórias são armazenadas localmente e criptografadas. Configure PIN para proteção adicional.';

  @override
  String get helpSupportTitle => 'Suporte';

  @override
  String get helpSupportDesc =>
      'Para dúvidas ou problemas, entre em contato conosco através do email de suporte ou verifique as atualizações do app.';

  @override
  String get errorCreateAccount => 'Erro ao criar conta. Tente novamente.';

  @override
  String get errorShare => 'Erro ao compartilhar';

  @override
  String errorPlayAudio(Object message) {
    return 'Erro ao reproduzir áudio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Erro ao selecionar vídeos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Erro ao selecionar arquivo: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Erro ao gravar vídeo: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Erro ao iniciar gravação: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Erro ao pausar gravação: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Erro ao retomar gravação: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Erro ao parar gravação: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Erro ao selecionar áudios: $message';
  }

  @override
  String get errorLoadVideo => 'Erro ao carregar vídeo';

  @override
  String get errorSelectImage => 'Erro ao selecionar imagem';

  @override
  String get imagePickerTitleMultiple => 'Adicionar Fotos';

  @override
  String get imagePickerTitleSingle => 'Adicionar Foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Escolha uma opção (galeria permite múltiplas fotos):';

  @override
  String get imagePickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get imagePickerGalleryMultiple => 'Selecionar da galeria';

  @override
  String get imagePickerGallerySingle => 'Buscar na galeria';

  @override
  String get imagePickerTakePhoto => 'Tirar uma foto';

  @override
  String get audioPickerTitleMultiple => 'Adicionar Áudios';

  @override
  String get audioPickerTitleSingle => 'Adicionar Áudio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos áudios):';

  @override
  String get audioPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get audioPickerSelectFilesMultiple => 'Selecionar arquivos de áudio';

  @override
  String get audioPickerSelectFilesSingle => 'Buscar arquivo de áudio';

  @override
  String get audioPickerRecord => 'Gravar um áudio';

  @override
  String get videoPickerTitleMultiple => 'Adicionar Vídeos';

  @override
  String get videoPickerTitleSingle => 'Adicionar Vídeo';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos vídeos):';

  @override
  String get videoPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get videoPickerSelectFilesMultiple => 'Selecionar arquivos de vídeo';

  @override
  String get videoPickerSelectFilesSingle => 'Buscar arquivo de vídeo';

  @override
  String get videoPickerRecord => 'Gravar um vídeo';

  @override
  String get successVideoAdded => 'Vídeo adicionado com sucesso!';

  @override
  String successVideosAdded(Object count) {
    return '$count vídeos adicionados com sucesso!';
  }

  @override
  String get startRecording => 'Iniciar Gravação';

  @override
  String get recordingPaused => 'Gravação Pausada';

  @override
  String get recording => 'Gravando...';

  @override
  String get readyToRecord => 'Pronto para Gravar';

  @override
  String get notificationDialogTitle => 'Agendar Notificação';

  @override
  String get notificationDialogPrompt =>
      'Quando você gostaria de ser notificado sobre esta entrada?';

  @override
  String get emailAlreadyRegistered => 'E-mail já cadastrado.';

  @override
  String get successNotificationScheduled => 'Notificação agendada com sucesso';

  @override
  String notificationReminderTitle(Object title) {
    return 'Lembrete: $title';
  }

  @override
  String get notificationReminderBody => 'Você tem uma entrada agendada';

  @override
  String get successImageAdded => 'Imagem adicionada com sucesso!';

  @override
  String successImagesAdded(Object count) {
    return '$count imagens adicionadas com sucesso!';
  }

  @override
  String errorSearch(Object message) {
    return 'Erro na pesquisa: $message';
  }

  @override
  String get successStoryRestored => 'História restaurada com sucesso';

  @override
  String get successStoryDeletedPermanently =>
      'História excluída permanentemente';

  @override
  String get trashAlreadyEmpty => 'A lixeira já está vazia';

  @override
  String get successVideoRecorded => 'Vídeo gravado com sucesso!';

  @override
  String get permissionMicrophoneDenied =>
      'Permissão de microfone não concedida';

  @override
  String errorSelectImages(Object message) {
    return 'Erro ao selecionar imagens: $message';
  }

  @override
  String get successPhotoCaptured => 'Foto capturada com sucesso!';

  @override
  String get restoreStoriesTitle => 'Restaurar histórias';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Deseja restaurar $count história(s) selecionada(s)?';
  }

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get permanentlyDeleteTitle => 'Excluir permanentemente';

  @override
  String get permanentlyDeleteConfirm =>
      'Esta ação não pode ser desfeita. Deseja realmente excluir esta história permanentemente?';

  @override
  String get permanentlyDeleteLabel => 'Excluir permanentemente';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Deseja remover o grupo \"$name\" das suas histórias?';
  }

  @override
  String get recoverPinTitle => 'Recuperar PIN';

  @override
  String get recoverPinDescription =>
      'Enviaremos um código de recuperação para o seu e-mail cadastrado.';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get emptyTrashTitle => 'Esvaziar lixeira';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Deseja excluir permanentemente todas as $count história(s) da lixeira? Esta ação não pode ser desfeita.';
  }

  @override
  String get emptyTrashLabel => 'Esvaziar lixeira';

  @override
  String errorTakePhoto(Object message) {
    return 'Erro ao tirar foto: $message';
  }

  @override
  String get notifications => 'Notificações';

  @override
  String get entryNotifications => 'Notificações de Entradas';

  @override
  String get entryNotificationsInfo =>
      'Entradas com data pelo menos 2 horas à frente podem ter notificações agendadas.';

  @override
  String get backgroundRestrictionsWarningTitle =>
      'Notificações e Segundo Plano';

  @override
  String get backgroundRestrictionsWarningDesc =>
      'Alguns sistemas reduzem drasticamente as atividades em segundo plano para economizar energia, o que pode bloquear suas notificações agendadas. Para garantir o funcionamento correto, abra as configurações do aplicativo no seu dispositivo e:\n• Desative a opção \'Pausar atividade do app quando sem uso\' (ou similar).\n• Defina as restrições de bateria como \'Sem Restrição\' (não se preocupe, o consumo de bateria do DayApp em segundo plano é desprezível).';

  @override
  String get defaultAdvanceTitle => 'Antecedência Padrão';

  @override
  String get notificationAdvanceTitle => 'Antecedência da Notificação';

  @override
  String get notificationAdvancePrompt =>
      'Com quanto tempo de antecedência você quer ser notificado?';

  @override
  String get notificationAdvanceDefault => 'Antecedência padrão';

  @override
  String get notificationScheduleModeTitle => 'Modo de agendamento (QA)';

  @override
  String get notificationScheduleModeInexact => 'Inexato (compatível com Play)';

  @override
  String get automaticBackup => 'Backup Automático';

  @override
  String get manageCompleteBackup => 'Gerenciar Backup Completo';

  @override
  String get backupWithVideosZip => 'Backup com vídeos em arquivo ZIP';

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
  String get incrementalBackupTitle => 'Pasta de Backup';

  @override
  String get incrementalBackupDescription =>
      'As suas histórias são guardadas automaticamente nesta pasta sempre que guardar uma.';

  @override
  String get incrementalBackupFolderNotSet => 'Pasta não configurada';

  @override
  String get incrementalBackupFolderConfigured => 'Pasta configurada';

  @override
  String get incrementalBackupSelectFolder => 'Selecionar Pasta';

  @override
  String get incrementalBackupChangeFolder => 'Alterar Pasta';

  @override
  String get incrementalBackupChangingFolder =>
      'A copiar ficheiros para a nova pasta...';

  @override
  String get incrementalBackupFolderChanged => 'Pasta de backup atualizada.';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Pasta de backup não configurada. As histórias não serão guardadas até configurar uma pasta nas Definições.';

  @override
  String get incrementalBackupSyncDone => 'Guardado em backup';

  @override
  String get backupSetupTitle => 'Configurar Pasta de Backup';

  @override
  String get backupSetupContent =>
      'Escolha uma pasta onde as suas histórias serão guardadas automaticamente. Isto garante que os seus dados estão sempre seguros.';

  @override
  String get backupSavedToFolder => 'A guardar backup na pasta configurada...';

  @override
  String get biometricsNotAvailable => 'Não disponível neste dispositivo';

  @override
  String get biometricsDisabled => 'Biometria desabilitada';

  @override
  String get biometricConfiguredInfo =>
      'A biometria está configurada. Você pode fazer login usando sua digital ou reconhecimento facial.';

  @override
  String get biometricAuthFailed => 'Falha na autenticação biométrica';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirme sua identidade para habilitar a biometria';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarFormatMonth => 'Mês';

  @override
  String get calendarFormatTwoWeeks => '2 Semanas';

  @override
  String get calendarFormatWeek => 'Semana';

  @override
  String get groupExists => 'Grupo já existe';

  @override
  String get enterGroupName => 'Digite um nome para o grupo';

  @override
  String get archivedTitle => 'Arquivados';

  @override
  String get toggleToIcons => 'Alternar para visualização de ícones';

  @override
  String get toggleToCards => 'Alternar para visualização em blocos';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editTip => 'Editar - toque duplo';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get close => 'Fechar';

  @override
  String get newStory => 'Nova História';

  @override
  String get noArchivedStories => 'Nenhuma história arquivada.';

  @override
  String get edit => 'Editar';

  @override
  String previewTitle(Object title) {
    return 'Visualização - $title';
  }

  @override
  String get archiveLabel => 'Arquivar';

  @override
  String get storyArchived => 'História arquivada';

  @override
  String get undo => 'Desfazer';

  @override
  String get ungroup => 'Desagrupar';

  @override
  String noStoriesInGroup(Object group) {
    return 'Nenhuma história no grupo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Erro ao exportar PDF: $error';
  }

  @override
  String get titleRequired => 'Título é obrigatório!';

  @override
  String errorSavingStory(Object error) {
    return 'Erro ao salvar história: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Título e descrição são obrigatórios para exportar.';

  @override
  String get exportHistory => 'Exportar História';

  @override
  String get exportHistoryPrompt =>
      'Deseja salvar antes de exportar ou ver um preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Salvar e exportar';

  @override
  String get untitled => 'Sem título';

  @override
  String errorLoadingFile(Object error) {
    return 'Erro ao carregar arquivo: $error';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get discardStoryTitle => 'Descartar história?';

  @override
  String get unsavedStoryPrompt =>
      'Você tem uma nova história não salva. Deseja sair sem salvar?';

  @override
  String get changeDateTooltip => 'Alterar Data';

  @override
  String get storyTitleLabel => 'Título';

  @override
  String get storyTitleHint => 'Digite o título';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get descriptionHint => 'Escreva sua história...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Fotos';

  @override
  String get audiosSection => 'Áudios';

  @override
  String get videosSection => 'Vídeos';

  @override
  String get importTxtTooltip => 'Importar .txt';

  @override
  String get expandTooltip => 'Expandir';

  @override
  String get photoTooltip => 'Foto';

  @override
  String get videoTooltip => 'Vídeo';

  @override
  String get audioTooltip => 'Áudio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Editar Descrição';

  @override
  String get editStory => 'Editar História';

  @override
  String get discardChangesTitle => 'Descartar alterações?';

  @override
  String get discardChangesPrompt =>
      'Você tem alterações não salvas. Deseja sair sem salvar?';

  @override
  String get archivedStateLabel => 'Arquivado';

  @override
  String get archiveSubtitle => 'Ocultar da tela inicial';

  @override
  String get chooseEmoji => 'Escolha um emoji';

  @override
  String get emojiGroupSentimentos => 'Sentimentos';

  @override
  String get emojiGroupAnimais => 'Animais';

  @override
  String get emojiGroupVegetais => 'Vegetais';

  @override
  String get emojiGroupCeu => 'Céu';

  @override
  String get emojiGroupObjetos => 'Objetos';

  @override
  String get emojiGroupAlimentos => 'Alimentos';

  @override
  String get emojiGroupLugares => 'Lugares';

  @override
  String get emojiGroupSimbolos => 'Símbolos';

  @override
  String get moodQuestion => 'Como você se sentiu nessa história?';

  @override
  String get moodVeryDifficult => 'Muito difícil';

  @override
  String get moodDifficult => 'Difícil';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodGood => 'Bom';

  @override
  String get moodVeryGood => 'Muito bom';

  @override
  String get energyQuestion => 'Como estava sua energia?';

  @override
  String get energyLow => 'Baixa';

  @override
  String get energyNormal => 'Normal';

  @override
  String get energyHigh => 'Alta';

  @override
  String get tagsHint => 'Digite e pressione Enter ou vírgula';

  @override
  String get addTag => 'Adicionar tag';

  @override
  String get tagLongPressHint => 'Pressione e segure para renomear';

  @override
  String get renameTagTitle => 'Renomear tag';

  @override
  String get renameTagWarning =>
      'Renomear afetará todas as histórias que usam esta tag.';

  @override
  String get tagNameLabel => 'Nome da tag';

  @override
  String get insightDiscovery => 'Descoberta';

  @override
  String get insightPattern => 'Encontrei um padrão';

  @override
  String get insightTrend => '📈 Tendência';

  @override
  String get insightMonthlySummary => '📊 Seu mês em histórias';

  @override
  String insightBestWeekday(String weekday) {
    return '$weekday costuma ser o seu dia mais positivo.';
  }

  @override
  String insightPositiveTag(String tag) {
    return 'Histórias com a tag #$tag tendem a ter um humor melhor.';
  }

  @override
  String get insightTrendPositive =>
      'Seu humor melhorou nos últimos 7 dias em comparação com os últimos 30 dias.';

  @override
  String insightMonthlySummaryText(int entries, String mood, String energy) {
    return 'Entradas: $entries\nHumor médio: $mood\nEnergia média: $energy';
  }

  @override
  String insightMonthlySummaryWithTag(
    int entries,
    String mood,
    String energy,
    String tag,
  ) {
    return 'Entradas: $entries\nHumor médio: $mood\nEnergia média: $energy\nTag mais frequente: #$tag';
  }

  @override
  String get insightSeeStories => 'Ver histórias';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get weekdayMonday => 'Segunda-feira';

  @override
  String get weekdayTuesday => 'Terça-feira';

  @override
  String get weekdayWednesday => 'Quarta-feira';

  @override
  String get weekdayThursday => 'Quinta-feira';

  @override
  String get weekdayFriday => 'Sexta-feira';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get insightDismiss => 'Dispensar';

  @override
  String get insightStoryBalanceTitle => 'Equilíbrio de Histórias';

  @override
  String get insightStoryBalancePositive =>
      'Você registrou mais histórias positivas nos últimos 10 dias. Continue assim!';

  @override
  String get insightStoryBalanceDifficult =>
      'Você registrou mais histórias difíceis nos últimos 10 dias. Cuide-se!';

  @override
  String get insightWritingTimeTitle => 'Horário de Escrita';

  @override
  String get insightWritingTimeMorning =>
      'Você escreveu mais durante a manhã nesta semana.';

  @override
  String get insightWritingTimeAfternoon =>
      'Você escreveu mais durante a tarde nesta semana.';

  @override
  String get insightWritingTimeNight =>
      'Você escreveu mais durante a noite nesta semana.';

  @override
  String get insightEnergyChartTitle => 'Energia — 7 Dias';

  @override
  String get insightEnergyChartSubtitle =>
      'Sua evolução de energia essa semana';

  @override
  String get insightPremiumRequired =>
      'Recurso Premium. Faça upgrade para desbloquear este insight.';

  @override
  String get insightPremiumCTA => 'Ver Premium';

  @override
  String get insightDevModeActive => 'Modo dev: todos os insights visíveis';

  @override
  String get backupProgressCreating => 'Criando arquivo de backup...';

  @override
  String get backupProgressCopyingDb => 'Copiando banco de dados...';

  @override
  String get backupProgressCopyingVideos => 'Copiando vídeos...';

  @override
  String backupProgressCopyingVideo(int current, int total) {
    return 'Copiando vídeo $current/$total...';
  }

  @override
  String get backupProgressCopyingPhotos => 'Copiando fotos...';

  @override
  String backupProgressCopyingPhoto(int current, int total) {
    return 'Copiando foto $current/$total...';
  }

  @override
  String get backupProgressCopyingAudios => 'Copiando áudios...';

  @override
  String backupProgressCopyingAudio(int current, int total) {
    return 'Copiando áudio $current/$total...';
  }

  @override
  String get backupProgressCreatingMetadata => 'Criando metadados...';

  @override
  String get backupProgressCompressing => 'Comprimindo arquivos...';

  @override
  String get backupProgressSuccess => 'Backup criado com sucesso!';

  @override
  String get backupShareText =>
      'Backup completo do DayApp com banco de dados e vídeos';

  @override
  String get errorBackupDbNotFound => 'Banco de dados não encontrado.';

  @override
  String get errorBackupFileNotFound => 'Arquivo de backup não encontrado.';

  @override
  String errorBackupDbNotFoundInFile(int count) {
    return 'Banco de dados não encontrado no arquivo de backup. Arquivos extraídos: $count';
  }

  @override
  String get restoreProgressExtracting => 'Extraindo arquivo de backup...';

  @override
  String restoreProgressZipContains(int count) {
    return 'ZIP contém $count arquivos...';
  }

  @override
  String get restoreProgressBackingUpCurrent =>
      'Fazendo backup do banco atual...';

  @override
  String get restoreProgressClosingDb => 'Fechando conexões do banco...';

  @override
  String get restoreProgressRestoringDb => 'Restaurando banco de dados...';

  @override
  String get restoreProgressCopyingRestoredDb =>
      'Copiando banco de dados restaurado...';

  @override
  String get restoreProgressRestoringVideos => 'Restaurando vídeos...';

  @override
  String restoreProgressRestoringVideo(int current, int total) {
    return 'Restaurando vídeo $current/$total...';
  }

  @override
  String get restoreProgressRestoringPhotos => 'Restaurando fotos...';

  @override
  String restoreProgressRestoringPhoto(int current, int total) {
    return 'Restaurando foto $current/$total...';
  }

  @override
  String get restoreProgressRestoringAudios => 'Restaurando áudios...';

  @override
  String restoreProgressRestoringAudio(int current, int total) {
    return 'Restaurando áudio $current/$total...';
  }

  @override
  String get restoreProgressReinitializingDb =>
      'Reinicializando banco de dados...';

  @override
  String restoreProgressDbStats(int active, int deleted) {
    return 'Banco restaurado: $active ativas, $deleted na lixeira.';
  }

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String codeExpiresIn(int minutes) {
    return 'Código expira em $minutes minutos';
  }

  @override
  String get backToStart => 'Voltar ao início';

  @override
  String get code => 'Código';

  @override
  String get pin => 'PIN';

  @override
  String get enterCode => 'Digite o código';

  @override
  String get codeCheckDescription =>
      'Insira o código de 6 dígitos que foi enviado para o seu e-mail.';

  @override
  String get defineNewPin => 'Defina um novo PIN seguro para sua conta.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get verifyCode => 'Verificar código';

  @override
  String get resetPin => 'Redefinir PIN';

  @override
  String get storyPreviewMoodVeryDifficultNarrative =>
      'Essa foi uma história muito difícil';

  @override
  String get storyPreviewMoodDifficultNarrative =>
      'Essa foi uma história difícil';

  @override
  String get storyPreviewMoodNeutralNarrative =>
      'Foi neutro em termos de sentimento';

  @override
  String get storyPreviewMoodGoodNarrative => 'Uma boa história';

  @override
  String get storyPreviewMoodVeryGoodNarrative => 'Uma história muito boa';

  @override
  String get storyPreviewEnergyLowNarrative => 'Eu estava com a energia baixa';

  @override
  String get storyPreviewEnergyNormalNarrative => 'Minha energia estava normal';

  @override
  String get storyPreviewEnergyHighNarrative => 'Estava com a energia bem alta';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get premiumVersion => 'Versão Premium';

  @override
  String get premiumScreenTitle => 'DayApp Premium';

  @override
  String get premiumScreenSubtitle =>
      'Desbloqueie todo o potencial do seu diário e preserve suas memórias com recursos exclusivos.';

  @override
  String get premiumScreenRestore => 'Restaurar compras';

  @override
  String get premiumScreenPurchaseButton => 'Adquirir Premium Vitalício';

  @override
  String get premiumScreenFeaturesTitle => 'O que você ganha com o Premium:';

  @override
  String get premiumFeatureShareHistory =>
      'Compartilhar histórias como imagem personalizada';

  @override
  String get premiumFeatureShareChapter => 'Exportar capítulos em HTML';

  @override
  String get premiumFeatureAutoSuggestions =>
      'Sugestões automáticas de capítulos inteligentes';

  @override
  String get premiumFeatureMonthlyInsights =>
      'Insights e resumos mensais detalhados';

  @override
  String get premiumFeatureWeeklyMood =>
      'Gráfico de evolução de humor de 7 dias';

  @override
  String get premiumFeatureCustomThemes =>
      'Acesso a todos os temas e cores exclusivas';

  @override
  String get premiumFeature => 'Recurso da versão Premium';

  @override
  String get premiumFeatureInfo =>
      'Este recurso está disponível na versão Premium.';

  @override
  String get freePlan => 'Grátis';

  @override
  String get currentPlan => 'Plano atual';

  @override
  String get premiumDebugTitle => 'Debug Premium';

  @override
  String get premiumDebugSubtitle =>
      'Somente em desenvolvimento — não visível na produção';

  @override
  String get premiumDebugActivate => 'Ativar Premium (debug)';

  @override
  String get premiumDebugDeactivate => 'Desativar Premium (voltar para Free)';

  @override
  String premiumDebugStatus(String plan) {
    return 'Status: $plan';
  }

  @override
  String premiumDebugSource(String source) {
    return 'Origem: $source';
  }

  @override
  String get premiumDebugWarning =>
      'Esta tela só está disponível em builds debug. Não aparecerá em produção.';

  @override
  String get premiumDebugFeatures => 'Funcionalidades controladas pelo plano';

  @override
  String get premiumDebugNoSource => 'nenhuma';

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
  String get collectionsTitle => 'Coleções';

  @override
  String get collectionsSubtitle =>
      'Seus momentos organizados em capítulos e grupos, como uma biblioteca de vida.';

  @override
  String get groupsTabLabel => 'Grupos';

  @override
  String get chapterShortcutToggle =>
      'Mostrar/ocultar card de capítulos na Home';

  @override
  String get chaptersHomeCardTitle => 'A sua vida por capítulos';

  @override
  String get chaptersHomeCardSubtitle =>
      'Suas histórias guardam momentos. Seus capítulos revelam a jornada.';

  @override
  String get chaptersPremiumRequired =>
      'Capítulos e sugestões automáticas são funcionalidades Premium.';

  @override
  String get themePremiumRequired =>
      'Temas personalizados são uma funcionalidade Premium.';

  @override
  String get chapterSuggestions => 'Capítulos sugeridos';

  @override
  String get chapterCreated => 'Capítulo criado com sucesso.';

  @override
  String get chapterEditTitle => 'Editar capítulo';

  @override
  String get chapterDescriptionHint =>
      'Digite uma descrição para este capítulo (opcional)';

  @override
  String get chapterUpdated => 'Capítulo atualizado com sucesso.';

  @override
  String get chapterDeleteConfirmTitle => 'Excluir capítulo';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return 'Deseja excluir o capítulo “$title”? As histórias vinculadas não serão excluídas.';
  }

  @override
  String get chapterDeleted => 'Capítulo excluído com sucesso.';

  @override
  String get chapterCreateManual => 'Criar capítulo manualmente';

  @override
  String get chapterCreateTitle => 'Criar Capítulo';

  @override
  String get chapterTitle => 'Título';

  @override
  String get chapterTitleHint => 'Ex: Mudança de emprego';

  @override
  String get chapterDescription => 'Descrição';

  @override
  String get chapterPhoto => 'Foto do Capítulo';

  @override
  String get chapterPhotoActionLabel => 'Foto';

  @override
  String get chapterAddPhoto => 'Adicionar foto';

  @override
  String get chapterChangePhoto => 'Alterar foto';

  @override
  String get chapterRemovePhoto => 'Remover foto';

  @override
  String get chapterSelectEntries =>
      'Selecione a menos 3 histórias relacionadas';

  @override
  String get chapterMinimumEntries => 'Mínimo: 3 histórias por capítulo.';

  @override
  String chapterPeriod(String start, String end) {
    return 'Histórias de $start - $end';
  }

  @override
  String chapterEntriesCount(int count) {
    return 'Histórias: $count';
  }

  @override
  String chapterAverageMood(String mood) {
    return 'Humor médio: $mood';
  }

  @override
  String chapterTopTags(String tags) {
    return 'Tags principais: $tags';
  }

  @override
  String get chapterCreateFromSuggestion => 'Criar capítulo';

  @override
  String get chapterViewSuggestions => 'Ver sugestões';

  @override
  String get chapterCreateMyLabel => 'Criar meu Capítulo';

  @override
  String get chapterIgnoreLabel => 'Ignorar';

  @override
  String chapterSuggestionMoreStories(int count) {
    return 'e mais $count história(s)';
  }

  @override
  String get chapterNoItems => 'Seu próximo capítulo começa aqui.';

  @override
  String get chapterFilterAll => 'Todos';

  @override
  String get chapterFilterAutomatic => 'Automáticos';

  @override
  String get chapterFilterManual => 'Manuais';

  @override
  String get chapterNoSearchResults =>
      'Nenhum capítulo encontrado com os filtros atuais.';

  @override
  String get chapterSortLabel => 'Ordenar por';

  @override
  String get chapterSortNewest => 'Período mais recente';

  @override
  String get chapterSortOldest => 'Período mais antigo';

  @override
  String get chapterSortTitle => 'Título';

  @override
  String get chapterSortStories => 'Mais histórias';

  @override
  String chapterEntriesAndMood(int count, String mood) {
    return '$count histórias - humor médio $mood';
  }

  @override
  String get chapterOpenLabel => 'Abrir';

  @override
  String get chapterIntroSubtitle =>
      'Organize suas histórias de forma significativa e reviva suas memórias em ordem';

  @override
  String get chapterIntroGroupTitle => 'Junte momentos conectados';

  @override
  String get chapterIntroGroupBody =>
      'Reúna várias postagens em um único capítulo para acompanhar toda a trajetória de um tema ou momento especial.';

  @override
  String get chapterIntroTimelineTitle =>
      'Reviva sua história do começo ao fim';

  @override
  String get chapterIntroTimelineBody =>
      'Navegue pelas memórias em ordem cronológica e veja como cada momento evoluiu com o tempo.';

  @override
  String get chapterIntroPhaseTitle => 'Um capítulo para cada fase';

  @override
  String get chapterIntroPhaseBody =>
      'Viagens, faculdade, família, trabalho, sonhos, metas ou lembranças especiais. Você decide como contar sua história.';

  @override
  String get chapterIntroCtaTitle => 'Pronto para organizar suas memórias?';

  @override
  String get chapterIntroCtaBody =>
      'Comece criando seu primeiro capítulo agora';

  @override
  String get chapterIntroShowOnOpen => 'Mostrar essa tela ao abrir Capítulos';

  @override
  String get chapterLinkSectionTitle => 'Capítulos';

  @override
  String get chapterLinkConfigure => 'Configurar';

  @override
  String get chapterLinkDialogTitle => 'Adicionar esta história aos capítulos';

  @override
  String get chapterLinkModeNone => 'Não adicionar';

  @override
  String get chapterLinkModeExisting => 'Adicionar a capítulo existente';

  @override
  String get chapterLinkModeNew => 'Criar novo capítulo';

  @override
  String get chapterSelectExistingLabel => 'Selecionar capítulo';

  @override
  String get chapterSelectExistingRequired =>
      'Selecione um capítulo existente.';

  @override
  String get chapterTitleRequired => 'O título do capítulo é obrigatório.';

  @override
  String get chapterMinimumRelatedWithCurrent =>
      'Selecione ao menos 2 histórias relacionadas. Com a história atual, o mínimo é 3.';

  @override
  String get chapterLinkSummaryNone => 'Sem vínculo com capítulos.';

  @override
  String get chapterLinkSummaryExisting =>
      'Será adicionada a um capítulo existente ao salvar.';

  @override
  String chapterLinkSummaryNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Novo capítulo com $count histórias',
      one: 'Novo capítulo com 1 história',
    );
    return '$_temp0';
  }

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get homeHeaderLargeCards => 'Ver em cards grandes';

  @override
  String get homeHeaderCompactCards => 'Ver em cards reduzidos';

  @override
  String get homeHeaderOpenCalendarTooltip => 'Ver calendário';

  @override
  String get homeGreetingMorning => 'Bom dia';

  @override
  String get homeGreetingAfternoon => 'Boa tarde';

  @override
  String get homeGreetingEvening => 'Boa noite';

  @override
  String get homeStoriesSubtitle => 'Aqui estão suas histórias';

  @override
  String get homeShowAllStoriesLabel => 'Ver todas';

  @override
  String get insightHistoryTitle => 'Histórico de Insights';

  @override
  String get insightHistoryEmpty => 'Nenhum insight registrado ainda.';

  @override
  String get insightHistoryClearAll => 'Limpar histórico';

  @override
  String get insightHistoryClearConfirm =>
      'Limpar todo o histórico de insights? Esta ação não pode ser desfeita.';

  @override
  String insightHistorySeenOn(String date) {
    return 'Visto em $date';
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
  String get pdfBackgroundColor => 'Cor de fundo';

  @override
  String get pdfBackgroundNone => 'Sem cor';

  @override
  String get pdfBackgroundBeige => 'Bege/creme';

  @override
  String get pdfBackgroundBlue => 'Azul pálido';

  @override
  String get pdfBackgroundGreen => 'Verde pálido';

  @override
  String get pdfBackgroundGray => 'Cinza claro';

  @override
  String get exportPdfPremiumRequired =>
      'Exportar Capítulo é um recurso Premium. Faça upgrade do seu plano para aceder.';

  @override
  String get changeEmail => 'Alterar E-mail';

  @override
  String get changePassword => 'Alterar Palavra-passe';

  @override
  String get currentPassword => 'Palavra-passe atual';

  @override
  String get wrongCurrentPassword => 'A palavra-passe atual está incorreta.';

  @override
  String get passwordChangedSuccess => 'Palavra-passe alterada com sucesso.';

  @override
  String get emailChangedSuccess => 'E-mail alterado com sucesso.';

  @override
  String get newPasswordMinLength =>
      'A nova palavra-passe deve ter pelo menos 4 caracteres.';

  @override
  String get fillAllFields => 'Por favor, preencha todos os campos.';

  @override
  String get backupInfoDialogTitle => 'Sobre o backup';

  @override
  String get backupInfoDialogContent =>
      '📦  O que está incluído no backup\n• Todas as suas histórias (textos, fotos, áudios, vídeos)\n• Base de dados do app\n• Fotos de capítulos\n\n📂  Como guardar o seu backup\nApós a criação, utilize o menu de partilha para guardar o ficheiro onde preferir — OneDrive, Google Drive, e-mail ou outro serviço.';

  @override
  String get backupPasswordDialogTitle => 'Proteja o seu backup';

  @override
  String get backupPasswordDescription =>
      'Defina uma senha para encriptar o ficheiro de backup. O conteúdo ficará protegido e ilegível para quem não tiver esta senha.';

  @override
  String get backupPasswordWarningTitle =>
      '⚠️  Importante — leia antes de continuar';

  @override
  String get backupPasswordWarning =>
      'Esta senha é conhecida apenas por si. Não é guardada em nenhum lugar no app nem nos nossos servidores.\n\nSe a esquecer, o ficheiro de backup ficará permanentemente inacessível — nem a nossa equipa conseguirá ajudar a recuperar os dados.\n\nGuarde esta senha num local seguro antes de continuar.';

  @override
  String get backupPasswordField => 'Senha';

  @override
  String get backupPasswordConfirmField => 'Confirmar senha';

  @override
  String get backupPasswordMismatch =>
      'As senhas não coincidem. Por favor, tente novamente.';

  @override
  String get backupPasswordTooShort =>
      'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get backupPasswordEmpty => 'Por favor, insira uma senha.';

  @override
  String get backupCreateEncrypted => 'Criar backup encriptado';

  @override
  String get restorePasswordDialogTitle => 'Introduza a senha do backup';

  @override
  String get restorePasswordDescription =>
      'Se definiu uma senha ao criar este backup, introduza-a abaixo.\n\nSe o backup foi criado sem senha, deixe o campo em branco.';

  @override
  String get restorePasswordField =>
      'Senha (deixe em branco se não foi definida)';

  @override
  String get restorePasswordWrong =>
      'Senha incorreta ou backup ilegível. Verifique a senha e tente novamente.';

  @override
  String get restoreContinue => 'Continuar';

  @override
  String get chapterExportPhotoSelectionTitle =>
      'Escolher fotos para exportação';

  @override
  String get chapterExportPhotoSelectionSubtitle =>
      'Selecione as fotos de cada história que você deseja exportar';

  @override
  String get chapterExportNoPhotoOption => 'Sem foto';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String codeExpiresMinutes(int count) {
    return 'Código expira em $count minutos';
  }

  @override
  String get codeLabel => 'Código';

  @override
  String get informRegisteredEmail => 'Informe seu e-mail cadastrado';

  @override
  String get newPasswordMinLengthLabel => 'Nova senha (mínimo 6 caracteres)';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nova senha';

  @override
  String get informYourEmailTitle => 'Informe seu e-mail';

  @override
  String get enterCodeTitle => 'Digite o código';

  @override
  String get newPasswordTitle => 'Nova senha';

  @override
  String get emailStepSubtitle =>
      'Enviaremos um código de recuperação para o e-mail cadastrado na sua conta.';

  @override
  String get codeStepSubtitle =>
      'Insira o código de 6 dígitos que foi enviado para o seu e-mail.';

  @override
  String get passwordStepSubtitle =>
      'Defina uma nova senha segura para sua conta.';

  @override
  String get sendCodeButtonLabel => 'Enviar código';

  @override
  String get verifyCodeButtonLabel => 'Verificar código';

  @override
  String get resetPasswordButtonLabel => 'Redefinir senha';

  @override
  String get birthDateCannotBeFuture =>
      'A data de nascimento não pode ser no futuro.';

  @override
  String get birthDateMinAge => 'Você deve ter pelo menos 14 anos de idade.';

  @override
  String get successAudioAdded => 'Áudio adicionado com sucesso!';

  @override
  String get photoDeleted => 'Foto excluída';

  @override
  String get videoSavedSuccess => 'Vídeo salvo com sucesso';

  @override
  String get videoPlaybackNotAvailableWindows =>
      'Reprodução de vídeo não disponível no Windows';

  @override
  String get supportEmailSubjectLogin => 'Suporte DayApp - Login';

  @override
  String get supportEmailBodyLogin =>
      'Olá, preciso de ajuda com o login no DayApp...';

  @override
  String successAudiosAdded(int count) {
    return '$count áudios adicionados com sucesso!';
  }

  @override
  String sizeLabel(String size) {
    return 'Tamanho: $size MB';
  }

  @override
  String durationLabel(String duration) {
    return 'Duração: $duration';
  }

  @override
  String get editDoubleTapHint => 'Editar - 2 toques';

  @override
  String deleteGroupWarningText(String groupName) {
    return 'Deseja excluir o grupo \"$groupName\"? As histórias deste grupo não serão excluídas, apenas removidas del grupo.';
  }

  @override
  String createdOn(String date) {
    return 'Criado em $date';
  }

  @override
  String get editorPlaceholder => 'Digite aqui...';

  @override
  String get aboutFlutterDesc =>
      'Framework para desenvolvimento multiplataforma';

  @override
  String get aboutDartDesc => 'Linguagem de programação moderna e eficiente';

  @override
  String get aboutSqliteDesc => 'Banco de dados local robusto e confiável';

  @override
  String get aboutProviderDesc => 'Gerenciamento de estado reativo';

  @override
  String get aboutMaterial3Title => 'Material Design 3';

  @override
  String get aboutMaterial3Desc => 'Design system moderno e acessível';

  @override
  String get aboutScreenTechnologiesTitle => 'Tecnologias';

  @override
  String get insightMood7Days => 'Humor — 7 Dias';

  @override
  String get insightMoodVariationThisWeek =>
      'Sua variação de humor essa semana';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get aboutScreenFeatureSmartOrganizationDescription =>
      'Categorize suas histórias em grupos temáticos personalizados e Capítulos que contam sobre você';

  @override
  String get aboutScreenFeatureSecureBackupDescription =>
      'Projeta seus dados com backups regulares.';

  @override
  String get backupZipExplanation =>
      'Gera um arquivo ZIP que você pode salvar no seu dispositivo, OneDrive, Google Drive, email ou qualquer outro local na nuvem, exceto apps de mensagens.';

  @override
  String get backupLinuxExplanation =>
      'Escolha uma pasta e o backup ZIP será salvo diretamente nela.';

  @override
  String get helpHomeItemDesc =>
      'Visualize as 5 últimas histórias ou todas em cartões grandes, reduzidos ou no calendário';

  @override
  String get helpHomeSwipeRightDesc =>
      'Arraste o card para a direita para Arquivar a história. A história é movida para a aba Coleções / Grupos / Arquivados';

  @override
  String get helpHomeSwipeLeftDesc =>
      'Arraste o card para a esquerda para associar a um Grupo. A história é movida para a aba Coleções / Grupos / Arquivados';

  @override
  String get helpHomeChapterIconDesc =>
      'Organize suas histórias em Capítulos e Grupos temáticos. Crie Capítulos e conte sua história completa. Crie Grupos personalizados para categorizar suas memórias.';

  @override
  String get helpGroupsNavDesc =>
      'Organize suas histórias em Capítulos e Grupos temáticos. Crie Capítulos e conte sua história completa. Crie Grupos personalizados para categorizar suas memórias.';

  @override
  String get helpAutomaticBackupTitle => 'Backup Automático';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure backup automático (Premium) nas Configurações. O backup será criado quando fizer logout.';

  @override
  String get helpManualBackupTitle => 'Backup';

  @override
  String get helpOrganizationTipDesc =>
      'Use Grupos para categorizar suas histórias por temas, e Capítulos para contar toda a história.';

  @override
  String get backupOnLogoutDescription => 'Backup será criado ao fazer logout';

  @override
  String get automaticBackupInfo =>
      'Ao fazer logout, um backup será criado e você poderá escolher onde salvar (pasta local, Google Drive, etc).';

  @override
  String get automaticBackupInfoLocal =>
      'Ao fazer logout, um backup será salvo automaticamente no dispositivo. Você pode exportá-lo para nuvem depois se necessário.';

  @override
  String get incrementalBackupDescription =>
      'Suas histórias são salvas automaticamente nesta pasta sempre que você salvar uma.';

  @override
  String get incrementalBackupChangingFolder =>
      'Copiando arquivos para a nova pasta...';

  @override
  String get incrementalBackupWarningNoFolder =>
      'Pasta de backup não configurada. As histórias não serão salvas em backup até que você configure uma pasta nas Configurações.';

  @override
  String get incrementalBackupSyncDone => 'Salvo em backup';

  @override
  String get backupSetupContent =>
      'Escolha uma pasta onde suas histórias serão salvas automaticamente. Isso garante que seus dados estejam sempre seguros.';

  @override
  String get backupSavedToFolder => 'Salvando backup na pasta configurada...';

  @override
  String get autoBackupPremiumRequired =>
      'Backups automáticos são um recurso Premium. Faça upgrade para acessar backups salvos, pontos de restauração e gerenciamento de armazenamento.';

  @override
  String autoBackupStorageInfo(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backups · $size',
      one: '1 backup · $size',
      zero: 'Nenhum backup salvo',
    );
    return '$_temp0';
  }

  @override
  String get chaptersHomeCardTitle => 'Sua vida por capítulos';

  @override
  String get chaptersPremiumRequired =>
      'Capítulos e sugestões automáticas são recursos Premium.';

  @override
  String get themePremiumRequired =>
      'Temas personalizados são um recurso Premium.';

  @override
  String get exportPdfPremiumRequired =>
      'Exportar Capítulo é um recurso Premium. Faça upgrade do seu plano para acessar.';

  @override
  String get changePassword => 'Alterar Senha';

  @override
  String get currentPassword => 'Senha atual';

  @override
  String get wrongCurrentPassword => 'A senha atual está incorreta.';

  @override
  String get passwordChangedSuccess => 'Senha alterada com sucesso.';

  @override
  String get newPasswordMinLength =>
      'A nova senha deve ter pelo menos 4 caracteres.';

  @override
  String get backupInfoDialogContent =>
      '📦  O que está incluído no backup\n• Todas as suas histórias (textos, fotos, áudios, vídeos)\n• Banco de dados do app\n• Fotos de capítulos\n\n📂  Como guardar o seu backup\nApós a criação, use o menu de compartilhamento para salvar o arquivo onde quiser — OneDrive, Google Drive, e-mail ou qualquer outro serviço.';

  @override
  String get backupPasswordDescription =>
      'Defina uma senha para criptografar o arquivo de backup. O conteúdo ficará protegido e ilegível para quem não tiver esta senha.';

  @override
  String get backupPasswordWarning =>
      'Essa senha é conhecida somente por você. Ela não é armazenada em nenhum lugar no app nem nos nossos servidores.\n\nSe você esquecer a senha, o arquivo de backup ficará permanentemente inacessível — nem a nossa equipe conseguirá ajudar a recuperar os dados.\n\nGuarde essa senha em um local seguro antes de continuar.';

  @override
  String get backupCreateEncrypted => 'Criar backup criptografado';

  @override
  String get restorePasswordDialogTitle => 'Digite a senha do backup';

  @override
  String get restorePasswordDescription =>
      'Se você definiu uma senha ao criar este backup, insira-a abaixo.\n\nSe o backup foi criado sem senha, deixe o campo em branco.';

  @override
  String get chapterExportPhotoSelectionSubtitle =>
      'Selecione as fotos de cada história que você deseja exportar';
}
