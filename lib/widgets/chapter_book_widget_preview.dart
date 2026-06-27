import 'dart:math';
import 'package:flutter/material.dart';
import 'chapter_book_widget.dart';

void main() {
  runApp(const MaterialApp(
    home: ChapterBookWidgetPreview(),
    debugShowCheckedModeBanner: false,
  ));
}

class ChapterBookWidgetPreview extends StatelessWidget {
  const ChapterBookWidgetPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> capas = [
      'assets/image/capa1.jpg',
      'assets/image/capa2.jpeg',
      'assets/image/capa3.jpeg',
      'assets/image/capa4.jpeg',
      'assets/image/capa5.jpg',
    ];

    final Random random = Random();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview: ChapterBookWidget'),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            ChapterBookWidget(
              titulo: 'Minhas Viagens de Verão em 2024',
              dataUpdate: DateTime(2024, 1, 15),
              coverAsset: capas[random.nextInt(capas.length)],
              onTap: () {},
            ),
            ChapterBookWidget(
              titulo: 'Aprendizados Profissionais',
              dataUpdate: DateTime(2023, 12, 10),
              coverAsset: capas[random.nextInt(capas.length)],
              onTap: () {},
            ),
            ChapterBookWidget(
              titulo: 'Reflexões Diárias',
              dataUpdate: DateTime(2024, 2, 5),
              coverAsset: capas[random.nextInt(capas.length)],
              onTap: () {},
            ),
            ChapterBookWidget(
              titulo: 'Projeto Especial de Final de Ano',
              dataUpdate: DateTime.now(),
              coverAsset: capas[random.nextInt(capas.length)],
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
