import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../helpers/audio_file_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/video_file_helper.dart';
import '../l10n/generated/app_localizations.dart';
import '../repositories/historia_repository.dart';

/// Entrypoint de isolate para criação de ZIP. Declarado como função top-level
/// para poder ser passado a [Isolate.spawn]. Também usado pelo
/// [IncrementalBackupService].
// ignore: library_private_types_in_public_api
void backupZipIsolateEntrypoint(Map<String, dynamic> zipConfig) {
  final sendPort = zipConfig['sendPort'] as SendPort;
  final zipPath = zipConfig['zipPath'] as String;
  final entries = (zipConfig['entries'] as List)
      .cast<Map>()
      .map((entry) => entry.cast<String, dynamic>())
      .toList();

  try {
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    final totalBytes = (zipConfig['totalBytes'] as int?) ?? 0;
    var processedBytes = 0;

    for (final entry in entries) {
      final sourcePath = entry['sourcePath'] as String?;
      final archivePath = entry['archivePath'] as String?;
      final sizeBytes = (entry['sizeBytes'] as int?) ?? 0;

      if (sourcePath == null || archivePath == null) {
        continue;
      }

      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        continue;
      }

      // Leitura síncrona para garantir que os bytes são lidos antes de
      // qualquer operação assíncrona poder interferir. Usar addFile (async)
      // sem await pode causar descarte silencioso de arquivos de mídia quando
      // o isolate é encerrado antes das Futures pendentes completarem.
      final fileBytes = sourceFile.readAsBytesSync();
      final archiveFile = ArchiveFile(archivePath, fileBytes.length, fileBytes);
      // Mídias já comprimidas pelo codec (mp4/jpg/png/m4a/mp3) usam modo Store
      // para evitar CPU desnecessária sem ganho real de tamanho.
      archiveFile.compression = ((entry['compress'] as bool?) ?? false)
          ? CompressionType.deflate
          : CompressionType.none;
      encoder.addArchiveFile(archiveFile);

      processedBytes += sizeBytes;

      sendPort.send({
        'type': 'progress',
        'processedBytes': processedBytes,
        'totalBytes': totalBytes,
      });
    }

    // closeSync garante que todos os dados (incluindo Central Directory) são
    // gravados e o handle do arquivo é fechado antes de notificar 'done'.
    encoder.closeSync();
    sendPort.send({'type': 'done'});
  } catch (e) {
    sendPort.send({'type': 'error', 'error': e.toString()});
  }
}

/// Conjunto de arquivos que representa um snapshot consistente do SQLite.
class DatabaseSnapshotBundle {
  final File dbFile;
  final File? walFile;
  final File? shmFile;
  final bool shouldCleanup;

  DatabaseSnapshotBundle({
    required this.dbFile,
    this.walFile,
    this.shmFile,
    this.shouldCleanup = true,
  });

  List<File> get files => [dbFile, ?walFile, ?shmFile];

  Future<void> cleanup() async {
    if (!shouldCleanup) return;
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint(
          'BackupService: erro ao limpar snapshot temporário ${file.path}: $e',
        );
      }
    }
  }
}

/// ServiÃ§o simplificado de backup - apenas arquivo ZIP local
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<int> countPendingBackupStories() async {
    return HistoriaRepository().countPendingBackupStories();
  }

  /// Cria um arquivo ZIP com backup completo e permite compartilhar
  /// (para OneDrive, Google Drive, etc)
  Future<String> createBackupZipFile({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    DatabaseSnapshotBundle? dbSnapshot;
    try {
      onProgressValue?.call(0.0);
      onProgress?.call(l10n.backupProgressCreating);

      final tempDir = await getTemporaryDirectory();

      // 1. Verificar banco de dados
      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'dayapp.db'));

      if (!await dbFile.exists()) {
        throw Exception(l10n.errorBackupDbNotFound);
      }

      dbSnapshot = await createConsistentDatabaseSnapshot();

      final videosDir = await VideoFileHelper.getVideosDirectory();
      final videoFiles = videosDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();

      final photosDir = await PhotoFileHelper.getPhotosDirectory();
      final photoFiles = photosDir
          .listSync()
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'),
          )
          .toList();

      final audiosDir = await AudioFileHelper.getAudiosDirectory();
      final audioFiles = audiosDir
          .listSync()
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.m4a') || file.path.endsWith('.mp3'),
          )
          .toList();

      // Coletar fotos de capítulos (diretório separado do photos)
      final appDocDir = await getApplicationDocumentsDirectory();
      final chapterPhotosDir = Directory(
        path.join(appDocDir.path, 'chapter_photos'),
      );
      final chapterPhotoFiles = (await chapterPhotosDir.exists())
          ? chapterPhotosDir
                .listSync()
                .whereType<File>()
                .where(
                  (file) =>
                      file.path.endsWith('.jpg') || file.path.endsWith('.png'),
                )
                .toList()
          : <File>[];

      // Coletar fotos de perfil (diretório separado do photos)
      final profileImagesDir = Directory(
        path.join(appDocDir.path, 'profile_images'),
      );
      final profileImageFiles = (await profileImagesDir.exists())
          ? profileImagesDir
                .listSync()
                .whereType<File>()
                .where(
                  (file) =>
                      file.path.endsWith('.jpg') || file.path.endsWith('.png'),
                )
                .toList()
          : <File>[];

      // 3. Marcar histórias como já salvas em backup
      try {
        await HistoriaRepository().markAllStoriesBackedUp();
      } catch (e) {
        // Não quebrar o fluxo de backup se a marcação falhar
        debugPrint(
          'BackupService: erro ao marcar histórias como salvas em backup: $e',
        );
      }

      // 4. Criar arquivo de metadados (único arquivo que requer escrita temporária)
      onProgress?.call(l10n.backupProgressCreatingMetadata);
      final metadataContent =
          '''
DayApp Backup
Data: ${DateTime.now().toIso8601String()}
Banco de dados: ${dbSnapshot.dbFile.lengthSync()} bytes
Vídeos: ${videoFiles.length} arquivo(s)
Fotos: ${photoFiles.length} arquivo(s)
Fotos de perfil: ${profileImageFiles.length} arquivo(s)
Áudios: ${audioFiles.length} arquivo(s)
Versão: 2.0.0
''';
      final metadataFile = File(path.join(tempDir.path, 'backup_info.txt'));
      await metadataFile.writeAsString(metadataContent);

      // 5. Calcular tamanhos em paralelo para evitar awaits sequenciais
      Future<int> fileSizeOrZero(File file) async =>
          await file.exists() ? await file.length() : 0;

      final allFiles = [
        ...dbSnapshot.files,
        ...videoFiles,
        ...photoFiles,
        ...chapterPhotoFiles,
        ...profileImageFiles,
        ...audioFiles,
        metadataFile,
      ];
      final sizes = await Future.wait(allFiles.map(fileSizeOrZero));

      // 6. Montar entradas do ZIP apontando para os arquivos originais.
      //    DB e metadados comprimem bem (texto/SQLite).
      //    Mídias já são comprimidas pelo codec — modo Store evita CPU
      //    desnecessária sem ganho real de tamanho.
      final zipEntriesWithSize = <Map<String, dynamic>>[];
      var totalBytes = 0;
      var sizeIdx = 0;

      void addEntry(
        String sourcePath,
        String archivePath,
        int sizeBytes, {
        bool compress = false,
      }) {
        if (sizeBytes <= 0) return;
        totalBytes += sizeBytes;
        zipEntriesWithSize.add({
          'sourcePath': sourcePath,
          'archivePath': archivePath,
          'sizeBytes': sizeBytes,
          'compress': compress,
        });
      }

      addEntry(
        dbSnapshot.dbFile.path,
        'dayapp.db',
        sizes[sizeIdx++],
        compress: true,
      );
      if (dbSnapshot.walFile != null) {
        addEntry(dbSnapshot.walFile!.path, 'dayapp.db-wal', sizes[sizeIdx++]);
      }
      if (dbSnapshot.shmFile != null) {
        addEntry(dbSnapshot.shmFile!.path, 'dayapp.db-shm', sizes[sizeIdx++]);
      }
      for (final f in videoFiles) {
        addEntry(f.path, 'videos/${path.basename(f.path)}', sizes[sizeIdx++]);
      }
      for (final f in photoFiles) {
        addEntry(f.path, 'photos/${path.basename(f.path)}', sizes[sizeIdx++]);
      }
      for (final f in chapterPhotoFiles) {
        addEntry(
          f.path,
          'chapter_photos/${path.basename(f.path)}',
          sizes[sizeIdx++],
        );
      }
      for (final f in profileImageFiles) {
        addEntry(
          f.path,
          'profile_images/${path.basename(f.path)}',
          sizes[sizeIdx++],
        );
      }
      for (final f in audioFiles) {
        addEntry(f.path, 'audios/${path.basename(f.path)}', sizes[sizeIdx++]);
      }
      addEntry(
        metadataFile.path,
        'backup_info.txt',
        sizes[sizeIdx++],
        compress: true,
      );

      // 7. Comprimir em ZIP via isolate (sem cópia prévia de arquivos)
      onProgress?.call(l10n.backupProgressCompressing);
      final now = DateTime.now();
      final backupStamp = _formatBackupTimestamp(now);
      final zipPath = path.join(tempDir.path, '${backupStamp}_bkp.dayapp');

      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(backupZipIsolateEntrypoint, {
        'sendPort': receivePort.sendPort,
        'zipPath': zipPath,
        'entries': zipEntriesWithSize,
        'totalBytes': totalBytes,
      });

      final completer = Completer<void>();
      late final StreamSubscription<dynamic> subscription;

      subscription = receivePort.listen((message) {
        if (message is! Map) {
          return;
        }

        final type = message['type'];
        if (type == 'progress') {
          final processedBytes = (message['processedBytes'] as int?) ?? 0;
          final workerTotalBytes =
              (message['totalBytes'] as int?) ?? totalBytes;

          final ratio = workerTotalBytes <= 0
              ? 1.0
              : (processedBytes / workerTotalBytes).clamp(0.0, 1.0).toDouble();

          final percentage = (ratio * 100).toStringAsFixed(0);
          onProgress?.call('${l10n.backupProgressCompressing} ($percentage%)');
          onProgressValue?.call(ratio);
        } else if (type == 'done') {
          onProgressValue?.call(1.0);
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else if (type == 'error') {
          if (!completer.isCompleted) {
            completer.completeError(Exception(message['error']));
          }
        }
      });

      try {
        await completer.future;
      } finally {
        await subscription.cancel();
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
      }

      // Limpar metadados temporários
      try {
        await metadataFile.delete();
      } catch (e) {
        // Silencioso — arquivo temporário, falha não é crítica
        debugPrint(
          'BackupService: erro ao deletar arquivo temporário de metadados de backup: $e',
        );
      }

      onProgress?.call(l10n.backupProgressSuccess);
      return zipPath;
    } catch (e) {
      rethrow;
    } finally {
      await dbSnapshot?.cleanup();
    }
  }

  /// Gera um snapshot consistente do banco e inclui WAL/SHM no fallback.
  Future<DatabaseSnapshotBundle> createConsistentDatabaseSnapshot() async {
    final db = await DatabaseHelper().database;
    final tempDir = await getTemporaryDirectory();
    final snapshotPath = path.join(
      tempDir.path,
      'dayapp_snapshot_${DateTime.now().millisecondsSinceEpoch}.db',
    );

    try {
      final escapedSnapshotPath = snapshotPath.replaceAll("'", "''");
      await db.execute("VACUUM INTO '$escapedSnapshotPath'");
      return DatabaseSnapshotBundle(dbFile: File(snapshotPath));
    } catch (e) {
      debugPrint(
        'BackupService: VACUUM INTO falhou, usando fallback com WAL/SHM: $e',
      );

      final dbPath = await getDatabasesPath();
      final sourceDb = File(path.join(dbPath, 'dayapp.db'));
      final sourceWal = File('${sourceDb.path}-wal');
      final sourceShm = File('${sourceDb.path}-shm');

      if (!await sourceDb.exists()) {
        throw Exception('Arquivo de banco não encontrado para snapshot.');
      }

      final copiedDb = await sourceDb.copy(snapshotPath);

      File? copiedWal;
      File? copiedShm;

      if (await sourceWal.exists()) {
        copiedWal = await sourceWal.copy('$snapshotPath-wal');
      }
      if (await sourceShm.exists()) {
        copiedShm = await sourceShm.copy('$snapshotPath-shm');
      }

      return DatabaseSnapshotBundle(
        dbFile: copiedDb,
        walFile: copiedWal,
        shmFile: copiedShm,
      );
    }
  }

  /// Gera um snapshot consistente do banco SQLite, incluindo dados pendentes
  /// no WAL, para evitar perda parcial de dados no backup.
  Future<File> createConsistentDatabaseSnapshotFile() async {
    final bundle = await createConsistentDatabaseSnapshot();
    return bundle.dbFile;
  }

  /// Compartilha o arquivo de backup (para salvar no OneDrive, Google Drive, etc)
  Future<String> shareBackupFile({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    try {
      final zipPath = await createBackupZipFile(
        onProgress: onProgress,
        onProgressValue: onProgressValue,
        l10n: l10n,
      );
      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception(l10n.errorBackupFileNotFound);
      }

      // Compartilhar arquivo
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(zipPath, mimeType: 'application/zip')],
        subject: l10n.backupShareSubject,
        text: l10n.backupShareText,
      );

      return zipPath;
    } catch (e) {
      rethrow;
    }
  }

  /// Cria o backup e salva o ZIP em uma pasta escolhida pelo usuário.
  Future<String> saveBackupFileToFolder({
    required String folderPath,
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    try {
      final zipPath = await createBackupZipFile(
        onProgress: onProgress,
        onProgressValue: onProgressValue,
        l10n: l10n,
      );
      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception(l10n.errorBackupFileNotFound);
      }

      onProgress?.call(l10n.backupSavedToFolder);
      onProgressValue?.call(0.95);

      final destinationPath = path.join(folderPath, path.basename(zipPath));
      final destinationFile = await zipFile.copy(destinationPath);

      onProgressValue?.call(1.0);
      onProgress?.call(l10n.backupProgressSuccess);

      return destinationFile.path;
    } catch (e) {
      rethrow;
    }
  }

  /// Restaura backup de um arquivo ZIP
  Future<void> restoreFromZipFile(
    String zipFilePath, {
    required AppLocalizations l10n,
    void Function(String)? onProgress,
    void Function(double?)? onProgressValue,
  }) async {
    try {
      onProgressValue?.call(0.0);
      onProgress?.call(l10n.restoreProgressExtracting);

      // Criar diretório temporário
      final tempDir = await getTemporaryDirectory();

      final extractDir = Directory(path.join(tempDir.path, 'backup_restore'));
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      // Extrair ZIP
      final zipFile = File(zipFilePath);
      final bytes = await zipFile.readAsBytes();

      // password null = backup sem criptografia (compatibilidade com backups antigos)
      final archive = ZipDecoder().decodeBytes(bytes);

      final extractTotalBytes = archive
          .where((file) => file.isFile)
          .fold<int>(0, (sum, file) => sum + file.size);

      Future<int> calculateFilesTotalBytes(List<File> files) async {
        var totalBytes = 0;
        for (final file in files) {
          if (await file.exists()) {
            totalBytes += await file.length();
          }
        }
        return totalBytes;
      }

      void reportOverallProgress({
        required int completedWorkBytes,
        required int totalWorkBytes,
      }) {
        if (totalWorkBytes <= 0) {
          onProgressValue?.call(0.0);
          return;
        }

        final ratio = (completedWorkBytes / totalWorkBytes)
            .clamp(0.0, 1.0)
            .toDouble();
        onProgressValue?.call(ratio);
      }

      onProgress?.call(l10n.restoreProgressZipContains(archive.length));

      var extractedBytesDone = 0;
      for (final file in archive) {
        final filename = path.join(extractDir.path, file.name);
        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedBytesDone += file.size;
          reportOverallProgress(
            completedWorkBytes: extractedBytesDone,
            totalWorkBytes: extractTotalBytes,
          );
        } else {
          await Directory(filename).create(recursive: true);
        }
      }

      // Função auxiliar para encontrar arquivo recursivamente
      File? findFile(Directory dir, String fileName) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is File && path.basename(entity.path) == fileName) {
            return entity;
          }
        }
        return null;
      }

      Directory? findDirectory(Directory dir, String directoryName) {
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is Directory &&
              path.basename(entity.path) == directoryName) {
            return entity;
          }
        }
        return null;
      }

      // Coletar arquivos restauráveis para calcular um progresso calibrado.
      final restoredDb = findFile(extractDir, 'dayapp.db');
      final restoredDbWal = findFile(extractDir, 'dayapp.db-wal');
      final restoredDbShm = findFile(extractDir, 'dayapp.db-shm');

      final videosRestoreDir = findDirectory(extractDir, 'videos');
      final restoredVideos =
          (videosRestoreDir
              ?.listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.mp4'))
              .toList()) ??
          <File>[];

      final photosRestoreDir = findDirectory(extractDir, 'photos');
      final restoredPhotos =
          (photosRestoreDir
              ?.listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
              .toList()) ??
          <File>[];

      final audiosRestoreDir = findDirectory(extractDir, 'audios');
      final restoredAudios =
          (audiosRestoreDir
              ?.listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp3'))
              .toList()) ??
          <File>[];

      final chapterPhotosRestoreDir = findDirectory(
        extractDir,
        'chapter_photos',
      );
      final restoredChapterPhotos =
          (chapterPhotosRestoreDir
              ?.listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
              .toList()) ??
          <File>[];

      final profileImagesRestoreDir = findDirectory(
        extractDir,
        'profile_images',
      );
      final restoredProfileImages =
          (profileImagesRestoreDir
              ?.listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
              .toList()) ??
          <File>[];

      final dbPath = await getDatabasesPath();
      final currentDb = File(path.join(dbPath, 'dayapp.db'));

      final currentDbBytes = await currentDb.exists()
          ? await currentDb.length()
          : 0;
      final restoredDbBytes = (restoredDb != null && await restoredDb.exists())
          ? await restoredDb.length()
          : 0;
      final restoredDbWalBytes =
          (restoredDbWal != null && await restoredDbWal.exists())
          ? await restoredDbWal.length()
          : 0;
      final restoredDbShmBytes =
          (restoredDbShm != null && await restoredDbShm.exists())
          ? await restoredDbShm.length()
          : 0;
      final restoredVideosBytes = await calculateFilesTotalBytes(
        restoredVideos,
      );
      final restoredPhotosBytes = await calculateFilesTotalBytes(
        restoredPhotos,
      );
      final restoredAudiosBytes = await calculateFilesTotalBytes(
        restoredAudios,
      );
      final restoredChapterPhotosBytes = await calculateFilesTotalBytes(
        restoredChapterPhotos,
      );
      final restoredProfileImagesBytes = await calculateFilesTotalBytes(
        restoredProfileImages,
      );

      final restoreCopyWorkBytes =
          currentDbBytes +
          restoredDbBytes +
          restoredDbWalBytes +
          restoredDbShmBytes +
          restoredVideosBytes +
          restoredPhotosBytes +
          restoredAudiosBytes +
          restoredChapterPhotosBytes +
          restoredProfileImagesBytes;
      final totalWorkBytes = extractTotalBytes + restoreCopyWorkBytes;
      var completedWorkBytes = extractTotalBytes;

      reportOverallProgress(
        completedWorkBytes: completedWorkBytes,
        totalWorkBytes: totalWorkBytes,
      );

      // 1. Fazer backup do banco atual
      onProgress?.call(l10n.restoreProgressBackingUpCurrent);

      if (await currentDb.exists()) {
        final backupCurrent = File(path.join(dbPath, 'dayapp_backup_local.db'));
        await currentDb.copy(backupCurrent.path);
        completedWorkBytes += currentDbBytes;
        reportOverallProgress(
          completedWorkBytes: completedWorkBytes,
          totalWorkBytes: totalWorkBytes,
        );
      }

      // 2. Restaurar banco de dados
      onProgress?.call(l10n.restoreProgressRestoringDb);

      // Procurar o arquivo do banco de dados recursivamente
      if (restoredDb != null && await restoredDb.exists()) {
        // Fechar todas as conexões com o banco antes de substituir
        onProgress?.call(l10n.restoreProgressClosingDb);
        await DatabaseHelper().resetDatabase();

        // Usar deleteDatabase do sqflite para garantir que o arquivo é liberado
        final dbFullPath = path.join(dbPath, 'dayapp.db');
        await deleteDatabase(dbFullPath);

        // Remover arquivos WAL e SHM do SQLite (podem conter dados em cache)
        final walFile = File('$dbFullPath-wal');
        final shmFile = File('$dbFullPath-shm');
        if (await walFile.exists()) {
          await walFile.delete();
        }
        if (await shmFile.exists()) {
          await shmFile.delete();
        }

        // Aguardar para garantir que os arquivos foram liberados
        await Future.delayed(const Duration(milliseconds: 500));

        // Copiar banco restaurado
        onProgress?.call(l10n.restoreProgressCopyingRestoredDb);
        await restoredDb.copy(currentDb.path);
        completedWorkBytes += restoredDbBytes;

        // Se o backup contiver WAL/SHM, restaurar também para preservar
        // transações recentes ainda não incorporadas ao dayapp.db.
        if (restoredDbWal != null && await restoredDbWal.exists()) {
          await restoredDbWal.copy('$dbFullPath-wal');
          completedWorkBytes += restoredDbWalBytes;
        }
        if (restoredDbShm != null && await restoredDbShm.exists()) {
          await restoredDbShm.copy('$dbFullPath-shm');
          completedWorkBytes += restoredDbShmBytes;
        }

        reportOverallProgress(
          completedWorkBytes: completedWorkBytes,
          totalWorkBytes: totalWorkBytes,
        );
        // Após copiar o banco restaurado, garantir compatibilidade com a nova
        // coluna `backed_up` e marcar todas as histórias do backup como já salvas.
        try {
          final restoredDbPath = path.join(dbPath, 'dayapp.db');
          final tmpDb = await openDatabase(restoredDbPath);
          try {
            // Marcar todas as histórias deste banco restaurado como já salvas
            await tmpDb.update('historia', {'backed_up': 1});
          } finally {
            await tmpDb.close();
          }
        } catch (e) {
          // Não falhar a restauração se a marcação não funcionar
          debugPrint(
            'BackupService: erro em ajustes pós-restauração do banco: $e',
          );
        }
      } else {
        throw Exception(
          l10n.errorBackupDbNotFoundInFile(
            extractDir.listSync(recursive: true).length,
          ),
        );
      }

      // 3. Restaurar vÃ­deos
      onProgress?.call(l10n.restoreProgressRestoringVideos);

      if (videosRestoreDir != null && await videosRestoreDir.exists()) {
        // Limpar vÃ­deos atuais
        final videosDir = await VideoFileHelper.getVideosDirectory();
        final currentVideos = videosDir.listSync();
        for (final file in currentVideos) {
          if (file is File) {
            await file.delete();
          }
        }

        for (int i = 0; i < restoredVideos.length; i++) {
          final videoFile = restoredVideos[i];
          final videoFileName = path.basename(videoFile.path);
          onProgress?.call(
            l10n.restoreProgressRestoringVideo(i + 1, restoredVideos.length),
          );

          final destFile = File(path.join(videosDir.path, videoFileName));
          await videoFile.copy(destFile.path);

          if (await videoFile.exists()) {
            completedWorkBytes += await videoFile.length();
            reportOverallProgress(
              completedWorkBytes: completedWorkBytes,
              totalWorkBytes: totalWorkBytes,
            );
          }
        }
      }

      // 4. Restaurar fotos
      onProgress?.call(l10n.restoreProgressRestoringPhotos);

      if (photosRestoreDir != null && await photosRestoreDir.exists()) {
        // Limpar fotos atuais
        final photosDir = await PhotoFileHelper.getPhotosDirectory();
        final currentPhotos = photosDir.listSync();
        for (final file in currentPhotos) {
          if (file is File) {
            await file.delete();
          }
        }

        for (int i = 0; i < restoredPhotos.length; i++) {
          final photoFile = restoredPhotos[i];
          final photoFileName = path.basename(photoFile.path);
          onProgress?.call(
            l10n.restoreProgressRestoringPhoto(i + 1, restoredPhotos.length),
          );

          final destFile = File(path.join(photosDir.path, photoFileName));
          await photoFile.copy(destFile.path);

          if (await photoFile.exists()) {
            completedWorkBytes += await photoFile.length();
            reportOverallProgress(
              completedWorkBytes: completedWorkBytes,
              totalWorkBytes: totalWorkBytes,
            );
          }
        }
      }

      // 5. Restaurar fotos de capítulos
      if (chapterPhotosRestoreDir != null &&
          await chapterPhotosRestoreDir.exists()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final chapterPhotosDestDir = Directory(
          path.join(appDocDir.path, 'chapter_photos'),
        );

        // Limpar fotos de capítulos atuais
        if (await chapterPhotosDestDir.exists()) {
          final currentChapterPhotos = chapterPhotosDestDir.listSync();
          for (final file in currentChapterPhotos) {
            if (file is File) {
              await file.delete();
            }
          }
        } else {
          await chapterPhotosDestDir.create(recursive: true);
        }

        for (final chapterPhotoFile in restoredChapterPhotos) {
          final fileName = path.basename(chapterPhotoFile.path);
          final destFile = File(path.join(chapterPhotosDestDir.path, fileName));
          await chapterPhotoFile.copy(destFile.path);

          if (await chapterPhotoFile.exists()) {
            completedWorkBytes += await chapterPhotoFile.length();
            reportOverallProgress(
              completedWorkBytes: completedWorkBytes,
              totalWorkBytes: totalWorkBytes,
            );
          }
        }
      }

      // 5.5. Restaurar fotos de perfil
      if (profileImagesRestoreDir != null &&
          await profileImagesRestoreDir.exists()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final profileImagesDestDir = Directory(
          path.join(appDocDir.path, 'profile_images'),
        );

        // Limpar fotos de perfil atuais
        if (await profileImagesDestDir.exists()) {
          final currentProfileImages = profileImagesDestDir.listSync();
          for (final file in currentProfileImages) {
            if (file is File) {
              await file.delete();
            }
          }
        } else {
          await profileImagesDestDir.create(recursive: true);
        }

        for (final profileImageFile in restoredProfileImages) {
          final fileName = path.basename(profileImageFile.path);
          final destFile = File(path.join(profileImagesDestDir.path, fileName));
          await profileImageFile.copy(destFile.path);

          if (await profileImageFile.exists()) {
            completedWorkBytes += await profileImageFile.length();
            reportOverallProgress(
              completedWorkBytes: completedWorkBytes,
              totalWorkBytes: totalWorkBytes,
            );
          }
        }
      }

      // 6. Restaurar áudios
      onProgress?.call(l10n.restoreProgressRestoringAudios);

      if (audiosRestoreDir != null && await audiosRestoreDir.exists()) {
        // Limpar áudios atuais
        final audiosDir = await AudioFileHelper.getAudiosDirectory();
        final currentAudios = audiosDir.listSync();
        for (final file in currentAudios) {
          if (file is File) {
            await file.delete();
          }
        }

        for (int i = 0; i < restoredAudios.length; i++) {
          final audioFile = restoredAudios[i];
          final audioFileName = path.basename(audioFile.path);
          onProgress?.call(
            l10n.restoreProgressRestoringAudio(i + 1, restoredAudios.length),
          );

          final destFile = File(path.join(audiosDir.path, audioFileName));
          await audioFile.copy(destFile.path);

          if (await audioFile.exists()) {
            completedWorkBytes += await audioFile.length();
            reportOverallProgress(
              completedWorkBytes: completedWorkBytes,
              totalWorkBytes: totalWorkBytes,
            );
          }
        }
      }

      // 7. Reescrever caminhos absolutos no banco restaurado.
      //
      // O banco de dados armazena caminhos ABSOLUTOS como:
      //   /data/user/0/<old_package>/app_flutter/photos/photo_xxx.jpg
      // Após restaurar para outro dispositivo ou após mudança de package ID,
      // esses caminhos ficam inválidos. Os arquivos já estão nas pastas certas,
      // mas o DB precisa apontar para o diretório atual do app.
      onProgress?.call(l10n.restoreProgressReinitializingDb);
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final dbFullPath2 = path.join(await getDatabasesPath(), 'dayapp.db');
        final patchDb = await openDatabase(dbFullPath2);
        try {
          final photosBase = path.join(appDocDir.path, 'photos');
          final audiosBase = path.join(appDocDir.path, 'audios');
          final videosBase = path.join(appDocDir.path, 'videos');
          final chapterPhotosBase = path.join(appDocDir.path, 'chapter_photos');
          final profileImagesBase = path.join(appDocDir.path, 'profile_images');

          // Reescreve foto_path em historia_fotos
          final fotos = await patchDb.query(
            'historia_fotos',
            columns: ['id', 'foto_path'],
          );
          for (final row in fotos) {
            final oldPath = row['foto_path'] as String;
            final newPath = path.join(photosBase, path.basename(oldPath));
            if (oldPath != newPath) {
              await patchDb.update(
                'historia_fotos',
                {'foto_path': newPath},
                where: 'id = ?',
                whereArgs: [row['id']],
              );
            }
          }

          // Reescreve audio_path em historia_audios
          final audios = await patchDb.query(
            'historia_audios',
            columns: ['id', 'audio_path'],
          );
          for (final row in audios) {
            final oldPath = row['audio_path'] as String;
            final newPath = path.join(audiosBase, path.basename(oldPath));
            if (oldPath != newPath) {
              await patchDb.update(
                'historia_audios',
                {'audio_path': newPath},
                where: 'id = ?',
                whereArgs: [row['id']],
              );
            }
          }

          // Reescreve video_path e thumbnail_path em historia_videos
          final videos = await patchDb.query(
            'historia_videos',
            columns: ['id', 'video_path', 'thumbnail_path'],
          );
          for (final row in videos) {
            final oldVideoPath = row['video_path'] as String;
            final newVideoPath = path.join(
              videosBase,
              path.basename(oldVideoPath),
            );
            final oldThumbnailPath = row['thumbnail_path'] as String?;
            final newThumbnailPath =
                (oldThumbnailPath != null && oldThumbnailPath.isNotEmpty)
                ? path.join(videosBase, path.basename(oldThumbnailPath))
                : null;
            if (oldVideoPath != newVideoPath ||
                oldThumbnailPath != newThumbnailPath) {
              await patchDb.update(
                'historia_videos',
                {
                  'video_path': newVideoPath,
                  'thumbnail_path': newThumbnailPath,
                },
                where: 'id = ?',
                whereArgs: [row['id']],
              );
            }
          }

          // Reescreve foto_path em capitulos
          final capitulos = await patchDb.query(
            'capitulos',
            columns: ['id', 'foto_path'],
            where: 'foto_path IS NOT NULL',
          );
          for (final row in capitulos) {
            final oldPath = row['foto_path'] as String?;
            if (oldPath == null || oldPath.isEmpty) continue;
            final newPath = path.join(
              chapterPhotosBase,
              path.basename(oldPath),
            );
            if (oldPath != newPath) {
              await patchDb.update(
                'capitulos',
                {'foto_path': newPath},
                where: 'id = ?',
                whereArgs: [row['id']],
              );
            }
          }

          // Reescreve foto_perfil em users
          final users = await patchDb.query(
            'users',
            columns: ['id', 'foto_perfil'],
            where: 'foto_perfil IS NOT NULL',
          );
          for (final row in users) {
            final oldPath = row['foto_perfil'] as String?;
            if (oldPath == null || oldPath.isEmpty) continue;
            if (!oldPath.startsWith('http') && !oldPath.startsWith('assets')) {
              final newPath = path.join(
                profileImagesBase,
                path.basename(oldPath),
              );
              if (oldPath != newPath) {
                await patchDb.update(
                  'users',
                  {'foto_perfil': newPath},
                  where: 'id = ?',
                  whereArgs: [row['id']],
                );
              }
            }
          }
        } finally {
          await patchDb.close();
        }
      } catch (e) {
        // Não bloquear a restauração se a reescrita falhar
        debugPrint('Aviso: falha ao reescrever caminhos de mídia: $e');
      }

      // Limpar diretório temporário
      await extractDir.delete(recursive: true);

      // Reinicializar conexão com o banco de dados restaurado
      onProgress?.call(l10n.restoreProgressReinitializingDb);

      // Garantir que o singleton foi resetado
      await DatabaseHelper().resetDatabase();

      // Aguardar um pouco mais para garantir
      await Future.delayed(const Duration(milliseconds: 500));

      // Verificação: contar registros para confirmar que o banco foi carregado
      final deletedCount = await HistoriaRepository().countStories(
        where: 'excluido = ?',
        whereArgs: ['sim'],
      );
      final activeCount = await HistoriaRepository().countStories(
        where: 'excluido IS NULL',
      );

      onProgress?.call(l10n.restoreProgressDbStats(activeCount, deletedCount));

      onProgress?.call(l10n.restoreSuccess);
      onProgressValue?.call(1.0);
    } catch (e) {
      rethrow;
    }
  }

  /// Valida se o nome do arquivo de backup (com ou sem extensão)
  /// corresponde a um dos padrões adotados pelo app ou se contém o nome do app e backup.
  bool isValidBackupFileName(String fileName) {
    final lowerName = fileName.toLowerCase();
    // 1. Aceita explicitamente formatos amigáveis/comuns ou arquivos com a extensão própria do app (.dayapp)
    if (lowerName.endsWith('.dayapp') ||
        (lowerName.contains('dayapp') &&
            (lowerName.contains('backup') || lowerName.contains('bkp')))) {
      return true;
    }

    // 2. Se não casar com os termos acima, mas terminar com .zip ou .dayapp, removemos a extensão para verificar
    // os padrões de nomes gerados automaticamente (legados e novos)
    String baseName = fileName;
    if (lowerName.endsWith('.zip')) {
      baseName = fileName.substring(0, fileName.length - 4);
    } else if (lowerName.endsWith('.dayapp')) {
      baseName = fileName.substring(0, fileName.length - 7);
    } else {
      // Se não tem extensão reconhecida e não casou com a regra genérica, falha
      return false;
    }

    final regExpCompat1 = RegExp(r'^dayapp_backup_\d+$');
    final regExpCompat2 = RegExp(r'^dayapp_\d{6}_\d+$');
    final regExpNew = RegExp(r'^dayapp_\d{2}[a-zA-Z]{3}_\d+$');
    final regExpNewFormat = RegExp(
      r'^dayapp_backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(?:-\d+)?$',
    );
    final regExpNewFormat2 = RegExp(
      r'^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(?:-\d+)?_DayApp_bkp$',
    );
    final regExpNewFormat3 = RegExp(
      r'^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(?:-\d+)?_bkp$',
    );

    return regExpCompat1.hasMatch(baseName) ||
        regExpCompat2.hasMatch(baseName) ||
        regExpNew.hasMatch(baseName) ||
        regExpNewFormat.hasMatch(baseName) ||
        regExpNewFormat2.hasMatch(baseName) ||
        regExpNewFormat3.hasMatch(baseName);
  }

  String _formatBackupTimestamp(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final micro = dateTime.microsecond.toString().padLeft(6, '0');
    return '$year-$month-${day}_$hour-$minute-$second-$micro';
  }

  Future<void> saveLastBackupFileName(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_backup_file_name', fileName);
  }

  Future<String?> getLastBackupFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_backup_file_name');
  }
}
