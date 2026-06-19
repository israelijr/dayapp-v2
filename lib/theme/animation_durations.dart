/// Constantes centrais para durações de animações/transições
/// Facilita ajuste global do tempo de transição entre telas e widgets.
class AppDurations {
  // Transição de rota/modal (Navigator.push, PageRouteBuilder)
  static const Duration routeTransition = Duration(milliseconds: 1000);

  // Tempo padrão para trocas de listas/AnimatedSwitcher
  static const Duration listSwitch = Duration(milliseconds: 500);

  // Duração curta para pequenas animações (opacity/scale, ícones)
  static const Duration short = Duration(milliseconds: 300);

  // Animação usada em retornos/fechamentos de modais arrastáveis
  static const Duration modalReturn = Duration(milliseconds: 400);

  // Animação para navegação de páginas internas (PageView.animateToPage)
  static const Duration pageView = Duration(milliseconds: 500);
}
