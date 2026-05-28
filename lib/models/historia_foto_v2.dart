/// Modelo de foto usando caminho de arquivo em vez de BLOB
/// Melhora performance evitando limite do CursorWindow do SQLite
class HistoriaFoto {
  final int? id;
  final int historiaId;
  final String fotoPath; // Caminho do arquivo no sistema
  final String? legenda;

  HistoriaFoto({
    required this.historiaId,
    required this.fotoPath,
    this.id,
    this.legenda,
  });

  factory HistoriaFoto.fromMap(Map<String, dynamic> map) {
    return HistoriaFoto(
      id: map['id'],
      historiaId: map['historia_id'],
      fotoPath: map['foto_path'] as String,
      legenda: map['legenda'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'foto_path': fotoPath,
      'legenda': legenda,
    };
  }

  /// Cria uma cópia com campos modificados
  HistoriaFoto copyWith({
    int? id,
    int? historiaId,
    String? fotoPath,
    String? legenda,
  }) {
    return HistoriaFoto(
      id: id ?? this.id,
      historiaId: historiaId ?? this.historiaId,
      fotoPath: fotoPath ?? this.fotoPath,
      legenda: legenda ?? this.legenda,
    );
  }
}
