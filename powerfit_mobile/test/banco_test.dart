import 'package:flutter_test/flutter_test.dart';
import 'package:powerfit_mobile/database/atividade_dao.dart';
import 'package:powerfit_mobile/database/banco_local.dart';
import 'package:powerfit_mobile/database/catalogo_dao.dart';
import 'package:powerfit_mobile/database/convidado_dao.dart';
import 'package:powerfit_mobile/database/usuario_dao.dart';
import 'package:powerfit_mobile/models/atividade.dart';
import 'package:powerfit_mobile/models/convidado.dart';
import 'package:powerfit_mobile/services/auth_service.dart';
import 'package:powerfit_mobile/services/convidado_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Testes com um SQLite de verdade, em memória.
void main() {
  sqfliteFfiInit();

  Future<Database> abrir({required Future<void> Function(Database) criar}) {
    return databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => criar(db),
      ),
    );
  }

  group('modelo do grupo', () {
    late Database db;
    late BancoLocal banco;
    late AuthService auth;

    setUp(() async {
      db = await abrir(criar: BancoLocal.criarTabelas);
      banco = BancoLocal.comBanco(db);
      auth = AuthService(dao: UsuarioDao(banco: banco));
    });

    tearDown(() => db.close());

    Future<List<String>> colunas(String tabela) async {
      final linhas = await db.rawQuery('PRAGMA table_info($tabela)');
      return linhas.map((l) => l['name'] as String).toList();
    }

    Future<int> cadastrar() async {
      final u = await auth.cadastrar(
        nome: 'Ana Souza',
        email: 'ana@email.com',
        telefone: '11987654321',
        senha: 'segredo1',
        planoId: 2,
      );
      return u.id!;
    }

    test('as quatro tabelas têm exatamente as colunas do diagrama', () async {
      expect(await colunas('plano'), ['id_plano', 'nome_plano', 'duracao_meses', 'preco']);
      expect(await colunas('usuario'), ['id_usuario', 'nome', 'email', 'senha', 'id_plano']);
      expect(await colunas('treino'),
          ['id_treino', 'descricao', 'data_treino', 'duracao_minutos', 'id_usuario']);
      expect(await colunas('convidado'), ['id_convidado', 'nome', 'data_visita', 'id_usuario']);
    });

    test('os planos do site continuam completos', () async {
      final planos = await CatalogoDao(banco: banco).planos();
      expect(planos.map((p) => p.nomeCurto), ['Mensal', 'Trimestral', 'Semestral', 'Anual']);
      expect(planos.map((p) => p.limiteConvidados), [0, 1, 1, 2]);
      expect(planos.last.precoMensal, 89);
      expect(planos.last.precoTotal, 1068);
      expect(planos.last.beneficios, contains('2 convidados por mês'));
    });

    test('a coluna senha guarda o hash e o login funciona', () async {
      await cadastrar();

      final linha = (await db.query('usuario')).single;
      expect(linha['senha'] as String, isNot(contains('segredo1')));

      final entrou = await auth.entrar('ana@email.com', 'segredo1');
      expect(entrou!.telefone, '11987654321');
      expect(await auth.entrar('ana@email.com', 'errada'), isNull);
    });

    test('e-mail repetido é recusado pelo banco', () async {
      await cadastrar();
      await expectLater(
        UsuarioDao(banco: banco).inserir((await auth.entrar('ana@email.com', 'segredo1'))!),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('CRUD de treino registrado grava na tabela treino', () async {
      final id = await cadastrar();
      final dao = AtividadeDao(banco: banco);

      final novo = await dao.inserir(Atividade(
        usuarioId: id,
        treinoId: 1,
        titulo: 'Treino A · Peito, ombro e tríceps',
        data: DateTime(2026, 11, 5, 18, 30),
        duracaoMin: 55,
        intensidade: Intensidade.intensa,
        observacao: 'Subi a carga.',
      ));

      final linha = (await db.query('treino')).single;
      expect(linha['data_treino'], '2026-11-05');
      expect(linha['duracao_minutos'], 55);

      var lido = (await dao.listar(id)).single;
      expect(lido.letraTreino, 'A');
      expect(lido.intensidade, Intensidade.intensa);
      expect(lido.observacao, 'Subi a carga.');

      await dao.atualizar(Atividade(
        id: novo,
        usuarioId: id,
        titulo: 'Corrida',
        data: DateTime(2026, 11, 4),
        duracaoMin: 30,
        intensidade: Intensidade.leve,
      ));
      lido = (await dao.listar(id)).single;
      expect(lido.titulo, 'Corrida');
      expect(lido.treinoId, isNull);
      expect(lido.data, DateTime(2026, 11, 4));

      await dao.excluir(novo, id);
      expect(await dao.listar(id), isEmpty);
      expect(await db.query('app_treino_detalhe'), isEmpty);
    });

    test('limite de convidados vale por mês e ignora o próprio registro', () async {
      final id = await cadastrar();
      final dao = ConvidadoDao(banco: banco);
      final service = ConvidadoService(dao: dao);

      await service.salvar(
        Convidado(nome: 'Bia', dataVisita: DateTime(2026, 11, 10), usuarioId: id),
        limitePorMes: 1,
      );

      await expectLater(
        service.salvar(
          Convidado(nome: 'Caio', dataVisita: DateTime(2026, 11, 20), usuarioId: id),
          limitePorMes: 1,
        ),
        throwsA(isA<LimiteConvidadosException>()),
      );

      await service.salvar(
        Convidado(nome: 'Caio', dataVisita: DateTime(2026, 12, 1), usuarioId: id),
        limitePorMes: 1,
      );

      final bia = (await dao.listar(id)).last;
      await service.salvar(
        Convidado(id: bia.id, nome: 'Bia Lima', dataVisita: DateTime(2026, 11, 11), usuarioId: id),
        limitePorMes: 1,
      );
      expect((await dao.listar(id)).last.nome, 'Bia Lima');

      await expectLater(
        service.salvar(
          Convidado(nome: 'Dani', dataVisita: DateTime(2026, 11, 1), usuarioId: id),
          limitePorMes: 0,
        ),
        throwsA(isA<LimiteConvidadosException>()),
      );
    });

    test('excluir a conta apaga treinos, convidados e perfil', () async {
      final id = await cadastrar();
      await AtividadeDao(banco: banco).inserir(Atividade(
        usuarioId: id,
        titulo: 'Corrida',
        data: DateTime(2026, 11, 5),
        duracaoMin: 30,
        intensidade: Intensidade.leve,
      ));
      await ConvidadoDao(banco: banco)
          .inserir(Convidado(nome: 'Bia', dataVisita: DateTime(2026, 11, 5), usuarioId: id));

      await UsuarioDao(banco: banco).excluir(id);

      for (final tabela in ['usuario', 'app_perfil', 'treino', 'app_treino_detalhe', 'convidado']) {
        expect(await db.query(tabela), isEmpty, reason: tabela);
      }
    });

    test('todas as fichas de treino abrem com exercícios', () async {
      final catalogo = CatalogoDao(banco: banco);
      final fichas = await catalogo.treinos();
      expect(fichas.map((f) => f.letra), ['A', 'B', 'C', 'D', 'E', 'F']);
      for (final f in fichas) {
        final completa = await catalogo.treinoCompleto(f.id);
        expect(completa!.exercicios, hasLength(f.quantidadeExercicios));
        expect(completa.exercicios, isNotEmpty);
      }
    });
  });

  test('quem já usava o app mantém a conta e os treinos', () async {
    final db = await abrir(criar: _criarBancoVersao1);
    addTearDown(db.close);

    await db.transaction((txn) => BancoLocal.migrarDaVersao1(txn));

    final banco = BancoLocal.comBanco(db);
    final auth = AuthService(dao: UsuarioDao(banco: banco));

    final usuario = await auth.entrar('ana@email.com', 'senha123');
    expect(usuario, isNotNull);
    expect(usuario!.nome, 'Ana Souza');
    expect(usuario.telefone, '11987654321');
    expect(usuario.planoId, 4);
    expect(usuario.criadoEm, DateTime.parse('2026-10-11T17:00:00.000'));

    final atividade = (await AtividadeDao(banco: banco).listar(usuario.id!)).single;
    expect(atividade.titulo, 'Treino C · Pernas e glúteos');
    expect(atividade.letraTreino, 'C');
    expect(atividade.data, DateTime(2026, 10, 11));
    expect(atividade.duracaoMin, 60);
    expect(atividade.intensidade, Intensidade.intensa);
    expect(atividade.observacao, 'Boa');

    final tabelas = await db.rawQuery("SELECT name FROM sqlite_master WHERE name LIKE 'antiga_%'");
    expect(tabelas, isEmpty);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });
}

/// O banco como estava antes de seguir o modelo do grupo (conta com senha
/// "senha123", hash calculado por AuthService).
Future<void> _criarBancoVersao1(Database db) async {
  const comandos = [
    '''CREATE TABLE plano (id INTEGER PRIMARY KEY, nome TEXT NOT NULL UNIQUE, meses INTEGER NOT NULL,
       preco_mensal REAL NOT NULL, descricao TEXT NOT NULL, beneficios TEXT NOT NULL,
       recomendado INTEGER NOT NULL DEFAULT 0)''',
    '''CREATE TABLE modalidade (id INTEGER PRIMARY KEY, nome TEXT NOT NULL UNIQUE, resumo TEXT NOT NULL,
       descricao TEXT NOT NULL, imagem TEXT NOT NULL)''',
    '''CREATE TABLE professor (id INTEGER PRIMARY KEY, nome TEXT NOT NULL, especialidade TEXT NOT NULL,
       cref TEXT NOT NULL UNIQUE, foto TEXT NOT NULL)''',
    '''CREATE TABLE usuario (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
       telefone TEXT NOT NULL, senha_hash TEXT NOT NULL, salt TEXT NOT NULL,
       plano_id INTEGER NOT NULL REFERENCES plano (id), criado_em TEXT NOT NULL)''',
    '''CREATE TABLE treino (id INTEGER PRIMARY KEY, letra TEXT NOT NULL, nome TEXT NOT NULL, foco TEXT NOT NULL,
       nivel TEXT NOT NULL, duracao_min INTEGER NOT NULL, imagem TEXT,
       modalidade_id INTEGER NOT NULL REFERENCES modalidade (id),
       professor_id INTEGER NOT NULL REFERENCES professor (id))''',
    '''CREATE TABLE exercicio (id INTEGER PRIMARY KEY AUTOINCREMENT,
       treino_id INTEGER NOT NULL REFERENCES treino (id) ON DELETE CASCADE, ordem INTEGER NOT NULL,
       nome TEXT NOT NULL, series INTEGER NOT NULL, repeticoes TEXT NOT NULL, carga TEXT NOT NULL,
       descanso_seg INTEGER NOT NULL DEFAULT 60)''',
    '''CREATE TABLE atividade (id INTEGER PRIMARY KEY AUTOINCREMENT,
       usuario_id INTEGER NOT NULL REFERENCES usuario (id) ON DELETE CASCADE,
       treino_id INTEGER REFERENCES treino (id) ON DELETE SET NULL, titulo TEXT NOT NULL, data TEXT NOT NULL,
       duracao_min INTEGER NOT NULL, intensidade INTEGER NOT NULL, observacao TEXT NOT NULL DEFAULT '')''',
    'CREATE INDEX idx_atividade_usuario_data ON atividade (usuario_id, data)',
    "INSERT INTO plano VALUES (4, 'Plano Anual', 12, 89, 'x', 'x', 1)",
    "INSERT INTO modalidade VALUES (1, 'Musculação', 'x', 'x', 'x')",
    "INSERT INTO professor VALUES (1, 'Gustavo', 'x', 'CREF 1', 'x')",
    "INSERT INTO treino VALUES (3, 'C', 'Pernas', 'x', 'x', 60, NULL, 1, 1)",
    "INSERT INTO exercicio (treino_id, ordem, nome, series, repeticoes, carga) VALUES (3, 1, 'x', 1, '1', 'x')",
    '''INSERT INTO usuario VALUES (7, 'Ana Souza', 'ana@email.com', '11987654321',
       '83af0e59ecd6641a3b44299e83346d8652b73775226d49c986514395bb9d4228', 'saltfixo', 4, '2026-10-11T17:00:00.000')''',
    '''INSERT INTO atividade VALUES (5, 7, 3, 'Treino C · Pernas e glúteos', '2026-10-11T17:30:00.000',
       60, 3, 'Boa')''',
  ];
  for (final c in comandos) {
    await db.execute(c);
  }
}
