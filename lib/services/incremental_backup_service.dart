import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/audio_file_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/video_file_helper.dart';
import '../l10n/generated/app_localizations.dart';
import 'backup_service.dart' show BackupService, backupZipIsolateEntrypoint;

/// Resultado do backup silencioso (disparado após salvar uma história).
enum BackupTriggerResult {
  /// Backup realizado com sucesso.
  success,

  /// A pasta de backup ainda não foi configurada pelo usuário.
  noFolder,

  /// Ocorreu algum erro durante o backup.
  error,
}

/// Serviço de backup incremental com suporte a SAF (Storage Access Framework).
///
/// Estratégia base+diff:
///  - `backup_base.zip`     → ZIP completo de todos os arquivos.
///  - `backup_diff.zip`     → ZIP com apenas arquivos novos/modificados desde a base.
///  - `backup_manifest.json`→ Mapa de caminho→dataMod dos arquivos incluídos na base.
///
/// Quando o diff atinge 50 % do tamanho da base, uma nova base é gerada.
class IncrementalBackupService {
  static final IncrementalBackupService _instance =
      IncrementalBackupService._internal();
  factory IncrementalBackupService() => _instance;
  IncrementalBackupService._internal();

  static const String _keyFolderPath = 'incremental_backup_folder_path';
  static const String _fileBase = 'backup_base.zip';
  static const String _fileDiff = 'backup_diff.zip';
  static const String _fileManifest = 'backup_manifest.json';

  final BackupService _backupService = BackupService();

  // ---------------------------------------------------------------------------
  // Configuração de pasta
  // ---------------------------------------------------------------------------

  /// Retorna o caminho da pasta configurada, ou null se não configurada.
  Future<String?> getBackupFolderUri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFolderPath);
  }

  /// Persiste o caminho da pasta de backup.
  Future<void> setBackupFolderUri(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFolderPath, folderPath);
  }

  /// Retorna true se a pasta de backup foi configurada.
  Future<bool> isConfigured() async {
    final uri = await getBackupFolderUri();
    return uri != null && uri.isNotEmpty;
  }

  /// Abre o seletor de pastas e persiste o caminho escolhido.
  ///
  /// Retorna true se o usuário selecionou uma pasta.
  Future<bool> pickAndSetFolder() async {
    final folderPath = await FilePicker.getDirectoryPath();
    if (folderPath == null) return false;
    await setBackupFolderUri(folderPath);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Backup de base (backup completo)
  // ---------------------------------------------------------------------------

  /// Cria um novo backup completo na pasta configurada.
  ///
  /// Sobrescreve `backup_base.zip` e `backup_manifest.json` e apaga
  /// `backup_diff.zip` (que passa a ser inválido com a nova base).
  Future<void> performBaseBackup({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    final folderPath = await getBackupFolderUri();
    if (folderPath == null) {
      throw StateError('Pasta de backup não configurada.');
    }

    onProgressValue?.call(0.0);

    // Reutiliza toda a lógica de coleta e compressão já testada em BackupService.
    final tempZipPath = await _backupService.createBackupZipFile(
      l10n: l10n,
      onProgress: onProgress,
      onProgressValue: (v) => onProgressValue?.call(v != null ? v * 0.7 : null),
    );

    onProgress?.call(l10n.backupProgressCompressing);
    onProgressValue?.call(0.75);

    // Copia o ZIP gerado para a pasta configurada
    final baseFile = File(path.join(folderPath, _fileBase));
    await File(tempZipPath).copy(baseFile.path);

    // Apaga diff antigo — nova base o torna obsoleto
    final diffFile = File(path.join(folderPath, _fileDiff));
    if (await diffFile.exists()) await diffFile.delete();

    onProgressValue?.call(0.85);

    // Grava o manifesto
    final manifest = await _buildCurrentManifest();
    await File(
      path.join(folderPath, _fileManifest),
    ).writeAsString(jsonEncode(manifest));

    // Limpa ZIP temporário
    try {
      await File(tempZipPath).delete();
    } catch (e) {
      // Limpeza opcional — não crítico
      debugPrint(
        'IncrementalBackupService: erro ao remover ZIP temporário base: $e',
      );
    }

    onProgressValue?.call(1.0);
    onProgress?.call(l10n.backupProgressSuccess);
  }

  // ---------------------------------------------------------------------------
  // Backup diferencial (somente arquivos novos/modificados)
  // ---------------------------------------------------------------------------

  /// Cria/atualiza `backup_diff.zip` com os arquivos modificados desde a base.
  ///
  /// Se não houver manifesto (base nunca criada), delega para [performBaseBackup].
  Future<void> performDiffBackup({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    final folderPath = await getBackupFolderUri();
    if (folderPath == null) {
      throw StateError('Pasta de backup não configurada.');
    }

    // Sem manifesto → base nunca foi criada; gera base completa
    final manifest = await _readManifest(folderPath);
    if (manifest == null) {
      await performBaseBackup(
        l10n: l10n,
        onProgress: onProgress,
        onProgressValue: onProgressValue,
      );
      return;
    }

    onProgressValue?.call(0.0);
    onProgress?.call(l10n.backupProgressCompressing);

    final manifestFiles = (manifest['files'] as Map<String, dynamic>?) ?? {};

    // DB é sempre incluído no diff (muda a cada história salva)
    final dbPath = await getDatabasesPath();
    final dbFile = File(path.join(dbPath, 'dayapp.db'));
    if (!await dbFile.exists()) {
      throw Exception(l10n.errorBackupDbNotFound);
    }

    final dbSnapshot = await _backupService.createConsistentDatabaseSnapshot();

    final media = await _collectAllMediaFiles();
    final entries = <Map<String, dynamic>>[];
    var totalBytes = 0;

    Future<void> addEntry(
      String sourcePath,
      String archivePath, {
      bool compress = false,
    }) async {
      final file = File(sourcePath);
      if (!await file.exists()) return;
      final size = await file.length();
      if (size <= 0) return;
      totalBytes += size;
      entries.add({
        'sourcePath': sourcePath,
        'archivePath': archivePath,
        'sizeBytes': size,
        'compress': compress,
      });
    }

    // Sempre inclui DB
    await addEntry(dbSnapshot.dbFile.path, 'dayapp.db', compress: true);
    if (dbSnapshot.walFile != null) {
      await addEntry(dbSnapshot.walFile!.path, 'dayapp.db-wal');
    }
    if (dbSnapshot.shmFile != null) {
      await addEntry(dbSnapshot.shmFile!.path, 'dayapp.db-shm');
    }

    // Inclui mídias novas ou modificadas desde o manifesto
    Future<void> checkAndAdd(File f, String archivePath) async {
      final manifestEntry = manifestFiles[archivePath] as Map<String, dynamic>?;
      if (manifestEntry == null) {
        // Arquivo novo — inclui
        await addEntry(f.path, archivePath);
      } else {
        final manifestModified = DateTime.tryParse(
          manifestEntry['modified'] as String? ?? '',
        );
        final fileStat = f.statSync();
        if (manifestModified == null ||
            fileStat.modified.isAfter(manifestModified)) {
          // Arquivo modificado — inclui
          await addEntry(f.path, archivePath);
        }
      }
    }

    for (final f in media.videos) {
      await checkAndAdd(f, 'videos/${path.basename(f.path)}');
    }
    for (final f in media.photos) {
      await checkAndAdd(f, 'photos/${path.basename(f.path)}');
    }
    for (final f in media.chapterPhotos) {
      await checkAndAdd(f, 'chapter_photos/${path.basename(f.path)}');
    }
    for (final f in media.audios) {
      await checkAndAdd(f, 'audios/${path.basename(f.path)}');
    }

    onProgressValue?.call(0.3);

    // Comprime via isolate
    final tempDir = await getTemporaryDirectory();
    final tempZipPath = path.join(
      tempDir.path,
      'dayapp_diff_${DateTime.now().millisecondsSinceEpoch}.zip',
    );

    await _buildZipViaIsolate(
      entries: entries,
      totalBytes: totalBytes,
      zipPath: tempZipPath,
      onProgressValue: (v) =>
          onProgressValue?.call(v != null ? 0.3 + v * 0.5 : null),
    );

    onProgressValue?.call(0.85);

    final diffFile = File(path.join(folderPath, _fileDiff));
    final tempZipFile = File(tempZipPath);
    await tempZipFile.copy(diffFile.path);

    try {
      await tempZipFile.delete();
    } catch (e) {
      // Limpeza opcional
      debugPrint(
        'IncrementalBackupService: erro ao remover ZIP temporário diff: $e',
      );
    }

    await dbSnapshot.cleanup();

    onProgressValue?.call(1.0);
  }

  // ---------------------------------------------------------------------------
  // Gatilho silencioso (chamado após salvar uma história)
  // ---------------------------------------------------------------------------

  /// Dispara um backup incremental em segundo plano após salvar uma história.
  ///
  /// Não bloqueia a thread de UI. Os callbacks [onSyncStart] e [onSyncEnd]
  /// são chamados na mesma thread de quem chama este método (use setState
  /// ou similar para atualizar a UI).
  Future<BackupTriggerResult> triggerSilentBackup({
    required AppLocalizations l10n,
    void Function()? onSyncStart,
    void Function(bool success)? onSyncEnd,
  }) async {
    if (!await isConfigured()) {
      onSyncEnd?.call(false);
      return BackupTriggerResult.noFolder;
    }

    onSyncStart?.call();

    try {
      if (await _shouldRegenerateBase()) {
        await performBaseBackup(l10n: l10n);
      } else {
        await performDiffBackup(l10n: l10n);
      }
      onSyncEnd?.call(true);
      return BackupTriggerResult.success;
    } catch (e) {
      debugPrint('IncrementalBackupService: erro no backup silencioso: $e');
      onSyncEnd?.call(false);
      return BackupTriggerResult.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Troca de pasta (copia arquivos existentes para a nova pasta)
  // ---------------------------------------------------------------------------

  /// Copia os arquivos de backup existentes para [newFolderUri] e atualiza a
  /// configuração. Exibe progresso via callbacks opcionais.
  Future<void> changeFolder({
    required String newFolderUri,
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    final oldFolderPath = await getBackupFolderUri();

    onProgressValue?.call(0.0);

    if (oldFolderPath != null && oldFolderPath.isNotEmpty) {
      final filesToCopy = [_fileBase, _fileManifest, _fileDiff];
      for (var i = 0; i < filesToCopy.length; i++) {
        final filename = filesToCopy[i];
        try {
          final srcFile = File(path.join(oldFolderPath, filename));
          if (await srcFile.exists()) {
            await srcFile.copy(path.join(newFolderUri, filename));
          }
        } catch (e) {
          debugPrint('IncrementalBackupService: erro ao copiar $filename: $e');
        }
        onProgressValue?.call((i + 1) / filesToCopy.length * 0.9);
      }
    }

    await setBackupFolderUri(newFolderUri);
    onProgressValue?.call(1.0);
    onProgress?.call(l10n.backupProgressSuccess);
  }

  // ---------------------------------------------------------------------------
  // Restauração
  // ---------------------------------------------------------------------------

  /// Restaura o banco de dados e os arquivos de mídia a partir dos backups
  /// armazenados na pasta configurada. Aplica a base primeiro, depois o diff.
  Future<void> restoreFromBackupFolder({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    final folderPath = await getBackupFolderUri();
    if (folderPath == null) {
      throw StateError('Pasta de backup não configurada.');
    }

    onProgressValue?.call(0.0);
    onProgress?.call(l10n.restoreProgressExtracting);

    final baseFile = File(path.join(folderPath, _fileBase));
    if (!await baseFile.exists()) {
      throw Exception('Arquivo de backup base não encontrado na pasta.');
    }

    // Copia para temp para restaurar via BackupService existente
    final tempDir = await getTemporaryDirectory();
    final baseTempPath = path.join(tempDir.path, 'restore_base.zip');
    await baseFile.copy(baseTempPath);
    onProgressValue?.call(0.1);

    // Aplica base
    await _backupService.restoreFromZipFile(
      baseTempPath,
      l10n: l10n,
      onProgress: onProgress,
      onProgressValue: (v) =>
          onProgressValue?.call(v != null ? 0.1 + v * 0.5 : null),
    );

    try {
      await File(baseTempPath).delete();
    } catch (e) {
      // Limpeza opcional de temporário — não deve interromper a restauração.
      debugPrint(
        'IncrementalBackupService: erro ao remover restore_base.zip: $e',
      );
    }

    // Aplica diff (se existir)
    final diffFile = File(path.join(folderPath, _fileDiff));
    if (await diffFile.exists()) {
      onProgressValue?.call(0.65);
      final diffTempPath = path.join(tempDir.path, 'restore_diff.zip');
      await diffFile.copy(diffTempPath);

      await _backupService.restoreFromZipFile(
        diffTempPath,
        l10n: l10n,
        onProgress: onProgress,
        onProgressValue: (v) =>
            onProgressValue?.call(v != null ? 0.65 + v * 0.3 : null),
      );

      try {
        await File(diffTempPath).delete();
      } catch (e) {
        // Limpeza opcional de temporário — não deve interromper a restauração.
        debugPrint(
          'IncrementalBackupService: erro ao remover restore_diff.zip: $e',
        );
      }
    }

    onProgressValue?.call(1.0);
    onProgress?.call(l10n.backupProgressSuccess);
  }

  // ---------------------------------------------------------------------------
  // Auxiliares internos — manifesto
  // ---------------------------------------------------------------------------

  /// Constrói o manifesto com o estado atual dos arquivos de mídia.
  Future<Map<String, dynamic>> _buildCurrentManifest() async {
    final media = await _collectAllMediaFiles();
    final filesMap = <String, dynamic>{};

    void addToManifest(File f, String archivePath) {
      try {
        final stat = f.statSync();
        filesMap[archivePath] = {
          'modified': stat.modified.toIso8601String(),
          'size': stat.size,
        };
      } catch (e) {
        // Arquivo pode ter sido removido enquanto o manifesto é montado.
        debugPrint(
          'IncrementalBackupService: erro ao ler metadados de $archivePath: $e',
        );
      }
    }

    for (final f in media.videos) {
      addToManifest(f, 'videos/${path.basename(f.path)}');
    }
    for (final f in media.photos) {
      addToManifest(f, 'photos/${path.basename(f.path)}');
    }
    for (final f in media.chapterPhotos) {
      addToManifest(f, 'chapter_photos/${path.basename(f.path)}');
    }
    for (final f in media.audios) {
      addToManifest(f, 'audios/${path.basename(f.path)}');
    }

    return {
      'version': '1.0',
      'created_at': DateTime.now().toIso8601String(),
      'files': filesMap,
    };
  }

  /// Lê e decodifica o manifesto da pasta configurada. Retorna null se não existir.
  Future<Map<String, dynamic>?> _readManifest(String folderPath) async {
    final file = File(path.join(folderPath, _fileManifest));
    if (!await file.exists()) return null;
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      debugPrint(
        'IncrementalBackupService: erro ao ler manifesto de backup: $e',
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Auxiliares internos — decisão de regeneração
  // ---------------------------------------------------------------------------

  /// Retorna true se o diff deve ser descartado e uma nova base criada.
  ///
  /// Critério: diff ≥ 50 % do tamanho da base, ou base não existe.
  Future<bool> _shouldRegenerateBase() async {
    final folderPath = await getBackupFolderUri();
    if (folderPath == null) return false;

    final baseFile = File(path.join(folderPath, _fileBase));
    if (!await baseFile.exists()) return true; // base nunca foi criada

    final diffFile = File(path.join(folderPath, _fileDiff));
    if (!await diffFile.exists()) return false; // diff não existe ainda

    final baseSize = await baseFile.length();
    final diffSize = await diffFile.length();
    return diffSize >= baseSize * 0.5;
  }

  // ---------------------------------------------------------------------------
  // Auxiliares internos — coleta de arquivos de mídia
  // ---------------------------------------------------------------------------

  Future<_MediaFiles> _collectAllMediaFiles() async {
    final videosDir = await VideoFileHelper.getVideosDirectory();
    final videos = videosDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.mp4'))
        .toList();

    final photosDir = await PhotoFileHelper.getPhotosDirectory();
    final photos = photosDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
        .toList();

    final audiosDir = await AudioFileHelper.getAudiosDirectory();
    final audios = audiosDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp3'))
        .toList();

    final appDocDir = await getApplicationDocumentsDirectory();
    final chapterPhotosDir = Directory(
      path.join(appDocDir.path, 'chapter_photos'),
    );
    final chapterPhotos = (await chapterPhotosDir.exists())
        ? chapterPhotosDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
              .toList()
        : <File>[];

    return _MediaFiles(
      videos: videos,
      photos: photos,
      audios: audios,
      chapterPhotos: chapterPhotos,
    );
  }

  // ---------------------------------------------------------------------------
  // Auxiliares internos — criação de ZIP via isolate
  // ---------------------------------------------------------------------------

  Future<void> _buildZipViaIsolate({
    required List<Map<String, dynamic>> entries,
    required int totalBytes,
    required String zipPath,
    void Function(double?)? onProgressValue,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(backupZipIsolateEntrypoint, {
      'sendPort': receivePort.sendPort,
      'zipPath': zipPath,
      'entries': entries,
      'totalBytes': totalBytes,
    });

    final completer = Completer<void>();
    late final StreamSubscription<dynamic> sub;

    sub = receivePort.listen((message) {
      if (message is! Map) return;
      final type = message['type'];
      if (type == 'progress' && onProgressValue != null) {
        final processed = (message['processedBytes'] as int?) ?? 0;
        if (totalBytes > 0) {
          onProgressValue(processed / totalBytes);
        }
      } else if (type == 'done' && !completer.isCompleted) {
        completer.complete();
      } else if (type == 'error' && !completer.isCompleted) {
        completer.completeError(Exception(message['error']));
      }
    });

    try {
      await completer.future;
    } finally {
      await sub.cancel();
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
    }
  }
}

// ---------------------------------------------------------------------------
// Classes de dados privadas
// ---------------------------------------------------------------------------

class _MediaFiles {
  final List<File> videos;
  final List<File> photos;
  final List<File> audios;
  final List<File> chapterPhotos;

  const _MediaFiles({
    required this.videos,
    required this.photos,
    required this.audios,
    required this.chapterPhotos,
  });
}
