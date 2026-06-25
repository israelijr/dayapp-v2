import 'package:flutter/foundation.dart';

import '../domain/chapter_export_document.dart';

class ChapterExportTelemetryService {
  const ChapterExportTelemetryService();

  Stopwatch startExport(ChapterExportDocument document) {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      'ChapterExportTelemetry: start chapterId=${document.chapterId ?? 0} '
      'storyCount=${document.storyCount}',
    );
    return stopwatch;
  }

  void logBlockedPremium(ChapterExportDocument? document) {
    debugPrint(
      'ChapterExportTelemetry: blockedPremium chapterId=${document?.chapterId ?? 0} '
      'storyCount=${document?.storyCount ?? 0}',
    );
  }

  void logSuccess(ChapterExportDocument document, Stopwatch stopwatch) {
    debugPrint(
      'ChapterExportTelemetry: success chapterId=${document.chapterId ?? 0} '
      'storyCount=${document.storyCount} durationMs=${stopwatch.elapsedMilliseconds}',
    );
  }

  void logFailure(
    ChapterExportDocument? document,
    Stopwatch stopwatch,
    Object error,
  ) {
    debugPrint(
      'ChapterExportTelemetry: fail chapterId=${document?.chapterId ?? 0} '
      'storyCount=${document?.storyCount ?? 0} '
      'durationMs=${stopwatch.elapsedMilliseconds} error=$error',
    );
  }

  void logSplitTriggered({required int qtdPartes, required int qtdBlocosTotal}) {
    debugPrint(
      'ChapterExportTelemetry: chapterExportSplitTriggered qtdPartes=$qtdPartes '
      'qtdBlocosTotal=$qtdBlocosTotal',
    );
  }

  void logPartStart({required int parteAtual, required int qtdPartes}) {
    debugPrint(
      'ChapterExportTelemetry: chapterExportPartStart parteAtual=$parteAtual '
      'qtdPartes=$qtdPartes',
    );
  }

  void logPartSuccess({
    required int parteAtual,
    required int durationMs,
    required int fileSizeBytes,
  }) {
    debugPrint(
      'ChapterExportTelemetry: chapterExportPartSuccess parteAtual=$parteAtual '
      'durationMs=$durationMs fileSizeBytes=$fileSizeBytes',
    );
  }

  void logPartFail({required int parteAtual, required Object reason}) {
    debugPrint(
      'ChapterExportTelemetry: chapterExportPartFail parteAtual=$parteAtual '
      'reason=$reason',
    );
  }
}

