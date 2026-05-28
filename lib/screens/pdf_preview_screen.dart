import 'dart:typed_data';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../theme/m3_expressive_theme.dart';

/// Tela que mostra um preview do PDF gerado e fornece ações: Compartilhar, Salvar, Fechar.
class PdfPreviewScreen extends StatefulWidget {
  final Uint8List? initialPdfBytes;
  // Callback que recebe (highQuality, backgroundColorHex) e retorna os bytes do PDF
  final Future<Uint8List> Function(bool highQuality, int? bgColor)? onGenerate;
  final String filename;
  final String title;
  final Future<bool> Function()? onSave; // Retorna true se salvo com sucesso

  const PdfPreviewScreen({
    required this.filename,
    required this.title,
    this.initialPdfBytes,
    this.onGenerate,
    this.onSave,
    super.key,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  bool _highQuality = false;
  // null = sem cor de fundo; valor hex ARGB = cor selecionada
  int? _bgColorHex;

  // Opções de cor de fundo: null = nenhuma, depois as 4 cores
  static const List<(int?, Color)> _bgOptions = [
    (null, Colors.transparent), // Sem cor
    (0xFFFFF8F0, Color(0xFFFFF8F0)), // Bege/creme
    (0xFFF0F4FF, Color(0xFFF0F4FF)), // Azul pálido
    (0xFFF0FFF4, Color(0xFFF0FFF4)), // Verde pálido
    (0xFFF5F5F5, Color(0xFFF5F5F5)), // Cinza claro
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPdfBytes != null) {
      _pdfBytes = widget.initialPdfBytes;
    } else if (widget.onGenerate != null) {
      _generate(_highQuality, _bgColorHex);
    }
  }

  Future<void> _generate(bool highQuality, int? bgColor) async {
    if (widget.onGenerate == null) return;
    setState(() => _isLoading = true);
    try {
      final bytes = await widget.onGenerate!(highQuality, bgColor);
      if (mounted) setState(() => _pdfBytes = bytes);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          SizedBox(
            width: 170,
            child: Row(
              children: [
                Text(
                  'Alta qualidade',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Switch.adaptive(
                  value: _highQuality,
                  onChanged: (v) async {
                    setState(() => _highQuality = v);
                    await _generate(_highQuality, _bgColorHex);
                  },
                ),
              ],
            ),
          ),
          if (widget.onSave != null)
            TextButton(
              onPressed: _pdfBytes == null || _isLoading
                  ? null
                  : () async {
                      final ok = await widget.onSave!();
                      if (ok) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('História salva com sucesso.'),
                            ),
                          );
                        }
                      }
                    },
              // Remover cor fixa para respeitar o tema (claro/escuro).
              child: const Text('Salvar'),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _pdfBytes == null
                ? null
                : () async {
                    await Printing.sharePdf(
                      bytes: _pdfBytes!,
                      filename: widget.filename,
                    );
                  },
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_pdfBytes == null
                ? Center(
                    child: Text(
                      'Nenhum PDF disponível',
                      style: TextStyle(color: AppColors.labelColor(context)),
                    ),
                  )
                : PdfPreview(
                    build: (format) async => _pdfBytes!,
                    scrollViewDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    useActions: false,
                  )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seletor de cor de fundo
              if (widget.onGenerate != null) ...[
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.pdfBackgroundColor,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    ..._bgOptions.map((opt) {
                      final (hexVal, flutterColor) = opt;
                      final isSelected = _bgColorHex == hexVal;
                      final isNone = hexVal == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Tooltip(
                          message: isNone
                              ? AppLocalizations.of(context)!.pdfBackgroundNone
                              : switch (hexVal) {
                                  0xFFFFF8F0 => AppLocalizations.of(
                                    context,
                                  )!.pdfBackgroundBeige,
                                  0xFFF0F4FF => AppLocalizations.of(
                                    context,
                                  )!.pdfBackgroundBlue,
                                  0xFFF0FFF4 => AppLocalizations.of(
                                    context,
                                  )!.pdfBackgroundGreen,
                                  _ => AppLocalizations.of(
                                    context,
                                  )!.pdfBackgroundGray,
                                },
                          child: GestureDetector(
                            onTap: () async {
                              if (_bgColorHex == hexVal) return;
                              setState(() => _bgColorHex = hexVal);
                              await _generate(_highQuality, hexVal);
                            },
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isNone
                                    ? Theme.of(context).colorScheme.surface
                                    : flutterColor,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: isNone
                                  ? Icon(
                                      Icons.block,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.4),
                                    )
                                  : isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: Text(AppLocalizations.of(context)!.share),
                      onPressed: _pdfBytes == null
                          ? null
                          : () async {
                              await Printing.sharePdf(
                                bytes: _pdfBytes!,
                                filename: widget.filename,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
