import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/notification_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../repositories/historia_repository.dart';
import '../services/emoji_service.dart';
import '../services/incremental_backup_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/compact_audio_icon.dart';
import '../widgets/compact_video_icon.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/entry_toolbar.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/mood_energy_selectors.dart';
import '../widgets/rich_text_editor_widget.dart';
import '../widgets/tag_input_widget.dart';
import '../widgets/video_recorder_widget.dart';
import 'rich_text_editor_screen.dart';

// Note: This file implements one UI feature requested by the team:
// 1) Animação de expansão do editor de descrição bottom-to-top ao abrir a tela de edição (_expandDescriptionEditor).
// The expanded editor screen is in `lib/screens/rich_text_editor_screen.dart` which
// provides drag-to-save (swipe down) behavior.

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se apenas a seleção mudou (texto é igual), não fazer nada
    // Isso permite seleção de múltiplas palavras sem interferência
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    String capitalizeText(String text) {
      if (text.isEmpty) return text;

      // Capitaliza a primeira letra do texto
      String result = text;
      if (result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }

      // Capitaliza após pontos finais (., !, ?) seguidos de espaço e letra minúscula
      result = result.replaceAllMapped(
        RegExp(r'([.!?]\s+)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      // Capitaliza após quebras de linha
      result = result.replaceAllMapped(
        RegExp(r'(\n)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      return result;
    }

    final capitalized = capitalizeText(newValue.text);
    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

class CreateHistoriaScreen extends StatefulWidget {
  const CreateHistoriaScreen({super.key});

  @override
  State<CreateHistoriaScreen> createState() => _CreateHistoriaScreenState();
}

class _CreateHistoriaScreenState extends State<CreateHistoriaScreen> {
  final titleController = TextEditingController();
  late final QuillController richTextController;
  final List<Uint8List> fotos = [];
  final List<Map<String, dynamic>> audios =
      []; // {audio: Uint8List, duration: int}
  final List<Map<String, dynamic>> videos =
      []; // {video: Uint8List, thumbnail: Uint8List?, duration: int}
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? selectedEmoticon;
  String? selectedEmojiTranslation;
  int _selectedMood = 3; // padrão: Neutro
  int _selectedEnergy = 2; // padrão: Normal

  // Lista de tags selecionadas
  List<Tag> _selectedTags = [];
  final HistoriaRepository _historiaRepository = HistoriaRepository();
  // Controle de alterações não salvas
  bool _hasUnsavedChanges = false;

  // Estado do indicador de sync de backup incremental
  bool _isSyncing = false;
  bool _syncDone = false;

  // Adicione este getter na classe _CreateHistoriaScreenState
  bool get _isFormValid {
    final plainText = richTextController.document.toPlainText().trim();
    return titleController.text.trim().isNotEmpty && plainText.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Inicializa o controller do Rich Text
    richTextController = QuillController.basic();
    // Adiciona listeners para detectar mudanças
    titleController.addListener(_checkForChanges);
    richTextController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    // Na tela de criação, qualquer coisa digitada é considerada mudança
    final plainText = richTextController.document.toPlainText().trim();
    final hasChanges =
        titleController.text.isNotEmpty ||
        plainText.isNotEmpty ||
        _selectedTags.isNotEmpty ||
        fotos.isNotEmpty ||
        audios.isNotEmpty ||
        videos.isNotEmpty ||
        selectedEmoticon != null ||
        _selectedMood != 3 ||
        _selectedEnergy != 2;

    /*     if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    } */

    setState(() {
      _hasUnsavedChanges = hasChanges;
    });
  }

  @override
  void dispose() {
    titleController.removeListener(_checkForChanges);
    richTextController.removeListener(_checkForChanges);
    titleController.dispose();
    richTextController.dispose();
    super.dispose();
  }

  String _capitalizeText(String text) {
    if (text.isEmpty) return text;

    // Capitaliza a primeira letra do texto
    String result = text;
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    // Capitaliza após pontos finais (., !, ?) seguidos de espaço e letra minúscula
    result = result.replaceAllMapped(
      RegExp(r'([.!?]\s+)([a-z])'),
      (match) => match.group(1)! + match.group(2)!.toUpperCase(),
    );

    // Capitaliza após quebras de linha
    result = result.replaceAllMapped(
      RegExp(r'(\n)([a-z])'),
      (match) => match.group(1)! + match.group(2)!.toUpperCase(),
    );

    return result;
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => ImagePickerWidget(
        allowMultiple: true,
        onMultipleImagesPicked: (imagesList) {
          setState(() {
            fotos.addAll(imagesList);
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeFoto(int index) {
    setState(() {
      fotos.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _recordAudio() async {
    showDialog(
      context: context,
      builder: (context) => AudioRecorderWidget(
        allowMultiple: true,
        onMultipleAudiosSelected: (audiosList) {
          setState(() {
            audios.addAll(audiosList);
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeAudio(int index) {
    setState(() {
      audios.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      builder: (context) => VideoRecorderWidget(
        allowMultiple: true,
        onMultipleVideosSelected: (videosList) {
          setState(() {
            for (final videoData in videosList) {
              videos.add({
                'video': videoData['video'],
                'thumbnail': null,
                'duration': videoData['duration'],
              });
            }
            _checkForChanges();
          });
        },
      ),
    );
  }

  void _removeVideo(int index) {
    setState(() {
      videos.removeAt(index);
      _checkForChanges();
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
    );
    if (!mounted) return;
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      if (!mounted) return;
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _showNotificationDialog(int historiaId) async {
    final plainText = richTextController.document.toPlainText();
    await NotificationHelper().showNotificationDialog(
      context,
      historiaId,
      selectedDate,
      titleController.text,
      plainText,
    );
  }

  Future<int?> _saveHistoria({bool navigateAfterSave = true}) async {
    /* final l10n = AppLocalizations.of(context)!;
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.titleRequired)));
      return null;
    } */
    final l10n = AppLocalizations.of(context)!;
    final plainText = richTextController.document.toPlainText().trim();

    // Validação estrita de título e descrição
    if (titleController.text.trim().isEmpty || plainText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.titleRequired),
        ), // Recomenda-se criar uma string genérica como l10n.fieldsRequired se disponível
      );
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Capture these before any async gaps to avoid using BuildContext after awaits
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      final navigator = Navigator.of(context);

      // Converte o conteúdo do Rich Text para JSON
      final richTextJson = RichTextHelper.controllerToJson(richTextController);
      final plainText = richTextController.document.toPlainText().trim();

      // Salva a história usando a camada de repositório
      final historiaId = await _historiaRepository.createHistoria(
        userId: auth.user?.id ?? '',
        titulo: _capitalizeText(titleController.text.trim()),
        descricao: plainText.isEmpty ? null : richTextJson,
        emoticon: selectedEmoticon,
        data: selectedDate,
        humor: _selectedMood,
        energia: _selectedEnergy,
        tags: _selectedTags,
        fotos: fotos,
        audios: audios,
        videos: videos,
      );

      // Se a data permitir notificação (pelo menos 2 horas à frente), perguntar sobre notificação
      if (NotificationHelper().shouldScheduleNotification(selectedDate)) {
        await _showNotificationDialog(historiaId);
      }

      // Atualiza a tela inicial
      if (!mounted) return historiaId;
      refreshProvider.refresh();

      // Dispara backup incremental em segundo plano com indicador visual.
      // Se a pasta não estiver configurada, exibe aviso dismissível.
      final l10nForBackup = l10n;
      IncrementalBackupService().triggerSilentBackup(
        l10n: l10nForBackup,
        onSyncStart: () {
          if (mounted) {
            setState(() {
              _isSyncing = true;
              _syncDone = false;
            });
          }
        },
        onSyncEnd: (success) {
          if (!mounted) return;
          setState(() {
            _isSyncing = false;
            _syncDone = success;
          });
          if (success) {
            // Apaga o ícone de sync após 2 segundos
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _syncDone = false);
            });
          }
        },
      );

      // Navega para a tela inicial se solicitado
      if (navigateAfterSave) {
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }

      return historiaId;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingStory(e.toString()),
            ),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancel() async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final dialogResult = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.discardStoryTitle),
        content: Text(loc.unsavedStoryPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.discard),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: Text(loc.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (dialogResult == 'save') {
      await _saveHistoria();
    } else if (dialogResult == 'discard') {
      Navigator.of(context).pop();
    }
  }

  void _expandDescriptionEditor() async {
    final navigator = Navigator.of(context);
    final richTextJson = RichTextHelper.controllerToJson(richTextController);
    final result = await navigator.push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RichTextEditorScreen(initialText: richTextJson),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from bottom
          final slideTween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));
          // Fade in
          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              // child includes the AppBar so it will animate in parallel
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.routeTransition,
      ),
    );
    if (result != null) {
      if (!mounted) return;
      setState(() {
        // Reconstrói o controller com o JSON retornado
        final newController = RichTextHelper.smartController(result);
        // Substitui todo o documento
        richTextController.replaceText(
          0,
          richTextController.document.length - 1,
          newController.document.toDelta(),
          null,
        );
      });
    }
  }

  Future<void> _selectEmoji() async {
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => const EmojiSelectionModal(),
    );
    if (result != null) {
      setState(() {
        selectedEmoticon = result.char;
        selectedEmojiTranslation = result.translation;
        _checkForChanges();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd(loc.localeName).add_Hm();
    final theme = Theme.of(context);

    // Determina a cor de destaque para textos conforme o tema ativo
    final Color labelColor = AppColors.labelColor(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          Navigator.of(context).pop();
          return;
        }
        if (_isLoading) return;

        final dialogResult = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(loc.discardStoryTitle),
            content: Text(loc.unsavedStoryPrompt),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('discard'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(loc.discard),
              ),
              /*               TextButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: Text(loc.save),
              ), */
              // Dentro do diálogo de _handleCancel e PopScope, altere o botão de salvar:
              TextButton(
                onPressed: !_isFormValid
                    ? null // Desabilita a opção de salvar no diálogo se for inválido
                    : () => Navigator.of(context).pop('save'),
                child: Text(loc.save),
              ),
            ],
          ),
        );

        if (!context.mounted) return;

        if (dialogResult == 'save') {
          await _saveHistoria();
        } else if (dialogResult == 'discard') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.newStory,
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: labelColor,
              height: 1.3,
            ),
          ),
          actions: [
            // Indicador de sync do backup incremental (Opção B: visível, não bloqueante)
            if (_isSyncing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_syncDone)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Tooltip(
                  message: loc.incrementalBackupSyncDone,
                  child: Icon(
                    Icons.cloud_done_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date and Emoji
                    Row(
                      children: [
                        Text(
                          dateFormat.format(selectedDate),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: labelColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 20),
                          onPressed: _pickDateTime,
                          tooltip: loc.changeDateTooltip,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        const Spacer(flex: 1),
                        if (selectedEmoticon != null)
                          Chip(
                            label: Text(
                              selectedEmoticon!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            onDeleted: () {
                              setState(() {
                                selectedEmoticon = null;
                                selectedEmojiTranslation = null;
                                _checkForChanges();
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    CustomTextField(
                      controller: titleController,
                      label: '* ${loc.storyTitleLabel}',
                      hintText: loc.storyTitleHint,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      inputFormatters: [
                        SentenceCapitalizationTextInputFormatter(),
                      ],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '* ${loc.descriptionLabel}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: labelColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: FloatingActionButton.small(
                            heroTag: null,
                            elevation: 1,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerLow,
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            tooltip: loc.expandTooltip,
                            onPressed: _expandDescriptionEditor,
                            child: const Icon(
                              Icons.open_in_full_rounded,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichTextEditorWidget(
                      key: const Key('description_field'),
                      controller: richTextController,
                      hintText: loc.descriptionHint,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      minLines: 8,
                      maxLines: 15,
                      showToolbar: true,
                      /* onChanged: () {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      }, */
                      onChanged: () {
                        _checkForChanges(); // Mudado de apenas colocar _hasUnsavedChanges = true
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Builder(
                      builder: (context) {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        return TagInputWidget(
                          userId: auth.user?.id ?? '',
                          initialTags: _selectedTags,
                          onTagsChanged: (tags) {
                            setState(() {
                              _selectedTags = tags;
                              _checkForChanges();
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Humor (como você se sentiu)
                    Text(
                      loc.moodQuestion,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MoodSelector(
                      value: _selectedMood,
                      onChanged: (v) => setState(() {
                        _selectedMood = v;
                        _checkForChanges();
                      }),
                    ),

                    // Energia
                    const SizedBox(height: 16),
                    Text(
                      loc.energyQuestion,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EnergySelector(
                      value: _selectedEnergy,
                      onChanged: (v) => setState(() {
                        _selectedEnergy = v;
                        _checkForChanges();
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Media Previews
                    if (fotos.isNotEmpty) ...[
                      Text(
                        loc.photosSection,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: fotos.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    fotos[i],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: IconButton.filled(
                                    onPressed: () => _removeFoto(i),
                                    icon: const Icon(Icons.close, size: 14),
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(24, 24),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (audios.isNotEmpty) ...[
                      Text(
                        loc.audiosSection,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: audios.asMap().entries.map((entry) {
                          return CompactAudioIcon(
                            audioData: entry.value['audio'],
                            duration: entry.value['duration'],
                            onDelete: () => _removeAudio(entry.key),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (videos.isNotEmpty) ...[
                      Text(
                        loc.videosSection,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: videos.asMap().entries.map((entry) {
                          return CompactVideoIcon(
                            videoData: entry.value['video'],
                            thumbnail: entry.value['thumbnail'],
                            duration: entry.value['duration'],
                            onDelete: () => _removeVideo(entry.key),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Main Toolbar (photos, videos, audio, emoji)
            EntryToolbar(
              onPickPhoto: _pickImage,
              onPickVideo: _pickVideo,
              onRecordAudio: _recordAudio,
              onSelectEmoji: _selectEmoji,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleCancel,
                      child: Text(loc.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  /* Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveHistoria,
                      child: Text(loc.save),
                    ),
                  ), */
                  Expanded(
                    child: FilledButton(
                      // Só permite o clique se NÃO estiver carregando E o formulário for válido
                      onPressed: (_isLoading || !_isFormValid)
                          ? null
                          : _saveHistoria,
                      child: Text(loc.save),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
