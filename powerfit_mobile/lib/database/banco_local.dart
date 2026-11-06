import 'package:sqflite/sqflite.dart';

import 'dados_iniciais.dart';
import 'fabrica_banco.dart';

/// Abre o banco SQLite do aparelho uma única vez e o reutiliza.
///
/// As tabelas `plano`, `usuario`, `treino` e `convidado` seguem o modelo do
/// grupo. As tabelas `app_*` guardam o que só o aplicativo usa e não fazem
/// parte desse modelo.
class BancoLocal {
  BancoLocal._();

  /// Usa um banco já aberto (nos testes).
  BancoLocal.comBanco(Database db) : _db = db;

  static final BancoLocal instancia = BancoLocal._();

  static const versao = 2;

  Database? _db;

  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    return fabricaBanco.openDatabase(
      await caminhoBanco('powerfit.db'),
      options: OpenDatabaseOptions(
        version: versao,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => criarTabelas(db),
        onUpgrade: (db, anterior, _) async {
          if (anterior < 2) await migrarDaVersao1(db);
        },
      ),
    );
  }

  static Future<void> criarTabelas(DatabaseExecutor db) async {
    final lote = db.batch();
    for (final comando in [..._tabelasDoModelo, ..._tabelasDoApp]) {
      lote.execute(comando);
    }
    DadosIniciais.inserir(lote);
    await lote.commit(noResult: true);
  }

  /// Passa quem já usava o app para as tabelas do modelo, sem perder contas
  /// nem treinos registrados. Os ids de plano e de treino não mudaram.
  static Future<void> migrarDaVersao1(DatabaseExecutor db) async {
    const antigas = ['atividade', 'usuario', 'exercicio', 'treino', 'plano', 'modalidade', 'professor'];

    var lote = db.batch();
    for (final tabela in antigas) {
      lote.execute('ALTER TABLE $tabela RENAME TO antiga_$tabela');
    }
    await lote.commit(noResult: true);

    await criarTabelas(db);

    lote = db.batch();
    lote.execute('''
      INSERT INTO usuario (id_usuario, nome, email, senha, id_plano)
      SELECT id, nome, email, salt || ':' || senha_hash, plano_id FROM antiga_usuario
    ''');
    lote.execute('''
      INSERT INTO app_perfil (id_usuario, telefone, criado_em)
      SELECT id, telefone, criado_em FROM antiga_usuario
    ''');
    lote.execute('''
      INSERT INTO treino (id_treino, descricao, data_treino, duracao_minutos, id_usuario)
      SELECT id, titulo, substr(data, 1, 10), duracao_min, usuario_id FROM antiga_atividade
    ''');
    lote.execute('''
      INSERT INTO app_treino_detalhe (id_treino, id_ficha, intensidade, observacao)
      SELECT id, treino_id, intensidade, observacao FROM antiga_atividade
    ''');
    for (final tabela in antigas) {
      lote.execute('DROP TABLE antiga_$tabela');
    }
    await lote.commit(noResult: true);
  }

  /// Modelo do grupo, coluna por coluna. O SQLite exige INTEGER (e não INT)
  /// para a chave primária gerar o id sozinha.
  static const _tabelasDoModelo = [
    '''
    CREATE TABLE plano (
      id_plano INTEGER PRIMARY KEY,
      nome_plano VARCHAR(30) NOT NULL UNIQUE,
      duracao_meses INT NOT NULL CHECK (duracao_meses > 0),
      preco DECIMAL(10,2) NOT NULL CHECK (preco > 0)
    )''',
    '''
    CREATE TABLE usuario (
      id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
      nome VARCHAR(100) NOT NULL,
      email VARCHAR(100) NOT NULL UNIQUE,
      senha VARCHAR(255) NOT NULL,
      id_plano INT NOT NULL REFERENCES plano (id_plano)
    )''',
    '''
    CREATE TABLE treino (
      id_treino INTEGER PRIMARY KEY AUTOINCREMENT,
      descricao VARCHAR(150) NOT NULL,
      data_treino DATE NOT NULL,
      duracao_minutos INT NOT NULL CHECK (duracao_minutos > 0),
      id_usuario INT NOT NULL REFERENCES usuario (id_usuario) ON DELETE CASCADE
    )''',
    '''
    CREATE TABLE convidado (
      id_convidado INTEGER PRIMARY KEY AUTOINCREMENT,
      nome VARCHAR(100) NOT NULL,
      data_visita DATE NOT NULL,
      id_usuario INT NOT NULL REFERENCES usuario (id_usuario) ON DELETE CASCADE
    )''',
    'CREATE INDEX idx_treino_usuario_data ON treino (id_usuario, data_treino)',
    'CREATE INDEX idx_convidado_usuario_data ON convidado (id_usuario, data_visita)',
  ];

  static const _tabelasDoApp = [
    '''
    CREATE TABLE app_perfil (
      id_usuario INTEGER PRIMARY KEY REFERENCES usuario (id_usuario) ON DELETE CASCADE,
      telefone TEXT NOT NULL,
      criado_em TEXT NOT NULL
    )''',
    '''
    CREATE TABLE app_plano (
      id_plano INTEGER PRIMARY KEY REFERENCES plano (id_plano),
      descricao TEXT NOT NULL,
      beneficios TEXT NOT NULL,
      recomendado INTEGER NOT NULL DEFAULT 0,
      limite_convidados INTEGER NOT NULL DEFAULT 0
    )''',
    '''
    CREATE TABLE app_modalidade (
      id INTEGER PRIMARY KEY,
      nome TEXT NOT NULL UNIQUE,
      resumo TEXT NOT NULL,
      descricao TEXT NOT NULL,
      imagem TEXT NOT NULL
    )''',
    '''
    CREATE TABLE app_professor (
      id INTEGER PRIMARY KEY,
      nome TEXT NOT NULL,
      especialidade TEXT NOT NULL,
      cref TEXT NOT NULL UNIQUE,
      foto TEXT NOT NULL
    )''',
    '''
    CREATE TABLE app_ficha (
      id INTEGER PRIMARY KEY,
      letra TEXT NOT NULL,
      nome TEXT NOT NULL,
      foco TEXT NOT NULL,
      nivel TEXT NOT NULL,
      duracao_min INTEGER NOT NULL,
      imagem TEXT,
      modalidade_id INTEGER NOT NULL REFERENCES app_modalidade (id),
      professor_id INTEGER NOT NULL REFERENCES app_professor (id)
    )''',
    '''
    CREATE TABLE app_exercicio (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_ficha INTEGER NOT NULL REFERENCES app_ficha (id) ON DELETE CASCADE,
      ordem INTEGER NOT NULL,
      nome TEXT NOT NULL,
      series INTEGER NOT NULL CHECK (series > 0),
      repeticoes TEXT NOT NULL,
      carga TEXT NOT NULL,
      descanso_seg INTEGER NOT NULL DEFAULT 60
    )''',
    '''
    CREATE TABLE app_treino_detalhe (
      id_treino INTEGER PRIMARY KEY REFERENCES treino (id_treino) ON DELETE CASCADE,
      id_ficha INTEGER REFERENCES app_ficha (id) ON DELETE SET NULL,
      intensidade INTEGER NOT NULL CHECK (intensidade BETWEEN 1 AND 3),
      observacao TEXT NOT NULL DEFAULT ''
    )''',
  ];
}
