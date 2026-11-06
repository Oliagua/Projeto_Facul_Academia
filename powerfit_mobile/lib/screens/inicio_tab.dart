import 'package:flutter/material.dart';

import '../database/atividade_dao.dart';
import '../database/catalogo_dao.dart';
import '../models/catalogo.dart';
import '../models/atividade.dart';
import '../models/treino.dart';
import '../services/estatisticas.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../widgets/componentes.dart';
import 'atividade_form_screen.dart';
import 'treino_detalhe_screen.dart';

class InicioTab extends StatefulWidget {
  const InicioTab({super.key, required this.sessao, required this.irParaAba});

  final SessaoAluno sessao;
  final ValueChanged<int> irParaAba;

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _DadosInicio {
  final List<Atividade> atividades;
  final List<Treino> treinos;
  final List<Modalidade> modalidades;
  final List<Professor> professores;
  final Plano? plano;

  const _DadosInicio(this.atividades, this.treinos, this.modalidades, this.professores, this.plano);
}

class _InicioTabState extends State<InicioTab> {
  final _catalogo = CatalogoDao();
  final _atividadeDao = AtividadeDao();
  _DadosInicio? _dados;

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
    final r = await Future.wait([
      _atividadeDao.listar(u.id!),
      _catalogo.treinos(),
      _catalogo.modalidades(),
      _catalogo.professores(),
      _catalogo.plano(u.planoId),
    ]);
    if (!mounted) return;
    setState(() {
      _dados = _DadosInicio(
        r[0] as List<Atividade>,
        r[1] as List<Treino>,
        r[2] as List<Modalidade>,
        r[3] as List<Professor>,
        r[4] as Plano?,
      );
    });
  }

  /// Próximo treino da sequência, depois do último que o aluno registrou.
  Treino? _treinoSugerido(_DadosInicio d) {
    if (d.treinos.isEmpty) return null;
    final ultimo = d.atividades.where((a) => a.treinoId != null).firstOrNull;
    if (ultimo == null) return d.treinos.first;
    final i = d.treinos.indexWhere((t) => t.id == ultimo.treinoId);
    return d.treinos[(i + 1) % d.treinos.length];
  }

  void _abrirTreino(Treino t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TreinoDetalheScreen(treinoId: t.id, sessao: widget.sessao)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _dados;
    if (d == null) return const Center(child: CircularProgressIndicator());

    final stats = Estatisticas.calcular(d.atividades);
    final sugerido = _treinoSugerido(d);

    return RefreshIndicator(
      onRefresh: _carregar,
      color: CoresPowerFit.tinta,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Cabecalho(sessao: widget.sessao, plano: d.plano, stats: stats),
          const SizedBox(height: 28),
          if (sugerido != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TituloSecao(
                    chamada: 'Bora treinar',
                    titulo: 'Treino de hoje',
                    acao: 'Todos',
                    aoTocarAcao: () => widget.irParaAba(1),
                  ),
                  const SizedBox(height: 12),
                  _TreinoDestaque(treino: sugerido, aoTocar: () => _abrirTreino(sugerido)),
                ],
              ),
            ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TituloSecao(chamada: 'Do seu jeito', titulo: 'Modalidades'),
          ),
          const SizedBox(height: 12),
          _Carrossel(
            altura: 210,
            largura: 175,
            itens: [
              for (final m in d.modalidades)
                _CartaoModalidade(modalidade: m, aoTocar: () => _mostrarModalidade(m)),
            ],
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TituloSecao(chamada: 'Time PowerFit', titulo: 'Professores'),
          ),
          const SizedBox(height: 12),
          _Carrossel(
            altura: 250,
            itens: [for (final p in d.professores) _CartaoProfessor(professor: p)],
          ),
          const SizedBox(height: 32),
          const _SecaoEscura(),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TituloSecao(chamada: 'Histórias de evolução', titulo: 'Quem treina, sente'),
          ),
          const SizedBox(height: 12),
          const _Carrossel(
            altura: 230,
            largura: 290,
            itens: [
              _Depoimento(
                foto: 'assets/imagens/fernanda.jpg',
                texto: 'Na PowerFit eu encontrei acolhimento e um treino que cabe na minha rotina.',
                autor: 'Fernanda Lima, aluna há 2 anos',
              ),
              _Depoimento(
                foto: 'assets/imagens/andre.jpg',
                texto: 'Os professores realmente acompanham a evolução. Minha disposição mudou completamente.',
                autor: 'André Silva, aluno há 1 ano',
              ),
              _Depoimento(
                foto: 'assets/imagens/juliana.jpg',
                texto: 'É o meu momento do dia. A estrutura é ótima e a energia contagia.',
                autor: 'Juliana Reis, aluna há 3 anos',
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: _InfoAcademia(),
          ),
        ],
      ),
    );
  }

  void _mostrarModalidade(Modalidade m) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (contexto) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 180, child: Foto(m.imagem)),
              const SizedBox(height: 16),
              const Text(
                'SEU PRÓXIMO TREINO',
                style: TextStyle(
                  color: CoresPowerFit.destaque,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              Text(m.nome, style: estiloTitulo(32)),
              const SizedBox(height: 8),
              Text(m.descricao, style: const TextStyle(height: 1.45, color: CoresPowerFit.cinza)),
              const SizedBox(height: 20),
              BotaoPrincipal(
                texto: 'Registrar aula de ${m.nome}',
                icone: Icons.add_task,
                aoPressionar: () {
                  Navigator.of(contexto).pop();
                  abrirFormularioAtividade(context, widget.sessao, tituloSugerido: m.nome);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Topo escuro com saudação, plano e o resumo da semana.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.sessao, required this.plano, required this.stats});

  final SessaoAluno sessao;
  final Plano? plano;
  final Estatisticas stats;

  @override
  Widget build(BuildContext context) {
    final u = sessao.usuario;
    final topo = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topo + 16, 20, 24),
      decoration: const BoxDecoration(
        color: CoresPowerFit.tinta,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarIniciais(u.iniciais, tamanho: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${Formatos.saudacao()},', style: const TextStyle(color: Colors.white70)),
                    Text(
                      u.primeiroNome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: estiloTitulo(30, cor: Colors.white),
                    ),
                  ],
                ),
              ),
              if (plano != null) Etiqueta(plano!.nomeCurto),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CoresPowerFit.grafite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _AnelMeta(stats: stats),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Meta da semana', style: estiloTitulo(22, cor: Colors.white, peso: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            stats.treinosNaSemana >= Estatisticas.metaSemanal
                                ? 'Meta batida! Continue assim.'
                                : 'Faltam ${Estatisticas.metaSemanal - stats.treinosNaSemana} treinos para bater a meta',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Numero(valor: '${stats.minutosNaSemana}', rotulo: 'min na semana'),
                              const SizedBox(width: 18),
                              _Numero(valor: '${stats.sequenciaDias}', rotulo: stats.sequenciaDias == 1 ? 'dia seguido' : 'dias seguidos'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _GraficoSemana(minutos: stats.minutosUltimos7Dias),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnelMeta extends StatelessWidget {
  const _AnelMeta({required this.stats});

  final Estatisticas stats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: stats.progressoMeta),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, valor, _) => CircularProgressIndicator(
              value: valor,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white12,
              color: CoresPowerFit.destaque,
            ),
          ),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${stats.treinosNaSemana}', style: estiloTitulo(28, cor: Colors.white)),
                  TextSpan(
                    text: '/${Estatisticas.metaSemanal}',
                    style: estiloTitulo(18, cor: Colors.white54, peso: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(valor, style: estiloTitulo(22, cor: CoresPowerFit.destaque)),
        Text(rotulo, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

/// Barras com os minutos treinados nos últimos 7 dias.
class _GraficoSemana extends StatelessWidget {
  const _GraficoSemana({required this.minutos});

  final List<int> minutos;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final maior = minutos.fold<int>(60, (m, v) => v > m ? v : m);

    if (minutos.every((m) => m == 0)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: CoresPowerFit.destaque),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Registre seus treinos para ver o gráfico dos últimos 7 dias.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Tooltip(
                message: '${minutos[i]} min',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: minutos[i] / maior),
                      duration: Duration(milliseconds: 500 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (_, fator, _) => Container(
                        width: 18,
                        height: 6 + 54 * fator,
                        decoration: BoxDecoration(
                          color: minutos[i] > 0 ? CoresPowerFit.destaque : Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatos.inicialDiaSemana(DateTime(hoje.year, hoje.month, hoje.day - 6 + i)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: i == 6 ? FontWeight.w700 : FontWeight.w500,
                        color: i == 6 ? CoresPowerFit.destaque : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TreinoDestaque extends StatelessWidget {
  const _TreinoDestaque({required this.treino, required this.aoTocar});

  final Treino treino;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Foto(treino.imagem, raio: 20, degrade: true),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SeloLetra(treino.letra, tamanho: 44),
                      const Spacer(),
                      const Etiqueta('Sugerido', escura: true),
                    ],
                  ),
                  const Spacer(),
                  Text(treino.nome, style: estiloTitulo(30, cor: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          children: [
                            InfoPequena(Icons.timer_outlined, '${treino.duracaoMin} min', cor: Colors.white),
                            InfoPequena(Icons.format_list_numbered, '${treino.quantidadeExercicios} exercícios', cor: Colors.white),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: CoresPowerFit.destaque, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: CoresPowerFit.tinta),
                      ),
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

/// Lista horizontal com rolagem.
class _Carrossel extends StatelessWidget {
  const _Carrossel({required this.altura, required this.itens, this.largura = 160});

  final double altura;
  final double largura;
  final List<Widget> itens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altura,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: itens.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: largura, child: itens[i]),
      ),
    );
  }
}

class _CartaoModalidade extends StatelessWidget {
  const _CartaoModalidade({required this.modalidade, required this.aoTocar});

  final Modalidade modalidade;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Foto(modalidade.imagem, degrade: true),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modalidade.nome, style: estiloTitulo(22, cor: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  modalidade.resumo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Text(
                      'Saiba mais',
                      style: TextStyle(color: CoresPowerFit.destaque, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward, size: 14, color: CoresPowerFit.destaque),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoProfessor extends StatelessWidget {
  const _CartaoProfessor({required this.professor});

  final Professor professor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Foto(professor.foto, alinhamento: Alignment.topCenter)),
        const SizedBox(height: 10),
        Text(
          professor.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: estiloTitulo(20, peso: FontWeight.w700),
        ),
        Text(
          professor.especialidade,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: CoresPowerFit.cinza),
        ),
        Text(professor.cref, style: const TextStyle(fontSize: 11, color: CoresPowerFit.cinzaClaro)),
      ],
    );
  }
}

/// Faixa escura com as fotos da estrutura, como a seção "Nossa casa" do site.
class _SecaoEscura extends StatelessWidget {
  const _SecaoEscura();

  static const _fotos = [
    ('assets/imagens/estrutura-1.jpg', 'Área de musculação'),
    ('assets/imagens/estrutura-2.jpg', 'Área funcional'),
    ('assets/imagens/estrutura-3.jpg', 'Vestiários'),
    ('assets/imagens/estrutura-4.jpg', 'Recepção'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CoresPowerFit.tinta,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TituloSecao(chamada: 'Nossa casa', titulo: 'Estrutura para ir mais longe', claro: true),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _fotos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Foto(_fotos[i].$1, raio: 14)),
                    const SizedBox(height: 8),
                    Text(_fotos[i].$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Depoimento extends StatelessWidget {
  const _Depoimento({required this.foto, required this.texto, required this.autor});

  final String foto;
  final String texto;
  final String autor;

  @override
  Widget build(BuildContext context) {
    return Cartao(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: AssetImage(foto)),
              const Spacer(),
              const Icon(Icons.format_quote_rounded, size: 40, color: CoresPowerFit.destaque),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              '“$texto”',
              style: const TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w500),
            ),
          ),
          Text('— $autor', style: const TextStyle(fontSize: 12, color: CoresPowerFit.cinza)),
        ],
      ),
    );
  }
}

/// Endereço, telefone e horários do site.
class _InfoAcademia extends StatelessWidget {
  const _InfoAcademia();

  @override
  Widget build(BuildContext context) {
    Widget linha(IconData icone, String titulo, String texto) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: CoresPowerFit.destaqueSuave, borderRadius: BorderRadius.circular(10)),
              child: Icon(icone, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(texto, style: const TextStyle(color: CoresPowerFit.cinza, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Cartao(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloSecao(chamada: 'Fale com a gente', titulo: 'A academia'),
          const SizedBox(height: 8),
          linha(Icons.place_outlined, 'Endereço', 'Rua da Energia, 500 — Centro, São Paulo/SP'),
          linha(Icons.schedule, 'Horários', 'Seg–Sex: 5h30 às 23h · Sáb: 8h às 16h'),
          linha(Icons.phone_outlined, 'Telefone', '(11) 4020-2026'),
          linha(Icons.mail_outline, 'E-mail', 'contato@powerfitacademia.com.br'),
        ],
      ),
    );
  }
}
