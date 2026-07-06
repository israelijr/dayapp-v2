import 'dart:io';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/repositories/historia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reseta o banco de dados e deleta o arquivo físico para começar do zero
    await DatabaseHelper().resetDatabase();
    final dbPath = await getDatabasesPath();
    final dbFile = File(p.join(dbPath, 'dayapp.db'));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  tearDown(() async {
    await DatabaseHelper().resetDatabase();
  });

  group('Database v4 and Continua Campo Tests', () {
    test('Database opens on version 4 and continua column exists', () async {
      final db = await DatabaseHelper().database;
      expect(await db.getVersion(), 4);

      // Verifica se a coluna 'continua' existe na tabela 'historia'
      final columns = await db.rawQuery('PRAGMA table_info(historia)');
      final hasContinua = columns.any((column) => column['name'] == 'continua');
      expect(hasContinua, isTrue);

      final continuaCol = columns.firstWhere((column) => column['name'] == 'continua');
      // A coluna deve ser do tipo INTEGER e ter o valor padrão '1' ou 1
      expect(continuaCol['type'], 'INTEGER');
      expect(continuaCol['dflt_value'].toString(), contains('1'));
    });

    test('HistoriaRepository persistence of continua field', () async {
      final repo = HistoriaRepository();
      const userId = 'test_user_v4';

      // 1. Cria história com continua = 3 (Talvez)
      final storyId = await repo.createHistoria(
        userId: userId,
        titulo: 'História com Continuidade',
        descricao: null,
        emoticon: '📝',
        data: DateTime.now(),
        humor: 4,
        energia: 2,
        continua: 3,
        tags: [],
        pessoas: [],
        local: null,
        fotos: [],
        audios: [],
        videos: [],
      );

      expect(storyId, isNotNull);
      expect(storyId, greaterThan(0));

      // 2. Recupera a história e valida o valor de continua no banco
      final db = await DatabaseHelper().database;
      final storyMaps = await db.query('historia', where: 'id = ?', whereArgs: [storyId]);
      expect(storyMaps.length, 1);
      expect(storyMaps.first['continua'], 3);

      // 3. Desserializa pelo modelo Historia e valida propriedades
      final story = Historia.fromMap(storyMaps.first);
      expect(story.continua, 3);

      // 4. Edita a história alterando continua para 4 (Sim)
      final historiaModel = Historia(
        id: storyId,
        userId: userId,
        titulo: 'História com Continuidade - Editada',
        data: DateTime.now(),
        humor: 4,
        energia: 2,
        continua: 4,
      );

      final saveSuccess = await repo.saveEditedHistoria(
        historia: historiaModel,
        titulo: 'História com Continuidade - Editada',
        descricao: null,
        emoticon: '📝',
        data: DateTime.now(),
        humor: 4,
        energia: 2,
        continua: 4,
        arquivado: null,
        local: null,
        tags: [],
        pessoas: [],
        newFotos: [],
        newAudios: [],
        newVideos: [],
      );

      expect(saveSuccess, isTrue);

      // 5. Verifica se o valor foi atualizado no banco
      final updatedStoryMaps = await db.query('historia', where: 'id = ?', whereArgs: [storyId]);
      expect(updatedStoryMaps.first['continua'], 4);
    });

    test('Self-healing automatically restores continua column if missing', () async {
      final db = await DatabaseHelper().database;

      // 1. Simula cenário sem a coluna continua
      await db.execute('DROP TABLE IF EXISTS historia_pessoas');
      await db.execute('DROP TABLE IF EXISTS pessoas');
      await db.execute('DROP TABLE IF EXISTS historia');
      await db.execute('''
        CREATE TABLE historia (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          titulo TEXT NOT NULL,
          data TIMESTAMP NOT NULL
        );
      ''');

      // 2. Reseta a conexão e reabre para acionar o verifyAndHealSchema
      await DatabaseHelper().resetDatabase();
      final healedDb = await DatabaseHelper().database;

      // 3. Valida se a coluna continua foi recuperada
      final columns = await healedDb.rawQuery('PRAGMA table_info(historia)');
      final hasContinua = columns.any((column) => column['name'] == 'continua');
      expect(hasContinua, isTrue);

      final continuaCol = columns.firstWhere((column) => column['name'] == 'continua');
      expect(continuaCol['type'], 'INTEGER');
    });
  });
}
