import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../services/emoji_service.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final TextEditingController _newGroupController = TextEditingController();
  String? _selectedEmoticon;
  String? _selectedEmojiTranslation;

  Future<List<Grupo>> _loadGrupos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return [];
    return await GrupoHelper().getGruposByUser(userId);
  }

  void _selectGroup(String group) {
    Navigator.pop(context, group);
  }

  void _createNewGroup() async {
    final newGroupName = _newGroupController.text.trim();
    if (newGroupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterGroupName)),
      );
      return;
    }

    if (_selectedEmoticon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chooseIcon)),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    // Verificar se já existe
    final existing = await GrupoHelper().getGrupoByNome(userId, newGroupName);
    if (existing != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupExists)),
      );
      return;
    }

    // Criar novo grupo
    final newGrupo = Grupo(
      userId: userId,
      nome: newGroupName,
      emoticon: _selectedEmoticon,
      dataCriacao: DateTime.now(),
    );
    await GrupoHelper().insertGrupo(newGrupo);
    if (!mounted) return;
    Navigator.pop(context, newGroupName);
  }

  Future<void> _pickEmoticon() async {
    final Emoji? result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => const EmojiSelectionModal(),
    );
    if (result != null) {
      setState(() {
        _selectedEmoticon = result.char;
        _selectedEmojiTranslation = result.translation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectGroup)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Grupo>>(
          future: _loadGrupos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final grupos = snapshot.data ?? [];
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.existingGroups,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];
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
                        onTap: () => _selectGroup(grupo.nome),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.createNewGroup,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickEmoticon,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: _selectedEmoticon == null
                              ? const SizedBox.shrink()
                              : Text(
                                  _selectedEmoticon!,
                                  style: const TextStyle(fontSize: 28),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _newGroupController,
                          label: AppLocalizations.of(context)!.groupNameLabel,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedEmojiTranslation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedEmojiTranslation!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _createNewGroup,
                      child: Text(
                        AppLocalizations.of(context)!.createAndSelect,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
