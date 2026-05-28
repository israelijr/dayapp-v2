import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_service.dart';

/// Serviço para recuperação de senha por e-mail
/// Gera códigos de recuperação (tokens) de 6 dígitos e envia via SMTP
class PasswordRecoveryService {
  static final PasswordRecoveryService _instance =
      PasswordRecoveryService._internal();
  factory PasswordRecoveryService() => _instance;
  PasswordRecoveryService._internal();

  final EmailService _emailService = EmailService();

  static const String _recoveryCodeKey = 'password_recovery_code';
  static const String _recoveryCodeTimeKey = 'password_recovery_code_time';
  static const String _recoveryEmailKey = 'password_recovery_email';

  /// Duração de validade do código de recuperação (em minutos)
  static const int recoveryCodeValidityMinutes = 15;

  /// Gera um código de recuperação de 6 dígitos
  String _generateRecoveryCode() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // Gera de 100000 a 999999
    return code.toString();
  }

  /// Gera um código de recuperação, armazena localmente e envia por e-mail via SMTP.
  /// Retorna true se o código foi gerado e o e-mail enviado com sucesso.
  Future<bool> sendRecoveryCode(String email) async {
    try {
      // Gera o código
      final code = _generateRecoveryCode();
      final now = DateTime.now();

      // Salva o código, o timestamp e o e-mail associado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recoveryCodeKey, code);
      await prefs.setString(_recoveryCodeTimeKey, now.toIso8601String());
      await prefs.setString(_recoveryEmailKey, email);

      // Envia o e-mail silenciosamente via SMTP
      final sent = await _emailService.sendRecoveryEmail(
        toEmail: email,
        recoveryCode: code,
        validityMinutes: recoveryCodeValidityMinutes,
      );

      if (!sent) {
        // Se falhou ao enviar, limpa o código gerado
        await clearRecoveryCode();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se há um código de recuperação ativo (não expirado)
  Future<bool> hasActiveRecoveryCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) return false;

      final codeTime = DateTime.parse(timeString);
      final difference = DateTime.now().difference(codeTime);

      return difference.inMinutes <= recoveryCodeValidityMinutes;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o código de recuperação ativo (para exibição quando não há app de e-mail)
  Future<String?> getActiveRecoveryCode() async {
    if (await hasActiveRecoveryCode()) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_recoveryCodeKey);
    }
    return null;
  }

  /// Obtém o e-mail associado ao código de recuperação ativo
  Future<String?> getRecoveryEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recoveryEmailKey);
  }

  /// Verifica se o código de recuperação informado é válido
  Future<bool> verifyRecoveryCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) return false;

      // Verifica se o código está correto
      if (savedCode != code) return false;

      // Verifica se o código ainda não expirou
      final codeTime = DateTime.parse(timeString);
      final difference = DateTime.now().difference(codeTime);

      if (difference.inMinutes > recoveryCodeValidityMinutes) {
        // Código expirado, limpa os dados
        await clearRecoveryCode();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpa o código de recuperação salvo
  Future<void> clearRecoveryCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recoveryCodeKey);
    await prefs.remove(_recoveryCodeTimeKey);
    await prefs.remove(_recoveryEmailKey);
  }

  /// Obtém o tempo restante de validade do código (em minutos)
  Future<int?> getRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (timeString == null) return null;

      final codeTime = DateTime.parse(timeString);
      final difference = DateTime.now().difference(codeTime);
      final remaining = recoveryCodeValidityMinutes - difference.inMinutes;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return null;
    }
  }
}
