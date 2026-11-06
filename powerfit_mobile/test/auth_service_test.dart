import 'package:flutter_test/flutter_test.dart';
import 'package:powerfit_mobile/database/usuario_dao.dart';
import 'package:powerfit_mobile/models/usuario.dart';
import 'package:powerfit_mobile/services/auth_service.dart';

/// Substitui o SQLite por uma lista em memória durante os testes.
class UsuarioDaoMemoria implements UsuarioDao {
  final usuarios = <Usuario>[];

  @override
  Future<int> inserir(Usuario usuario) async {
    usuarios.add(usuario.copyWith(id: usuarios.length + 1));
    return usuarios.length;
  }

  @override
  Future<Usuario?> buscarPorEmail(String email) async =>
      usuarios.where((u) => u.email == email).firstOrNull;

  @override
  Future<Usuario?> buscarPorId(int id) async => usuarios.where((u) => u.id == id).firstOrNull;

  @override
  Future<void> atualizar(Usuario usuario) async {
    final i = usuarios.indexWhere((u) => u.id == usuario.id);
    usuarios[i] = usuario;
  }

  @override
  Future<void> excluir(int id) async => usuarios.removeWhere((u) => u.id == id);
}

void main() {
  late UsuarioDaoMemoria dao;
  late AuthService auth;

  Future<Usuario> cadastrarAna() => auth.cadastrar(
        nome: 'Ana Souza',
        email: ' Ana@Email.com ',
        telefone: '(11) 98765-4321',
        senha: 'segredo1',
        planoId: 4,
      );

  setUp(() {
    dao = UsuarioDaoMemoria();
    auth = AuthService(dao: dao);
  });

  test('cadastra e entra com as mesmas credenciais', () async {
    await cadastrarAna();

    final usuario = await auth.entrar('ana@email.com', 'segredo1');

    expect(usuario, isNotNull);
    expect(usuario!.nome, 'Ana Souza');
    expect(usuario.telefone, '11987654321');
    expect(usuario.planoId, 4);
    expect(dao.usuarios.single.senhaHash, isNot(contains('segredo1')));
  });

  test('recusa senha errada e e-mail inexistente', () async {
    await cadastrarAna();

    expect(await auth.entrar('ana@email.com', 'outra123'), isNull);
    expect(await auth.entrar('bia@email.com', 'segredo1'), isNull);
  });

  test('não permite cadastrar o mesmo e-mail duas vezes', () async {
    await cadastrarAna();

    expect(
      () => auth.cadastrar(
        nome: 'Outra Ana',
        email: 'ANA@email.com',
        telefone: '11999998888',
        senha: 'abcdef',
        planoId: 1,
      ),
      throwsA(isA<EmailJaCadastradoException>()),
    );
  });

  test('altera a senha só com a senha atual correta', () async {
    final ana = await cadastrarAna();

    expect(
      () => auth.alterarSenha(ana, senhaAtual: 'errada', novaSenha: 'nova123'),
      throwsA(isA<SenhaIncorretaException>()),
    );

    await auth.alterarSenha(ana, senhaAtual: 'segredo1', novaSenha: 'nova123');
    expect(await auth.entrar('ana@email.com', 'segredo1'), isNull);
    expect(await auth.entrar('ana@email.com', 'nova123'), isNotNull);
  });

  test('atualiza perfil, troca plano e exclui a conta', () async {
    var ana = await cadastrarAna();

    ana = await auth.atualizarPerfil(ana, nome: 'Ana S. Lima', telefone: '(21) 3333-4444');
    ana = await auth.trocarPlano(ana, 2);
    final salva = await auth.buscar(ana.id!);
    expect(salva!.nome, 'Ana S. Lima');
    expect(salva.telefone, '2133334444');
    expect(salva.planoId, 2);

    await auth.excluirConta(ana, 'segredo1');
    expect(await auth.buscar(ana.id!), isNull);
  });
}
