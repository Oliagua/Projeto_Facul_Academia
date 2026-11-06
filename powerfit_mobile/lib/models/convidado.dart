import '../utils/formatos.dart';

/// Tabela `convidado` do modelo.
class Convidado {
  final int? id;
  final String nome;
  final DateTime dataVisita;
  final int usuarioId;

  const Convidado({
    this.id,
    required this.nome,
    required this.dataVisita,
    required this.usuarioId,
  });

  Map<String, Object?> toMap() {
    return {
      'id_convidado': id,
      'nome': nome,
      'data_visita': Formatos.dataSql(dataVisita),
      'id_usuario': usuarioId,
    };
  }

  factory Convidado.fromMap(Map<String, Object?> map) {
    return Convidado(
      id: map['id_convidado'] as int?,
      nome: map['nome'] as String,
      dataVisita: DateTime.parse(map['data_visita'] as String),
      usuarioId: map['id_usuario'] as int,
    );
  }
}
