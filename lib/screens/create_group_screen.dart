import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/group_management_provider.dart';
import '../providers/refresh_provider.dart';
import '../repositories/capitulo_repository.dart';
import '../repositories/group_repository.dart';
import '../services/emoji_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  static const int _maxGroupNameLength = 15;

  final TextEditingController _nameController = TextEditingController();
  final CapituloRepository _capituloRepository = CapituloRepository();
  final Set<int> _selectedStoryIds = <int>{};

  late final GroupManagementProvider _groupManagementProvider;

  bool _isLoadingStories = true;
  bool _isSaving = false;
  List<Historia> _stories = const <Historia>[];
  Map<int, String> _tagNomesPorId = const <int, String>{};

  String? _selectedEmoticon;
  String? _selectedEmojiTranslation;

  @override
  void initState() {
    super.initState();
    _groupManagementProvider = GroupManagementProvider(
      repository: GroupRepository(),
      authProvider: context.read<AuthProvider>(),
    );
    _loadStories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupManagementProvider.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoadingStories = false);
      return;
    }

    try {
      final entries = await _capituloRepository.listEntradasElegiveisComTags(
        userId,
      );

      final stories = entries
          .map((entry) => entry.historia)
          .where(
            (story) =>
                story.id != null &&
                story.grupo == null &&
                story.excluido == null,
          )
          .toList(growable: false);

      stories.sort((a, b) {
        final aArchived = a.arquivado == 'sim';
        final bArchived = b.arquivado == 'sim';
        if (aArchived != bArchived) {
          return aArchived ? 1 : -1;
        }
        return b.data.compareTo(a.data);
      });

      final tagNomesPorId = <int, String>{
        for (final entry in entries)
          if (entry.historia.id != null) entry.historia.id!: entry.tagNomes,
      };

      if (!mounted) return;
      setState(() {
        _stories = stories;
        _tagNomesPorId = tagNomesPorId;
        _isLoadingStories = false;
      });
    } catch (e) {
      debugPrint('CreateGroupScreen: erro ao carregar histórias: $e');
      if (!mounted) return;
      setState(() {
        _stories = const <Historia>[];
        _tagNomesPorId = const <int, String>{};
        _isLoadingStories = false;
      });
    }
  }

  Future<void> _pickEmoticon() async {
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => const EmojiSelectionModal(),
    );

    if (result == null) return;
    setState(() {
      _selectedEmoticon = result.char;
      _selectedEmojiTranslation = result.translation;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final groupName = _nameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterGroupName)));
      return;
    }

    if (groupName.length > _maxGroupNameLength) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupNameTooLong)));
      return;
    }

    if (_selectedStoryIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupMinimumStories)));
      return;
    }

    if (_selectedEmoticon == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chooseIcon)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _groupManagementProvider.createGrupoWithStories(
        groupName: groupName,
        emoticon: _selectedEmoticon,
        storyIds: _selectedStoryIds.toList(growable: false),
      );

      if (!mounted) return;
      context.read<RefreshProvider>().refresh();
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('CreateGroupScreen: erro ao criar grupo: $e');
      if (!mounted) return;

      final isDuplicate =
          e is StateError && e.message == 'GROUP_ALREADY_EXISTS';
      final message = isDuplicate
          ? l10n.groupExists
          : l10n.errorSavingStory(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newGroup)),
      body: _isLoadingStories
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickEmoticon,
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _selectedEmoticon ?? '😀',
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _nameController,
                            label: l10n.groupNameLabel,
                            maxLength: _maxGroupNameLength,
                            helperText: l10n.groupNameMaxLengthHint,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedEmojiTranslation ?? l10n.chooseIcon,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.groupSelectStories,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _GroupStoriesChecklist(
                        stories: _stories,
                        tagNomesPorId: _tagNomesPorId,
                        selectedStoryIds: _selectedStoryIds,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.group_add_outlined),
            label: Text(l10n.createAndSelect),
          ),
        ),
      ),
    );
  }
}

class _GroupStoriesChecklist extends StatefulWidget {
  final List<Historia> stories;
  final Map<int, String> tagNomesPorId;
  final Set<int> selectedStoryIds;

  const _GroupStoriesChecklist({
    required this.stories,
    required this.tagNomesPorId,
    required this.selectedStoryIds,
  });

  @override
  State<_GroupStoriesChecklist> createState() => _GroupStoriesChecklistState();
}

class _GroupStoriesChecklistState extends State<_GroupStoriesChecklist> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    final filteredStories = widget.stories
        .where((story) {
          if (normalizedQuery.isEmpty) return true;

          final title = story.titulo.toLowerCase();
          final date = DateFormat(
            'dd/MM/yyyy',
            l10n.localeName,
          ).format(story.data).toLowerCase();
          final subject = (story.assunto ?? '').toLowerCase();
          final legacyTag = (story.tag ?? '').toLowerCase();
          final tagNames = story.id != null
              ? (widget.tagNomesPorId[story.id!] ?? '').toLowerCase()
              : '';

          return title.contains(normalizedQuery) ||
              date.contains(normalizedQuery) ||
              subject.contains(normalizedQuery) ||
              legacyTag.contains(normalizedQuery) ||
              tagNames.contains(normalizedQuery);
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.search,
            hintText: l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: filteredStories.length,
              itemBuilder: (context, index) {
                final story = filteredStories[index];
                final id = story.id;
                if (id == null) return const SizedBox.shrink();

                return CheckboxListTile(
                  value: widget.selectedStoryIds.contains(id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        widget.selectedStoryIds.add(id);
                      } else {
                        widget.selectedStoryIds.remove(id);
                      }
                    });
                  },
                  title: Text(story.titulo),
                  subtitle: Text(() {
                    final dateText = DateFormat(
                      'dd/MM/yyyy',
                      l10n.localeName,
                    ).format(story.data);
                    final isArchived = story.arquivado == 'sim';
                    return isArchived
                        ? '${l10n.archivedStoryPrefixLabel} • $dateText'
                        : dateText;
                  }()),
                );
              },
            ),
          ),
        ),
        if (filteredStories.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.noStoriesHere,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.groupMinimumStories,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
