import '../models/usuario.dart';
import 'banco_local.dart';

/// Conta do aluno: tabela `usuario` do modelo e `app_perfil` (telefone e data).
class UsuarioDao {
  UsuarioDao({BancoLocal? banco}) : _banco = banco ?? BancoLocal.instancia;

  final BancoLocal _banco;

  static const _select = '''
    SELECT u.id_usuario, u.nome, u.email, u.senha, u.id_plano, p.telefone, p.criado_em
      FROM usuario u
      JOIN app_perfil p ON p.id_usuario = u.id_usuario
  ''';

  Future<int> inserir(Usuario usuario) async {
    final db = await _banco.database;
    return db.transaction((txn) async {
      final id = await txn.insert('usuario', usuario.toMap()..remove('id_usuario'));
      await txn.insert('app_perfil', {'id_usuario': id, ...usuario.perfilToMap()});
      return id;
    });
  }

  Future<Usuario?> buscarPorEmail(String email) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_select WHERE u.email = ?', [email]);
    return linhas.isEmpty ? null : Usuario.fromMap(linhas.first);
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_select WHERE u.id_usuario = ?', [id]);
    return linhas.isEmpty ? null : Usuario.fromMap(linhas.first);
  }

  Future<void> atualizar(Usuario usuario) async {
    final db = await _banco.database;
    await db.transaction((txn) async {
      final dados = usuario.toMap()
        ..remove('id_usuario')
        ..remove('email');
      await txn.update('usuario', dados, where: 'id_usuario = ?', whereArgs: [usuario.id]);
      await txn.update(
        'app_perfil',
        {'telefone': usuario.telefone},
        where: 'id_usuario = ?',
        whereArgs: [usuario.id],
      );
    });
  }

  /// Treinos, convidados e perfil do aluno são apagados junto (ON DELETE CASCADE).
  Future<void> excluir(int id) async {
    final db = await _banco.database;
    await db.delete('usuario', where: 'id_usuario = ?', whereArgs: [id]);
  }
}
