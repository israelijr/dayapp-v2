import 'dart:io';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/models/capitulo.dart';
import 'package:dayapp/models/grupo.dart';
import 'package:dayapp/models/user.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/stats_provider.dart';
import 'package:dayapp/repositories/capitulo_repository.dart';
import 'package:dayapp/repositories/group_repository.dart';
import 'package:dayapp/repositories/historia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeAuthProvider extends AuthProvider {
  User? _fakeUser;

  @override
  User? get user => _fakeUser;

  @override
  bool get isLoggedIn => _fakeUser != null;

  void setFakeUser(User user) {
    _fakeUser = user;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
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

  test('StatsProvider loads non-zero stats correctly', () async {
    final auth = FakeAuthProvider();
    final historiaRepo = HistoriaRepository();
    final capituloRepo = CapituloRepository();
    final groupRepo = GroupRepository();

    final testUser = User(
      id: 'test_user_uuid_123',
      nome: 'Test User',
      email: 'test@example.com',
    );
    auth.setFakeUser(testUser);
    final userId = testUser.id;

    // 2. Insere grupo
    final grupoId = await groupRepo.insertGrupo(
      Grupo(userId: userId, nome: 'Estudos', emoticon: '📚'),
    );
    expect(grupoId, greaterThan(0));

    // 3. Insere histórias
    final h1Id = await historiaRepo.createHistoria(
      userId: userId,
      titulo: 'Primeira história',
      data: DateTime.now(),
      humor: 4,
      energia: 2,
      grupo: 'Estudos',
    );
    expect(h1Id, greaterThan(0));

    final h2Id = await historiaRepo.createHistoria(
      userId: userId,
      titulo: 'Segunda história',
      data: DateTime.now().subtract(const Duration(days: 10)), // Fora da semana atual
      humor: 5,
      energia: 3,
    );
    expect(h2Id, greaterThan(0));

    // 4. Insere capítulo
    final capId = await capituloRepo.insertCapituloWithEntradas(
      Capitulo(
        userId: userId,
        titulo: 'Capítulo 1',
        descricao: 'Descrição',
        dataInicio: DateTime.now().subtract(const Duration(days: 15)),
        dataFim: DateTime.now(),
      ),
      [h1Id, h2Id],
    );
    expect(capId, greaterThan(0));

    // 5. Instancia StatsProvider e carrega
    final stats = StatsProvider(
      historiaRepository: historiaRepo,
      capituloRepository: capituloRepo,
      groupRepository: groupRepo,
      authProvider: auth,
    );

    // O construtor do StatsProvider agora chama o loadStats automaticamente porque setamos o user antes.
    // Vamos aguardar um pouco para garantir que a carga automática finalize ou chamar diretamente.
    await stats.loadStats();

    // 6. Assegura que os contadores estão corretos
    expect(stats.totalStories, 2);
    expect(stats.totalChapters, 1);
    expect(stats.totalGroups, 1);
    expect(stats.storiesThisWeek, 1); // Apenas h1 está na semana atual
  });
}
