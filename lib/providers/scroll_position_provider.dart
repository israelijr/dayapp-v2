import 'package:flutter/foundation.dart';

/// Provider para manter as posições de scroll de diferentes telas.
/// Evita que o scroll retorne ao topo quando o usuário volta de uma edição.
class ScrollPositionProvider with ChangeNotifier {
  // Mapa: chave da tela -> offset do scroll
  final Map<String, double> _scrollPositions = {};

  /// Salva a posição do scroll para uma tela específica
  void saveScrollPosition(String screenKey, double offset) {
    _scrollPositions[screenKey] = offset;
  }

  /// Retorna a posição do scroll salva para uma tela
  /// Retorna 0.0 se nenhuma posição foi salva anteriormente
  double getScrollPosition(String screenKey) {
    return _scrollPositions[screenKey] ?? 0.0;
  }

  /// Limpa a posição do scroll para uma tela específica
  void clearScrollPosition(String screenKey) {
    _scrollPositions.remove(screenKey);
  }

  /// Limpa todos as posições de scroll
  void clearAllScrollPositions() {
    _scrollPositions.clear();
  }
}
