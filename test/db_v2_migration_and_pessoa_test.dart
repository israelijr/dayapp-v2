import 'dart:io';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/db/pessoa_helper.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/models/pessoa.dart';
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
    // Reset database and delete database file to start fresh
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

  group('Database v2 and Pessoa CRUD Tests', () {
    test('Database opens on version 4 and tables exist', () async {
      final db = await DatabaseHelper().database;
      expect(await db.getVersion(), 4);

      // Verify that 'pessoas' and 'historia_pessoas' tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND (name='pessoas' OR name='historia_pessoas')",
      );
      expect(tables.length, 2);

      // Verify 'local' column exists in 'historia' table
      final columns = await db.rawQuery('PRAGMA table_info(historia)');
      final hasLocal = columns.any((column) => column['name'] == 'local');
      expect(hasLocal, isTrue);
    });

    test('Pessoa CRUD operations and autocomplete', () async {
      final helper = PessoaHelper();
      const userId = 'test_user_123';

      // 1. Insert Pessoa
      const p1 = Pessoa(nome: 'João da Silva', slug: 'joao-da-silva', userId: userId);
      final createdP1 = await helper.getOrCreatePessoa(userId, p1.nome);
      expect(createdP1.id, isNotNull);
      expect(createdP1.id!, greaterThan(0));

      // 2. Fetch all for user
      final all = await helper.getAllPessoasByUser(userId);
      expect(all.length, 1);
      expect(all.first.nome, 'João da Silva');
      expect(all.first.slug, 'joao-da-silva');

      // 3. Autocomplete / Suggestion match
      final suggestions = await helper.searchPessoas(userId, 'joao');
      expect(suggestions.length, 1);
      expect(suggestions.first.nome, 'João da Silva');

      // Empty query or no match
      final noMatches = await helper.searchPessoas(userId, 'maria');
      expect(noMatches.isEmpty, isTrue);

      // 4. Update name
      await helper.renamePessoa(createdP1.id!, 'João de Souza');

      final fetchedUpdated = await helper.getAllPessoasByUser(userId);
      expect(fetchedUpdated.first.nome, 'João de Souza');
      expect(fetchedUpdated.first.slug, 'joao-de-souza');

      // 5. Delete Pessoa
      await helper.deletePessoa(createdP1.id!);
      expect((await helper.getAllPessoasByUser(userId)).isEmpty, isTrue);
    });

    test('Historia association with local and pessoas in Repository', () async {
      final repo = HistoriaRepository();
      const userId = 'user_story_test';

      final p1 = await PessoaHelper().getOrCreatePessoa(userId, 'Alice');
      final p2 = await PessoaHelper().getOrCreatePessoa(userId, 'Bob');

      // Create story with local and pessoas
      final storyId = await repo.createHistoria(
        userId: userId,
        titulo: 'Um Lindo Dia no Parque',
        descricao: null,
        emoticon: '☀️',
        data: DateTime.now(),
        humor: 5,
        energia: 3,
        tags: [],
        pessoas: [p1, p2],
        local: 'Parque Ibirapuera',
        fotos: [],
        audios: [],
        videos: [],
      );

      expect(storyId, isNotNull);

      // Retrieve story and verify local
      final db = await DatabaseHelper().database;
      final storyMaps = await db.query('historia', where: 'id = ?', whereArgs: [storyId]);
      expect(storyMaps.length, 1);
      expect(storyMaps.first['local'], 'Parque Ibirapuera');

      // Verify associated people
      final associatedPeople = await PessoaHelper().getPessoasByHistoria(storyId);
      expect(associatedPeople.length, 2);
      expect(associatedPeople.any((p) => p.nome == 'Alice'), isTrue);
      expect(associatedPeople.any((p) => p.nome == 'Bob'), isTrue);

      // Verify names list from repo helper
      final names = await repo.fetchPessoaNamesForStory(storyId);
      expect(names, contains('Alice'));
      expect(names, contains('Bob'));

      // Edit Story (update local and change people list)
      final historiaModel = Historia(
        id: storyId,
        userId: userId,
        titulo: 'Um Lindo Dia no Parque - Editado',
        data: DateTime.now(),
        humor: 4,
        energia: 2,
        local: 'Novo Parque',
      );

      final saveSuccess = await repo.saveEditedHistoria(
        historia: historiaModel,
        titulo: 'Um Lindo Dia no Parque - Editado',
        descricao: null,
        emoticon: '🌤️',
        data: DateTime.now(),
        humor: 4,
        energia: 2,
        continua: 1,
        arquivado: '0',
        local: 'Novo Parque',
        tags: [],
        pessoas: [p1],
        newFotos: [],
        newAudios: [],
        newVideos: [],
      );

      expect(saveSuccess, isTrue);

      // Check local updated
      final updatedStoryMaps = await db.query('historia', where: 'id = ?', whereArgs: [storyId]);
      expect(updatedStoryMaps.first['local'], 'Novo Parque');

      // Check Bob association deleted, only Alice remaining
      final updatedPeople = await PessoaHelper().getPessoasByHistoria(storyId);
      expect(updatedPeople.length, 1);
      expect(updatedPeople.first.nome, 'Alice');
    });

    test('Self-healing automatically adds missing columns and tables', () async {
      final db = await DatabaseHelper().database;
      
      // 1. Força estado inconsistente apagando tabelas e recriando historia sem 'local'
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

      // 2. Reseta conexão e reabre para disparar o verifyAndHealSchema
      await DatabaseHelper().resetDatabase();
      final healedDb = await DatabaseHelper().database;

      // 3. Valida se as tabelas de pessoas foram recriadas
      final tables = await healedDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND (name='pessoas' OR name='historia_pessoas')",
      );
      expect(tables.length, 2);

      // 4. Valida se a coluna local foi re-adicionada
      final columns = await healedDb.rawQuery('PRAGMA table_info(historia)');
      final hasLocal = columns.any((column) => column['name'] == 'local');
      expect(hasLocal, isTrue);
    });
  });
}
