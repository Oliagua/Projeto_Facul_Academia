/// Conteúdo da academia: planos, modalidades e professores.
class Plano {
  final int id;
  final String nome;
  final int meses;
  final double precoMensal;
  final String descricao;
  final List<String> beneficios;
  final bool recomendado;
  final int limiteConvidados;

  const Plano({
    required this.id,
    required this.nome,
    required this.meses,
    required this.precoMensal,
    required this.descricao,
    required this.beneficios,
    required this.recomendado,
    required this.limiteConvidados,
  });

  double get precoTotal => precoMensal * meses;

  /// Nome curto: "Plano Anual" → "Anual".
  String get nomeCurto => nome.replaceFirst('Plano ', '');

  factory Plano.fromMap(Map<String, Object?> map) {
    return Plano(
      id: map['id_plano'] as int,
      nome: map['nome_plano'] as String,
      meses: map['duracao_meses'] as int,
      precoMensal: (map['preco'] as num).toDouble(),
      descricao: map['descricao'] as String,
      beneficios: (map['beneficios'] as String).split(';'),
      recomendado: map['recomendado'] == 1,
      limiteConvidados: map['limite_convidados'] as int,
    );
  }
}

class Modalidade {
  final int id;
  final String nome;
  final String resumo;
  final String descricao;
  final String imagem;

  const Modalidade({
    required this.id,
    required this.nome,
    required this.resumo,
    required this.descricao,
    required this.imagem,
  });

  factory Modalidade.fromMap(Map<String, Object?> map) {
    return Modalidade(
      id: map['id'] as int,
      nome: map['nome'] as String,
      resumo: map['resumo'] as String,
      descricao: map['descricao'] as String,
      imagem: map['imagem'] as String,
    );
  }
}

class Professor {
  final int id;
  final String nome;
  final String especialidade;
  final String cref;
  final String foto;

  const Professor({
    required this.id,
    required this.nome,
    required this.especialidade,
    required this.cref,
    required this.foto,
  });

  factory Professor.fromMap(Map<String, Object?> map) {
    return Professor(
      id: map['id'] as int,
      nome: map['nome'] as String,
      especialidade: map['especialidade'] as String,
      cref: map['cref'] as String,
      foto: map['foto'] as String,
    );
  }
}
