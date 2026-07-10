import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/backup_service.dart';
import '../theme/m3_expressive_theme.dart';
import 'backup_info_screen.dart';

class BackupManagerScreen extends StatefulWidget {
  const BackupManagerScreen({super.key});

  @override
  State<BackupManagerScreen> createState() => _BackupManagerScreenState();
}

class _BackupManagerScreenState extends State<BackupManagerScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  String _statusMessage = '';
  double? _progressValue;
  bool _statusIsError = false; // nova flag para colorir card de status
  bool _statusIsSuccess = false;
  String? _lastBackupFileName;

  @override
  void initState() {
    super.initState();
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    final fileName = await _backupService.getLastBackupFileName();
    if (mounted) {
      setState(() {
        _lastBackupFileName = fileName;
      });
    }
  }

  bool get _isLinuxDesktop =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  String _backupCardExplanation(AppLocalizations loc) {
    if (_isLinuxDesktop) {
      return loc.backupLinuxExplanation;
    }
    return loc.backupZipExplanation;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );
    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.manageBackups,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              // color: screenTheme.colorScheme.onPrimary,
              color:
                  Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, size: 28),
              tooltip: loc.backupInfoDialogTitle,
              onPressed: () => _openBackupInfoScreen(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: kIsWeb
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.backupNotAvailableWeb,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          // color: AppColors.labelColor(context),
                          color:
                              Theme.of(context).appBarTheme.foregroundColor ??
                              Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.backupNotAvailableDetail,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  // Conteúdo principal
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Backup em Arquivo ZIP
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📦 ${loc.backupComplete}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.labelColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _backupCardExplanation(loc),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.labelColor(context),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _createAndShareBackup,
                                  icon: Icon(
                                    _isLinuxDesktop
                                        ? Icons.save_alt
                                        : Icons.share,
                                  ),
                                  label: Text(
                                    _isLinuxDesktop
                                        ? loc.saveAndExport
                                        : loc.createAndShareBackup,
                                  ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 12),
                                Text(
                                  '📥 ${loc.restoreSectionTitle}:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.labelColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.restoreSectionDescription,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.labelColor(context),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.tonalIcon(
                                  onPressed: _isLoading
                                      ? null
                                      : _restoreFromFile,
                                  icon: const Icon(Icons.file_upload),
                                  label: Text(loc.restoreFromFile),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                ),
                                if (_lastBackupFileName != null) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      loc.lastBackupLabel(_lastBackupFileName!),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Mensagem de status (quando não está carregando)
                        if (!_isLoading && _statusMessage.isNotEmpty)
                          Card(
                            color: _statusIsError
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _statusIsSuccess
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _statusIsError
                                        ? Theme.of(context).colorScheme.error
                                        : AppColors.emoticonGreen,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _statusMessage,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Overlay de carregamento - cobre toda a tela
                  if (_isLoading)
                    ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                      child: Center(
                        child: Card(
                          margin: const EdgeInsets.all(32),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    _statusMessage.isEmpty
                                        ? loc.processing
                                        : _statusMessage,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 200,
                                    child: LinearProgressIndicator(
                                      value: _progressValue,
                                    ),
                                  ),
                                  if (_progressValue != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(_progressValue! * 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Text(
                                    loc.pleaseWait,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _openBackupInfoScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BackupInfoScreen()));
  }

  // Future<void> _createAndShareBackup() async {
  //   final loc = AppLocalizations.of(context)!;

  //   // Obter o PinProvider para evitar bloqueio durante compartilhamento
  //   final pinProvider = Provider.of<PinProvider>(context, listen: false);

  //   // Seta flag ANTES de qualquer operação para evitar bloqueio
  //   pinProvider.isPickingExternalMedia = true;
  //   debugPrint('BACKUP: Flag isPickingExternalMedia = true');

  //   setState(() {
  //     _isLoading = true;
  //     _statusMessage = loc.backupStarting;
  //     _progressValue = null;
  //     _statusIsError = false;
  //     _statusIsSuccess = false;
  //   });

  //   try {
  //     String resultingFilePath;
  //     if (_isLinuxDesktop) {
  //       final selectedFolderPath = await FilePicker.getDirectoryPath();

  //       if (selectedFolderPath == null) {
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //             _statusMessage = '';
  //             _progressValue = null;
  //             _statusIsError = false;
  //             _statusIsSuccess = false;
  //           });
  //         }

  //         await Future.delayed(const Duration(milliseconds: 500));
  //         pinProvider.isPickingExternalMedia = false;
  //         return;
  //       }

  //       resultingFilePath = await _backupService.saveBackupFileToFolder(
  //         folderPath: selectedFolderPath,
  //         onProgress: (message) {
  //           if (mounted) setState(() => _statusMessage = message);
  //         },
  //         onProgressValue: (value) {
  //           if (mounted) setState(() => _progressValue = value);
  //         },
  //         l10n: loc,
  //       );
  //     } else {
  //       resultingFilePath = await _backupService.shareBackupFile(
  //         onProgress: (message) {
  //           if (mounted) setState(() => _statusMessage = message);
  //         },
  //         onProgressValue: (value) {
  //           if (mounted) setState(() => _progressValue = value);
  //         },
  //         l10n: loc,
  //       );
  //     }

  //     if (!mounted) {
  //       pinProvider.isPickingExternalMedia = false;
  //       return;
  //     }

  //     final fileName = resultingFilePath.replaceAll('\\', '/').split('/').last;
  //     final now = DateTime.now();
  //     final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  //     final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  //     final baseSuccessMessage = _isLinuxDesktop
  //         ? loc.backupProgressSuccess
  //         : loc.backupCreatedSuccess;

  //     final successMessage = '$baseSuccessMessage\n\nArquivo: $fileName\nGerado em: $date às $time';

  //     debugPrint('BACKUP: Compartilhamento concluído');

  //     await _backupService.saveLastBackupFileName(fileName);

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _statusMessage = successMessage;
  //         _progressValue = null;
  //         _statusIsError = false;
  //         _statusIsSuccess = true;
  //         _lastBackupFileName = fileName;
  //       });
  //       Provider.of<RefreshProvider>(context, listen: false).refresh();
  //     }

  //     // Aguarda um tempo para garantir que todos os eventos de lifecycle foram processados
  //     // antes de resetar a flag (o share sheet pode disparar múltiplos eventos resumed)
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     debugPrint('BACKUP: Resetando flag após delay');
  //     pinProvider.isPickingExternalMedia = false;
  //   } catch (e) {
  //     debugPrint('BACKUP: Erro, resetando flag: $e');
  //     // Garante reset da flag em caso de erro
  //     pinProvider.isPickingExternalMedia = false;

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _statusMessage = loc.backupFailedMessage;
  //         _progressValue = null;
  //         _statusIsError = true;
  //         _statusIsSuccess = false;
  //       });

  //       final tryAgain = await _showErrorDialog(
  //         title: loc.backupFailedTitle,
  //         message: loc.backupFailedMessage,
  //       );
  //       if (tryAgain == true) {
  //         await Future.delayed(const Duration(milliseconds: 300));
  //         _createAndShareBackup();
  //       }
  //     }
  //   }
  // }

  Future<void> _createAndShareBackup() async {
    final loc = AppLocalizations.of(context)!;
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    // Captura o RefreshProvider antes do gap assíncrono
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );

    pinProvider.isPickingExternalMedia = true;
    debugPrint('BACKUP: Flag isPickingExternalMedia = true');

    setState(() {
      _isLoading = true;
      _statusMessage = loc.backupStarting;
      _progressValue = null;
      _statusIsError = false;
      _statusIsSuccess = false;
    });

    try {
      String resultingFilePath;
      if (_isLinuxDesktop) {
        final selectedFolderPath = await FilePicker.getDirectoryPath();

        if (selectedFolderPath == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _statusMessage = '';
              _progressValue = null;
              _statusIsError = false;
              _statusIsSuccess = false;
            });
          }

          await Future.delayed(const Duration(milliseconds: 500));
          pinProvider.isPickingExternalMedia = false;
          return;
        }

        resultingFilePath = await _backupService.saveBackupFileToFolder(
          folderPath: selectedFolderPath,
          onProgress: (message) {
            if (mounted) setState(() => _statusMessage = message);
          },
          onProgressValue: (value) {
            if (mounted) setState(() => _progressValue = value);
          },
          l10n: loc,
        );
      } else {
        resultingFilePath = await _backupService.shareBackupFile(
          onProgress: (message) {
            if (mounted) setState(() => _statusMessage = message);
          },
          onProgressValue: (value) {
            if (mounted) setState(() => _progressValue = value);
          },
          l10n: loc,
        );
      }

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final fileName = resultingFilePath.replaceAll('\\', '/').split('/').last;
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final baseSuccessMessage = _isLinuxDesktop
          ? loc.backupProgressSuccess
          : loc.backupCreatedSuccess;

      final successMessage =
          '$baseSuccessMessage\n\nArquivo: $fileName\nGerado em: $date às $time';

      debugPrint('BACKUP: Compartilhamento concluído');

      await _backupService.saveLastBackupFileName(fileName);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = successMessage;
          _progressValue = null;
          _statusIsError = false;
          _statusIsSuccess = true;
          _lastBackupFileName = fileName;
        });
        // Usa a referência salva previamente
        refreshProvider.refresh();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('BACKUP: Resetando flag após delay');
      pinProvider.isPickingExternalMedia = false;
    } catch (e) {
      debugPrint('BACKUP: Erro, resetando flag: $e');
      pinProvider.isPickingExternalMedia = false;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = loc.backupFailedMessage;
          _progressValue = null;
          _statusIsError = true;
          _statusIsSuccess = false;
        });

        final tryAgain = await _showErrorDialog(
          title: loc.backupFailedTitle,
          message: loc.backupFailedMessage,
        );
        if (tryAgain == true && mounted) {
          await Future.delayed(const Duration(milliseconds: 300));
          _createAndShareBackup();
        }
      }
    }
  }

  Future<void> _restoreFromFile() async {
    final loc = AppLocalizations.of(context)!;
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context); // Salva o navigator root no início

    bool keepTrying = true;

    while (keepTrying) {
      keepTrying = false;

      pinProvider.isPickingExternalMedia = true;
      debugPrint('RESTORE: Flag isPickingExternalMedia = true');

      try {
        await FilePicker.clearTemporaryFiles();
      } catch (e) {
        debugPrint('RESTORE: Erro ao limpar arquivos temporários: $e');
      }

      await Future.delayed(const Duration(milliseconds: 300));

      String? filePath;

      try {
        final result = await FilePicker.pickFiles(type: FileType.any);

        if (result == null || result.files.single.path == null) {
          debugPrint(
            'RESTORE: Usuário cancelou seleção, limpando cache e resetando flag',
          );
          await Future.delayed(const Duration(milliseconds: 300));
          pinProvider.isPickingExternalMedia = false;
          return;
        }

        filePath = result.files.single.path!;
      } catch (e) {
        debugPrint('RESTORE: Erro ao abrir seletor de arquivos: $e');
        await Future.delayed(const Duration(milliseconds: 300));
        pinProvider.isPickingExternalMedia = false;

        if (mounted) {
          final tryAgain = await _showErrorDialog(
            title: loc.restoreFailedTitle,
            message: loc.restoreFailedMessage,
          );
          if (tryAgain == true) {
            keepTrying = true;
            continue;
          }
        }
        return;
      }

      final fileName = path.basename(filePath);

      if (!_backupService.isValidBackupFileName(fileName)) {
        debugPrint('RESTORE: Nome de arquivo de backup inválido: $fileName');
        await Future.delayed(const Duration(milliseconds: 300));
        pinProvider.isPickingExternalMedia = false;

        if (mounted) {
          final tryAgain = await _showErrorDialog(
            title: loc.invalidBackupFilenameTitle,
            message: loc.invalidBackupFilenameMessage(fileName),
          );
          if (tryAgain == true) {
            keepTrying = true;
            continue;
          }
        }
        return;
      }

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final confirmed2 = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text(loc.restoreConfirmTitle),
          content: Text(loc.restoreConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: Text(loc.restore),
            ),
          ],
        ),
      );

      if (confirmed2 != true) {
        debugPrint('RESTORE: Usuário cancelou confirmação, resetando flag');
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _statusMessage = loc.restoreStarting;
        _progressValue = null;
        _statusIsError = false;
        _statusIsSuccess = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));

      try {
        await _backupService.restoreFromZipFile(
          filePath,
          onProgress: (message) {
            if (mounted) setState(() => _statusMessage = message);
          },
          onProgressValue: (value) {
            if (mounted) setState(() => _progressValue = value);
          },
          l10n: loc,
        );

        if (!mounted) {
          pinProvider.isPickingExternalMedia = false;
          return;
        }

        await _backupService.saveLastBackupFileName(fileName);
        refreshProvider.refresh();

        debugPrint('RESTORE: Restauração concluída, resetando flag');
        pinProvider.isPickingExternalMedia = false;

        setState(() {
          _isLoading = false;
          _statusMessage = loc.restoreSuccess;
          _progressValue = null;
          _statusIsError = false;
          _statusIsSuccess = true;
          _lastBackupFileName = fileName;
        });

        if (!mounted) return;

        // Exibe o diálogo de sucesso corrigido usando as instâncias pré-salvas
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(loc.restoreSuccessTitle),
            content: Text(loc.restoreSuccessContent),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await authProvider.logout();
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Text(loc.accessAccount),
              ),
            ],
          ),
        );
      } catch (e) {
        debugPrint('RESTORE: Erro durante a restauração: $e');
        pinProvider.isPickingExternalMedia = false;

        if (mounted) {
          setState(() {
            _isLoading = false;
            _statusMessage = loc.restoreFailedMessage;
            _progressValue = null;
            _statusIsError = true;
            _statusIsSuccess = false;
          });

          final tryAgain = await _showErrorDialog(
            title: loc.restoreFailedTitle,
            message: loc.restoreFailedMessage,
          );
          if (tryAgain == true) {
            keepTrying = true;
            continue;
          }
        }
      }
    }
  }

  Future<bool?> _showErrorDialog({
    required String title,
    required String message,
  }) {
    final loc = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(loc.tryAgain),
          ),
        ],
      ),
    );
  }
}
