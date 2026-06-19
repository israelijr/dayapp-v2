import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/emoji_service.dart';

class EmojiSelectionModal extends StatefulWidget {
  const EmojiSelectionModal({super.key});

  @override
  State<EmojiSelectionModal> createState() => _EmojiSelectionModalState();
}

class _EmojiSelectionModalState extends State<EmojiSelectionModal> {
  final EmojiService _emojiService = EmojiService();
  bool _isLoading = true;
  String _selectedGroup = '';
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadEmojis();
  }

  Future<void> _loadEmojis() async {
    await _emojiService.loadEmojis();
    if (mounted) {
      setState(() {
        _groups = _emojiService.groups;
        if (_groups.isNotEmpty) {
          _selectedGroup = _groups.first;
        }
        _isLoading = false;
      });
    }
  }

  /// Traduz o nome do grupo de emoji (vindo do JSON em português) para o idioma atual
  String _translateGroup(String group, AppLocalizations loc) {
    switch (group.toUpperCase()) {
      case 'SENTIMENTOS':
        return loc.emojiGroupSentimentos;
      case 'ANIMAIS':
        return loc.emojiGroupAnimais;
      case 'VEGETAIS':
        return loc.emojiGroupVegetais;
      case 'CÉU':
        return loc.emojiGroupCeu;
      case 'OBJETOS':
        return loc.emojiGroupObjetos;
      case 'ALIMENTOS':
        return loc.emojiGroupAlimentos;
      case 'LUGARES':
        return loc.emojiGroupLugares;
      case 'SÍMBOLOS':
        return loc.emojiGroupSimbolos;
      default:
        return group;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '🙂', // Placeholder icon
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.chooseEmoji,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            // Group Tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  final isSelected = group == _selectedGroup;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        _translateGroup(group, AppLocalizations.of(context)!),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGroup = group;
                          });
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Emoji Grid
            Expanded(
              child: _selectedGroup.isEmpty
                  ? const SizedBox()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount:
                          _emojiService.groupedEmojis[_selectedGroup]?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final emoji =
                            _emojiService.groupedEmojis[_selectedGroup]![index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context, emoji);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                emoji.char,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
