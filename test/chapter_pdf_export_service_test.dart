import 'dart:io';

import 'package:dayapp/domain/chapter_export_document.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/services/chapter_pdf_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
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
    tempDirectory = Directory.systemTemp.createTempSync('chapter_pdf_test_');
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

  test('exports chapter document to a non-empty pdf file', () async {
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
    final file = await service.export(
      document: document,
      localeName: 'pt_BR',
      storyCountLabel: '1 história',
    );

    expect(await file.exists(), isTrue);
    expect(await file.length(), greaterThan(0));
    expect(file.path, startsWith(tempDirectory.path));
  });

  test('optimizes large images before embedding them in the pdf', () async {
    final sourceImage = img.Image(width: 1200, height: 1200);

    for (var y = 0; y < sourceImage.height; y++) {
      for (var x = 0; x < sourceImage.width; x++) {
        sourceImage.setPixelRgba(
          x,
          y,
          (x * 13 + y * 7) % 256,
          (x * 5 + y * 11) % 256,
          (x * 17 + y * 3) % 256,
          255,
        );
      }
    }

    final sourceBytes = img.encodeBmp(sourceImage);
    final sourceFile = File('${tempDirectory.path}/large_story_image.bmp');
    await sourceFile.writeAsBytes(sourceBytes);

    final document = ChapterExportDocument(
      chapterId: 99,
      userId: 'user-1',
      chapterTitle: 'Capitulo com imagem grande',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 5),
      storyCount: 1,
      blocks: [
        const TitleExportBlock(text: 'Capitulo com imagem grande'),
        ImageExportBlock(imagePath: sourceFile.path, storyId: 1),
      ],
    );

    const service = ChapterPdfExportService();
    final pdfFile = await service.export(
      document: document,
      localeName: 'pt_BR',
      storyCountLabel: '1 história',
    );

    expect(await pdfFile.exists(), isTrue);
    expect(await pdfFile.length(), lessThan(await sourceFile.length()));
  });

  test('does not block export when chapter has many large images', () async {
    final sourceImage = img.Image(width: 1200, height: 1200);

    for (var y = 0; y < sourceImage.height; y++) {
      for (var x = 0; x < sourceImage.width; x++) {
        sourceImage.setPixelRgba(
          x,
          y,
          (x * 13 + y * 7) % 256,
          (x * 5 + y * 11) % 256,
          (x * 17 + y * 3) % 256,
          255,
        );
      }
    }

    final sourceBytes = img.encodeBmp(sourceImage);
    final imagePaths = <String>[];
    for (var index = 0; index < 4; index++) {
      final file = File('${tempDirectory.path}/oversized_$index.bmp');
      await file.writeAsBytes(sourceBytes);
      imagePaths.add(file.path);
    }

    final document = ChapterExportDocument(
      chapterId: 100,
      userId: 'user-1',
      chapterTitle: 'Capitulo pesado',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 5),
      storyCount: 4,
      blocks: [
        const TitleExportBlock(text: 'Capitulo pesado'),
        for (var index = 0; index < imagePaths.length; index++)
          ImageExportBlock(imagePath: imagePaths[index], storyId: index + 1),
      ],
    );

    const service = ChapterPdfExportService();

    final pdfFile = await service.export(
      document: document,
      localeName: 'pt_BR',
      storyCountLabel: '4 histórias',
      maxExportDuration: const Duration(minutes: 2),
    );

    expect(await pdfFile.exists(), isTrue);
    expect(await pdfFile.length(), greaterThan(0));
  });

  test('aborts export when it exceeds the configured deadline', () async {
    final document = ChapterExportDocument(
      chapterId: 101,
      userId: 'user-1',
      chapterTitle: 'Capitulo lento',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 5),
      storyCount: 1,
      blocks: [
        const TitleExportBlock(text: 'Capitulo lento'),
        const ParagraphExportBlock(
          text: 'Texto curto apenas para acionar o timeout.',
          storyId: 1,
        ),
      ],
    );

    const service = ChapterPdfExportService();

    expect(
      () => service.export(
        document: document,
        localeName: 'pt_BR',
        storyCountLabel: '1 história',
        maxExportDuration: Duration.zero,
      ),
      throwsA(isA<ChapterPdfExportTimeoutException>()),
    );
  });
}
