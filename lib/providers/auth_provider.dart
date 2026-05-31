import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../db/database_helper.dart';
import '../models/user.dart';
import '../services/pin_recovery_service.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  final PinRecoveryService _pinRecoveryService = PinRecoveryService();
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    final db = await DatabaseHelper().database;
    // Busca usuário pelo email
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final storedPassword = result.first['senha'] as String;
      // Verifica senha com hash (suporta migração de senhas antigas)
      if (_secureStorage.verifyPassword(password, storedPassword)) {
        _user = User.fromMap(result.first);

        // Se a senha ainda não tem hash, atualiza para versão segura
        if (!storedPassword.contains('\$')) {
          final salt = _secureStorage.generateSalt();
          final hashedPassword = _secureStorage.hashPassword(password, salt);
          await db.update(
            'users',
            {'senha': hashedPassword},
            where: 'id = ?',
            whereArgs: [_user!.id],
          );
        }

        // Atualiza o e-mail de recuperação para o usuário atual,
        // garantindo que contas diferentes não compartilhem o mesmo e-mail.
        await _pinRecoveryService.saveUserEmail(email, userId: _user!.id);

        if (remember) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', _user!.id);
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> verifyCredentials({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) return false;

    final storedPassword = result.first['senha'] as String;

    final validPassword = _secureStorage.verifyPassword(
      password,
      storedPassword,
    );
    if (!validPassword) return false;

    if (!storedPassword.contains('\$')) {
      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(password, salt);
      await db.update(
        'users',
        {'senha': hashedPassword},
        where: 'id = ?',
        whereArgs: [result.first['id']],
      );
    }

    return true;
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String senha,
    DateTime? dtNascimento,
    String? fotoPerfil,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return false;
      }

      // Gera hash seguro para a senha
      final salt = _secureStorage.generateSalt();
      final hashedSenha = _secureStorage.hashPassword(senha, salt);

      final uuid = const Uuid().v4();
      await db.insert('users', {
        'id': uuid,
        'nome': nome,
        'email': email,
        'senha': hashedSenha,
        'dt_nascimento': dtNascimento?.toIso8601String(),
        'foto_perfil': fotoPerfil,
      });
      _user = User(
        id: uuid,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );

      // Salva o e-mail de recuperação automaticamente (por usuário)
      await _pinRecoveryService.saveUserEmail(email, userId: uuid);

      // Remove credenciais biométricas de qualquer conta anterior,
      // garantindo que a tela de login mostre o checkbox de configuração
      // de biometria em vez do botão de login biométrico da conta antiga.
      await _secureStorage.removeBiometricCredentials();

      // Salva o ID do novo usuário em SharedPreferences para que o
      // tryAutoLogin restaure a sessão correta ao reiniciar o app,
      // sem retornar para a conta anterior.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uuid);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (result.isNotEmpty) {
        _user = User.fromMap(result.first);
        // Garante que o e-mail de recuperação está sincronizado com o usuário atual
        await _pinRecoveryService.saveUserEmail(
          _user!.email,
          userId: _user!.id,
        );
        notifyListeners();
      }
    }
  }

  /// Verifica se existe um usuário com o e-mail informado
  Future<bool> emailExists(String email) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  /// Atualiza a senha de um usuário pelo e-mail (usado na recuperação de senha)
  Future<bool> updatePasswordByEmail(String email, String newPassword) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isEmpty) return false;

      // Gera hash seguro para a nova senha
      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(newPassword, salt);

      await db.update(
        'users',
        {'senha': hashedPassword},
        where: 'email = ?',
        whereArgs: [email],
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser({
    required String nome,
    required String email,
    DateTime? dtNascimento,
    String? fotoPerfil,
  }) async {
    if (_user == null) return false;

    try {
      final db = await DatabaseHelper().database;
      await db.update(
        'users',
        {
          'nome': nome,
          'email': email,
          'dt_nascimento': dtNascimento?.toIso8601String(),
          'foto_perfil': fotoPerfil,
        },
        where: 'id = ?',
        whereArgs: [_user!.id],
      );

      _user = User(
        id: _user!.id,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Altera o e-mail do usuário logado.
  /// Retorna false se o novo e-mail já estiver em uso por outra conta.
  Future<bool> updateEmail(String newEmail) async {
    if (_user == null) return false;

    try {
      final db = await DatabaseHelper().database;

      // Verifica se o novo e-mail já pertence a outra conta
      final existing = await db.query(
        'users',
        where: 'email = ? AND id != ?',
        whereArgs: [newEmail, _user!.id],
      );
      if (existing.isNotEmpty) return false;

      await db.update(
        'users',
        {'email': newEmail},
        where: 'id = ?',
        whereArgs: [_user!.id],
      );

      _user = User(
        id: _user!.id,
        nome: _user!.nome,
        email: newEmail,
        dtNascimento: _user!.dtNascimento,
        fotoPerfil: _user!.fotoPerfil,
      );

      // Sincroniza o e-mail de recuperação de PIN
      await _pinRecoveryService.saveUserEmail(newEmail, userId: _user!.id);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Altera a senha do usuário logado verificando a senha atual.
  /// Retorna 'wrongPassword' se a senha atual estiver errada, 'error' em
  /// caso de falha, ou 'ok' em caso de sucesso.
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return 'error';

    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [_user!.id],
      );
      if (result.isEmpty) return 'error';

      final storedHash = result.first['senha'] as String;
      if (!_secureStorage.verifyPassword(currentPassword, storedHash)) {
        return 'wrongPassword';
      }

      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(newPassword, salt);

      await db.update(
        'users',
        {'senha': hashedPassword},
        where: 'id = ?',
        whereArgs: [_user!.id],
      );

      return 'ok';
    } catch (e) {
      return 'error';
    }
  }
}
