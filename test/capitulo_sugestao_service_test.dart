import 'package:dayapp/db/capitulo_helper.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/services/capitulo_sugestao_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCapituloHelper extends CapituloHelper {
  final List<({Historia historia, String tagNomes})> entries;

  _FakeCapituloHelper(this.entries);

  @override
  Future<List<({Historia historia, String tagNomes})>>
  listEntradasElegiveisComTags(String userId) async {
    return entries;
  }

  @override
  Future<Set<String>> getIgnoredSuggestionFingerprints(String userId) async {
    return {};
  }

  @override
  Future<Set<int>> getEntradasJaVinculadas(String userId) async {
    return {};
  }
}

void main() {
  test(
    'chapter suggestion refines title and ranks bigger clusters higher',
    () async {
      final helper = _FakeCapituloHelper([
        // Smaller group with no tags, relying on top tokens for title.
        (
          historia: Historia(
            id: 1,
            userId: 'user-1',
            titulo: 'Teste emprego',
            data: DateTime(2026, 5, 24),
            descricao: 'Mudanca de emprego',
          ),
          tagNomes: '',
        ),
        (
          historia: Historia(
            id: 2,
            userId: 'user-1',
            titulo: 'Teste emprego',
            data: DateTime(2026, 5, 28),
            descricao: 'Candidato para emprego',
          ),
          tagNomes: '',
        ),
        (
          historia: Historia(
            id: 3,
            userId: 'user-1',
            titulo: 'Teste emprego',
            data: DateTime(2026, 5, 29),
            descricao: 'Novo emprego em mudanca',
          ),
          tagNomes: '',
        ),
        // Larger group using tags to generate a stronger suggestion.
        (
          historia: Historia(
            id: 4,
            userId: 'user-1',
            titulo: 'Viagem para praia',
            data: DateTime(2026, 5, 1),
            tag: 'praia',
          ),
          tagNomes: 'praia',
        ),
        (
          historia: Historia(
            id: 5,
            userId: 'user-1',
            titulo: 'Praia tranquila',
            data: DateTime(2026, 5, 3),
            tag: 'praia',
          ),
          tagNomes: 'praia',
        ),
        (
          historia: Historia(
            id: 6,
            userId: 'user-1',
            titulo: 'Areia e mar',
            data: DateTime(2026, 5, 5),
            tag: 'praia',
          ),
          tagNomes: 'praia',
        ),
        (
          historia: Historia(
            id: 7,
            userId: 'user-1',
            titulo: 'Sol na praia',
            data: DateTime(2026, 5, 6),
            tag: 'praia',
          ),
          tagNomes: 'praia',
        ),
      ]);

      final service = CapituloSugestaoService(capituloHelper: helper);
      final suggestions = await service.sugerirCapitulos('user-1');

      expect(suggestions.length, 2);
      expect(suggestions[0].tituloSugerido, 'Praia');
      expect(suggestions[1].tituloSugerido, 'Emprego & Mudanca');
      expect(
        suggestions[0].scoreConfianca,
        greaterThan(suggestions[1].scoreConfianca),
      );
    },
  );
}
