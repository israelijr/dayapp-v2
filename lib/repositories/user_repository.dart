import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  static const String _table = 'users';

  Future<Database> get _database async => await DatabaseHelper().database;

  Future<Map<String, dynamic>?> findUserRowByEmail(String email) async {
    final db = await _database;
    final result = await db.query(
      _table,
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<User?> findByEmail(String email) async {
    final row = await findUserRowByEmail(email);
    return row == null ? null : User.fromMap(row);
  }

  Future<User?> findById(String id) async {
    final db = await _database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<bool> emailExists(String email) async {
    return await findUserRowByEmail(email) != null;
  }

  Future<bool> insertUser(User user, String hashedPassword) async {
    final db = await _database;
    await db.insert(_table, {...user.toMap(), 'senha': hashedPassword});
    return true;
  }

  Future<bool> updatePasswordByEmail(
    String email,
    String hashedPassword,
  ) async {
    final db = await _database;
    final count = await db.update(
      _table,
      {'senha': hashedPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

  Future<bool> updateUserProfile(User user) async {
    final db = await _database;
    final updatedRows = await db.update(
      _table,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return updatedRows > 0;
  }

  Future<bool> updateEmail(String newEmail, String userId) async {
    final db = await _database;
    final updatedRows = await db.update(
      _table,
      {'email': newEmail},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return updatedRows > 0;
  }
}
