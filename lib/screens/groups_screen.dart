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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _grupos.length + 1,
              itemBuilder: (context, index) {
                if (index == _grupos.length) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 4,
                        ),
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.17),
                        ),
                        right: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.17),
                        ),
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.17),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      title: Text(AppLocalizations.of(context)!.archivedTitle),
                      subtitle: Text(
                        '$_arquivadosCount ${_arquivadosCount == 1 ? AppLocalizations.of(context)!.record : AppLocalizations.of(context)!.records}',
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
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        _navigateAndRefresh(const ArchivedStoriesScreen());
                      },
                    ),
                  );
                }

                final grupo = _grupos[index];
                final count = _grupoCounts[grupo.nome] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.17),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
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
                          title: Text(
                            grupo.nome,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '$count ${count == 1 ? AppLocalizations.of(context)!.record : AppLocalizations.of(context)!.records}',
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            _navigateAndRefresh(
                              GroupStoriesScreen(grupo: grupo),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
