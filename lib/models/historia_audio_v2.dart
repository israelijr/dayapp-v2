/// Modelo de áudio usando caminho de arquivo em vez de BLOB
/// Melhora performance evitando limite do CursorWindow do SQLite
class HistoriaAudio {
  final int? id;
  final int historiaId;
  final String audioPath; // Caminho do arquivo no sistema
  final String? legenda;
  final int? duracao; // duração em segundos

  HistoriaAudio({
    required this.historiaId,
    required this.audioPath,
    this.id,
    this.legenda,
    this.duracao,
  });

  factory HistoriaAudio.fromMap(Map<String, dynamic> map) {
    return HistoriaAudio(
      id: map['id'],
      historiaId: map['historia_id'],
      audioPath: map['audio_path'] as String,
      legenda: map['legenda'] as String?,
      duracao: map['duracao'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'audio_path': audioPath,
      'legenda': legenda,
      'duracao': duracao,
    };
  }

  /// Cria uma cópia com campos modificados
  HistoriaAudio copyWith({
    int? id,
    int? historiaId,
    String? audioPath,
    String? legenda,
    int? duracao,
  }) {
    return HistoriaAudio(
      id: id ?? this.id,
      historiaId: historiaId ?? this.historiaId,
      audioPath: audioPath ?? this.audioPath,
      legenda: legenda ?? this.legenda,
      duracao: duracao ?? this.duracao,
    );
  }
}
