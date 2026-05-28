class Capitulo {
  final int? id;
  final String userId;
  final String titulo;
  final String? descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final double? scoreConfianca;
  final bool criadoAutomaticamente;
  final DateTime? dataCriacao;
  final DateTime? dataUpdate;
  final String? fotoPath;

  const Capitulo({
    required this.userId,
    required this.titulo,
    required this.dataInicio,
    required this.dataFim,
    this.id,
    this.descricao,
    this.scoreConfianca,
    this.criadoAutomaticamente = false,
    this.dataCriacao,
    this.dataUpdate,
    this.fotoPath,
  });

  factory Capitulo.fromMap(Map<String, dynamic> map) {
    return Capitulo(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String?,
      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataFim: DateTime.parse(map['data_fim'] as String),
      scoreConfianca: (map['score_confianca'] as num?)?.toDouble(),
      criadoAutomaticamente: (map['criado_automaticamente'] as int? ?? 0) == 1,
      dataCriacao: map['data_criacao'] != null
          ? DateTime.tryParse(map['data_criacao'] as String)
          : null,
      dataUpdate: map['data_update'] != null
          ? DateTime.tryParse(map['data_update'] as String)
          : null,
      fotoPath: map['foto_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'descricao': descricao,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim.toIso8601String(),
      'score_confianca': scoreConfianca,
      'criado_automaticamente': criadoAutomaticamente ? 1 : 0,
      'data_criacao': dataCriacao?.toIso8601String(),
      'data_update': dataUpdate?.toIso8601String(),
      'foto_path': fotoPath,
    };
  }
}

class CapituloResumo {
  final Capitulo capitulo;
  final int totalEntradas;
  final double humorMedio;
  final List<String> topTags;

  const CapituloResumo({
    required this.capitulo,
    required this.totalEntradas,
    required this.humorMedio,
    required this.topTags,
  });
}
