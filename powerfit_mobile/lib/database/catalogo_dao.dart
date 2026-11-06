import '../models/catalogo.dart';
import '../models/treino.dart';
import 'banco_local.dart';

/// Consultas do conteúdo da academia: planos, modalidades, professores e fichas.
class CatalogoDao {
  CatalogoDao({BancoLocal? banco}) : _banco = banco ?? BancoLocal.instancia;

  final BancoLocal _banco;

  static const _selectPlano = '''
    SELECT p.id_plano, p.nome_plano, p.duracao_meses, p.preco,
           d.descricao, d.beneficios, d.recomendado, d.limite_convidados
      FROM plano p
      JOIN app_plano d ON d.id_plano = p.id_plano
  ''';

  Future<List<Plano>> planos() async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_selectPlano ORDER BY p.duracao_meses');
    return linhas.map(Plano.fromMap).toList();
  }

  Future<Plano?> plano(int id) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_selectPlano WHERE p.id_plano = ?', [id]);
    return linhas.isEmpty ? null : Plano.fromMap(linhas.first);
  }

  Future<List<Modalidade>> modalidades() async {
    final db = await _banco.database;
    final linhas = await db.query('app_modalidade', orderBy: 'id');
    return linhas.map(Modalidade.fromMap).toList();
  }

  Future<List<Professor>> professores() async {
    final db = await _banco.database;
    final linhas = await db.query('app_professor', orderBy: 'nome');
    return linhas.map(Professor.fromMap).toList();
  }

  static const _selectTreino = '''
    SELECT t.id, t.letra, t.nome, t.foco, t.nivel, t.duracao_min,
           m.nome AS modalidade, COALESCE(t.imagem, m.imagem) AS imagem,
           p.nome AS professor, p.foto AS foto_professor,
           (SELECT COUNT(*) FROM app_exercicio e WHERE e.id_ficha = t.id) AS qtd_exercicios
      FROM app_ficha t
      JOIN app_modalidade m ON m.id = t.modalidade_id
      JOIN app_professor p ON p.id = t.professor_id
  ''';

  Future<List<Treino>> treinos() async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_selectTreino ORDER BY t.letra');
    return linhas.map(Treino.fromMap).toList();
  }

  /// Ficha com a lista de exercícios na ordem de execução.
  Future<Treino?> treinoCompleto(int id) async {
    final db = await _banco.database;
    final linhas = await db.rawQuery('$_selectTreino WHERE t.id = ?', [id]);
    if (linhas.isEmpty) return null;
    final exercicios = await db.query(
      'app_exercicio',
      where: 'id_ficha = ?',
      whereArgs: [id],
      orderBy: 'ordem',
    );
    return Treino.fromMap(linhas.first)
        .comExercicios(exercicios.map(Exercicio.fromMap).toList());
  }
}
