import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/grupo_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import 'archived_stories_screen.dart';
import 'group_stories_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Grupo> _grupos = [];
  Map<String, int> _grupoCounts = {};
  int _arquivadosCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrupos();
  }

  Future<void> _loadGrupos() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      if (userId != null) {
        final grupoHelper = GrupoHelper();
        final todosGrupos = await grupoHelper.getGruposByUser(userId);

        // Filtrar grupos que têm histórias e contar registros
        final gruposComHistorias = <Grupo>[];
        final counts = <String, int>{};

        for (final grupo in todosGrupos) {
          final count = await grupoHelper.countHistoriasInGrupo(
            userId,
            grupo.nome,
          );
          if (count > 0) {
            gruposComHistorias.add(grupo);
            counts[grupo.nome] = count;
          }
        }

        // Contar arquivadas
        final arquivadosCount = await grupoHelper.countArquivadas(userId);

        setState(() {
          _grupos = gruposComHistorias;
          _grupoCounts = counts;
          _arquivadosCount = arquivadosCount;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    // Recarregar grupos ao voltar
    _loadGrupos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myStories)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _grupos.length + 1,
              itemBuilder: (context, index) {
                if (index == _grupos.length) {
                  return Column(
                    children: [
                      const Divider(height: 1, thickness: 1),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.archivedTitle,
                        ),
                        subtitle: Text(
                          '$_arquivadosCount ${_arquivadosCount == 1 ? AppLocalizations.of(context)!.record : AppLocalizations.of(context)!.records}',
                        ),
                        leading: Icon(
                          Icons.archive,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _navigateAndRefresh(const ArchivedStoriesScreen());
                        },
                      ),
                    ],
                  );
                }

                final grupo = _grupos[index];
                final count = _grupoCounts[grupo.nome] ?? 0;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      grupo.emoticon ?? '📁',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(grupo.nome),
                  subtitle: Text(
                    '$count ${count == 1 ? AppLocalizations.of(context)!.record : AppLocalizations.of(context)!.records}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _navigateAndRefresh(GroupStoriesScreen(grupo: grupo));
                  },
                );
              },
            ),
    );
  }
}
