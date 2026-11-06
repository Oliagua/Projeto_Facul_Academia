import '../utils/formatos.dart';

enum Intensidade {
  leve(1, 'Leve'),
  moderada(2, 'Moderada'),
  intensa(3, 'Intensa');

  const Intensidade(this.valor, this.rotulo);

  final int valor;
  final String rotulo;

  static Intensidade deValor(int valor) =>
      Intensidade.values.firstWhere((i) => i.valor == valor, orElse: () => moderada);
}

/// Treino realizado pelo aluno: é a tabela `treino` do modelo (o CRUD do app).
class Atividade {
  final int? id;
  final int usuarioId;

  /// Ficha de treino usada (A a F), quando houver.
  final int? treinoId;
  final String titulo;
  final DateTime data;
  final int duracaoMin;
  final Intensidade intensidade;
  final String observacao;

  /// Vem do JOIN com a tabela treino, quando houver.
  final String? letraTreino;

  const Atividade({
    this.id,
    required this.usuarioId,
    this.treinoId,
    required this.titulo,
    required this.data,
    required this.duracaoMin,
    required this.intensidade,
    this.observacao = '',
    this.letraTreino,
  });

  /// Colunas da tabela `treino`.
  Map<String, Object?> toMap() {
    return {
      'id_treino': id,
      'descricao': titulo,
      'data_treino': Formatos.dataSql(data),
      'duracao_minutos': duracaoMin,
      'id_usuario': usuarioId,
    };
  }

  /// Colunas da tabela `app_treino_detalhe`.
  Map<String, Object?> detalheToMap() {
    return {
      'id_ficha': treinoId,
      'intensidade': intensidade.valor,
      'observacao': observacao,
    };
  }

  factory Atividade.fromMap(Map<String, Object?> map) {
    return Atividade(
      id: map['id_treino'] as int?,
      usuarioId: map['id_usuario'] as int,
      treinoId: map['id_ficha'] as int?,
      titulo: map['descricao'] as String,
      data: DateTime.parse(map['data_treino'] as String),
      duracaoMin: map['duracao_minutos'] as int,
      intensidade: Intensidade.deValor((map['intensidade'] as int?) ?? Intensidade.moderada.valor),
      observacao: (map['observacao'] as String?) ?? '',
      letraTreino: map['letra'] as String?,
    );
  }
}
