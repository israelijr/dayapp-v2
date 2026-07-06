import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/create_group_provider.dart';
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

  late final GroupManagementProvider _groupManagementProvider;

  @override
  void initState() {
    super.initState();
    _groupManagementProvider = GroupManagementProvider(
      repository: GroupRepository(),
      authProvider: context.read<AuthProvider>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupManagementProvider.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context, CreateGroupProvider provider) async {
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

    if (provider.selectedStoryIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupMinimumStories)));
      return;
    }

    // Abre a janela para selecionar o emoji antes de salvar
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => const EmojiSelectionModal(),
    );

    if (!context.mounted) return;

    if (result != null) {
      provider.setEmoticon(result.char, result.translation);
    } else {
      provider.setEmoticon('🚫', '');
    }

    try {
      await provider.saveGroup(groupName: groupName);

      if (!context.mounted) return;
      context.read<RefreshProvider>().refresh();
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('CreateGroupScreen: erro ao criar grupo: $e');
      if (!context.mounted) return;

      final isDuplicate =
          e is StateError && e.message == 'GROUP_ALREADY_EXISTS';
      final message = isDuplicate
          ? l10n.groupExists
          : l10n.errorSavingStory(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateGroupProvider>(
      create: (context) => CreateGroupProvider(
        capituloRepository: CapituloRepository(),
        authProvider: context.read<AuthProvider>(),
        groupManagementProvider: _groupManagementProvider,
      ),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final colorScheme = Theme.of(context).colorScheme;
          final provider = context.watch<CreateGroupProvider>();

          return Scaffold(
            appBar: AppBar(title: Text(l10n.newGroup)),
            body: provider.isLoadingStories
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              label: l10n.groupNameLabel,
                              maxLength: _maxGroupNameLength,
                              helperText: l10n.groupNameMaxLengthHint,
                              textCapitalization: TextCapitalization.sentences,
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
                            const _GroupStoriesChecklist(),
                          ],
                        ),
                      ),
                    ),
                  ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton(
                  onPressed: provider.isSaving ? null : () => _save(context, provider),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupStoriesChecklist extends StatefulWidget {
  const _GroupStoriesChecklist();

  @override
  State<_GroupStoriesChecklist> createState() => _GroupStoriesChecklistState();
}

class _GroupStoriesChecklistState extends State<_GroupStoriesChecklist> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CreateGroupProvider>();

    final filteredStories = provider.getFilteredStories(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.search,
            hintText: l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: provider.setSearchQuery,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredStories.length,
            itemBuilder: (context, index) {
              final story = filteredStories[index];
              final id = story.id;
              if (id == null) return const SizedBox.shrink();

              return CheckboxListTile(
                value: provider.selectedStoryIds.contains(id),
                onChanged: (value) {
                  if (value != null) {
                    provider.toggleStorySelection(id, value);
                  }
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
