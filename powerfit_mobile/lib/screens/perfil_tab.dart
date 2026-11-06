import 'package:flutter/material.dart';

import '../models/catalogo.dart';
import '../database/atividade_dao.dart';
import '../database/catalogo_dao.dart';
import '../services/auth_service.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../widgets/componentes.dart';
import 'conta_screens.dart';
import 'convidados_screen.dart';
import 'login_screen.dart';
import 'planos_screen.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  final _auth = AuthService();
  Plano? _plano;
  int _totalTreinos = 0;
  int _totalMinutos = 0;

  @override
  void initState() {
    super.initState();
    widget.sessao.addListener(_carregar);
    _carregar();
  }

  @override
  void dispose() {
    widget.sessao.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    final u = widget.sessao.usuario;
    final plano = await CatalogoDao().plano(u.planoId);
    final atividades = await AtividadeDao().listar(u.id!);
    if (!mounted) return;
    setState(() {
      _plano = plano;
      _totalTreinos = atividades.length;
      _totalMinutos = atividades.fold(0, (s, a) => s + a.duracaoMin);
    });
  }

  void _abrir(Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  Future<void> _sair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará informar e-mail e senha novamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirmou != true) return;
    await SessaoAluno.esquecer();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _excluirConta() async {
    final senha = TextEditingController();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sua conta e todo o histórico de atividades serão apagados deste aparelho. Isso não pode ser desfeito.'),
            const SizedBox(height: 16),
            TextField(
              controller: senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirme sua senha'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(c).colorScheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    final digitada = senha.text;
    senha.dispose();
    if (confirmou != true || !mounted) return;

    try {
      await _auth.excluirConta(widget.sessao.usuario, digitada);
      await SessaoAluno.esquecer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta excluída.')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on SenhaIncorretaException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta. A conta não foi excluída.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.sessao.usuario;
    final plano = _plano;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Row(
            children: [
              AvatarIniciais(u.iniciais, tamanho: 76),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.nome, style: estiloTitulo(28)),
                    Text(u.email, style: const TextStyle(color: CoresPowerFit.cinza)),
                    const SizedBox(height: 2),
                    Text(
                      'Aluno desde ${Formatos.data(u.criadoEm)}',
                      style: const TextStyle(color: CoresPowerFit.cinzaClaro, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Indicador(valor: '$_totalTreinos', rotulo: 'treinos registrados')),
              const SizedBox(width: 12),
              Expanded(child: _Indicador(valor: Formatos.duracao(_totalMinutos), rotulo: 'de treino no total')),
            ],
          ),
          const SizedBox(height: 20),
          if (plano != null) _CartaoPlano(plano: plano, aoTrocar: () => _abrir(PlanosScreen(sessao: widget.sessao))),
          const SizedBox(height: 24),
          Text('Conta', style: estiloTitulo(22, peso: FontWeight.w700)),
          const SizedBox(height: 10),
          Cartao(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Opcao(
                  icone: Icons.badge_outlined,
                  titulo: 'Meus dados',
                  subtitulo: '${u.nome} · ${Formatos.telefone(u.telefone)}',
                  aoTocar: () => _abrir(EditarPerfilScreen(sessao: widget.sessao)),
                ),
                const Divider(indent: 60),
                _Opcao(
                  icone: Icons.lock_outline,
                  titulo: 'Alterar senha',
                  aoTocar: () => _abrir(AlterarSenhaScreen(sessao: widget.sessao)),
                ),
                const Divider(indent: 60),
                _Opcao(
                  icone: Icons.card_membership_outlined,
                  titulo: 'Planos',
                  subtitulo: 'Compare e troque seu plano',
                  aoTocar: () => _abrir(PlanosScreen(sessao: widget.sessao)),
                ),
                const Divider(indent: 60),
                _Opcao(
                  icone: Icons.group_add_outlined,
                  titulo: 'Convidados',
                  subtitulo: 'Traga alguém para treinar com você',
                  aoTocar: () => _abrir(ConvidadosScreen(sessao: widget.sessao)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Cartao(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Opcao(icone: Icons.logout, titulo: 'Sair', aoTocar: _sair),
                const Divider(indent: 60),
                _Opcao(
                  icone: Icons.delete_forever_outlined,
                  titulo: 'Excluir conta',
                  perigo: true,
                  aoTocar: _excluirConta,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PowerFit Academia · projeto acadêmico\nTrabalho Integrador — Java Web, Flutter e Banco de Dados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: CoresPowerFit.cinzaClaro, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: estiloTitulo(30)),
          Text(rotulo, style: const TextStyle(fontSize: 12, color: CoresPowerFit.cinza)),
        ],
      ),
    );
  }
}

class _CartaoPlano extends StatelessWidget {
  const _CartaoPlano({required this.plano, required this.aoTrocar});

  final Plano plano;
  final VoidCallback aoTrocar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CoresPowerFit.tinta,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SEU PLANO',
                style: TextStyle(color: CoresPowerFit.destaque, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.4),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: Formatos.moeda(plano.precoMensal), style: estiloTitulo(26, cor: Colors.white)),
                    const TextSpan(text: ' /mês', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          Text(plano.nome, style: estiloTitulo(32, cor: Colors.white)),
          const SizedBox(height: 12),
          for (final b in plano.beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: CoresPowerFit.destaque),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b, style: const TextStyle(color: Colors.white))),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: aoTrocar,
            style: OutlinedButton.styleFrom(
              foregroundColor: CoresPowerFit.destaque,
              side: const BorderSide(color: CoresPowerFit.destaque, width: 1.5),
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text('Trocar plano'),
          ),
        ],
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({
    required this.icone,
    required this.titulo,
    required this.aoTocar,
    this.subtitulo,
    this.perigo = false,
  });

  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final VoidCallback aoTocar;
  final bool perigo;

  @override
  Widget build(BuildContext context) {
    final cor = perigo ? Theme.of(context).colorScheme.error : CoresPowerFit.tinta;
    return ListTile(
      onTap: aoTocar,
      leading: Icon(icone, color: cor),
      title: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, color: cor)),
      subtitle: subtitulo == null
          ? null
          : Text(subtitulo!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: perigo ? null : const Icon(Icons.chevron_right),
    );
  }
}
