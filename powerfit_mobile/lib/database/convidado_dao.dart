import '../models/convidado.dart';
import 'banco_local.dart';

/// CRUD da tabela `convidado` do modelo.
class ConvidadoDao {
  ConvidadoDao({BancoLocal? banco}) : _banco = banco ?? BancoLocal.instancia;

  final BancoLocal _banco;

  Future<int> inserir(Convidado convidado) async {
    final db = await _banco.database;
    return db.insert('convidado', convidado.toMap()..remove('id_convidado'));
  }

  Future<List<Convidado>> listar(int usuarioId) async {
    final db = await _banco.database;
    final linhas = await db.query(
      'convidado',
      where: 'id_usuario = ?',
      whereArgs: [usuarioId],
      orderBy: 'data_visita DESC, id_convidado DESC',
    );
    return linhas.map(Convidado.fromMap).toList();
  }

  Future<void> atualizar(Convidado convidado) async {
    final db = await _banco.database;
    await db.update(
      'convidado',
      convidado.toMap()..remove('id_convidado'),
      where: 'id_convidado = ? AND id_usuario = ?',
      whereArgs: [convidado.id, convidado.usuarioId],
    );
  }

  Future<void> excluir(int id, int usuarioId) async {
    final db = await _banco.database;
    await db.delete(
      'convidado',
      where: 'id_convidado = ? AND id_usuario = ?',
      whereArgs: [id, usuarioId],
    );
  }

  /// Quantos convidados o aluno tem no mês ("2026-11"), sem contar [ignorarId].
  Future<int> contarNoMes(int usuarioId, String anoMes, {int? ignorarId}) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('''
      SELECT COUNT(*) AS total
        FROM convidado
       WHERE id_usuario = ?
         AND substr(data_visita, 1, 7) = ?
         AND id_convidado <> ?
    ''', [usuarioId, anoMes, ignorarId ?? -1]);
    return linhas.first['total'] as int;
  }
}
