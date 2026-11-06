import 'package:flutter/material.dart';

import '../database/catalogo_dao.dart';
import '../models/treino.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../widgets/componentes.dart';
import 'atividade_form_screen.dart';

/// Detalhe do treino. O aluno pode marcar os exercícios enquanto treina
/// e, no fim, registrar o treino como atividade.
class TreinoDetalheScreen extends StatefulWidget {
  const TreinoDetalheScreen({super.key, required this.treinoId, required this.sessao});

  final int treinoId;
  final SessaoAluno sessao;

  @override
  State<TreinoDetalheScreen> createState() => _TreinoDetalheScreenState();
}

class _TreinoDetalheScreenState extends State<TreinoDetalheScreen> {
  late final Future<Treino?> _treino = CatalogoDao().treinoCompleto(widget.treinoId);
  final _feitos = <int>{};
  final _rolagem = ScrollController();

  /// O título só aparece na barra quando a foto do topo já foi recolhida.
  bool _recolhido = false;

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(() {
      final recolhido = _rolagem.offset > 170;
      if (recolhido != _recolhido) setState(() => _recolhido = recolhido);
    });
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  Future<void> _registrar(Treino treino) async {
    final salvou = await abrirFormularioAtividade(context, widget.sessao, treino: treino);
    if (salvou && mounted) setState(_feitos.clear);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Treino?>(
      future: _treino,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final treino = snap.data;
        if (treino == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Treino não encontrado.')));
        }
        final total = treino.exercicios.length;
        final progresso = total == 0 ? 0.0 : _feitos.length / total;

        return Scaffold(
          body: CustomScrollView(
            controller: _rolagem,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                backgroundColor: CoresPowerFit.tinta,
                foregroundColor: Colors.white,
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _recolhido ? 1 : 0,
                  child: Text(treino.titulo, style: estiloTitulo(22, cor: Colors.white)),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Foto(treino.imagem, raio: 0, degrade: true),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        // Some aos poucos enquanto o topo recolhe, para não ficar cortado.
                        child: AnimatedBuilder(
                          animation: _rolagem,
                          builder: (context, filho) {
                            final deslocamento = _rolagem.hasClients ? _rolagem.offset : 0.0;
                            return Opacity(
                              opacity: (1 - deslocamento / 120).clamp(0.0, 1.0),
                              child: filho,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SeloLetra(treino.letra, tamanho: 30),
                                  const SizedBox(width: 8),
                                  Etiqueta(treino.modalidade),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(treino.nome, style: estiloTitulo(36, cor: Colors.white)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 14,
                                children: [
                                  InfoPequena(Icons.timer_outlined, '${treino.duracaoMin} min', cor: Colors.white),
                                  InfoPequena(Icons.track_changes, treino.foco, cor: Colors.white),
                                  InfoPequena(Icons.signal_cellular_alt, treino.nivel, cor: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverList.list(
                  children: [
                    Cartao(
                      child: Row(
                        children: [
                          CircleAvatar(radius: 24, backgroundImage: AssetImage(treino.fotoProfessor)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Montado por', style: TextStyle(fontSize: 12, color: CoresPowerFit.cinza)),
                                Text(treino.professor, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified, color: CoresPowerFit.destaque),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Text('Exercícios', style: estiloTitulo(26))),
                        Text(
                          '${_feitos.length} de $total feitos',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: CoresPowerFit.cinza),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 8,
                        backgroundColor: CoresPowerFit.linha,
                        color: CoresPowerFit.destaque,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toque em um exercício para marcá-lo como feito.',
                      style: TextStyle(fontSize: 12, color: CoresPowerFit.cinzaClaro),
                    ),
                    const SizedBox(height: 14),
                    for (final e in treino.exercicios)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ItemExercicio(
                          exercicio: e,
                          feito: _feitos.contains(e.id),
                          aoTocar: () => setState(() {
                            if (!_feitos.remove(e.id)) _feitos.add(e.id);
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: BotaoPrincipal(
              texto: progresso == 1 ? 'Concluir e registrar treino' : 'Registrar treino',
              icone: Icons.check_circle_outline,
              aoPressionar: () => _registrar(treino),
            ),
          ),
        );
      },
    );
  }
}

class _ItemExercicio extends StatelessWidget {
  const _ItemExercicio({required this.exercicio, required this.feito, required this.aoTocar});

  final Exercicio exercicio;
  final bool feito;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final e = exercicio;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: feito ? 0.6 : 1,
      child: Cartao(
        aoTocar: aoTocar,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: feito ? CoresPowerFit.sucesso : CoresPowerFit.tinta,
                shape: BoxShape.circle,
              ),
              child: feito
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text('${e.ordem}', style: estiloTitulo(18, cor: CoresPowerFit.destaque)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decoration: feito ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Pilula('${e.series} × ${e.repeticoes}'),
                      _Pilula(e.carga),
                      if (e.descansoSeg > 0) _Pilula('${e.descansoSeg}s descanso', icone: Icons.hourglass_bottom),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pilula extends StatelessWidget {
  const _Pilula(this.texto, {this.icone});

  final String texto;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CoresPowerFit.creme,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 12, color: CoresPowerFit.cinza), const SizedBox(width: 3)],
          Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
