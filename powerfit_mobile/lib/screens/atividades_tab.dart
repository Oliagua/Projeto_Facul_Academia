import 'package:flutter/material.dart';

import '../database/atividade_dao.dart';
import '../models/atividade.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../widgets/componentes.dart';
import 'atividade_form_screen.dart';

class AtividadesTab extends StatefulWidget {
  const AtividadesTab({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<AtividadesTab> createState() => _AtividadesTabState();
}

class _AtividadesTabState extends State<AtividadesTab> {
  final _dao = AtividadeDao();
  List<Atividade>? _atividades;
  int _versaoCarregada = -1;

  @override
  void initState() {
    super.initState();
    widget.sessao.addListener(_aoMudarSessao);
    _carregar();
  }

  @override
  void dispose() {
    widget.sessao.removeListener(_aoMudarSessao);
    super.dispose();
  }

  void _aoMudarSessao() {
    if (widget.sessao.versaoAtividades != _versaoCarregada) _carregar();
  }

  Future<void> _carregar() async {
    _versaoCarregada = widget.sessao.versaoAtividades;
    final lista = await _dao.listar(widget.sessao.usuario.id!);
    if (mounted) setState(() => _atividades = lista);
  }

  Future<void> _excluirComDesfazer(Atividade atividade) async {
    await _dao.excluir(atividade.id!, atividade.usuarioId);
    widget.sessao.atividadesMudaram();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Atividade excluída.'),
          duration: const Duration(seconds: 5),
          persist: false,
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              await _dao.inserir(atividade);
              widget.sessao.atividadesMudaram();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final atividades = _atividades;
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'registrar',
        onPressed: () => abrirFormularioAtividade(context, widget.sessao),
        icon: const Icon(Icons.add),
        label: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: atividades == null
          ? const Center(child: CircularProgressIndicator())
          : atividades.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: EstadoVazio(
                      icone: Icons.event_available_outlined,
                      titulo: 'Nenhum treino registrado',
                      texto: 'Registre cada treino que você fizer para acompanhar sua evolução e manter a sequência.',
                      acao: SizedBox(
                        width: 240,
                        child: BotaoPrincipal(
                          texto: 'Registrar primeiro treino',
                          aoPressionar: () => abrirFormularioAtividade(context, widget.sessao),
                        ),
                      ),
                    ),
                  ),
                )
              : _lista(atividades),
    );
  }

  Widget _lista(List<Atividade> atividades) {
    final agora = DateTime.now();
    final doMes = atividades.where((a) => a.data.year == agora.year && a.data.month == agora.month);
    final minutosMes = doMes.fold<int>(0, (s, a) => s + a.duracaoMin);

    // Agrupa por dia, mantendo a ordem (mais recentes primeiro).
    final grupos = <String, List<Atividade>>{};
    for (final a in atividades) {
      grupos.putIfAbsent(Formatos.diaRelativo(a.data), () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _Resumo(valor: '${doMes.length}', rotulo: 'treinos no mês')),
              const SizedBox(width: 12),
              Expanded(child: _Resumo(valor: '$minutosMes', rotulo: 'min no mês')),
              const SizedBox(width: 12),
              Expanded(child: _Resumo(valor: '${atividades.length}', rotulo: 'no total')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toque para editar · deslize para excluir',
          style: TextStyle(fontSize: 12, color: CoresPowerFit.cinzaClaro),
        ),
        for (final grupo in grupos.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(grupo.key, style: estiloTitulo(20, peso: FontWeight.w700)),
          ),
          for (final a in grupo.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey('atividade-${a.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => confirmarExclusaoAtividade(context),
                onDismissed: (_) {
                  setState(() => _atividades!.remove(a));
                  _excluirComDesfazer(a);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: _ItemAtividade(
                  atividade: a,
                  aoTocar: () => abrirFormularioAtividade(context, widget.sessao, atividade: a),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: CoresPowerFit.tinta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: estiloTitulo(28, cor: CoresPowerFit.destaque)),
          Text(rotulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ItemAtividade extends StatelessWidget {
  const _ItemAtividade({required this.atividade, required this.aoTocar});

  final Atividade atividade;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final a = atividade;
    final corIntensidade = switch (a.intensidade) {
      Intensidade.leve => const Color(0xFF4CAF50),
      Intensidade.moderada => CoresPowerFit.destaque,
      Intensidade.intensa => const Color(0xFFE65100),
    };

    return Cartao(
      aoTocar: aoTocar,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          a.letraTreino != null
              ? SeloLetra(a.letraTreino!, tamanho: 44)
              : Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: CoresPowerFit.destaqueSuave, shape: BoxShape.circle),
                  child: const Icon(Icons.directions_run, color: CoresPowerFit.tinta),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    InfoPequena(Icons.timer_outlined, '${a.duracaoMin} min'),
                    InfoPequena(Icons.bolt, a.intensidade.rotulo, cor: corIntensidade),
                  ],
                ),
                if (a.observacao.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    a.observacao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: CoresPowerFit.cinza, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: CoresPowerFit.cinzaClaro),
        ],
      ),
    );
  }
}
