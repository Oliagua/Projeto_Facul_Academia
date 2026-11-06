import 'package:flutter/material.dart';

import '../database/catalogo_dao.dart';
import '../models/treino.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../widgets/componentes.dart';
import 'treino_detalhe_screen.dart';

class TreinosTab extends StatefulWidget {
  const TreinosTab({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<TreinosTab> createState() => _TreinosTabState();
}

class _TreinosTabState extends State<TreinosTab> {
  late final Future<List<Treino>> _treinos = CatalogoDao().treinos();
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus treinos')),
      body: FutureBuilder<List<Treino>>(
        future: _treinos,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final todos = snap.data!;
          final modalidades = {for (final t in todos) t.modalidade}.toList();
          final lista = _filtro == null ? todos : todos.where((t) => t.modalidade == _filtro).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const Text(
                'Montados pelos professores da PowerFit para o seu objetivo.',
                style: TextStyle(color: CoresPowerFit.cinza),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _chip('Todos', _filtro == null, () => setState(() => _filtro = null)),
                    for (final m in modalidades) _chip(m, _filtro == m, () => setState(() => _filtro = m)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final t in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CartaoTreino(
                    treino: t,
                    aoTocar: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TreinoDetalheScreen(treinoId: t.id, sessao: widget.sessao),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String texto, bool selecionado, VoidCallback aoTocar) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: selecionado,
        showCheckmark: false,
        onSelected: (_) => aoTocar(),
      ),
    );
  }
}

/// Cartão com foto da modalidade, letra, nome e informações do treino.
class CartaoTreino extends StatelessWidget {
  const CartaoTreino({super.key, required this.treino, required this.aoTocar});

  final Treino treino;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final t = treino;
    return Cartao(
      aoTocar: aoTocar,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Foto(t.imagem, raio: 0, degrade: true),
                Positioned(
                  left: 16,
                  bottom: 12,
                  right: 16,
                  child: Row(
                    children: [
                      SeloLetra(t.letra, tamanho: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.modalidade.toUpperCase(),
                              style: const TextStyle(
                                color: CoresPowerFit.destaque,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(t.nome, style: estiloTitulo(24, cor: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      InfoPequena(Icons.timer_outlined, '${t.duracaoMin} min'),
                      InfoPequena(Icons.format_list_numbered, '${t.quantidadeExercicios} exercícios'),
                      InfoPequena(Icons.signal_cellular_alt, t.nivel),
                    ],
                  ),
                ),
                CircleAvatar(radius: 15, backgroundImage: AssetImage(t.fotoProfessor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
