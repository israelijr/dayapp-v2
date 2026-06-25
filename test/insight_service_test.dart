import 'dart:io';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/models/insight.dart';
import 'package:dayapp/services/insight_service.dart';
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
    tempRoot = await Directory.systemTemp.createTemp('insight_service_test_');
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

    // Reinicializa o DatabaseHelper para forçar abertura do novo banco limpo
    DatabaseHelper().resetDatabase();
  });

  tearDown(() async {
    await DatabaseHelper().resetDatabase();
    PathProviderPlatform.instance = originalPlatform;
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('InsightService - calculateChapterEngagement', () async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Criar tabelas e inserir usuário
    await db.insert('users', {
      'id': 'user-test',
      'nome': 'Test User',
      'email': 'test@example.com',
      'senha': 'password',
    });

    // Inserir histórias
    final id1 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'História 1',
      'data': '2026-06-25T10:00:00.000',
      'descricao': 'Algum texto curto',
      'humor': 3,
    });
    final id2 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'História 2',
      'data': '2026-06-25T11:00:00.000',
      'descricao': 'Algum outro texto curto',
      'humor': 4,
    });
    final id3 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'História 3',
      'data': '2026-06-25T12:00:00.000',
      'descricao': 'Mais um texto curto',
      'humor': 3,
    });

    // Criar capítulo
    final capId = await db.insert('capitulos', {
      'user_id': 'user-test',
      'titulo': 'Capítulo Denso',
      'data_inicio': '2026-06-20T00:00:00.000',
      'data_fim': '2026-06-26T00:00:00.000',
    });

    // Vincular histórias ao capítulo (3 entradas)
    await db.insert('capitulo_entradas', {'capitulo_id': capId, 'entrada_id': id1});
    await db.insert('capitulo_entradas', {'capitulo_id': capId, 'entrada_id': id2});
    await db.insert('capitulo_entradas', {'capitulo_id': capId, 'entrada_id': id3});

    final service = InsightService();
    final result = await service.calculateChapterEngagement('user-test');

    expect(result, isNotNull);
    expect(result!.type, InsightType.chapterEngagement);
    expect(result.metadata?['chapter_title'], 'Capítulo Denso');
    expect(result.metadata?['count'], 3);
  });

  test('InsightService - calculateChapterHappiest', () async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    await db.insert('users', {
      'id': 'user-test',
      'nome': 'Test User',
      'email': 'test@example.com',
      'senha': 'password',
    });

    // Inserir histórias para dois capítulos diferentes
    // Capítulo 1 - Muito Feliz (médias altas)
    final h1 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Festa',
      'data': '2026-06-25T10:00:00.000',
      'descricao': 'Dia maravilhoso',
      'humor': 5,
    });
    final h2 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Parque',
      'data': '2026-06-25T11:00:00.000',
      'descricao': 'Passeio legal',
      'humor': 5,
    });
    final h3 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Cinema',
      'data': '2026-06-25T12:00:00.000',
      'descricao': 'Filme divertido',
      'humor': 4,
    }); // média = 4.67

    // Capítulo 2 - Neutro/Difícil (médias baixas)
    final h4 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Trabalho',
      'data': '2026-06-24T10:00:00.000',
      'descricao': 'Cansativo',
      'humor': 3,
    });
    final h5 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Chuva',
      'data': '2026-06-24T11:00:00.000',
      'descricao': 'Frio',
      'humor': 2,
    });
    final h6 = await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Trânsito',
      'data': '2026-06-24T12:00:00.000',
      'descricao': 'Estressado',
      'humor': 2,
    }); // média = 2.33

    final cap1 = await db.insert('capitulos', {
      'user_id': 'user-test',
      'titulo': 'Férias Felizes',
      'data_inicio': '2026-06-20T00:00:00.000',
      'data_fim': '2026-06-26T00:00:00.000',
    });
    final cap2 = await db.insert('capitulos', {
      'user_id': 'user-test',
      'titulo': 'Rotina Difícil',
      'data_inicio': '2026-06-15T00:00:00.000',
      'data_fim': '2026-06-19T00:00:00.000',
    });

    await db.insert('capitulo_entradas', {'capitulo_id': cap1, 'entrada_id': h1});
    await db.insert('capitulo_entradas', {'capitulo_id': cap1, 'entrada_id': h2});
    await db.insert('capitulo_entradas', {'capitulo_id': cap1, 'entrada_id': h3});

    await db.insert('capitulo_entradas', {'capitulo_id': cap2, 'entrada_id': h4});
    await db.insert('capitulo_entradas', {'capitulo_id': cap2, 'entrada_id': h5});
    await db.insert('capitulo_entradas', {'capitulo_id': cap2, 'entrada_id': h6});

    final service = InsightService();
    final result = await service.calculateChapterHappiest('user-test');

    expect(result, isNotNull);
    expect(result!.type, InsightType.chapterHappiest);
    expect(result.metadata?['chapter_title'], 'Férias Felizes');
    expect(result.metadata?['avg_mood'], closeTo(4.66, 0.02));
  });

  test('InsightService - calculateWritingLength (congrats)', () async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    await db.insert('users', {
      'id': 'user-test',
      'nome': 'Test User',
      'email': 'test@example.com',
      'senha': 'password',
    });

    // Inserir uma história longa (mais de 150 palavras)
    final longDesc = List.generate(160, (index) => 'palavra').join(' ');

    await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'História Longa',
      'data': DateTime.now().toIso8601String(),
      'descricao': longDesc,
      'humor': 4,
    });

    final service = InsightService();
    final result = await service.calculateWritingLength('user-test');

    expect(result, isNotNull);
    expect(result!.type, InsightType.writingLength);
    expect(result.description, 'insightWritingLengthCongrats');
    expect(result.metadata?['style'], 'congrats');
    expect(result.metadata?['count'], 160);
  });

  test('InsightService - calculateWritingLength (tip)', () async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    await db.insert('users', {
      'id': 'user-test',
      'nome': 'Test User',
      'email': 'test@example.com',
      'senha': 'password',
    });

    // Inserir 3 histórias bem curtas (média < 40 palavras) no período recente
    final dataStr = DateTime.now().toIso8601String();
    await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Curta 1',
      'data': dataStr,
      'descricao': 'Um dois três', // 3 palavras
      'humor': 3,
    });
    await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Curta 2',
      'data': dataStr,
      'descricao': 'Um dois três quatro cinco', // 5 palavras
      'humor': 3,
    });
    await db.insert('historia', {
      'user_id': 'user-test',
      'titulo': 'Curta 3',
      'data': dataStr,
      'descricao': 'Um dois', // 2 palavras
      'humor': 3,
    });

    final service = InsightService();
    final result = await service.calculateWritingLength('user-test');

    expect(result, isNotNull);
    expect(result!.type, InsightType.writingLength);
    expect(result.description, 'insightWritingLengthTip');
    expect(result.metadata?['style'], 'tip');
    expect(result.metadata?['avg_words'], 3); // média arredondada de (3+5+2)/3 = 3.33 => 3
  });
}
