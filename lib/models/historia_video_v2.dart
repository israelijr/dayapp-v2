class HistoriaVideo {
  final int? id;
  final int historiaId;
  final String videoPath; // Caminho do arquivo no sistema
  final String? legenda;
  final int? duracao; // duração em segundos
  final String? thumbnailPath; // Caminho da miniatura

  HistoriaVideo({
    required this.historiaId, required this.videoPath, this.id,
    this.legenda,
    this.duracao,
    this.thumbnailPath,
  });

  factory HistoriaVideo.fromMap(Map<String, dynamic> map) {
    return HistoriaVideo(
      id: map['id'],
      historiaId: map['historia_id'],
      videoPath: map['video_path'] as String,
      legenda: map['legenda'] as String?,
      duracao: map['duracao'] as int?,
      thumbnailPath: map['thumbnail_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_id': historiaId,
      'video_path': videoPath,
      'legenda': legenda,
      'duracao': duracao,
      'thumbnail_path': thumbnailPath,
    };
  }

  /// Cria uma cópia com campos modificados
  HistoriaVideo copyWith({
    int? id,
    int? historiaId,
    String? videoPath,
    String? legenda,
    int? duracao,
    String? thumbnailPath,
  }) {
    return HistoriaVideo(
      id: id ?? this.id,
      historiaId: historiaId ?? this.historiaId,
      videoPath: videoPath ?? this.videoPath,
      legenda: legenda ?? this.legenda,
      duracao: duracao ?? this.duracao,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
