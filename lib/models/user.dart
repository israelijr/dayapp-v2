class User {
  final String id;
  final String nome;
  final String email;
  final DateTime? dtNascimento;
  final String? fotoPerfil;

  User({
    required this.id,
    required this.nome,
    required this.email,
    this.dtNascimento,
    this.fotoPerfil,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      dtNascimento: map['dt_nascimento'] != null
          ? DateTime.tryParse(map['dt_nascimento'])
          : null,
      fotoPerfil: map['foto_perfil'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'dt_nascimento': dtNascimento?.toIso8601String(),
      'foto_perfil': fotoPerfil,
    };
  }
}
