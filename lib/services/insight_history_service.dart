import 'dart:convert';

import '../db/database_helper.dart';
import '../models/insight.dart';

/// Registro de um insight no histórico persistido.
class InsightHistoryEntry {
  final int id;
  final String userId;
  final InsightType type;
  final String title;
  final String description;
  final String icon;
  final Map<String, dynamic>? metadata;
  final DateTime seenAt;
  final bool isPremium;

  const InsightHistoryEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.metadata,
    required this.seenAt,
    required this.isPremium,
  });

  factory InsightHistoryEntry.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? meta;
    final rawMeta = map['metadata'] as String?;
    if (rawMeta != null && rawMeta.isNotEmpty) {
      meta = Map<String, dynamic>.from(jsonDecode(rawMeta) as Map);
    }
    return InsightHistoryEntry(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      type: InsightType.fromString(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      metadata: meta,
      seenAt: DateTime.fromMillisecondsSinceEpoch(map['seen_at'] as int),
      isPremium: (map['is_premium'] as int) == 1,
    );
  }
}

/// Serviço responsável por gravar e consultar o histórico de insights.
///
/// Cada combinação (user_id, type) armazena apenas um registro — ao reexibir
/// o mesmo tipo o timestamp é atualizado via UPSERT. Isso garante que o
/// histórico reflete a exibição mais recente de cada categoria.
class InsightHistoryService {
  final DatabaseHelper _db = DatabaseHelper();

  // ---------------------------------------------------------------------------
  // Escrita
  // ---------------------------------------------------------------------------

  /// Registra (ou atualiza) a exibição de um insight no histórico.
  Future<void> saveInsight(
    String userId,
    Insight insight,
    DateTime seenAt,
  ) async {
    final db = await _db.database;
    await db.rawInsert(
      '''
      INSERT INTO insight_history
        (user_id, type, title, description, icon, metadata, seen_at, is_premium)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(user_id, type) DO UPDATE SET
        title       = excluded.title,
        description = excluded.description,
        icon        = excluded.icon,
        metadata    = excluded.metadata,
        seen_at     = excluded.seen_at,
        is_premium  = excluded.is_premium
      ''',
      [
        userId,
        insight.type.value,
        insight.title,
        insight.description,
        insight.icon,
        insight.metadata != null ? jsonEncode(insight.metadata) : null,
        seenAt.millisecondsSinceEpoch,
        insight.isPremium ? 1 : 0,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Leitura
  // ---------------------------------------------------------------------------

  /// Retorna o histórico de insights do usuário, do mais recente ao mais antigo.
  ///
  /// [limitDays] filtra apenas registros dos últimos N dias.
  /// Passe `null` para buscar todos.
  Future<List<InsightHistoryEntry>> getHistory(
    String userId, {
    int? limitDays,
  }) async {
    final db = await _db.database;

    String? whereClause = 'user_id = ?';
    final whereArgs = <dynamic>[userId];

    if (limitDays != null) {
      final cutoff = DateTime.now()
          .subtract(Duration(days: limitDays))
          .millisecondsSinceEpoch;
      whereClause = 'user_id = ? AND seen_at >= ?';
      whereArgs.add(cutoff);
    }

    final rows = await db.query(
      'insight_history',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'seen_at DESC',
    );

    return rows
        .map((r) => InsightHistoryEntry.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Remove todo o histórico de um usuário.
  Future<void> clearHistory(String userId) async {
    final db = await _db.database;
    await db.delete(
      'insight_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
