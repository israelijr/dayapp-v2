class Grupo {
  final int? id;
  final String userId;
  final String nome;
  final String? emoticon;
  final DateTime? dataCriacao;

  Grupo({
    required this.userId, required this.nome, this.id,
    this.emoticon,
    this.dataCriacao,
  });

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(
      id: map['id'],
      userId: map['user_id'],
      nome: map['nome'],
      emoticon: map['emoticon'],
      dataCriacao: map['data_criacao'] != null
          ? DateTime.tryParse(map['data_criacao'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nome': nome,
      'emoticon': emoticon,
      'data_criacao': dataCriacao?.toIso8601String(),
    };
  }
}
