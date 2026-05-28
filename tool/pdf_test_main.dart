import 'dart:io';

import 'package:dayapp/services/pdf_export_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Runner com UI mínima para testar a geração de PDF em ambiente Flutter.
// Executar com: flutter run -t tool/pdf_test_main.dart
void main() {
  runApp(const PdfTestApp());
}

class PdfTestApp extends StatelessWidget {
  const PdfTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PdfTestScreen());
  }
}

class PdfTestScreen extends StatefulWidget {
  const PdfTestScreen({super.key});

  @override
  State<PdfTestScreen> createState() => _PdfTestScreenState();
}

class _PdfTestScreenState extends State<PdfTestScreen> {
  String? status;
  String? path;
  String? error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() {
      status = 'Gerando PDF...';
      error = null;
      path = null;
    });

    try {
      final bytes = await PdfExportService.generatePdfFromHistoria(
        title: 'Teste PDF',
        content: 'Conteúdo de teste para verificar geração de PDF e fontes.',
        date: DateTime.now(),
        images: null,
        tags: 'teste, pdf',
        emoticon: '😊',
        highQuality: false,
      );

      final docDir = await getApplicationDocumentsDirectory();
      final out = File('${docDir.path}/test_historia.pdf');
      await out.writeAsBytes(bytes);

      setState(() {
        status = 'Concluído';
        path = out.path;
      });
      // Também print para logs do flutter run
      // ignore: avoid_print
      print('PDF gerado com sucesso: ${out.path}');
    } catch (e, st) {
      setState(() {
        status = 'Erro';
        error = e.toString();
      });
      // ignore: avoid_print
      print('Erro ao gerar PDF: $e');
      // ignore: avoid_print
      print(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Test Runner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == null || status == 'Gerando PDF...') ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Text(status ?? 'Iniciando...'),
              const SizedBox(height: 8),
              if (path != null) SelectableText('Arquivo: $path'),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text('Erro: $error', style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: status == 'Gerando PDF...' ? null : _generatePdf,
                child: const Text('Gerar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
