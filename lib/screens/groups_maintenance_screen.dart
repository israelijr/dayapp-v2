import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../providers/group_management_provider.dart';
import '../repositories/group_repository.dart';
import '../services/emoji_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';
import 'archived_stories_screen.dart';

class GroupsMaintenanceScreen extends StatefulWidget {
  const GroupsMaintenanceScreen({super.key});

  @override
  State<GroupsMaintenanceScreen> createState() =>
      _GroupsMaintenanceScreenState();
}

class _GroupsMaintenanceScreenState extends State<GroupsMaintenanceScreen> {
  late final GroupManagementProvider _groupManagementProvider;

  @override
  void initState() {
    super.initState();
    _groupManagementProvider = GroupManagementProvider(
      repository: GroupRepository(),
      authProvider: context.read<AuthProvider>(),
    )..loadGrupos();
  }

  @override
  void dispose() {
    _groupManagementProvider.dispose();
    super.dispose();
  }

  Future<void> _showGroupDialog({Grupo? grupo}) async {
    final provider = _groupManagementProvider;
    final isEditing = grupo != null;
    final nameController = TextEditingController(text: grupo?.nome);
    String? selectedEmoticon = grupo?.emoticon;
    String? selectedEmojiTranslation;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            title: Text(
              isEditing
                  ? AppLocalizations.of(context)!.editGroup
                  : AppLocalizations.of(context)!.newGroup,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final Emoji? result = await showModalBottomSheet<Emoji>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: const Color(0x00000000),
                        builder: (context) => const EmojiSelectionModal(),
                      );
                      if (result != null) {
                        setStateDialog(() {
                          selectedEmoticon = result.char;
                          selectedEmojiTranslation = result.translation;
                        });
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedEmoticon ?? '😀',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedEmojiTranslation ??
                        AppLocalizations.of(context)!.chooseIcon,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: nameController,
                    label: AppLocalizations.of(context)!.groupNameLabel,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final userId = provider.userId;
                  if (userId == null) return;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final locale = Localizations.localeOf(context).languageCode;

                  try {
                    if (isEditing) {
                      final currentGrupo = grupo;
                      final savedGrupo = Grupo(
                        id: currentGrupo.id,
                        userId: userId,
                        nome: name,
                        emoticon: selectedEmoticon,
                        dataCriacao: currentGrupo.dataCriacao,
                      );

                      await provider.saveGrupo(
                        savedGrupo,
                        oldName: currentGrupo.nome,
                      );
                    } else {
                      final savedGrupo = Grupo(
                        userId: userId,
                        nome: name,
                        emoticon: selectedEmoticon,
                        dataCriacao: DateTime.now(),
                      );

                      await provider.saveGrupo(savedGrupo);
                    }

                    if (!mounted) return;
                    navigator.pop();
                  } catch (e) {
                    debugPrint('GroupsMaintenanceScreen: erro ao salvar grupo: $e');
                    if (!mounted) return;
                    
                    String errorMsg;
                    switch (locale) {
                      case 'pt':
                        errorMsg = 'Erro ao salvar grupo. Tente novamente.';
                        break;
                      case 'es':
                        errorMsg = 'Error al guardar el grupo. Tente nuevamente.';
                        break;
                      case 'fr':
                        errorMsg = 'Erreur lors de l\'enregistrement du groupe. Réessayez.';
                        break;
                      default:
                        errorMsg = 'Error saving group. Please try again.';
                    }
                    
                    messenger.showSnackBar(
                      SnackBar(content: Text(errorMsg)),
                    );
                  }
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    final provider = _groupManagementProvider;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteGroupTitle),
        content: Text(
          AppLocalizations.of(context)!.deleteGroupWarningText(grupo.nome),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.deleteLabel),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await provider.deleteGrupo(grupo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupManagementProvider>(
      create: (_) => _groupManagementProvider,
      child: Consumer<GroupManagementProvider>(
        builder: (context, provider, child) {
          final grupos = provider.grupos;

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.manageGroups),
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    itemCount: grupos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == grupos.length) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          elevation: 3,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.archive,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.archivedTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArchivedStoriesScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      final grupo = grupos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                        elevation: 3,
                        shadowColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              grupo.emoticon ?? '📁',
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            grupo.nome,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.createdOn(grupo.dataCriacao?.toLocal().toString().split(' ')[0] ?? ''),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                onPressed: () => _showGroupDialog(grupo: grupo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                onPressed: () => _deleteGrupo(grupo),
                              ),
                            ],
                          ),
                          onTap: () => _showGroupDialog(grupo: grupo),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showGroupDialog(),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
