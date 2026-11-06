class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final String senhaHash;
  final String salt;
  final int planoId;
  final DateTime criadoEm;

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senhaHash,
    required this.salt,
    required this.planoId,
    required this.criadoEm,
  });

  String get primeiroNome => nome.trim().split(RegExp(r'\s+')).first;

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? senhaHash,
    String? salt,
    int? planoId,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email,
      telefone: telefone ?? this.telefone,
      senhaHash: senhaHash ?? this.senhaHash,
      salt: salt ?? this.salt,
      planoId: planoId ?? this.planoId,
      criadoEm: criadoEm,
    );
  }

  /// Colunas da tabela `usuario`. A coluna `senha` guarda "salt:hash".
  Map<String, Object?> toMap() {
    return {
      'id_usuario': id,
      'nome': nome,
      'email': email,
      'senha': '$salt:$senhaHash',
      'id_plano': planoId,
    };
  }

  /// Colunas da tabela `app_perfil`.
  Map<String, Object?> perfilToMap() {
    return {
      'telefone': telefone,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, Object?> map) {
    final senha = map['senha'] as String;
    final separador = senha.indexOf(':');
    return Usuario(
      id: map['id_usuario'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      salt: senha.substring(0, separador),
      senhaHash: senha.substring(separador + 1),
      planoId: map['id_plano'] as int,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }
}
