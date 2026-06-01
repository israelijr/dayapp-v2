import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/models/capitulo.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/models/historia_foto_v2.dart';
import 'package:dayapp/services/chapter_document_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builder orders stories using display order before date and id', () {
    final chapter = Capitulo(
      id: 1,
      userId: 'user-1',
      titulo: 'Carro na oficina',
      dataInicio: DateTime(2026, 3, 1),
      dataFim: DateTime(2026, 3, 30),
      descricao: 'Linha narrativa do mes',
      fotoPath: '/tmp/chapter-cover.jpg',
    );

    final stories = [
      Historia(
        id: 100,
        userId: 'user-1',
        titulo: 'Segunda visita',
        data: DateTime(2026, 3, 20),
        descricao: 'Problema persistia',
      ),
      Historia(
        id: 90,
        userId: 'user-1',
        titulo: 'Primeira visita',
        data: DateTime(2026, 3, 10),
        descricao: 'Levei para diagnostico',
      ),
    ];

    final photosByStoryId = {
      100: [
        HistoriaFoto(
          id: 1,
          historiaId: 100,
          fotoPath: '/tmp/photo-100.jpg',
          legenda: 'Orcamento',
        ),
      ],
    };

    final builder = ChapterDocumentBuilder();
    final document = builder.build(
      chapter: chapter,
      stories: stories,
      photosByStoryId: photosByStoryId,
      displayOrderByStoryId: const {100: 1, 90: 2},
    );

    final firstStoryTitle =
        document.blocks.firstWhere(
              (block) => block is TitleExportBlock && block.storyId != null,
            )
            as TitleExportBlock;

    expect(document.chapterTitle, 'Carro na oficina');
    expect(document.storyCount, 2);
    expect(firstStoryTitle.text, 'Segunda visita');
    expect(
      document.blocks.whereType<ImageExportBlock>().any(
        (image) => image.imagePath == '/tmp/photo-100.jpg',
      ),
      isTrue,
    );
  });

  test('builder normalizes quill json in chapter and story descriptions', () {
    final chapter = Capitulo(
      id: 5,
      userId: 'user-2',
      titulo: 'Reforma da casa',
      dataInicio: DateTime(2026, 2, 1),
      dataFim: DateTime(2026, 2, 28),
      descricao: '[{"insert":"Resumo geral\\n"}]',
    );

    final stories = [
      Historia(
        id: 1,
        userId: 'user-2',
        titulo: 'Compra de materiais',
        data: DateTime(2026, 2, 2),
        descricao: '[{"insert":"Escolhemos tinta e piso\\n"}]',
      ),
    ];

    final builder = ChapterDocumentBuilder();
    final document = builder.build(chapter: chapter, stories: stories);

    final paragraphs = document.blocks.whereType<ParagraphExportBlock>().toList(
      growable: false,
    );

    expect(paragraphs.length, 2);
    expect(paragraphs[0].text, 'Resumo geral');
    expect(paragraphs[1].text, 'Escolhemos tinta e piso');
  });
}
