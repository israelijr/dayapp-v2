import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/file_utils.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final List<Historia> _selectedItems = [];
  bool _isSelectionMode = false;
  late Future<List<Historia>> _futureHistorias;
  int _lastRefreshCounter = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza o future apenas quando o refreshCounter muda,
    // evitando recriar o Future a cada setState (ex.: seleção de cards).
    final refreshCounter = Provider.of<RefreshProvider>(context).refreshCounter;
    if (_lastRefreshCounter != refreshCounter) {
      _lastRefreshCounter = refreshCounter;
      _futureHistorias = _fetchDeletedHistorias();
    }
  }

  /// Exclui os arquivos de mídia associados a uma história (fotos, áudios, vídeos e capa).
  Future<void> _deleteHistoriaMedia(Historia historia) async {
    if (historia.id == null) return;
    await HistoriaFotoHelper().deleteFotosByHistoria(historia.id!);
    await HistoriaAudioHelper().deleteAudiosByHistoria(historia.id!);
    await HistoriaVideoHelper().deleteVideosByHistoria(historia.id!);
    await FileUtils.deleteFileIfExists(historia.fotoHistoria);
  }

  Future<List<Historia>> _fetchDeletedHistorias() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';

    // Garante que itens com mais de 30 dias não apareçam mais na lixeira.
    await DatabaseHelper().deleteExpiredTrashStories(userId: userId);

    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where: 'user_id = ? AND excluido = ?',
      whereArgs: [userId, 'sim'],
      orderBy: 'data_exclusao DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
  }

  Future<void> _restoreSelected() async {
    if (_selectedItems.isEmpty) return;

    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.restoreStoriesTitle),
        content: Text(loc.restoreStoriesConfirm(_selectedItems.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.restoreLabel),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      for (final historia in _selectedItems) {
        await db.update(
          'historia',
          {
            'excluido': null,
            'data_exclusao': null,
            'data_update': DateTime.now().toIso8601String(),
            'backed_up': 0,
          },
          where: 'id = ?',
          whereArgs: [historia.id],
        );
      }
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.successStoryRestored)));
    }
  }

  Future<void> _permanentlyDeleteSelected() async {
    if (_selectedItems.isEmpty) return;

    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctxLoc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(ctxLoc.permanentlyDeleteTitle),
          content: Text(ctxLoc.permanentlyDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctxLoc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                ctxLoc.permanentlyDeleteLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      for (final historia in _selectedItems) {
        await _deleteHistoriaMedia(historia);
        await db.delete('historia', where: 'id = ?', whereArgs: [historia.id]);
      }
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.successStoryDeletedPermanently)),
      );
    }
  }

  Future<void> _emptyTrash() async {
    final loc = AppLocalizations.of(context)!;
    final historias = await _fetchDeletedHistorias();
    if (historias.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.trashAlreadyEmpty)));
      return;
    }

    final confirm = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.emptyTrashTitle),
          content: Text(loc.emptyTrashConfirm(historias.length)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.emptyTrashLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      // ignore: use_build_context_synchronously
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id ?? '';
      for (final historia in historias) {
        await _deleteHistoriaMedia(historia);
      }
      await db.delete(
        'historia',
        where: 'user_id = ? AND excluido = ?',
        whereArgs: [userId, 'sim'],
      );
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.successStoryDeletedPermanently)),
      );
    }
  }

  void _toggleSelection(Historia historia) {
    setState(() {
      if (_selectedItems.contains(historia)) {
        _selectedItems.remove(historia);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(historia);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _handleDeleteAction() async {
    if (_selectedItems.isEmpty) {
      await _emptyTrash();
    } else {
      await _permanentlyDeleteSelected();
    }
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna o próprio valor se já for um emoji
  String _convertLegacyEmoticon(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '😊';
      case 'Tranquilo':
        return '😌';
      case 'Aliviado':
        return '😮‍💨';
      case 'Pensativo':
        return '🤔';
      case 'Sono':
        return '😴';
      case 'Preocupado':
        return '😟';
      case 'Assustado':
        return '😨';
      case 'Bravo':
        return '😠';
      case 'Triste':
        return '😢';
      case 'Muito Triste':
        return '😭';
      default:
        return emoticon; // Já é um emoji Unicode
    }
  }

  Widget _buildHistoriaCard(Historia historia) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isSelected = _selectedItems.contains(historia);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surfaceContainerLow
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: const Color(0x00000000),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _toggleSelection(historia),
            onLongPress: () => _toggleSelection(historia),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                      if (historia.emoticon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _convertLegacyEmoticon(historia.emoticon!),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              historia.titulo,
                              style: GoogleFonts.notoSerif(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.labelColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dateFormatter.format(historia.data)} ${loc.timeAtConnector} ${timeFormatter.format(historia.data)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (historia.assunto != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      historia.assunto!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (historia.descricao != null &&
                      historia.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: RichTextViewerWidget(
                        jsonContent: historia.descricao,
                      ),
                    ),
                  ],
                  if (historia.dataExclusao != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${loc.deleted} ${dateFormatter.format(historia.dataExclusao!)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.emoticonRed,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 100),
                  HistoriaMediaRow(
                    historiaId: historia.id ?? 0,
                    emoticon: historia.emoticon,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );
    return Theme(
      data: screenTheme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          ),
          title: Text(
            loc.trash,
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: FutureBuilder<List<Historia>>(
          future: _futureHistorias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  loc.errorLoadingFile(snapshot.error ?? ''),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            final historias = snapshot.data ?? [];

            if (historias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.noStoriesYetTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.noStoriesHere,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: historias.length,
              itemBuilder: (context, index) {
                return _buildHistoriaCard(historias[index]);
              },
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _selectedItems.isEmpty ? null : _restoreSelected,
                    child: Text(loc.restoreLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                    onPressed: _handleDeleteAction,
                    child: Text(loc.deleteLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
