import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../database/usuario_dao.dart';
import '../models/usuario.dart';

class EmailJaCadastradoException implements Exception {}

class SenhaIncorretaException implements Exception {}

/// Cadastro, login e manutenção da conta. A senha nunca é salva em texto
/// puro: guardamos SHA-256(salt + senha), com um salt aleatório por usuário.
class AuthService {
  AuthService({UsuarioDao? dao}) : _dao = dao ?? UsuarioDao();

  final UsuarioDao _dao;

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required int planoId,
  }) async {
    final emailNormalizado = _normalizar(email);
    if (await _dao.buscarPorEmail(emailNormalizado) != null) {
      throw EmailJaCadastradoException();
    }

    final salt = _gerarSalt();
    final usuario = Usuario(
      nome: nome.trim(),
      email: emailNormalizado,
      telefone: somenteDigitos(telefone),
      senhaHash: _hash(senha, salt),
      salt: salt,
      planoId: planoId,
      criadoEm: DateTime.now(),
    );

    try {
      final id = await _dao.inserir(usuario);
      return usuario.copyWith(id: id);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw EmailJaCadastradoException();
      rethrow;
    }
  }

  /// Retorna o usuário se as credenciais estiverem corretas, ou null.
  Future<Usuario?> entrar(String email, String senha) async {
    final usuario = await _dao.buscarPorEmail(_normalizar(email));
    if (usuario == null) return null;
    return _confere(usuario, senha) ? usuario : null;
  }

  Future<Usuario?> buscar(int id) => _dao.buscarPorId(id);

  Future<Usuario> atualizarPerfil(
    Usuario usuario, {
    required String nome,
    required String telefone,
  }) async {
    final atualizado = usuario.copyWith(
      nome: nome.trim(),
      telefone: somenteDigitos(telefone),
    );
    await _dao.atualizar(atualizado);
    return atualizado;
  }

  Future<Usuario> trocarPlano(Usuario usuario, int planoId) async {
    final atualizado = usuario.copyWith(planoId: planoId);
    await _dao.atualizar(atualizado);
    return atualizado;
  }

  Future<Usuario> alterarSenha(
    Usuario usuario, {
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (!_confere(usuario, senhaAtual)) throw SenhaIncorretaException();
    final salt = _gerarSalt();
    final atualizado = usuario.copyWith(salt: salt, senhaHash: _hash(novaSenha, salt));
    await _dao.atualizar(atualizado);
    return atualizado;
  }

  Future<void> excluirConta(Usuario usuario, String senha) async {
    if (!_confere(usuario, senha)) throw SenhaIncorretaException();
    await _dao.excluir(usuario.id!);
  }

  static String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

  bool _confere(Usuario usuario, String senha) =>
      _hash(senha, usuario.salt) == usuario.senhaHash;

  String _normalizar(String email) => email.trim().toLowerCase();

  String _gerarSalt() {
    final aleatorio = Random.secure();
    final bytes = List<int>.generate(16, (_) => aleatorio.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String senha, String salt) {
    return sha256.convert(utf8.encode('$salt$senha')).toString();
  }
}
