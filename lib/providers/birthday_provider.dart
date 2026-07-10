import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

enum BirthdayStatus { none, today, passed }

class BirthdayProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isChecking = false;
  BirthdayStatus _status = BirthdayStatus.none;
  bool _shouldShow = false;

  BirthdayProvider({required AuthProvider authProvider}) : _authProvider = authProvider {
    _checkBirthday();
  }

  BirthdayStatus get status => _status;
  bool get shouldShow => _shouldShow;
  bool get isChecking => _isChecking;
  String? get userId => _authProvider.user?.id;
  DateTime? get birthDate => _authProvider.user?.dtNascimento;

  Future<void> _checkBirthday() async {
    final user = _authProvider.user;
    if (user == null || user.dtNascimento == null) {
      _status = BirthdayStatus.none;
      _shouldShow = false;
      notifyListeners();
      return;
    }

    _isChecking = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final birthDate = user.dtNascimento!;
      
      // Data do aniversário este ano (horas zeradas)
      final birthdayThisYear = DateTime(now.year, birthDate.month, birthDate.day);
      final today = DateTime(now.year, now.month, now.day);
      
      final prefs = await SharedPreferences.getInstance();
      // Chave inclui dia e mês para o caso de alteração da data de nascimento do usuário
      final key = 'birthday_shown_${user.id}_${now.year}_${birthDate.month}_${birthDate.day}';
      final alreadyShown = prefs.getBool(key) ?? false;

      if (alreadyShown) {
        _status = BirthdayStatus.none;
        _shouldShow = false;
      } else {
        if (today.isAtSameMomentAs(birthdayThisYear)) {
          _status = BirthdayStatus.today;
          _shouldShow = true;
        } else if (today.isAfter(birthdayThisYear)) {
          _status = BirthdayStatus.passed;
          _shouldShow = true;
        } else {
          _status = BirthdayStatus.none;
          _shouldShow = false;
        }
      }
    } catch (e) {
      _status = BirthdayStatus.none;
      _shouldShow = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> markAsShown() async {
    final user = _authProvider.user;
    if (user == null || user.dtNascimento == null) return;

    final now = DateTime.now();
    final birthDate = user.dtNascimento!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'birthday_shown_${user.id}_${now.year}_${birthDate.month}_${birthDate.day}';
      await prefs.setBool(key, true);
      _shouldShow = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao marcar aniversário como exibido: $e');
    }
  }
}
