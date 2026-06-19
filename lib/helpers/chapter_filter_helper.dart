import '../models/capitulo.dart';

enum ChapterOriginFilter { all, automatic, manual }

enum ChapterSortOption { newestPeriod, oldestPeriod, title, stories }

/// Verifica se [resumo] corresponde à [query] de texto e ao [originFilter].
bool matchesChapterFilter(
  CapituloResumo resumo,
  String query,
  ChapterOriginFilter originFilter,
) {
  final normalizedQuery = query.trim().toLowerCase();
  final titulo = resumo.capitulo.titulo.toLowerCase();
  final descricao = resumo.capitulo.descricao?.toLowerCase() ?? '';
  final tags = resumo.topTags.join(' ').toLowerCase();

  final matchesText =
      normalizedQuery.isEmpty ||
      titulo.contains(normalizedQuery) ||
      descricao.contains(normalizedQuery) ||
      tags.contains(normalizedQuery);

  if (!matchesText) return false;

  switch (originFilter) {
    case ChapterOriginFilter.all:
      return true;
    case ChapterOriginFilter.automatic:
      return resumo.capitulo.criadoAutomaticamente;
    case ChapterOriginFilter.manual:
      return !resumo.capitulo.criadoAutomaticamente;
  }
}

/// Retorna uma nova lista ordenada de [capitulos] conforme [sortOption].
List<CapituloResumo> sortCapitulos(
  List<CapituloResumo> capitulos,
  ChapterSortOption sortOption,
) {
  final sorted = [...capitulos];

  switch (sortOption) {
    case ChapterSortOption.newestPeriod:
      sorted.sort(
        (a, b) => b.capitulo.dataInicio.compareTo(a.capitulo.dataInicio),
      );
    case ChapterSortOption.oldestPeriod:
      sorted.sort(
        (a, b) => a.capitulo.dataInicio.compareTo(b.capitulo.dataInicio),
      );
    case ChapterSortOption.title:
      sorted.sort(
        (a, b) => a.capitulo.titulo.toLowerCase().compareTo(
          b.capitulo.titulo.toLowerCase(),
        ),
      );
    case ChapterSortOption.stories:
      sorted.sort((a, b) => b.totalEntradas.compareTo(a.totalEntradas));
  }

  return sorted;
}
