import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';
import 'secure_storage_service.dart';

/// Serviço para recuperação de PIN por e-mail
/// Gera códigos de recuperação (tokens) de 6 dígitos e envia via SMTP
class PinRecoveryService {
  static final PinRecoveryService _instance = PinRecoveryService._internal();
  factory PinRecoveryService() => _instance;
  PinRecoveryService._internal();

  final EmailService _emailService = EmailService();
  final SecureStorageService _secureStorage = SecureStorageService();

  static const String _recoveryCodeKey = 'pin_recovery_code';
  static const String _recoveryCodeTimeKey = 'pin_recovery_code_time';
  static const String _recoveryEmailKey = 'pin_recovery_email';
  static const String _legacyUserEmailKey = 'user_email';

  /// Duração de validade do código de recuperação (em minutos)
  static const int recoveryCodeValidityMinutes = 15;

  /// Gera um código de recuperação de 6 dígitos
  String _generateRecoveryCode() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // Gera de 100000 a 999999
    return code.toString();
  }

  /// Salva o e-mail do usuário (armazenamento seguro por usuário)
  Future<void> saveUserEmail(String email, {String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await _secureStorage.saveRecoveryEmailForUser(userId, email);
    }
    // Mantém também o e-mail global para compatibilidade com versões antigas
    await _secureStorage.saveRecoveryEmail(email);

    // Remove dados legados se existirem
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyUserEmailKey);
  }

  /// Obtém o e-mail do usuário salvo
  /// Prioriza a chave por userId, com fallback para chave global e dados legados
  Future<String?> getUserEmail({String? userId}) async {
    // Tenta primeiro a chave específica do usuário
    if (userId != null && userId.isNotEmpty) {
      final userEmail = await _secureStorage.getRecoveryEmailForUser(userId);
      if (userEmail != null) return userEmail;
    }

    // Fallback: armazenamento global (compatibilidade)
    final secureEmail = await _secureStorage.getRecoveryEmail();
    if (secureEmail != null) return secureEmail;

    // Verifica se há dados legados para migrar
    final prefs = await SharedPreferences.getInstance();
    final legacyEmail = prefs.getString(_legacyUserEmailKey);

    if (legacyEmail != null) {
      // Migra para armazenamento seguro
      await _secureStorage.saveRecoveryEmail(legacyEmail);
      await prefs.remove(_legacyUserEmailKey);
      return legacyEmail;
    }

    return null;
  }

  /// Gera e envia um código de recuperação por e-mail via SMTP.
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
      final sent = await _emailService.sendRecoveryPinEmail(
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
      debugPrint('PinRecoveryService.sendRecoveryCode: erro ao enviar código de recuperação: $e');
      return false;
    }
  }

  /// Verifica se há um código de recuperação ativo
  Future<bool> hasActiveRecoveryCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) {
        return false;
      }

      // Verifica se o código ainda é válido (não expirou)
      final codeTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(codeTime);

      return difference.inMinutes <= recoveryCodeValidityMinutes;
    } catch (e) {
      debugPrint('PinRecoveryService.hasActiveRecoveryCode: erro ao verificar código ativo: $e');
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

  /// Verifica se o código de recuperação é válido
  Future<bool> verifyRecoveryCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_recoveryCodeKey);
      final timeString = prefs.getString(_recoveryCodeTimeKey);

      if (savedCode == null || timeString == null) {
        return false;
      }

      // Verifica se o código está correto
      if (savedCode != code) {
        return false;
      }

      // Verifica se o código ainda é válido (não expirou)
      final codeTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(codeTime);

      if (difference.inMinutes > recoveryCodeValidityMinutes) {
        // Código expirado, limpa os dados
        await clearRecoveryCode();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('PinRecoveryService.verifyRecoveryCode: erro ao verificar código: $e');
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
      debugPrint('PinRecoveryService.getRemainingTime: erro ao obter tempo restante: $e');
      return null;
    }
  }
}
