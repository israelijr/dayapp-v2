import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../helpers/audio_file_helper.dart';
import '../helpers/photo_file_helper.dart';
import '../helpers/video_file_helper.dart';
import '../models/historia.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'dayapp.db');
      final db = await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      await _verifyAndHealSchema(db);
      return db;
    } catch (e) {
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          senha TEXT NOT NULL,
          dt_nascimento TIMESTAMP,
          foto_perfil TEXT
        );
      ''');
      await db.execute('''
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
          local TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE historia_fotos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          foto_path TEXT NOT NULL,
          legenda TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE historia_audios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          audio_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE historia_videos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail_path TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE grupos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          emoticon TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE notification_scheduled (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          notification_id INTEGER NOT NULL,
          scheduled_time TEXT NOT NULL,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_historia_user_id ON historia(user_id);',
      );
      await db.execute('CREATE INDEX idx_historia_data ON historia(data);');
      await db.execute('CREATE INDEX idx_historia_tag ON historia(tag);');
      await db.execute('CREATE INDEX idx_users_email ON users(email);');

      // Tabela de tags (v15)
      await db.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          slug TEXT NOT NULL,
          UNIQUE(user_id, slug),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      // Tabela de relação N×N entre histórias e tags (v15)
      await db.execute('''
        CREATE TABLE historia_tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          UNIQUE(historia_id, tag_id),
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_tags_user_slug ON tags(user_id, slug);',
      );
      await db.execute(
        'CREATE INDEX idx_historia_tags_historia ON historia_tags(historia_id);',
      );
      await db.execute(
        'CREATE INDEX idx_historia_tags_tag ON historia_tags(tag_id);',
      );

      // Tabela de pessoas (v2)
      await db.execute('''
        CREATE TABLE pessoas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          slug TEXT NOT NULL,
          UNIQUE(user_id, slug),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      // Tabela de relação N×N entre histórias e pessoas (v2)
      await db.execute('''
        CREATE TABLE historia_pessoas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          pessoa_id INTEGER NOT NULL,
          UNIQUE(historia_id, pessoa_id),
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
          FOREIGN KEY (pessoa_id) REFERENCES pessoas(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_pessoas_user_slug ON pessoas(user_id, slug);',
      );
      await db.execute(
        'CREATE INDEX idx_historia_pessoas_historia ON historia_pessoas(historia_id);',
      );
      await db.execute(
        'CREATE INDEX idx_historia_pessoas_pessoa ON historia_pessoas(pessoa_id);',
      );

      // Tabelas de capítulos (v17)
      await db.execute('''
        CREATE TABLE capitulos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          titulo TEXT NOT NULL,
          descricao TEXT,
          data_inicio TIMESTAMP NOT NULL,
          data_fim TIMESTAMP NOT NULL,
          score_confianca REAL,
          criado_automaticamente INTEGER DEFAULT 0,
          foto_path TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE capitulo_entradas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          capitulo_id INTEGER NOT NULL,
          entrada_id INTEGER NOT NULL,
          display_order INTEGER,
          UNIQUE(capitulo_id, entrada_id),
          FOREIGN KEY (capitulo_id) REFERENCES capitulos(id) ON DELETE CASCADE,
          FOREIGN KEY (entrada_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('''
        CREATE TABLE capitulo_sugestoes_ignoradas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          fingerprint TEXT NOT NULL,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, fingerprint),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_capitulos_user_data ON capitulos(user_id, data_inicio, data_fim);',
      );
      await db.execute(
        'CREATE INDEX idx_capitulo_entradas_capitulo ON capitulo_entradas(capitulo_id);',
      );
      await db.execute(
        'CREATE INDEX idx_capitulo_entradas_entrada ON capitulo_entradas(entrada_id);',
      );
      await db.execute(
        'CREATE INDEX idx_capitulo_entradas_ordem ON capitulo_entradas(capitulo_id, display_order);',
      );
      await db.execute(
        'CREATE INDEX idx_capitulo_sugestoes_user ON capitulo_sugestoes_ignoradas(user_id);',
      );

      // Histórico de insights (v18)
      await db.execute('''
        CREATE TABLE insight_history (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id     TEXT    NOT NULL,
          type        TEXT    NOT NULL,
          title       TEXT    NOT NULL,
          description TEXT    NOT NULL,
          icon        TEXT    NOT NULL,
          metadata    TEXT,
          seen_at     INTEGER NOT NULL,
          is_premium  INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      await db.execute(
        'CREATE INDEX idx_insight_history_user_seen ON insight_history(user_id, seen_at DESC);',
      );
      await db.execute(
        'CREATE UNIQUE INDEX idx_insight_history_user_type ON insight_history(user_id, type);',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // Adiciona a coluna local na tabela historia se oldVersion < 2
        try {
          await db.execute('ALTER TABLE historia ADD COLUMN local TEXT;');
        } catch (e) {
          debugPrint('DatabaseHelper: erro ao adicionar coluna local (v2): $e');
        }

        // Cria a tabela de pessoas
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pessoas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              nome TEXT NOT NULL,
              slug TEXT NOT NULL,
              UNIQUE(user_id, slug),
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS historia_pessoas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              historia_id INTEGER NOT NULL,
              pessoa_id INTEGER NOT NULL,
              UNIQUE(historia_id, pessoa_id),
              FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
              FOREIGN KEY (pessoa_id) REFERENCES pessoas(id) ON DELETE CASCADE
            );
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_pessoas_user_slug ON pessoas(user_id, slug);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_historia_pessoas_historia ON historia_pessoas(historia_id);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_historia_pessoas_pessoa ON historia_pessoas(pessoa_id);',
          );
        } catch (e) {
          debugPrint('DatabaseHelper: erro ao criar tabelas/indices de pessoas (v2): $e');
        }
      }

      if (oldVersion < 3) {
        // Garante que a coluna local existe na tabela historia
        try {
          await db.execute('ALTER TABLE historia ADD COLUMN local TEXT;');
        } catch (e) {
          debugPrint('DatabaseHelper: coluna local na v3 já existe ou erro: $e');
        }

        // Garante que as tabelas pessoas e historia_pessoas existem
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pessoas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              nome TEXT NOT NULL,
              slug TEXT NOT NULL,
              UNIQUE(user_id, slug),
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            );
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS historia_pessoas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              historia_id INTEGER NOT NULL,
              pessoa_id INTEGER NOT NULL,
              UNIQUE(historia_id, pessoa_id),
              FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
              FOREIGN KEY (pessoa_id) REFERENCES pessoas(id) ON DELETE CASCADE
            );
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_pessoas_user_slug ON pessoas(user_id, slug);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_historia_pessoas_historia ON historia_pessoas(historia_id);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_historia_pessoas_pessoa ON historia_pessoas(pessoa_id);',
          );
        } catch (e) {
          debugPrint('DatabaseHelper: erro ao garantir tabelas/indices de pessoas (v3): $e');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _verifyAndHealSchema(Database db) async {
    try {
      // 1. Verificar colunas na tabela historia
      final columns = await db.rawQuery('PRAGMA table_info(historia)');
      final existingColumns = columns.map((c) => c['name'] as String).toSet();

      final requiredColumns = {
        'local': 'TEXT',
        'backed_up': 'INTEGER DEFAULT 0',
        'humor': 'INTEGER DEFAULT 3',
        'energia': 'INTEGER DEFAULT 2',
        'arquivado': 'TEXT',
        'grupo': 'TEXT',
        'excluido': 'TEXT',
        'data_exclusao': 'TIMESTAMP',
      };

      for (final entry in requiredColumns.entries) {
        if (!existingColumns.contains(entry.key)) {
          try {
            await db.execute('ALTER TABLE historia ADD COLUMN ${entry.key} ${entry.value};');
            debugPrint('DatabaseHelper: coluna ${entry.key} adicionada via Self-Healing.');
          } catch (e) {
            debugPrint('DatabaseHelper: erro ao adicionar coluna ${entry.key} via Self-Healing: $e');
          }
        }
      }

      // 2. Garantir que todas as tabelas e índices adicionais existam
      // Usamos CREATE TABLE IF NOT EXISTS para cada uma delas de forma silenciosa e resiliente
      
      // Tabela de pessoas (v2)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pessoas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          slug TEXT NOT NULL,
          UNIQUE(user_id, slug),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS historia_pessoas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          pessoa_id INTEGER NOT NULL,
          UNIQUE(historia_id, pessoa_id),
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
          FOREIGN KEY (pessoa_id) REFERENCES pessoas(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_pessoas_user_slug ON pessoas(user_id, slug);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_historia_pessoas_historia ON historia_pessoas(historia_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_historia_pessoas_pessoa ON historia_pessoas(pessoa_id);');

      // Tabela de capítutos e sugestões (v17, v19, v20)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS capitulos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          titulo TEXT NOT NULL,
          descricao TEXT,
          data_inicio TIMESTAMP NOT NULL,
          data_fim TIMESTAMP NOT NULL,
          score_confianca REAL,
          criado_automaticamente INTEGER DEFAULT 0,
          foto_path TEXT,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          data_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS capitulo_entradas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          capitulo_id INTEGER NOT NULL,
          entrada_id INTEGER NOT NULL,
          display_order INTEGER,
          UNIQUE(capitulo_id, entrada_id),
          FOREIGN KEY (capitulo_id) REFERENCES capitulos(id) ON DELETE CASCADE,
          FOREIGN KEY (entrada_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS capitulo_sugestoes_ignoradas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          fingerprint TEXT NOT NULL,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, fingerprint),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_capitulos_user_data ON capitulos(user_id, data_inicio, data_fim);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_capitulo ON capitulo_entradas(capitulo_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_entrada ON capitulo_entradas(entrada_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_ordem ON capitulo_entradas(capitulo_id, display_order);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_capitulo_sugestoes_user ON capitulo_sugestoes_ignoradas(user_id);');

      // Tabela de insights (v18)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS insight_history (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id     TEXT    NOT NULL,
          type        TEXT    NOT NULL,
          title       TEXT    NOT NULL,
          description TEXT    NOT NULL,
          icon        TEXT    NOT NULL,
          metadata    TEXT,
          seen_at     INTEGER NOT NULL,
          is_premium  INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_insight_history_user_seen ON insight_history(user_id, seen_at DESC);');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_insight_history_user_type ON insight_history(user_id, type);');

      // Verificar colunas extras nas outras tabelas
      // 1. capitulo_entradas: display_order
      try {
        final ceCols = await db.rawQuery('PRAGMA table_info(capitulo_entradas)');
        final ceExisting = ceCols.map((c) => c['name'] as String).toSet();
        if (!ceExisting.contains('display_order')) {
          await db.execute('ALTER TABLE capitulo_entradas ADD COLUMN display_order INTEGER;');
          debugPrint('DatabaseHelper: coluna display_order adicionada via Self-Healing.');
        }
      } catch (e) {
        debugPrint('DatabaseHelper: erro ao garantir display_order em capitulo_entradas: $e');
      }

      // 2. capitulos: foto_path
      try {
        final capCols = await db.rawQuery('PRAGMA table_info(capitulos)');
        final capExisting = capCols.map((c) => c['name'] as String).toSet();
        if (!capExisting.contains('foto_path')) {
          await db.execute('ALTER TABLE capitulos ADD COLUMN foto_path TEXT;');
          debugPrint('DatabaseHelper: coluna foto_path adicionada via Self-Healing.');
        }
      } catch (e) {
        debugPrint('DatabaseHelper: erro ao garantir foto_path em capitulos: $e');
      }

    } catch (e) {
      debugPrint('DatabaseHelper: erro durante o verifyAndHealSchema: $e');
    }
  }

  Future<Historia?> getHistoria(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'historia',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Historia.fromMap(maps.first);
    }
    return null;
  }

  /// Remove histórias da lixeira com data de exclusão igual ou anterior ao
  /// limite de retenção. Por padrão, remove após 30 dias.
  Future<int> deleteExpiredTrashStories({
    int retentionDays = 30,
    String? userId,
    DateTime? now,
  }) async {
    final db = await database;
    final currentTime = now ?? DateTime.now();
    final cutoff = currentTime
        .subtract(Duration(days: retentionDays))
        .toIso8601String();

    // Buscar histórias a expirar para deletar suas mídias antes de removê-las
    final List<Map<String, dynamic>> expiring;
    if (userId != null && userId.isNotEmpty) {
      expiring = await db.query(
        'historia',
        columns: ['id', 'foto_historia'],
        where:
            'user_id = ? AND excluido = ? AND data_exclusao IS NOT NULL AND data_exclusao <= ?',
        whereArgs: [userId, 'sim', cutoff],
      );
    } else {
      expiring = await db.query(
        'historia',
        columns: ['id', 'foto_historia'],
        where:
            'excluido = ? AND data_exclusao IS NOT NULL AND data_exclusao <= ?',
        whereArgs: ['sim', cutoff],
      );
    }

    // Deletar arquivos de mídia de cada história expirada
    for (final map in expiring) {
      final id = map['id'] as int?;
      if (id == null) continue;

      final fotos = await db.query(
        'historia_fotos',
        columns: ['foto_path'],
        where: 'historia_id = ?',
        whereArgs: [id],
      );
      for (final foto in fotos) {
        final path = foto['foto_path'] as String?;
        if (path != null) await PhotoFileHelper.deletePhoto(path);
      }

      final audios = await db.query(
        'historia_audios',
        columns: ['audio_path'],
        where: 'historia_id = ?',
        whereArgs: [id],
      );
      for (final audio in audios) {
        final path = audio['audio_path'] as String?;
        if (path != null) await AudioFileHelper.deleteAudio(path);
      }

      final videos = await db.query(
        'historia_videos',
        columns: ['video_path', 'thumbnail_path'],
        where: 'historia_id = ?',
        whereArgs: [id],
      );
      for (final video in videos) {
        final path = video['video_path'] as String?;
        final thumb = video['thumbnail_path'] as String?;
        if (path != null) await VideoFileHelper.deleteVideo(path);
        if (thumb != null) await VideoFileHelper.deleteVideo(thumb);
      }

      final fotoHistoria = map['foto_historia'] as String?;
      if (fotoHistoria != null && fotoHistoria.isNotEmpty) {
        try {
          final f = File(fotoHistoria);
          if (await f.exists()) await f.delete();
        } catch (e) {
          // Ignora erros ao deletar capa da história
          debugPrint('DatabaseHelper: erro ao deletar capa da história ($fotoHistoria): $e');
        }
      }
    }

    return deleteExpiredTrashStoriesFromDatabase(
      db,
      retentionDays: retentionDays,
      userId: userId,
      now: now,
    );
  }

  /// Versão estática para facilitar testes unitários com banco em memória.
  static Future<int> deleteExpiredTrashStoriesFromDatabase(
    Database db, {
    int retentionDays = 30,
    String? userId,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final cutoff = currentTime
        .subtract(Duration(days: retentionDays))
        .toIso8601String();

    if (userId != null && userId.isNotEmpty) {
      return db.delete(
        'historia',
        where:
            'user_id = ? AND excluido = ? AND data_exclusao IS NOT NULL AND data_exclusao <= ?',
        whereArgs: [userId, 'sim', cutoff],
      );
    }

    return db.delete(
      'historia',
      where:
          'excluido = ? AND data_exclusao IS NOT NULL AND data_exclusao <= ?',
      whereArgs: ['sim', cutoff],
    );
  }

  /// Close any open database and reset the cached instance so the next call
  /// to `database` will re-open the (possibly replaced) DB file.
  Future<void> resetDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Métodos para gerenciar notificações agendadas

  /// Agenda uma notificação para uma história
  Future<void> scheduleNotificationForHistoria(
    int historiaId,
    int notificationId,
    DateTime scheduledTime,
  ) async {
    final db = await database;

    // Cancela notificação existente se houver
    await db.delete(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    // Insere nova notificação
    await db.insert('notification_scheduled', {
      'historia_id': historiaId,
      'notification_id': notificationId,
      'scheduled_time': scheduledTime.toIso8601String(),
    });
  }

  /// Busca notificação agendada para uma história
  Future<Map<String, dynamic>?> getScheduledNotification(int historiaId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Cancela notificação agendada para uma história
  Future<void> cancelScheduledNotification(int historiaId) async {
    final db = await database;
    await db.delete(
      'notification_scheduled',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
  }
}
