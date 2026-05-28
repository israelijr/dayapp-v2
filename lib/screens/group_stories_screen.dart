import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/tag_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/grupo.dart';
import '../models/historia.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../services/pdf_export_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'edit_profile_screen.dart';
import 'pdf_preview_screen.dart';

class GroupStoriesScreen extends StatefulWidget {
  final Grupo grupo;

  const GroupStoriesScreen({required this.grupo, super.key});

  @override
  State<GroupStoriesScreen> createState() => _GroupStoriesScreenState();
}

class _GroupStoriesScreenState extends State<GroupStoriesScreen> {
  // Constantes para melhor organização
  static const double cardMargin = 24.0;

  // Key para ScaffoldMessenger local — snackbars ficam escopados a esta tela
  // e são descartados automaticamente quando o usuário navega para outra rota.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  bool _isCardView = true; // true = modo blocos, false = modo ícones

  // Controle de scroll para manter posição da lista
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Restaura posição do scroll ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  @override
  void dispose() {
    // Salva posição do scroll ao sair da tela
    _saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  /// Restaura a posição do scroll para a posição anterior
  void _restoreScrollPosition() {
    final scrollProvider = Provider.of<ScrollPositionProvider>(
      context,
      listen: false,
    );
    final scrollKey = 'group_list_scroll_${widget.grupo.nome}';
    final savedPosition = scrollProvider.getScrollPosition(scrollKey);
    if (_scrollController.hasClients && savedPosition > 0) {
      _scrollController.jumpTo(savedPosition);
    }
  }

  /// Salva a posição do scroll antes de sair da tela
  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      final scrollKey = 'group_list_scroll_${widget.grupo.nome}';
      scrollProvider.saveScrollPosition(scrollKey, _scrollController.offset);
    }
  }

  @override
  void deactivate() {
    // Salva a posição quando o widget é removido da widget tree
    _saveScrollPosition();
    super.deactivate();
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna null se já for um emoji (default case)
  String? _convertLegacyEmoticon(String emoticon) {
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
        return null; // Já é um emoji Unicode
    }
  }

  Future<void> _exportHistoria(Historia historia) async {
    // Bloqueia exportação de PDF para usuários Free
    if (!context.read<PremiumProvider>().canExportPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.exportPdfPremiumRequired),
        ),
      );
      return;
    }
    try {
      // Captura o locale antes do primeiro await para evitar uso de context após async
      final localeName = AppLocalizations.of(context)!.localeName;
      final fotosData = await HistoriaFotoHelper().getFotosComBytesByHistoria(
        historia.id ?? 0,
      );
      final images = fotosData.map((f) => f.bytes).toList();
      final content = RichTextHelper.jsonToPlainText(historia.descricao);
      final pdfBytes = await PdfExportService.generatePdfFromHistoria(
        title: historia.titulo,
        content: content,
        date: historia.data,
        images: images,
        tags: historia.tag,
        emoticon: historia.emoticon,
        locale: localeName,
      );
      final filename =
          'historia_${historia.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            initialPdfBytes: pdfBytes,
            onGenerate: (highQuality, bgColor) =>
                PdfExportService.generatePdfFromHistoria(
                  title: historia.titulo,
                  content: content,
                  date: historia.data,
                  images: images,
                  tags: historia.tag,
                  emoticon: historia.emoticon,
                  highQuality: highQuality,
                  backgroundColorHex: bgColor,
                  locale: localeName,
                ),
            filename: filename,
            title: AppLocalizations.of(context)!.previewTitle(historia.titulo),
            onSave: null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.exportPdfError(e.toString()),
          ),
        ),
      );
    }
  }

  Future<List<Historia>> _fetchHistoriasByGrupo() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo = ? AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId, widget.grupo.nome],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList();
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.deleteStoryTitle ?? 'Excluir história',
        ),
        content: Text(
          AppLocalizations.of(context)?.deleteStoryConfirm ??
              'Deseja mover esta história para a lixeira?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context)?.deleteLabel ?? 'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      // Soft delete: marca como excluído ao invés de deletar
      await db.update(
        'historia',
        {
          'excluido': 'sim',
          'data_exclusao': DateTime.now().toIso8601String(),
          'data_update': DateTime.now().toIso8601String(),
          'backed_up': 0,
        },
        where: 'id = ?',
        whereArgs: [historia.id],
      );
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();

      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.movedToTrash ??
                'História movida para a lixeira',
          ),
        ),
      );
    }
  }

  Future<void> _updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    final db = await DatabaseHelper().database;
    final Map<String, dynamic> updateData = {
      'data_update': DateTime.now().toIso8601String(),
    };

    if (updates != null) {
      updateData.addAll(updates);
    }

    // Se a atualização não explicitar o estado de backup, marcar como não salvo
    // para que a história seja incluída no próximo backup.
    if (!updateData.containsKey('backed_up')) {
      updateData['backed_up'] = 0;
    }

    await db.update(
      'historia',
      updateData,
      where: 'id = ?',
      whereArgs: [historia.id],
    );
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousTag = historia.tag;
    final previousGrupo = historia.grupo;

    // Atualiza o BD diretamente, sem disparar o refresh ainda,
    // para que o Consumer<RefreshProvider> não reconstrua o body
    // antes de o snackbar ser exibido.
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'arquivado': 'sim',
        'grupo': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );

    if (!mounted) return;
    final localizations = AppLocalizations.of(context);
    final messenger = _messengerKey.currentState!;
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(localizations?.storyArchived ?? 'História arquivada'),
        action: SnackBarAction(
          label: localizations?.undo ?? 'Desfazer',
          onPressed: () async {
            await _updateHistoria(
              historia,
              updates: {
                'arquivado': null,
                'tag': previousTag,
                'grupo': previousGrupo,
              },
            );
          },
        ),
      ),
    );
    // Backup: fecha o snackbar após 5 s sem depender do estado de montagem
    Future.delayed(const Duration(seconds: 5), controller.close);

    // Dispara o refresh no próximo frame, após o snackbar ter sido adicionado
    // à fila do ScaffoldMessenger, para evitar que a reconstrução do Consumer
    // interfira no temporizador do snackbar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<RefreshProvider>(context, listen: false).refresh();
    });
  }

  Widget _buildCardView(Historia historia) {
    return FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final hasImages = snapshot.hasData && snapshot.data!.isNotEmpty;

        return Slidable(
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  await _archiveWithUndo(historia);
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: Icons.archive,
                label: AppLocalizations.of(context)?.archiveLabel ?? 'Arquivar',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (slidableContext) async {
                  final refreshProvider = Provider.of<RefreshProvider>(
                    slidableContext,
                    listen: false,
                  );
                  final ungroupedMsg = AppLocalizations.of(
                    slidableContext,
                  )!.storyUngrouped;
                  await _updateHistoria(
                    historia,
                    updates: {'tag': null, 'arquivado': null, 'grupo': null},
                  );
                  if (!mounted) return;
                  refreshProvider.refresh();
                  _messengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text(ungroupedMsg)),
                  );
                },
                backgroundColor: AppColors.emoticonGreen,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: Icons.group_off,
                label: AppLocalizations.of(context)?.ungroup ?? 'Desagrupar',
              ),
            ],
          ),
          child: GestureDetector(
            onDoubleTap: () {
              final refreshProvider = Provider.of<RefreshProvider>(
                context,
                listen: false,
              );
              Navigator.push(
                context,
                RouteTransitionHelper.slideUpRotateTransition(
                  EditHistoriaScreen(historia: historia),
                ),
              ).then((updated) {
                if (!mounted) return;
                if (updated == true) {
                  refreshProvider.refresh();
                }
              });
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: cardMargin),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImages) ...[
                      HistoriaFotosGrid(
                        historiaId: historia.id ?? 0,
                        height: 100,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Linha combinada: Emoticon + Áudios + Vídeos
                    HistoriaMediaRow(
                      historiaId: historia.id ?? 0,
                      emoticon: historia.emoticon,
                      convertLegacyEmoticon: _convertLegacyEmoticon,
                    ),
                    Text(
                      historia.titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: RichTextViewerWidget(
                        jsonContent: historia.descricao,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Data
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (historia.emoticon != null &&
                                historia.emoticon!.isNotEmpty)
                              Builder(
                                builder: (context) {
                                  final convertedEmoji = _convertLegacyEmoticon(
                                    historia.emoticon!,
                                  );
                                  final displayEmoji =
                                      convertedEmoji ?? historia.emoticon!;
                                  return Text(
                                    displayEmoji,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1,
                                    ),
                                  );
                                },
                              ),
                            if (historia.emoticon != null &&
                                historia.emoticon!.isNotEmpty)
                              const SizedBox(width: 6),
                            SizedBox(
                              width: 140,
                              child: Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                  'pt_BR',
                                ).format(historia.data),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final navigator = Navigator.of(context);
                              final refreshProvider =
                                  Provider.of<RefreshProvider>(
                                    context,
                                    listen: false,
                                  );
                              navigator
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => EditHistoriaScreen(
                                        historia: historia,
                                      ),
                                    ),
                                  )
                                  .then((updated) {
                                    if (!mounted) return;
                                    if (updated == true) {
                                      refreshProvider.refresh();
                                    }
                                  });
                            } else if (value == 'delete') {
                              await _deleteHistoria(historia);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                AppLocalizations.of(context)?.editTip ??
                                    'Editar - 2 toques',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                AppLocalizations.of(context)?.deleteLabel ??
                                    'Excluir',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Tags da história (novo sistema + legado)
                    FutureBuilder<List<Tag>>(
                      future: TagHelper().getTagsByHistoria(historia.id ?? 0),
                      builder: (context, tagSnapshot) {
                        final newTags = tagSnapshot.data ?? [];
                        final legacyTag = historia.tag;
                        final tagNames = newTags.isNotEmpty
                            ? newTags.map((t) => t.nome).toList()
                            : (legacyTag != null && legacyTag.isNotEmpty
                                  ? [legacyTag]
                                  : <String>[]);
                        if (tagNames.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: tagNames
                                  .map(
                                    (name) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconView(Historia historia) {
    return Dismissible(
      key: Key('icon_${historia.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          AppLocalizations.of(context)?.archiveLabel ?? 'Arquivar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.emoticonGreen,
        child: Text(
          AppLocalizations.of(context)?.ungroup ?? 'Desagrupar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _archiveWithUndo(historia);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          final refreshProvider = Provider.of<RefreshProvider>(
            context,
            listen: false,
          );
          final ungroupedMsg = AppLocalizations.of(context)!.storyUngrouped;
          await _updateHistoria(
            historia,
            updates: {'tag': null, 'arquivado': null, 'grupo': null},
          );
          if (!mounted) return false;
          refreshProvider.refresh();
          _messengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(ungroupedMsg)),
          );
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        // Já tratado no confirmDismiss
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  if (historia.emoticon != null &&
                      historia.emoticon!.isNotEmpty) {
                    final converted = _convertLegacyEmoticon(
                      historia.emoticon!,
                    );
                    final display = converted ?? historia.emoticon!;
                    return Text(
                      display,
                      style: const TextStyle(fontSize: 20, height: 1),
                    );
                  }
                  return Icon(
                    Icons.image,
                    color: Theme.of(context).iconTheme.color,
                    size: 26,
                  );
                },
              ),
            ),
          ),
          title: Text(
            historia.titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy', 'pt_BR').format(historia.data),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).iconTheme.color,
            ),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  RouteTransitionHelper.slideUpRotateTransition(
                    EditHistoriaScreen(historia: historia),
                  ),
                ).then((updated) {
                  if (!mounted) return;
                  if (updated == true) {
                    final refreshProvider = Provider.of<RefreshProvider>(
                      context,
                      listen: false,
                    );
                    refreshProvider.refresh();
                  }
                });
              } else if (value == 'delete') {
                await _deleteHistoria(historia);
              } else if (value == 'export') {
                await _exportHistoria(historia);
              } else if (value == 'desagrupar') {
                final refreshProvider = Provider.of<RefreshProvider>(
                  context,
                  listen: false,
                );
                await _updateHistoria(
                  historia,
                  updates: {'tag': null, 'arquivado': null, 'grupo': null},
                );
                if (!mounted) return;
                refreshProvider.refresh();
                _messengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.storyUngrouped),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(AppLocalizations.of(context)?.edit ?? 'Editar'),
              ),
              PopupMenuItem(
                value: 'export',
                child: Text(
                  AppLocalizations.of(context)?.exportPdf ?? 'Exportar PDF',
                ),
              ),
              PopupMenuItem(
                value: 'desagrupar',
                child: Text(
                  AppLocalizations.of(context)?.ungroup ?? 'Desagrupar',
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  AppLocalizations.of(context)?.deleteLabel ?? 'Excluir',
                ),
              ),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: SingleChildScrollView(
                      child: _buildCardView(historia),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppLocalizations.of(context)?.close ?? 'Fechar',
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            children: [
              if (widget.grupo.emoticon != null &&
                  widget.grupo.emoticon!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    widget.grupo.emoticon!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              Expanded(
                child: Text(
                  widget.grupo.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isCardView
                    ? Icons.grid_view_rounded
                    : Icons.view_agenda_rounded,
              ),
              onPressed: () {
                setState(() {
                  _isCardView = !_isCardView;
                });
              },
              tooltip: _isCardView
                  ? (AppLocalizations.of(context)?.toggleToIcons ??
                        'Alternar para modo ícones')
                  : (AppLocalizations.of(context)?.toggleToCards ??
                        'Alternar para modo blocos'),
            ),
            // delete group
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _deleteGroup(),
              tooltip: AppLocalizations.of(context)!.deleteGroupTitle,
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  AppLocalizations.of(context)!.menu,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.editProfile),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.settings),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: () async {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final pinProvider = Provider.of<PinProvider>(
                    context,
                    listen: false,
                  );
                  final navigator = Navigator.of(context);
                  await auth.logout();
                  // Atualiza o status de login no PinProvider
                  pinProvider.updateUserLoginStatus(false);
                  if (!mounted) return;
                  navigator.pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
        body: Consumer<RefreshProvider>(
          builder: (context, refreshProvider, child) {
            return FutureBuilder<List<Historia>>(
              key: ValueKey<int>(refreshProvider.refreshCounter),
              future: _fetchHistoriasByGrupo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final historias = snapshot.data ?? [];
                if (historias.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.noStoriesInGroup(widget.grupo.nome) ??
                          'Nenhuma história no grupo "${widget.grupo.nome}".',
                      style: TextStyle(color: AppColors.labelColor(context)),
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: AppDurations.listSwitch,
                  child: ListView.builder(
                    key: ValueKey<bool>(_isCardView),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    itemCount: historias.length,
                    itemBuilder: (context, index) {
                      final historia = historias[index];
                      return _isCardView
                          ? _buildCardView(historia)
                          : _buildIconView(historia);
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PulseAnimation(
            scaleTarget: 1.06,
            child: FloatingActionButton.extended(
              onPressed: () {
                final refreshProvider = Provider.of<RefreshProvider>(
                  context,
                  listen: false,
                );
                Navigator.push(
                  context,
                  RouteTransitionHelper.slideUpRotateTransition(
                    const CreateHistoriaScreen(),
                  ),
                ).then((created) {
                  if (!mounted) return;
                  refreshProvider.refresh();
                });
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newStory),
            ),
          ),
        ),
      ), // Scaffold
    ); // ScaffoldMessenger
  }

  Future<void> _deleteGroup() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.deleteGroupTitle),
          content: Text(loc.deleteGroupConfirm(widget.grupo.nome)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.deleteLabel,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;
      // Atualiza histórias do grupo para voltar para a Home
      // Remove os flags de grupo e arquivado para que apareçam na Home
      await db.update(
        'historia',
        {
          'grupo': null,
          'arquivado': null,
          'data_update': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND grupo = ?',
        whereArgs: [userId, widget.grupo.nome],
      );

      // Remove o grupo da tabela grupos se presente
      try {
        await db.delete(
          'grupos',
          where: 'user_id = ? AND nome = ?',
          whereArgs: [userId, widget.grupo.nome],
        );
      } catch (e) {
        // Falha na remoção do registro do grupo não deve interromper o fluxo,
        // mas precisa ser visível para diagnóstico e suporte.
        debugPrint('GroupStoriesScreen: erro ao remover grupo: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorDeletingStory(e.toString()),
            ),
          ),
        );
      }

      if (!mounted) return;
      navigator.pushReplacementNamed('/home');
    }
  }
}
