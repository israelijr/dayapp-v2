import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../theme/m3_expressive_theme.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  Future<List<Grupo>> _loadGrupos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return [];
    return await GrupoHelper().getGruposByUser(userId);
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    // Verificar se há histórias vinculadas
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM historia WHERE user_id = ? AND tag = ?',
      [userId, grupo.nome],
    );
    final historiasCount = result.isNotEmpty ? result.first['count'] as int : 0;

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
      await GrupoHelper().deleteGrupoAndUpdateHistorias(
        grupo.id!,
        grupo.nome,
        userId,
      );
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.groupDeletedSuccess),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.manageGroups)),
      body: FutureBuilder<List<Grupo>>(
        future: _loadGrupos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final grupos = snapshot.data ?? [];
          if (grupos.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noGroupsFound,
                style: TextStyle(color: AppColors.labelColor(context)),
              ),
            );
          }
          return ListView.builder(
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final grupo = grupos[index];
              return ListTile(
                title: Text(grupo.nome),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _deleteGrupo(grupo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
