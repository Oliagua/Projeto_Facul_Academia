class Exercicio {
  final int id;
  final int treinoId;
  final int ordem;
  final String nome;
  final int series;
  final String repeticoes;
  final String carga;
  final int descansoSeg;

  const Exercicio({
    required this.id,
    required this.treinoId,
    required this.ordem,
    required this.nome,
    required this.series,
    required this.repeticoes,
    required this.carga,
    required this.descansoSeg,
  });

  factory Exercicio.fromMap(Map<String, Object?> map) {
    return Exercicio(
      id: map['id'] as int,
      treinoId: map['id_ficha'] as int,
      ordem: map['ordem'] as int,
      nome: map['nome'] as String,
      series: map['series'] as int,
      repeticoes: map['repeticoes'] as String,
      carga: map['carga'] as String,
      descansoSeg: map['descanso_seg'] as int,
    );
  }
}

/// Ficha de treino montada pelo professor (tabela `app_ficha`), com os dados da
/// modalidade e do professor já unidos (JOIN).
class Treino {
  final int id;
  final String letra;
  final String nome;
  final String foco;
  final String nivel;
  final int duracaoMin;
  final String modalidade;
  final String imagem;
  final String professor;
  final String fotoProfessor;
  final int quantidadeExercicios;
  final List<Exercicio> exercicios;

  const Treino({
    required this.id,
    required this.letra,
    required this.nome,
    required this.foco,
    required this.nivel,
    required this.duracaoMin,
    required this.modalidade,
    required this.imagem,
    required this.professor,
    required this.fotoProfessor,
    required this.quantidadeExercicios,
    this.exercicios = const [],
  });

  String get titulo => 'Treino $letra · $nome';

  Treino comExercicios(List<Exercicio> lista) {
    return Treino(
      id: id,
      letra: letra,
      nome: nome,
      foco: foco,
      nivel: nivel,
      duracaoMin: duracaoMin,
      modalidade: modalidade,
      imagem: imagem,
      professor: professor,
      fotoProfessor: fotoProfessor,
      quantidadeExercicios: lista.length,
      exercicios: lista,
    );
  }

  factory Treino.fromMap(Map<String, Object?> map) {
    return Treino(
      id: map['id'] as int,
      letra: map['letra'] as String,
      nome: map['nome'] as String,
      foco: map['foco'] as String,
      nivel: map['nivel'] as String,
      duracaoMin: map['duracao_min'] as int,
      modalidade: map['modalidade'] as String,
      imagem: map['imagem'] as String,
      professor: map['professor'] as String,
      fotoProfessor: map['foto_professor'] as String,
      quantidadeExercicios: map['qtd_exercicios'] as int,
    );
  }
}
