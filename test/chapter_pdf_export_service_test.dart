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

  group('ChapterExportDocument split tests', () {
    test('does not split if blocks are under maxBlocksPerPart', () {
      final document = ChapterExportDocument(
        userId: 'user-1',
        chapterTitle: 'My Chapter',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 3),
        storyCount: 2,
        blocks: [
          const TitleExportBlock(text: 'Story 1', storyId: 1),
          const ParagraphExportBlock(text: 'Text 1', storyId: 1),
          const TitleExportBlock(text: 'Story 2', storyId: 2),
          const ParagraphExportBlock(text: 'Text 2', storyId: 2),
        ],
      );

      final parts = document.split(5);
      expect(parts.length, 1);
      expect(parts[0].blocks.length, 4);
    });

    test('splits blocks respecting story integrity', () {
      final document = ChapterExportDocument(
        userId: 'user-1',
        chapterTitle: 'My Chapter',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 3),
        storyCount: 3,
        blocks: [
          const TitleExportBlock(text: 'Story 1', storyId: 1), // 1
          const ParagraphExportBlock(text: 'Text 1', storyId: 1), // 2
          const TitleExportBlock(text: 'Story 2', storyId: 2), // 3
          const ParagraphExportBlock(text: 'Text 2', storyId: 2), // 4
          const TitleExportBlock(text: 'Story 3', storyId: 3), // 5
          const ParagraphExportBlock(text: 'Text 3', storyId: 3), // 6
        ],
      );

      // maxBlocksPerPart = 3
      // Story 1 has 2 blocks, Story 2 has 2 blocks, Story 3 has 2 blocks.
      // Part 1: gets Story 1 (2 blocks). Adding Story 2 would make 4 blocks (> 3). So closed.
      // Part 2: gets Story 2 (2 blocks). Adding Story 3 would make 4 blocks (> 3). So closed.
      // Part 3: gets Story 3 (2 blocks).
      final parts = document.split(3);
      expect(parts.length, 3);
      expect(parts[0].blocks.length, 2);
      expect(parts[0].blocks[0].storyId, 1);

      expect(parts[1].blocks.length, 2);
      expect(parts[1].blocks[0].storyId, 2);

      expect(parts[2].blocks.length, 2);
      expect(parts[2].blocks[0].storyId, 3);
    });

    test('permits controlled exception for single story exceeding limit', () {
      final document = ChapterExportDocument(
        userId: 'user-1',
        chapterTitle: 'My Chapter',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 3),
        storyCount: 1,
        blocks: [
          const TitleExportBlock(text: 'Story 1', storyId: 1),
          const ParagraphExportBlock(text: 'Text 1', storyId: 1),
          const ParagraphExportBlock(text: 'Text 2', storyId: 1),
          const ParagraphExportBlock(text: 'Text 3', storyId: 1),
        ],
      );

      // maxBlocksPerPart = 2, but Story 1 has 4 blocks.
      // Since it's a single story, it should not fail, but generate a single part with 4 blocks.
      final parts = document.split(2);
      expect(parts.length, 1);
      expect(parts[0].blocks.length, 4);
    });
  });

  test('exports html with custom partSuffix and partTitle', () async {
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
      partSuffix: '_parte-1-de-2',
      partTitle: 'Relatorio de viagem (Parte 1 de 2)',
    );

    expect(await file.exists(), isTrue);
    expect(file.path, endsWith('_parte-1-de-2.html'));

    final content = await file.readAsString();
    expect(content, contains('<h1>Relatorio de viagem (Parte 1 de 2)</h1>'));
  });

  test('exports html with grouped consecutive images in image-grid layout', () async {
    final document = ChapterExportDocument(
      chapterId: 42,
      userId: 'user-1',
      chapterTitle: 'Viagem com Fotos',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 3),
      storyCount: 1,
      blocks: [
        const TitleExportBlock(text: 'Viagem com Fotos'),
        const ImageExportBlock(imagePath: 'path/to/photo1.jpg', caption: 'Foto 1', storyId: 1),
        const ImageExportBlock(imagePath: 'path/to/photo2.jpg', caption: 'Foto 2', storyId: 1),
        const ParagraphExportBlock(text: 'Texto intermediario', storyId: 1),
        const ImageExportBlock(imagePath: 'path/to/single.jpg', caption: 'Foto Isolada', storyId: 1),
      ],
    );

    const service = ChapterPdfExportService();
    final file = await service.exportHtml(
      document: document,
      localeName: 'pt_BR',
      storyCountLabel: '1 história',
    );

    expect(await file.exists(), isTrue);
    final content = await file.readAsString();

    // Deve conter a estilização de grid e A4
    expect(content, contains('@page { size: A4; margin: 20mm 15mm; }'));
    expect(content, contains('.image-grid { display: grid;'));

    // As duas primeiras fotos devem ser agrupadas no grid
    expect(content, contains('<div class="image-grid">'));
    expect(content, contains('<div class="grid-item">'));
    expect(content, contains('<div class="caption">Foto 1</div>'));
    expect(content, contains('<div class="caption">Foto 2</div>'));

    // A foto isolada deve ser renderizada normalmente sem o grid-item
    expect(content, contains('<div class="image-block">'));
    expect(content, contains('<div class="caption">Foto Isolada</div>'));
  });
}
