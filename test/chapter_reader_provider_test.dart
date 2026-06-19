import 'package:dayapp/domain/chapter_export_document.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/providers/chapter_reader_provider.dart';
import 'package:dayapp/repositories/capitulo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCapituloRepository extends CapituloRepository {
  final ChapterExportDocument? document;
  final bool throwOnLoad;

  _FakeCapituloRepository({this.document, this.throwOnLoad = false});

  @override
  Future<ChapterExportDocument?> fetchChapterExportDocument(
    int capituloId,
  ) async {
    if (throwOnLoad) {
      throw Exception('load error');
    }
    return document;
  }
}

void main() {
  test('provider loads chapter document successfully', () async {
    final expectedDocument = ChapterExportDocument(
      chapterId: 7,
      userId: 'user-1',
      chapterTitle: 'Viagem',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      storyCount: 1,
      blocks: const [TitleExportBlock(text: 'Viagem')],
    );

    final provider = ChapterReaderProvider(
      chapterId: 7,
      capituloRepository: _FakeCapituloRepository(document: expectedDocument),
    );

    await provider.load();

    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    expect(provider.document?.chapterId, 7);
    expect(provider.document?.chapterTitle, 'Viagem');
  });

  test('provider exposes error when repository fails', () async {
    final provider = ChapterReaderProvider(
      chapterId: 9,
      capituloRepository: _FakeCapituloRepository(throwOnLoad: true),
    );

    await provider.load();

    expect(provider.isLoading, isFalse);
    expect(provider.document, isNull);
    expect(provider.errorMessage, isNotNull);
  });
}
