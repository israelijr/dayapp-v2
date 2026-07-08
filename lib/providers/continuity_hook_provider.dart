import 'package:flutter/material.dart';

import '../models/historia.dart';
import '../repositories/historia_repository.dart';

/// Tipos de mensagem de gancho conforme a Matriz Emocional da ERS.
///
/// - [g01]: Pós-Tensão — humor ≤ 2 + energia = 3 (história SIM)
/// - [g02]: Fechamento contextual — fallback com sinal emocional para SIM
/// - [g03]: Expressão — extremo emocional + nota breve (história SIM)
/// - [talvez]: Contextual para histórias TALVEZ (com sinal emocional)
/// - [naoSei]: Contextual para histórias NÃO SEI (com sinal emocional)
/// - [genericSim]: Direto para SIM sem sinal emocional (humor=3, energia=2)
/// - [genericTalvez]: Direto para TALVEZ sem sinal emocional
/// - [genericNaoSei]: Direto para NÃO SEI sem sinal emocional
enum GanchoType { g01, g02, g03, talvez, naoSei, genericSim, genericTalvez, genericNaoSei }

/// Gerencia o estado do card de continuidade exibido na Home.
///
/// Responsabilidades:
/// - Buscar a história mais relevante via [HistoriaRepository.fetchContinuityHook]
/// - Selecionar o tipo de gancho conforme a Matriz Emocional
/// - Controlar a expansão da Fase 2 (opções de status)
/// - Expor o acelerador de relógio para testes (via PremiumDebugScreen)
class ContinuityHookProvider extends ChangeNotifier {
  final HistoriaRepository _repository = HistoriaRepository();

  Historia? _hookStory;
  GanchoType? _ganchoType;
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _debugAccelerate = false;

  // ---------------------------------------------------------------------------
  // Getters públicos
  // ---------------------------------------------------------------------------

  Historia? get hookStory => _hookStory;
  GanchoType? get ganchoType => _ganchoType;
  bool get isExpanded => _isExpanded;
  bool get isLoading => _isLoading;
  bool get debugAccelerate => _debugAccelerate;

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  /// Carrega a história mais relevante para o card de continuidade.
  ///
  /// Deve ser chamado no initState da Home, após o carregamento dos insights.
  Future<void> loadHook(String userId, {required bool isPremium}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final story = await _repository.fetchContinuityHook(
        userId,
        isPremium: isPremium,
        debugAccelerate: _debugAccelerate,
      );

      _hookStory = story;
      _ganchoType = story != null ? _selectGanchoType(story) : null;
      _isExpanded = false;
    } catch (e) {
      debugPrint('ContinuityHookProvider.loadHook: erro ao buscar gancho: $e');
      _hookStory = null;
      _ganchoType = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registra que o card foi exibido ao usuário.
  /// Deve ser chamado no momento em que o card se torna visível.
  Future<void> markDisplayed() async {
    final story = _hookStory;
    if (story?.id == null) return;
    try {
      await _repository.markHookDisplayed(story!.id!);
    } catch (e) {
      debugPrint('ContinuityHookProvider.markDisplayed: $e');
    }
  }

  /// Dispensa o card sem alterar o status da história.
  /// A exibição já foi contabilizada por [markDisplayed].
  Future<void> dismiss() async {
    _hookStory = null;
    _ganchoType = null;
    _isExpanded = false;
    notifyListeners();
  }

  /// Navega para a tela de criação de história com o ID da história pai.
  /// O fechamento da história pai é tratado em [HistoriaRepository.createHistoria].
  void continueStory(BuildContext context, String routeName) {
    final story = _hookStory;
    if (story?.id == null) return;

    // Limpa o card antes de navegar
    _hookStory = null;
    _ganchoType = null;
    _isExpanded = false;
    notifyListeners();

    Navigator.pushNamed(
      context,
      routeName,
      arguments: {'idHistoriaOrigem': story!.id},
    );
  }

  /// Atualiza o status de continuidade da história atual e fecha o card.
  /// Se [continua] = 1 (Não), o repositório encerrará o ciclo automaticamente.
  Future<void> updateStatus(int continua) async {
    final story = _hookStory;
    if (story?.id == null) return;

    try {
      await _repository.updateContinuaStatus(story!.id!, continua);
    } catch (e) {
      debugPrint('ContinuityHookProvider.updateStatus: $e');
    }

    // Fecha o card independentemente do resultado
    _hookStory = null;
    _ganchoType = null;
    _isExpanded = false;
    notifyListeners();
  }

  /// Alterna entre Fase 1 (gancho) e Fase 2 (opções de status).
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Ativa ou desativa o acelerador de relógio para testes.
  /// Quando ativo, a query ignora as janelas de tempo de 2/3/4 dias.
  void setDebugAccelerate(bool value) {
    _debugAccelerate = value;
    notifyListeners();
  }

  /// Reseta os contadores de sugestão de todas as histórias (debug only).
  Future<void> debugResetCounters(String userId) async {
    try {
      await _repository.debugResetHookCounters(userId);
    } catch (e) {
      debugPrint('ContinuityHookProvider.debugResetCounters: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Lógica interna de seleção do tipo de gancho
  // ---------------------------------------------------------------------------

  /// Seleciona o tipo de gancho conforme a Matriz Emocional da ERS.
  ///
  /// **Detecção de sinal emocional neutro:**
  /// Quando humor==3 (Neutro) AND energia==2 (Normal) — os valores padrão da
  /// tela de criação — considera-se que não há sinal emocional capturado.
  /// Nesse caso, usamos mensagens diretas/genéricas em vez das contextuais.
  ///
  /// Para histórias SIM (continua=4) com sinal emocional:
  /// - G-01: humor díficil/neutro (≤2) + energia alta (=3)
  /// - G-03: extremo emocional (humor=1 ou 4) + relato breve (<15 palavras)
  /// - G-02: fallback contextual
  ///
  /// Para TALVEZ (continua=3) e NÃO SEI (continua=2): contextuais ou genéricas.
  GanchoType _selectGanchoType(Historia historia) {
    final bool hasEmotionalSignal =
        !(historia.humor == 3 && historia.energia == 2);

    switch (historia.continua) {
      case 4: // SIM
        if (!hasEmotionalSignal) return GanchoType.genericSim;
        if (historia.humor <= 2 && historia.energia == 3) return GanchoType.g01;
        if ((historia.humor == 1 || historia.humor == 4) &&
            _countWords(historia.descricao ?? '') < 15) {
          return GanchoType.g03;
        }
        return GanchoType.g02;

      case 3: // TALVEZ
        return hasEmotionalSignal ? GanchoType.talvez : GanchoType.genericTalvez;

      case 2: // NÃO SEI
        return hasEmotionalSignal ? GanchoType.naoSei : GanchoType.genericNaoSei;

      default:
        return GanchoType.genericSim;
    }
  }

  /// Conta palavras em um texto plano (usado para a condição G-03).
  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
