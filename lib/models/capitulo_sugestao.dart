import 'historia.dart';

class CapituloSugestao {
  final String fingerprint;
  final String tituloSugerido;
  final DateTime dataInicio;
  final DateTime dataFim;
  final double scoreConfianca;
  final List<int> entradaIds;
  final List<Historia> entradas;
  final List<String> topTags;
  final List<String> topPalavras;

  const CapituloSugestao({
    required this.fingerprint,
    required this.tituloSugerido,
    required this.dataInicio,
    required this.dataFim,
    required this.scoreConfianca,
    required this.entradaIds,
    required this.entradas,
    required this.topTags,
    required this.topPalavras,
  });
}
