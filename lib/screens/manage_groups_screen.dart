import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../providers/group_management_provider.dart';
import '../repositories/group_repository.dart';
import '../theme/m3_expressive_theme.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
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

  Future<void> _deleteGrupo(Grupo grupo) async {
    final provider = _groupManagementProvider;
    final historiasCount = await provider.countHistoriasInGroup(grupo.nome);

    if (!mounted) return;

    bool confirmDelete = true;
    if (historiasCount > 0) {
      confirmDelete =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmDeletion),
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.groupDeleteWarning(historiasCount),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context)!.deleteLabel),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (confirmDelete) {
      await provider.deleteGrupo(grupo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.groupDeletedSuccess),
        ),
      );
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
                : grupos.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noGroupsFound,
                      style: TextStyle(color: AppColors.labelColor(context)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _deleteGrupo(grupo),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
