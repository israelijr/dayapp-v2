import 'package:dayapp/db/capitulo_helper.dart';
import 'package:dayapp/models/capitulo.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/services/capitulo_sugestao_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCapituloHelper extends CapituloHelper {
  final List<({Historia historia, String tagNomes})> entries;
  final List<CapituloResumo> existingChapters;

  _FakeCapituloHelper(this.entries, {this.existingChapters = const []});

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

  @override
  Future<List<CapituloResumo>> getCapitulosResumoByUser(String userId) async {
    return existingChapters;
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

  test(
    'does not suggest a chapter if a chapter with the same theme/title already exists',
    () async {
      final existingCapitulo = Capitulo(
        userId: 'user-1',
        titulo: 'Praia',
        dataInicio: DateTime(2026, 5, 1),
        dataFim: DateTime(2026, 5, 10),
      );
      final existingResumo = CapituloResumo(
        capitulo: existingCapitulo,
        totalEntradas: 4,
        humorMedio: 4.5,
        topTags: const ['praia'],
      );

      final helper = _FakeCapituloHelper([
        // Group that would generate a suggestion with title "Praia"
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
      ], existingChapters: [existingResumo]);

      final service = CapituloSugestaoService(capituloHelper: helper);
      final suggestions = await service.sugerirCapitulos('user-1');

      // The suggestion for "Praia" should be ignored because a chapter with that theme already exists
      expect(suggestions.isEmpty, isTrue);
    },
  );
}
