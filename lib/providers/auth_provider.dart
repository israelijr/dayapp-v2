import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/pin_recovery_service.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  final PinRecoveryService _pinRecoveryService = PinRecoveryService();
  final UserRepository _userRepository = UserRepository();
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    final result = await _userRepository.findUserRowByEmail(email);
    if (result == null) return false;

    final storedPassword = result['senha'] as String;
    if (!_secureStorage.verifyPassword(password, storedPassword)) {
      return false;
    }

    _user = User.fromMap(result);

    if (!storedPassword.contains('\$')) {
      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(password, salt);
      await _userRepository.updatePasswordByEmail(email, hashedPassword);
    }

    await _pinRecoveryService.saveUserEmail(email, userId: _user!.id);

    if (remember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user!.id);
    }

    notifyListeners();
    return true;
  }

  Future<bool> verifyCredentials({
    required String email,
    required String password,
  }) async {
    final result = await _userRepository.findUserRowByEmail(email);
    if (result == null) return false;

    final storedPassword = result['senha'] as String;
    if (!_secureStorage.verifyPassword(password, storedPassword)) {
      return false;
    }

    if (!storedPassword.contains('\$')) {
      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(password, salt);
      await _userRepository.updatePasswordByEmail(email, hashedPassword);
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
      if (await _userRepository.emailExists(email)) {
        return false;
      }

      final salt = _secureStorage.generateSalt();
      final hashedSenha = _secureStorage.hashPassword(senha, salt);
      final uuid = const Uuid().v4();

      final user = User(
        id: uuid,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );

      await _userRepository.insertUser(user, hashedSenha);
      _user = user;

      await _pinRecoveryService.saveUserEmail(email, userId: uuid);
      await _secureStorage.removeBiometricCredentials();

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
      final user = await _userRepository.findById(userId);
      if (user != null) {
        _user = user;
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
    return await _userRepository.emailExists(email);
  }

  /// Atualiza a senha de um usuário pelo e-mail (usado na recuperação de senha)
  Future<bool> updatePasswordByEmail(String email, String newPassword) async {
    try {
      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(newPassword, salt);
      return await _userRepository.updatePasswordByEmail(email, hashedPassword);
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
      final updatedUser = User(
        id: _user!.id,
        nome: nome,
        email: email,
        dtNascimento: dtNascimento,
        fotoPerfil: fotoPerfil,
      );
      final updated = await _userRepository.updateUserProfile(updatedUser);
      if (!updated) return false;

      _user = updatedUser;
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
      final emailAlreadyInUse = await _userRepository.emailExists(newEmail);
      if (emailAlreadyInUse && newEmail != _user!.email) {
        return false;
      }

      final updated = await _userRepository.updateEmail(newEmail, _user!.id);
      if (!updated) return false;

      _user = User(
        id: _user!.id,
        nome: _user!.nome,
        email: newEmail,
        dtNascimento: _user!.dtNascimento,
        fotoPerfil: _user!.fotoPerfil,
      );

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
      final currentUser = await _userRepository.findById(_user!.id);
      if (currentUser == null) return 'error';

      final result = await _userRepository.findUserRowByEmail(
        currentUser.email,
      );
      if (result == null) return 'error';

      final storedHash = result['senha'] as String;
      if (!_secureStorage.verifyPassword(currentPassword, storedHash)) {
        return 'wrongPassword';
      }

      final salt = _secureStorage.generateSalt();
      final hashedPassword = _secureStorage.hashPassword(newPassword, salt);
      await _userRepository.updatePasswordByEmail(
        currentUser.email,
        hashedPassword,
      );

      return 'ok';
    } catch (e) {
      return 'error';
    }
  }
}
