import 'package:sqflite/sqflite.dart';

import '../models/atividade.dart';
import 'banco_local.dart';

/// CRUD dos treinos registrados pelo aluno: tabela `treino` do modelo
/// e `app_treino_detalhe` (ficha usada, intensidade e observação).
class AtividadeDao {
  AtividadeDao({BancoLocal? banco}) : _banco = banco ?? BancoLocal.instancia;

  final BancoLocal _banco;

  Future<int> inserir(Atividade atividade) async {
    final db = await _banco.database;
    return db.transaction((txn) async {
      final id = await txn.insert('treino', atividade.toMap()..remove('id_treino'));
      await txn.insert('app_treino_detalhe', {'id_treino': id, ...atividade.detalheToMap()});
      return id;
    });
  }

  Future<List<Atividade>> listar(int usuarioId) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('''
      SELECT t.id_treino, t.descricao, t.data_treino, t.duracao_minutos, t.id_usuario,
             d.id_ficha, d.intensidade, d.observacao, f.letra
        FROM treino t
        LEFT JOIN app_treino_detalhe d ON d.id_treino = t.id_treino
        LEFT JOIN app_ficha f ON f.id = d.id_ficha
       WHERE t.id_usuario = ?
       ORDER BY t.data_treino DESC, t.id_treino DESC
    ''', [usuarioId]);
    return linhas.map(Atividade.fromMap).toList();
  }

  Future<void> atualizar(Atividade atividade) async {
    final db = await _banco.database;
    await db.transaction((txn) async {
      await txn.update(
        'treino',
        atividade.toMap()..remove('id_treino'),
        where: 'id_treino = ? AND id_usuario = ?',
        whereArgs: [atividade.id, atividade.usuarioId],
      );
      await txn.insert(
        'app_treino_detalhe',
        {'id_treino': atividade.id, ...atividade.detalheToMap()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// O detalhe é apagado junto (ON DELETE CASCADE).
  Future<void> excluir(int id, int usuarioId) async {
    final db = await _banco.database;
    await db.delete(
      'treino',
      where: 'id_treino = ? AND id_usuario = ?',
      whereArgs: [id, usuarioId],
    );
  }
}
