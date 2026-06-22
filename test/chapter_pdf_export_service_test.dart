import 'dart:io';

import 'package:dayapp/domain/chapter_export_document.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/services/chapter_pdf_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.temporaryPath);

  final String temporaryPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PathProviderPlatform originalPlatform;
  late Directory tempDirectory;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  setUp(() {
    originalPlatform = PathProviderPlatform.instance;
    tempDirectory = Directory.systemTemp.createTempSync('chapter_html_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      tempDirectory.path,
    );
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('exports chapter document to a non-empty html file', () async {
    final document = ChapterExportDocument(
      chapterId: 42,
      userId: 'user-1',
      chapterTitle: 'Relatorio de viagem',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 3),
      storyCount: 1,
      blocks: [
        const TitleExportBlock(text: 'Relatorio de viagem'),
        const ParagraphExportBlock(text: 'Resumo da viagem', storyId: 1),
      ],
    );

    const service = ChapterPdfExportService();
    final file = await service.exportHtml(
      document: document,
      localeName: 'pt_BR',
      storyCountLabel: '1 história',
    );

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(0));
    expect(file.path, startsWith(tempDirectory.path));
    expect(file.path, endsWith('.html'));

    final content = await file.readAsString();
    expect(content, contains('<h1>Relatorio de viagem</h1>'));
    expect(content, contains('<p>Resumo da viagem</p>'));
  });
}
