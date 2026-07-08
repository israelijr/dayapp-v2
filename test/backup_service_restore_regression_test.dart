import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/db/pessoa_helper.dart';
import 'package:dayapp/l10n/app_localizations_en.dart';
import 'package:dayapp/models/pessoa.dart';
import 'package:dayapp/repositories/historia_repository.dart';
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

  test('backup/restore preserva local e pessoas com WAL ativo', () async {
    final db = await DatabaseHelper().database;
    await db.execute('PRAGMA journal_mode = WAL;');

    await db.insert('users', {
      'id': 'user-wal',
      'nome': 'Usuario WAL',
      'email': 'wal@example.com',
      'senha': 'segredo',
      'dt_nascimento': null,
      'foto_perfil': null,
    });

    final pessoaAna = await PessoaHelper().getOrCreatePessoa('user-wal', 'Ana');
    final pessoaBeto = await PessoaHelper().getOrCreatePessoa(
      'user-wal',
      'Beto',
    );

    final historiaId = await HistoriaRepository().createHistoria(
      userId: 'user-wal',
      titulo: 'Historia com local e pessoas',
      data: DateTime(2026, 7, 1, 10),
      humor: 4,
      energia: 3,
      descricao: 'Teste de backup WAL',
      local: 'Praia de Copacabana',
      pessoas: [pessoaAna, pessoaBeto],
    );

    final service = BackupService();
    final backupPath = await service.createBackupZipFile(
      l10n: AppLocalizationsEn('en'),
    );

    expect(
      p.basename(backupPath),
      matches(
        RegExp(r'^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(?:-\d+)?_bkp\.dayapp$'),
      ),
    );

    await db.update(
      'historia',
      {'local': null},
      where: 'id = ?',
      whereArgs: [historiaId],
    );
    await PessoaHelper().setPessoasForHistoria(
      historiaId,
      const <Pessoa>[],
      null,
    );

    await service.restoreFromZipFile(
      backupPath,
      l10n: AppLocalizationsEn('en'),
    );

    final restoredDb = await DatabaseHelper().database;
    final restoredRows = await restoredDb.query(
      'historia',
      columns: ['local'],
      where: 'id = ?',
      whereArgs: [historiaId],
    );

    expect(restoredRows, hasLength(1));
    expect(restoredRows.first['local'], 'Praia de Copacabana');

    final restoredPeople = await PessoaHelper().getPessoasByHistoria(
      historiaId,
    );
    expect(restoredPeople, hasLength(2));
    expect(restoredPeople.any((p) => p.nome == 'Ana'), isTrue);
    expect(restoredPeople.any((p) => p.nome == 'Beto'), isTrue);
  });

  test('backup filename validator accepts new and legacy formats', () {
    final service = BackupService();

    expect(
      service.isValidBackupFileName('dayapp_backup_2026-07-04_22-35-18.zip'),
      isTrue,
    );
    expect(
      service.isValidBackupFileName('2026-07-04_22-35-18_DayApp_bkp.zip'),
      isTrue,
    );
    expect(service.isValidBackupFileName('dayapp_backup_123456.zip'), isTrue);
    expect(service.isValidBackupFileName('dayapp_250704_123.zip'), isTrue);
    expect(service.isValidBackupFileName('dayapp_04jul_123.zip'), isTrue);
    expect(service.isValidBackupFileName('Backup DayApp'), isTrue);
    expect(service.isValidBackupFileName('Backup DayApp.zip'), isTrue);
    expect(service.isValidBackupFileName('Backup_DayApp'), isTrue);
    expect(service.isValidBackupFileName('DayApp Backup'), isTrue);
    expect(service.isValidBackupFileName('DayApp_bkp'), isTrue);
    expect(service.isValidBackupFileName('2026-07-04_22-35-18_bkp.dayapp'), isTrue);
    expect(service.isValidBackupFileName('2026-07-04_22-35-18-123456_bkp.dayapp'), isTrue);
    expect(service.isValidBackupFileName('dayapp_backup_2026-07-04_22-35-18-123456.zip'), isTrue);
    expect(service.isValidBackupFileName('meubackup.dayapp'), isTrue);
    expect(service.isValidBackupFileName('DayApp'), isFalse);
    expect(service.isValidBackupFileName('Backup.zip'), isFalse);
    expect(service.isValidBackupFileName('invalid.zip'), isFalse);
  });

  test(
    'restore aplica dayapp.db-wal do zip e preserva pessoas/local',
    () async {
      final sourceDbPath = p.join(tempRoot.path, 'source_wal_bundle.db');
      final sourceDb = await databaseFactoryFfi.openDatabase(sourceDbPath);

      await sourceDb.execute('PRAGMA journal_mode = WAL;');
      await sourceDb.execute('PRAGMA wal_autocheckpoint = 0;');
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
        energia INTEGER DEFAULT 2,
        local TEXT
      );
    ''');
      await sourceDb.execute('''
      CREATE TABLE pessoas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        slug TEXT NOT NULL,
        UNIQUE(user_id, slug)
      );
    ''');
      await sourceDb.execute('''
      CREATE TABLE historia_pessoas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_id INTEGER NOT NULL,
        pessoa_id INTEGER NOT NULL,
        UNIQUE(historia_id, pessoa_id)
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
        'id': 'user-wal-zip',
        'nome': 'Usuario Zip',
        'email': 'zip@example.com',
        'senha': 'segredo',
        'foto_perfil': null,
      });

      final storyId = await sourceDb.insert('historia', {
        'user_id': 'user-wal-zip',
        'titulo': 'Historia com dados no WAL',
        'data': '2026-07-02T10:00:00.000',
        'descricao': 'Dados sensíveis ao WAL',
        'humor': 4,
        'energia': 3,
        'local': 'Praia do Leme',
        'backed_up': 1,
      });

      final pessoaAnaId = await sourceDb.insert('pessoas', {
        'user_id': 'user-wal-zip',
        'nome': 'Ana',
        'slug': 'ana',
      });
      final pessoaBetoId = await sourceDb.insert('pessoas', {
        'user_id': 'user-wal-zip',
        'nome': 'Beto',
        'slug': 'beto',
      });

      await sourceDb.insert('historia_pessoas', {
        'historia_id': storyId,
        'pessoa_id': pessoaAnaId,
      });
      await sourceDb.insert('historia_pessoas', {
        'historia_id': storyId,
        'pessoa_id': pessoaBetoId,
      });

      await sourceDb.execute('PRAGMA user_version = 3;');

      final dbFile = File(sourceDbPath);
      final walFile = File('$sourceDbPath-wal');
      final shmFile = File('$sourceDbPath-shm');

      expect(await dbFile.exists(), isTrue);

      // Captura os bytes enquanto a conexão ainda está aberta para evitar que
      // o close faça checkpoint e remova/trunque o WAL antes da leitura.
      final dbBytes = await dbFile.readAsBytes();
      final walExistsBeforeClose = await walFile.exists();
      expect(walExistsBeforeClose, isTrue);
      final walBytes = await walFile.readAsBytes();
      final shmBytes = await shmFile.exists()
          ? await shmFile.readAsBytes()
          : null;

      await sourceDb.close();

      final zipPath = p.join(tempRoot.path, 'wal_bundle_backup.zip');
      final archive = Archive()
        ..addFile(ArchiveFile('dayapp.db', dbBytes.length, dbBytes))
        ..addFile(ArchiveFile('dayapp.db-wal', walBytes.length, walBytes));

      if (shmBytes != null) {
        archive.addFile(
          ArchiveFile('dayapp.db-shm', shmBytes.length, shmBytes),
        );
      }

      final zipBytes = ZipEncoder().encode(archive);
      await File(zipPath).writeAsBytes(zipBytes);

      final service = BackupService();
      await service.restoreFromZipFile(zipPath, l10n: AppLocalizationsEn('en'));

      final restoredDb = await DatabaseHelper().database;
      final restoredStory = await restoredDb.query(
        'historia',
        columns: ['local'],
        where: 'id = ?',
        whereArgs: [storyId],
      );
      expect(restoredStory, hasLength(1));
      expect(restoredStory.first['local'], 'Praia do Leme');

      final rows = await restoredDb.rawQuery(
        '''
      SELECT p.nome
      FROM historia_pessoas hp
      JOIN pessoas p ON p.id = hp.pessoa_id
      WHERE hp.historia_id = ?
      ORDER BY p.nome ASC
      ''',
        [storyId],
      );
      final names = rows.map((r) => r['nome'] as String).toList();
      expect(names, ['Ana', 'Beto']);
    },
  );
}
