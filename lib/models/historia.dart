class Historia {
  final int? id;
  final String userId;
  final String? assunto;
  final String titulo;
  final DateTime data;
  final String? tag;
  final String? descricao;
  final String? sentimento;
  final String? emoticon;
  final DateTime? dataCriacao;
  final DateTime? dataUpdate;
  final String? fotoHistoria;
  final String? grupo;
  final String? arquivado;
  final String? excluido;
  final DateTime? dataExclusao;
  final bool backedUp;
  // 1=Difícil, 2=Neutro, 3=Bom (padrão), 4=Muito bom
  final int humor;
  // 1=Baixa, 2=Normal (padrão), 3=Alta
  final int energia;
  final String? local;
  final int continua;

  Historia({
    required this.userId,
    required this.titulo,
    required this.data,
    this.id,
    this.assunto,
    this.tag,
    this.descricao,
    this.sentimento,
    this.emoticon,
    this.dataCriacao,
    this.dataUpdate,
    this.fotoHistoria,
    this.grupo,
    this.arquivado,
    this.excluido,
    this.dataExclusao,
    this.backedUp = false,
    this.humor = 3,
    this.energia = 2,
    this.local,
    this.continua = 1,
  });

  factory Historia.fromMap(Map<String, dynamic> map) {
    return Historia(
      id: map['id'],
      userId: map['user_id'],
      assunto: map['assunto'],
      titulo: map['titulo'],
      data: DateTime.parse(map['data']),
      tag: map['tag'],
      descricao: map['descricao'],
      sentimento: map['sentimento'],
      emoticon: map['emoticon'],
      dataCriacao: map['data_criacao'] != null
          ? DateTime.tryParse(map['data_criacao'])
          : null,
      dataUpdate: map['data_update'] != null
          ? DateTime.tryParse(map['data_update'])
          : null,
      fotoHistoria: map['foto_historia'],
      grupo: map['grupo'],
      arquivado: map['arquivado'],
      excluido: map['excluido'],
      dataExclusao: map['data_exclusao'] != null
          ? DateTime.tryParse(map['data_exclusao'])
          : null,
      // Compatibilidade: backups antigos podem não ter a coluna 'backed_up'
      backedUp: map.containsKey('backed_up')
          ? ((map['backed_up'] is int)
                ? (map['backed_up'] as int) == 1
                : (map['backed_up'] == true))
          : false,
      // Compatibilidade: histórias antigas sem humor/energia usam os valores padrão
      humor: map['humor'] as int? ?? 3,
      energia: map['energia'] as int? ?? 2,
      // Compatibilidade: campo local pode ser nulo se não existir no banco
      local: map.containsKey('local') ? map['local'] as String? : null,
      continua: map['continua'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'assunto': assunto,
      'titulo': titulo,
      'data': data.toIso8601String(),
      'tag': tag,
      'descricao': descricao,
      'sentimento': sentimento,
      'emoticon': emoticon,
      'data_criacao': dataCriacao?.toIso8601String(),
      'data_update': dataUpdate?.toIso8601String(),
      'foto_historia': fotoHistoria,
      'grupo': grupo,
      'arquivado': arquivado,
      'excluido': excluido,
      'data_exclusao': dataExclusao?.toIso8601String(),
      'backed_up': backedUp ? 1 : 0,
      'humor': humor,
      'energia': energia,
      'local': local,
      'continua': continua,
    };
  }
}
