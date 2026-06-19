import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/l10n/app_localizations_en.dart';
import 'package:dayapp/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform({
    required this.temporaryPath,
    required this.documentsPath,
  });

  final String temporaryPath;
  final String documentsPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => documentsPath;

  @override
  Future<String?> getLibraryPath() async => documentsPath;

  @override
  Future<String?> getApplicationCachePath() async => temporaryPath;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return null;
  }

  @override
  Future<String?> getDownloadsPath() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late Directory documentsDir;
  late PathProviderPlatform originalPlatform;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('backup_restore_test_');
    documentsDir = Directory(p.join(tempRoot.path, 'documents'));
    await documentsDir.create(recursive: true);
    originalPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      temporaryPath: tempRoot.path,
      documentsPath: documentsDir.path,
    );

    final dbPath = await getDatabasesPath();
    final dbDir = Directory(dbPath);
    if (await dbDir.exists()) {
      await dbDir.delete(recursive: true);
    }
    await dbDir.create(recursive: true);

    final currentDb = File(p.join(dbPath, 'dayapp.db'));
    if (await currentDb.exists()) {
      await currentDb.delete();
    }

    BackupService();
  });

  tearDown(() async {
    await DatabaseHelper().resetDatabase();
    PathProviderPlatform.instance = originalPlatform;
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('restore adds display_order back to legacy chapter backups', () async {
    final dbPath = await getDatabasesPath();
    final sourceDbPath = p.join(tempRoot.path, 'source_legacy.db');
    final sourceDb = await databaseFactoryFfi.openDatabase(sourceDbPath);

    await sourceDb.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        foto_perfil TEXT
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE historia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        assunto TEXT,
        titulo TEXT NOT NULL,
        data TIMESTAMP NOT NULL,
        tag TEXT,
        grupo TEXT,
        arquivado TEXT,
        excluido TEXT,
        data_exclusao TIMESTAMP,
        descricao TEXT,
        sentimento TEXT,
        emoticon TEXT,
        data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        foto_historia TEXT,
        backed_up INTEGER DEFAULT 0,
        humor INTEGER DEFAULT 3,
        energia INTEGER DEFAULT 2
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE capitulos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        titulo TEXT NOT NULL,
        data_inicio TIMESTAMP NOT NULL,
        data_fim TIMESTAMP NOT NULL,
        descricao TEXT,
        foto_path TEXT
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE capitulo_entradas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        capitulo_id INTEGER NOT NULL,
        entrada_id INTEGER NOT NULL,
        UNIQUE(capitulo_id, entrada_id)
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE historia_fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_id INTEGER NOT NULL,
        foto_path TEXT NOT NULL,
        legenda TEXT
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE historia_audios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_id INTEGER NOT NULL,
        audio_path TEXT NOT NULL,
        legenda TEXT,
        duracao INTEGER
      );
    ''');
    await sourceDb.execute('''
      CREATE TABLE historia_videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_id INTEGER NOT NULL,
        video_path TEXT NOT NULL,
        legenda TEXT,
        duracao INTEGER,
        thumbnail_path TEXT
      );
    ''');

    await sourceDb.insert('users', {
      'id': 'user-1',
      'nome': 'User 1',
      'email': 'user@example.com',
      'senha': 'secret',
      'foto_perfil': null,
    });
    final storyId = await sourceDb.insert('historia', {
      'user_id': 'user-1',
      'assunto': null,
      'titulo': 'Primeira história',
      'data': '2026-06-01T10:00:00.000',
      'tag': null,
      'grupo': null,
      'arquivado': null,
      'excluido': null,
      'data_exclusao': null,
      'descricao': 'Conteúdo legado',
      'sentimento': null,
      'emoticon': null,
      'data_criacao': '2026-06-01T10:00:00.000',
      'data_update': '2026-06-01T10:00:00.000',
      'foto_historia': null,
      'backed_up': 1,
      'humor': 3,
      'energia': 2,
    });
    final chapterId = await sourceDb.insert('capitulos', {
      'user_id': 'user-1',
      'titulo': 'Capítulo legado',
      'data_inicio': '2026-06-01T00:00:00.000',
      'data_fim': '2026-06-30T00:00:00.000',
      'descricao': null,
      'foto_path': null,
    });
    await sourceDb.insert('capitulo_entradas', {
      'capitulo_id': chapterId,
      'entrada_id': storyId,
    });
    await sourceDb.execute('PRAGMA user_version = 20;');
    await sourceDb.close();

    final zipPath = p.join(tempRoot.path, 'legacy_backup.zip');
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          'dayapp.db',
          await File(sourceDbPath).length(),
          await File(sourceDbPath).readAsBytes(),
        ),
      );
    final zipBytes = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipBytes);

    final service = BackupService();
    await service.restoreFromZipFile(zipPath, l10n: AppLocalizationsEn('en'));

    final restoredDbPath = p.join(dbPath, 'dayapp.db');
    final restoredDb = await databaseFactoryFfi.openDatabase(restoredDbPath);

    final tableInfo = await restoredDb.rawQuery(
      'PRAGMA table_info(capitulo_entradas)',
    );
    expect(
      tableInfo.any((column) => column['name'] == 'display_order'),
      isTrue,
    );

    final rows = await restoredDb.query(
      'capitulo_entradas',
      columns: ['capitulo_id', 'entrada_id', 'display_order'],
    );
    expect(rows, hasLength(1));
    expect(rows.first['display_order'], 1);

    await restoredDb.close();
  });
}
