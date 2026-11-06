/// Regras da área administrativa do site (docs/integracao-admin.md), com os
/// tamanhos de coluna do modelo do banco: nome e e-mail em VARCHAR(100).
class Validadores {
  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? nome(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe o nome';
    if (texto.length > 100) return 'Use no máximo 100 caracteres';
    return null;
  }

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail';
    if (texto.length > 100 || !_formatoEmail.hasMatch(texto)) return 'E-mail inválido';
    return null;
  }

  /// DDD + número: 10 ou 11 dígitos.
  static String? telefone(String? valor) {
    final digitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return 'Informe o telefone';
    if (digitos.length < 10 || digitos.length > 11) return 'Use DDD + número';
    return null;
  }

  /// Usado no login: só exige que a senha seja preenchida.
  static String? senhaObrigatoria(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe a senha';
    return null;
  }

  /// Usado no cadastro e na troca de senha: exige o tamanho mínimo.
  static String? novaSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe a senha';
    if (valor.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  static String? duracao(String? valor) {
    final minutos = int.tryParse(valor?.trim() ?? '');
    if (minutos == null || minutos <= 0) return 'Informe os minutos';
    if (minutos > 600) return 'Máximo de 600 minutos';
    return null;
  }
}
