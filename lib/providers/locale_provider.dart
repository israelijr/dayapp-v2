import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar a seleção de idioma do app.
/// Armazena a preferência em `SharedPreferences`.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_selection';

  /// 'system' | 'en' | 'es'
  String _selection = 'system';
  Locale? _locale; // null = usar padrão do dispositivo

  LocaleProvider();

  String get selection => _selection;
  Locale? get locale => _locale;

  /// Carrega a seleção salva (assíncrono)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _selection = prefs.getString(_prefsKey) ?? 'system';
    // Em algumas versões antigas gravávamos o locale completo (ex: en_US).
    // Normalizamos já aqui para evitar que um valor inesperado seja salvo
    // novamente caso o usuário abra o diálogo de idioma posteriormente.
    if (_selection.contains('_')) {
      _selection = _selection.split('_').first;
    }
    _applySelection(notify: false);
    // registro simples para debug durante desenvolvimento
    debugPrint('LocaleProvider.load -> selection=$_selection locale=$_locale');
  }

  void _applySelection({bool notify = true}) {
    // Trata casos em que _selection pode ter sido gravado em formato
    // estendido (ex: 'en_US' ou 'pt_BR') ou apenas o idioma.
    final sel = _selection.toLowerCase();
    if (sel.startsWith('en')) {
      _locale = const Locale('en', 'US');
    } else if (sel.startsWith('es')) {
      _locale = const Locale('es', 'ES');
    } else if (sel.startsWith('pt')) {
      // Português -> forçar Brasil para consistência com ARB
      _locale = const Locale('pt', 'BR');
    } else if (sel.startsWith('fr')) {
      _locale = const Locale('fr', 'FR');
    } else if (sel.startsWith('it')) {
      _locale = const Locale('it', 'IT');
    } else if (sel == 'system') {
      _locale = null;
    } else {
      // Qualquer outro valor não reconhecido, usamos o idioma do sistema
      _locale = null;
    }

    if (notify) notifyListeners();
  }

  /// Define e persiste a seleção.
  ///
  /// Atualiza o estado local **imediatamente** (notificando listeners) e
  /// só depois grava nos _SharedPreferences_. Isso evita que a UI fique
  /// presa no idioma anterior durante o tempo que o armazenamento leva para
  /// completar.
  Future<void> setSelection(String sel) async {
    // garante apenas o código de idioma curto
    if (sel.contains('_')) {
      sel = sel.split('_').first;
    }
    _selection = sel;
    // aplica antes de gravar, o notify faz com que a árvore (MaterialApp)
    // reconstrua com o novo locale imediatamente.
    _applySelection();
    debugPrint(
      'LocaleProvider.setSelection -> selection=$_selection locale=$_locale',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, sel);
    } catch (e) {
      // Silencia erros de escrita - não é crítico para o uso imediato.
    }
  }
}
