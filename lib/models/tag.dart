/// Modelo de dados para uma tag.
/// Armazena o nome exibido e o slug normalizado (sem acentos, lowercase),
/// usado para evitar duplicação por capitalização ou acento.
class Tag {
  final int? id;
  final String userId;
  final String nome;
  final String slug;

  const Tag({
    required this.userId,
    required this.nome,
    required this.slug,
    this.id,
  });

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
    id: map['id'] as int?,
    userId: map['user_id'] as String,
    nome: map['nome'] as String,
    slug: map['slug'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'nome': nome,
    'slug': slug,
  };

  /// Gera o slug normalizado a partir de um nome:
  /// converte para minúsculas, remove acentos, substitui
  /// caracteres não-alfanuméricos por hífen e colapsa múltiplos hífens.
  ///
  /// Exemplos:
  ///   "Família"  → "familia"
  ///   "São Paulo" → "sao-paulo"
  ///   "café & Música" → "cafe-musica"
  static String generateSlug(String name) {
    const Map<String, String> accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
      'ý': 'y',
      'ÿ': 'y',
      'ß': 'ss',
    };

    String result = name.toLowerCase().trim();

    for (final entry in accents.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    // Substitui qualquer caractere não-alfanumérico por hífen
    result = result.replaceAll(RegExp(r'[^a-z0-9]'), '-');
    // Colapsa múltiplos hífens em um único
    result = result.replaceAll(RegExp(r'-+'), '-');
    // Remove hífens do início e do fim
    result = result.replaceAll(RegExp(r'^-|-$'), '');

    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == id && other.slug == slug);

  @override
  int get hashCode => Object.hash(id, slug);

  @override
  String toString() => 'Tag(id: $id, nome: $nome, slug: $slug)';
}
