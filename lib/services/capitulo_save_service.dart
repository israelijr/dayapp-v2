import '../db/capitulo_helper.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/capitulo.dart';

/// Modo de vínculo de capítulo ao salvar uma história.
enum CapituloVinculoModo { none, existing, newChapter }

/// Serviço responsável por validação e aplicação de vínculo de capítulo ao salvar histórias.
///
/// Encapsula a lógica de negócio para:
/// - Validar configuração de capítulo antes de salvar
/// - Aplicar linkagem de capítulo após a históia ser salva no banco
class CapituloSaveService {
  final CapituloHelper _capituloHelper;

  CapituloSaveService({CapituloHelper? capituloHelper})
    : _capituloHelper = capituloHelper ?? CapituloHelper();

  /// Valida a configuração de capítulo antes de salvar uma história.
  ///
  /// Retorna uma mensagem de erro (string) se houver validação falha,
  /// ou `null` se a validação passou.
  ///
  /// Regras de validação:
  /// - Se modo é `none`: validação sempre passa.
  /// - Se modo é `existing`: requer um capítulo selecionado (`capituloId != null`).
  /// - Se modo é `newChapter`: requer titulo não-vazio E mínimo 3 entradas relacionadas.
  String? validateCapituloConfig({
    required CapituloVinculoModo modo,
    required AppLocalizations l10n,
    int? capituloId,
    String? novoCapituloTitulo,
    int? novoCapituloEntradasCount,
  }) {
    if (modo == CapituloVinculoModo.none) {
      return null;
    }

    if (modo == CapituloVinculoModo.existing) {
      if (capituloId == null) {
        return l10n.chapterSelectExistingRequired;
      }
      return null;
    }

    // Modo: newChapter
    if (novoCapituloTitulo == null || novoCapituloTitulo.trim().isEmpty) {
      return l10n.chapterTitleRequired;
    }

    // Na criação, a entrada atual entra automaticamente no capítulo.
    // Portanto, precisamos de mínimo 2 entradas relacionadas (+ 1 atual = 3 total)
    if ((novoCapituloEntradasCount ?? 0) < 2) {
      return l10n.chapterMinimumRelatedWithCurrent;
    }

    return null;
  }

  /// Aplica o vínculo de capítulo após salvar uma história.
  ///
  /// - Se modo é `none`: não faz nada.
  /// - Se modo é `existing`: adiciona a nova entrada (historia) ao capítulo selecionado.
  /// - Se modo é `newChapter`: cria um novo capítulo com a entrada atual + relacionadas.
  ///
  /// Parâmetros:
  /// - `modo`: Modo de vínculo (none, existing ou newChapter)
  /// - `historiaId`: ID da história que foi salva
  /// - `userId`: ID do usuário proprietário
  /// - `capituloId`: ID do capítulo (requerido para modo existing)
  /// - `novoCapituloTitulo`: Título do novo capítulo (requerido para modo newChapter)
  /// - `novoCapituloEntradasRelacionadas`: IDs das entradas relacionadas (para modo newChapter)
  /// - `selectedDate`: Data da história salva (usada para calcular período do novo capítulo)
  /// - `getHistoriasByIds`: Função para buscar histórias por IDs (injetado para testabilidade)
  Future<void> applyCapituloLinkage({
    required CapituloVinculoModo modo,
    required int historiaId,
    required String userId,
    int? capituloId,
    String? novoCapituloTitulo,
    List<int>? novoCapituloEntradasRelacionadas,
    DateTime? selectedDate,
    Future<List<dynamic>> Function(List<int>)? getHistoriasByIds,
  }) async {
    if (modo == CapituloVinculoModo.none || userId.isEmpty) {
      return;
    }

    if (modo == CapituloVinculoModo.existing) {
      if (capituloId != null) {
        await _capituloHelper.addEntradaToCapitulo(
          capituloId: capituloId,
          entradaId: historiaId,
        );
      }
      return;
    }

    // Modo: newChapter
    if (novoCapituloTitulo == null ||
        novoCapituloTitulo.trim().isEmpty ||
        novoCapituloEntradasRelacionadas == null ||
        selectedDate == null) {
      return;
    }

    // Busca as histórias para calcular período do novo capítulo
    final relacionadas = await (getHistoriasByIds != null
        ? getHistoriasByIds(novoCapituloEntradasRelacionadas)
        : _capituloHelper.getHistoriasByIds(novoCapituloEntradasRelacionadas));

    // Calcula data de início (mínima) e fim (máxima) do período do capítulo
    final datas = <DateTime>[
      selectedDate,
      ...relacionadas.map((e) => (e as dynamic).data as DateTime),
    ]..sort();

    await _capituloHelper.insertCapituloWithEntradas(
      Capitulo(
        userId: userId,
        titulo: novoCapituloTitulo.trim(),
        descricao: null,
        dataInicio: datas.first,
        dataFim: datas.last,
        criadoAutomaticamente: false,
      ),
      [...novoCapituloEntradasRelacionadas, historiaId],
    );
  }
}
