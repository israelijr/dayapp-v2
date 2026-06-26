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
      return await openDatabase(
        path,
        version: 20,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
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
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE historia ADD COLUMN emoticon TEXT;');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE historia ADD COLUMN grupo TEXT;');
      await db.execute('ALTER TABLE historia ADD COLUMN arquivado TEXT;');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE grupos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE historia ADD COLUMN arquivado TEXT;');
      } catch (e) {
        // Column may already exist
        debugPrint('DatabaseHelper: coluna arquivado pode já existir na v5: $e');
      }
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE historia_audios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          audio BLOB NOT NULL,
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
    }
    if (oldVersion < 7) {
      // Migração: BLOB para sistema de arquivos
      // Criar nova tabela com caminhos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historia_videos_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          video_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          thumbnail_path TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');

      // Tentar migrar dados existentes (apenas vídeos pequenos < 2MB)
      try {
        final videos = await db.query('historia_videos', limit: 100);

        for (final video in videos) {
          try {
            final videoBlob = video['video'];
            if (videoBlob != null && videoBlob is List<int>) {
              final videoData = Uint8List.fromList(videoBlob);

              // Só migra vídeos < 2MB (que ainda conseguem ser lidos)
              if (videoData.length < 2000000) {
                final historiaId = video['historia_id'] as int;

                // Salvar no sistema de arquivos
                final videosDir = await VideoFileHelper.getVideosDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final fileName =
                    'video_${historiaId}_${timestamp}_migrated.mp4';
                final filePath = p.join(videosDir.path, fileName);

                final file = File(filePath);
                await file.writeAsBytes(videoData);

                // Inserir na nova tabela
                await db.insert('historia_videos_new', {
                  'historia_id': historiaId,
                  'video_path': filePath,
                  'legenda': video['legenda'],
                  'duracao': video['duracao'],
                  'thumbnail_path': null,
                });
              }
            }
          } catch (e) {
            // Skip video on error
            debugPrint('DatabaseHelper: erro ao migrar vídeo na v7: $e');
          }
        }
      } catch (e) {
        // Old table doesn't exist or migration error
        debugPrint('DatabaseHelper: erro na migração v7 de historia_videos: $e');
      }

      // Dropar tabela antiga e renomear nova
      await db.execute('DROP TABLE IF EXISTS historia_videos');
      await db.execute(
        'ALTER TABLE historia_videos_new RENAME TO historia_videos',
      );
    }
    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE historia ADD COLUMN excluido TEXT;');
        await db.execute(
          'ALTER TABLE historia ADD COLUMN data_exclusao TIMESTAMP;',
        );
      } catch (e) {
        // Columns may already exist
        debugPrint('DatabaseHelper: colunas excluido/data_exclusao na v8 podem já existir: $e');
      }
    }
    if (oldVersion < 9) {
      // Garantir que a tabela historia_videos tenha a estrutura correta (video_path)
      try {
        // Verificar se a tabela existe e tem a estrutura correta
        final result = await db.rawQuery('PRAGMA table_info(historia_videos)');
        final hasVideoPath = result.any(
          (column) => column['name'] == 'video_path',
        );

        if (!hasVideoPath) {
          // Tabela ainda usa BLOB, precisa migrar
          // Criar nova tabela com estrutura correta
          await db.execute('''
            CREATE TABLE IF NOT EXISTS historia_videos_fixed (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              historia_id INTEGER NOT NULL,
              video_path TEXT NOT NULL,
              legenda TEXT,
              duracao INTEGER,
              thumbnail_path TEXT,
              FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
            );
          ''');

          // Dropar tabela antiga e renomear nova
          await db.execute('DROP TABLE IF EXISTS historia_videos');
          await db.execute(
            'ALTER TABLE historia_videos_fixed RENAME TO historia_videos',
          );
        }
      } catch (e) {
        // Error correcting table structure
        debugPrint('DatabaseHelper: erro ao corrigir estrutura da tabela na v9: $e');
      }
    }
    if (oldVersion < 10) {
      // Adicionar tabela de notificações agendadas
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_scheduled (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            historia_id INTEGER NOT NULL,
            notification_id INTEGER NOT NULL,
            scheduled_time TEXT NOT NULL,
            FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
          );
        ''');
      } catch (e) {
        // Error creating notification_scheduled table
        debugPrint('DatabaseHelper: erro ao criar tabela notification_scheduled na v10: $e');
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE grupos ADD COLUMN emoticon TEXT;');
      } catch (e) {
        // Column may already exist
        debugPrint('DatabaseHelper: coluna emoticon de grupos na v11 pode já existir: $e');
      }
    }
    if (oldVersion < 12) {
      // Migração: Fotos e Áudios de BLOB para sistema de arquivos
      await _migratePhotosToFileSystem(db);
      await _migrateAudiosToFileSystem(db);
    }
    if (oldVersion < 13) {
      // Adicionar coluna para indicar que a história já foi incluída em backup
      try {
        await db.execute(
          'ALTER TABLE historia ADD COLUMN backed_up INTEGER DEFAULT 0;',
        );
      } catch (e) {
        // Column may already exist or operation not supported; ignore
        debugPrint('DatabaseHelper: coluna backed_up na v13 pode já existir ou operação não suportada: $e');
      }
    }
    if (oldVersion < 14) {
      // Adicionar colunas de humor e energia
      try {
        await db.execute(
          'ALTER TABLE historia ADD COLUMN humor INTEGER DEFAULT 3;',
        );
        await db.execute(
          'ALTER TABLE historia ADD COLUMN energia INTEGER DEFAULT 2;',
        );
        // Preencher histórias existentes com os valores padrão
        await db.execute('UPDATE historia SET humor = 3 WHERE humor IS NULL;');
        await db.execute(
          'UPDATE historia SET energia = 2 WHERE energia IS NULL;',
        );
      } catch (e) {
        // Colunas já existem ou erro na migração; ignorar
        debugPrint('DatabaseHelper: colunas humor/energia na v14 podem já existir ou erro na migração: $e');
      }
    }
    if (oldVersion < 15) {
      // Criação das tabelas de tags e relação história↔tags
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            nome TEXT NOT NULL,
            slug TEXT NOT NULL,
            UNIQUE(user_id, slug),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS historia_tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            historia_id INTEGER NOT NULL,
            tag_id INTEGER NOT NULL,
            UNIQUE(historia_id, tag_id),
            FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE,
            FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
          );
        ''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tags_user_slug ON tags(user_id, slug);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_historia_tags_historia ON historia_tags(historia_id);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_historia_tags_tag ON historia_tags(tag_id);',
        );
      } catch (e) {
        // Erro criando tabelas; ignorar para não bloquear o app
        debugPrint('Erro criando tabelas de tags: $e');
      }

      // Migração: popula as novas tabelas a partir do campo `historia.tag`
      // (pode conter múltiplas tags separadas por vírgula)
      await DatabaseHelper.migrateTagsFromLegacyField(db);
    }
    if (oldVersion < 16) {
      // Escala de humor expandida: antigo 1–4 → novo 2–5.
      // Valor 1 (😞 Muito difícil) é novo; deslocar existentes +1.
      try {
        await db.execute(
          'UPDATE historia SET humor = humor + 1 WHERE humor BETWEEN 1 AND 4;',
        );
        // Registros sem humor ficam como Neutro (3)
        await db.execute('UPDATE historia SET humor = 3 WHERE humor IS NULL;');
      } catch (e) {
        // Migração não crítica; ignora erro para não bloquear o app
        debugPrint('Erro migrando valores de humor (v16): \$e');
      }
    }
    if (oldVersion < 17) {
      // Estrutura de capítulos e relação N×N com entradas.
      try {
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
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulos_user_data ON capitulos(user_id, data_inicio, data_fim);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_capitulo ON capitulo_entradas(capitulo_id);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_entrada ON capitulo_entradas(entrada_id);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_ordem ON capitulo_entradas(capitulo_id, display_order);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulo_sugestoes_user ON capitulo_sugestoes_ignoradas(user_id);',
        );
      } catch (e) {
        debugPrint('Erro criando tabelas de capítulos: $e');
      }
    }
    if (oldVersion < 18) {
      // Histórico de insights exibidos ao usuário.
      try {
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
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_insight_history_user_seen ON insight_history(user_id, seen_at DESC);',
        );
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_insight_history_user_type ON insight_history(user_id, type);',
        );
      } catch (e) {
        debugPrint('Erro criando tabela insight_history (v18): $e');
      }
    }
    if (oldVersion < 19) {
      // Adiciona coluna de foto ao capítulo.
      try {
        await db.execute('ALTER TABLE capitulos ADD COLUMN foto_path TEXT;');
      } catch (e) {
        debugPrint('Erro adicionando foto_path em capitulos (v19): $e');
      }
    }
    if (oldVersion < 20) {
      // Adiciona coluna de ordenação manual no vínculo capítulo-entrada.
      try {
        await db.execute(
          'ALTER TABLE capitulo_entradas ADD COLUMN display_order INTEGER;',
        );
      } catch (e) {
        debugPrint(
          'Erro adicionando display_order em capitulo_entradas (v20): $e',
        );
      }

      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_capitulo_entradas_ordem ON capitulo_entradas(capitulo_id, display_order);',
        );
      } catch (e) {
        debugPrint('Erro criando índice idx_capitulo_entradas_ordem (v20): $e');
      }

      try {
        final capitulos = await db.rawQuery(
          'SELECT DISTINCT capitulo_id FROM capitulo_entradas ORDER BY capitulo_id ASC',
        );

        for (final item in capitulos) {
          final capituloId = item['capitulo_id'] as int?;
          if (capituloId == null) continue;

          final entradas = await db.rawQuery(
            '''
            SELECT ce.id
            FROM capitulo_entradas ce
            JOIN historia h ON h.id = ce.entrada_id
            WHERE ce.capitulo_id = ?
            ORDER BY h.data ASC, h.id ASC
            ''',
            [capituloId],
          );

          var order = 1;
          for (final entrada in entradas) {
            final entryId = entrada['id'] as int?;
            if (entryId == null) continue;
            await db.update(
              'capitulo_entradas',
              {'display_order': order},
              where: 'id = ?',
              whereArgs: [entryId],
            );
            order += 1;
          }
        }
      } catch (e) {
        debugPrint(
          'Erro ao popular display_order em capitulo_entradas (v20): $e',
        );
      }
    }
  }

  /// Migra tags do campo legado `historia.tag` (texto, pode ter vírgulas)
  /// para as tabelas `tags` e `historia_tags`.
  ///
  /// Exposto como `static` para ser reutilizado pelo [BackupService] ao
  /// restaurar backups antigos (anteriores à v15).
  static Future<void> migrateTagsFromLegacyField(Database db) async {
    try {
      // Importa o helper de slug inline para evitar dependência circular
      // (o Tag.generateSlug usa apenas operações de String puras)
      String generateSlug(String name) {
        const Map<String, String> accents = {
          'à': 'a',
          'á': 'a',
          'â': 'a',
          'ã': 'a',
          'ä': 'a',
          'è': 'e',
          'é': 'e',
          'ê': 'e',
          'ë': 'e',
          'ì': 'i',
          'í': 'i',
          'î': 'i',
          'ï': 'i',
          'ò': 'o',
          'ó': 'o',
          'ô': 'o',
          'õ': 'o',
          'ö': 'o',
          'ù': 'u',
          'ú': 'u',
          'û': 'u',
          'ü': 'u',
          'ç': 'c',
          'ñ': 'n',
          'ý': 'y',
          'ÿ': 'y',
          'ß': 'ss',
        };
        String result = name.toLowerCase().trim();
        for (final entry in accents.entries) {
          result = result.replaceAll(entry.key, entry.value);
        }
        result = result.replaceAll(RegExp(r'[^a-z0-9]'), '-');
        result = result.replaceAll(RegExp(r'-+'), '-');
        result = result.replaceAll(RegExp(r'^-|-$'), '');
        return result;
      }

      final historias = await db.query(
        'historia',
        columns: ['id', 'user_id', 'tag'],
        where: 'tag IS NOT NULL AND tag <> ""',
      );

      for (final h in historias) {
        final historiaId = h['id'] as int;
        final userId = h['user_id'] as String;
        final tagField = h['tag'] as String;

        // Suporta tags separadas por vírgula ou por espaço
        final tagNames = tagField
            .split(RegExp(r'[,]'))
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();

        for (final nome in tagNames) {
          final slug = generateSlug(nome);
          if (slug.isEmpty) continue;

          // Insere a tag (ignora conflito por UNIQUE)
          await db.insert('tags', {
            'user_id': userId,
            'nome': nome,
            'slug': slug,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          // Obtém o id da tag
          final tagRows = await db.query(
            'tags',
            columns: ['id'],
            where: 'user_id = ? AND slug = ?',
            whereArgs: [userId, slug],
            limit: 1,
          );
          if (tagRows.isEmpty) continue;
          final tagId = tagRows.first['id'] as int;

          // Cria a relação
          await db.insert('historia_tags', {
            'historia_id': historiaId,
            'tag_id': tagId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    } catch (e) {
      // Migração de tags legadas falhou; não bloqueia o app
      debugPrint('Erro na migração de tags legadas: $e');
    }
  }

  /// Migra fotos de BLOB para sistema de arquivos
  Future<void> _migratePhotosToFileSystem(Database db) async {
    try {
      // Verificar se a tabela ainda usa BLOB
      final result = await db.rawQuery('PRAGMA table_info(historia_fotos)');
      final hasBlob = result.any((column) => column['name'] == 'foto');

      if (!hasBlob) {
        // Tabela já usa foto_path, não precisa migrar
        return;
      }

      // Criar nova tabela com estrutura correta
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historia_fotos_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          foto_path TEXT NOT NULL,
          legenda TEXT,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');

      // Migrar fotos existentes (apenas fotos < 2MB para evitar erro de CursorWindow)
      try {
        final fotos = await db.query('historia_fotos', limit: 500);

        for (final foto in fotos) {
          try {
            final fotoBlob = foto['foto'];
            if (fotoBlob != null && fotoBlob is List<int>) {
              final fotoData = Uint8List.fromList(fotoBlob);

              // Só migra fotos < 2MB
              if (fotoData.length < 2000000) {
                final historiaId = foto['historia_id'] as int;

                // Salvar no sistema de arquivos
                final photosDir = await PhotoFileHelper.getPhotosDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final fileName =
                    'photo_${historiaId}_${timestamp}_migrated.jpg';
                final filePath = p.join(photosDir.path, fileName);

                final file = File(filePath);
                await file.writeAsBytes(fotoData);

                // Inserir na nova tabela
                await db.insert('historia_fotos_new', {
                  'historia_id': historiaId,
                  'foto_path': filePath,
                  'legenda': foto['legenda'],
                });
              }
            }
          } catch (e) {
            // Pula foto com erro e continua
            debugPrint('Erro ao migrar foto: $e');
          }
        }
      } catch (e) {
        // Erro na migração de fotos
        debugPrint('Erro na migração de fotos: $e');
      }

      // Dropar tabela antiga e renomear nova
      await db.execute('DROP TABLE IF EXISTS historia_fotos');
      await db.execute(
        'ALTER TABLE historia_fotos_new RENAME TO historia_fotos',
      );
    } catch (e) {
      debugPrint('Erro na migração de fotos para sistema de arquivos: $e');
    }
  }

  /// Migra áudios de BLOB para sistema de arquivos
  Future<void> _migrateAudiosToFileSystem(Database db) async {
    try {
      // Verificar se a tabela ainda usa BLOB
      final result = await db.rawQuery('PRAGMA table_info(historia_audios)');
      final hasBlob = result.any((column) => column['name'] == 'audio');

      if (!hasBlob) {
        // Tabela já usa audio_path, não precisa migrar
        return;
      }

      // Criar nova tabela com estrutura correta
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historia_audios_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          historia_id INTEGER NOT NULL,
          audio_path TEXT NOT NULL,
          legenda TEXT,
          duracao INTEGER,
          FOREIGN KEY (historia_id) REFERENCES historia(id) ON DELETE CASCADE
        );
      ''');

      // Migrar áudios existentes
      try {
        final audios = await db.query('historia_audios', limit: 500);

        for (final audio in audios) {
          try {
            final audioBlob = audio['audio'];
            if (audioBlob != null && audioBlob is List<int>) {
              final audioData = Uint8List.fromList(audioBlob);

              // Só migra áudios < 2MB
              if (audioData.length < 2000000) {
                final historiaId = audio['historia_id'] as int;

                // Salvar no sistema de arquivos
                final audiosDir = await AudioFileHelper.getAudiosDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final fileName =
                    'audio_${historiaId}_${timestamp}_migrated.m4a';
                final filePath = p.join(audiosDir.path, fileName);

                final file = File(filePath);
                await file.writeAsBytes(audioData);

                // Inserir na nova tabela
                await db.insert('historia_audios_new', {
                  'historia_id': historiaId,
                  'audio_path': filePath,
                  'legenda': audio['legenda'],
                  'duracao': audio['duracao'],
                });
              }
            }
          } catch (e) {
            // Pula áudio com erro e continua
            debugPrint('Erro ao migrar áudio: $e');
          }
        }
      } catch (e) {
        // Erro na migração de áudios
        debugPrint('Erro na migração de áudios: $e');
      }

      // Dropar tabela antiga e renomear nova
      await db.execute('DROP TABLE IF EXISTS historia_audios');
      await db.execute(
        'ALTER TABLE historia_audios_new RENAME TO historia_audios',
      );
    } catch (e) {
      debugPrint('Erro na migração de áudios para sistema de arquivos: $e');
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
