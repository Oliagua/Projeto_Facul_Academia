import 'package:flutter/material.dart';

import '../database/catalogo_dao.dart';
import '../database/convidado_dao.dart';
import '../models/catalogo.dart';
import '../models/convidado.dart';
import '../services/convidado_service.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../utils/validadores.dart';
import '../widgets/componentes.dart';
import 'planos_screen.dart';

/// CRUD dos convidados do aluno, respeitando o limite mensal do plano.
class ConvidadosScreen extends StatefulWidget {
  const ConvidadosScreen({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<ConvidadosScreen> createState() => _ConvidadosScreenState();
}

class _ConvidadosScreenState extends State<ConvidadosScreen> {
  final _dao = ConvidadoDao();
  List<Convidado>? _convidados;
  Plano? _plano;

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
    final lista = await _dao.listar(u.id!);
    if (!mounted) return;
    setState(() {
      _plano = plano;
      _convidados = lista;
    });
  }

  Future<void> _abrirFormulario([Convidado? convidado]) async {
    final salvou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioConvidado(
        usuarioId: widget.sessao.usuario.id!,
        limitePorMes: _plano!.limiteConvidados,
        convidado: convidado,
      ),
    );
    if (salvou == true) await _carregar();
  }

  Future<void> _excluir(Convidado convidado) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir convidado?'),
        content: Text('${convidado.nome} será removido da sua lista.'),
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
    if (confirmou != true) return;
    await _dao.excluir(convidado.id!, convidado.usuarioId);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Convidado excluído.')));
  }

  @override
  Widget build(BuildContext context) {
    final convidados = _convidados;
    final plano = _plano;
    if (convidados == null || plano == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Convidados')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final permitido = plano.limiteConvidados > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Convidados')),
      floatingActionButton: permitido
          ? FloatingActionButton.extended(
              heroTag: 'convidar',
              onPressed: _abrirFormulario,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Convidar', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          _ResumoMes(plano: plano, convidados: convidados),
          const SizedBox(height: 20),
          if (!permitido)
            EstadoVazio(
              icone: Icons.group_add_outlined,
              titulo: 'Seu plano não inclui convidados',
              texto: 'Os planos Trimestral e Semestral dão direito a 1 convidado por mês, e o Anual a 2.',
              acao: SizedBox(
                width: 200,
                child: BotaoPrincipal(
                  texto: 'Ver planos',
                  aoPressionar: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PlanosScreen(sessao: widget.sessao)),
                  ),
                ),
              ),
            )
          else if (convidados.isEmpty)
            const EstadoVazio(
              icone: Icons.group_add_outlined,
              titulo: 'Nenhum convidado ainda',
              texto: 'Traga alguém para treinar com você. Toque em Convidar para informar o nome e o dia da visita.',
            ),
          for (final c in convidados)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Cartao(
                aoTocar: permitido ? () => _abrirFormulario(c) : null,
                padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: CoresPowerFit.destaqueSuave,
                      child: Icon(Icons.person_outline, color: CoresPowerFit.tinta),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          InfoPequena(Icons.calendar_today_outlined, 'Visita em ${Formatos.data(c.dataVisita)}'),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Excluir ${c.nome}',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _excluir(c),
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

class _ResumoMes extends StatelessWidget {
  const _ResumoMes({required this.plano, required this.convidados});

  final Plano plano;
  final List<Convidado> convidados;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final doMes = Formatos.anoMes(agora);
    final usados = convidados.where((c) => Formatos.anoMes(c.dataVisita) == doMes).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: CoresPowerFit.tinta, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$usados', style: estiloTitulo(40, cor: CoresPowerFit.destaque)),
                TextSpan(
                  text: '/${plano.limiteConvidados}',
                  style: estiloTitulo(22, cor: Colors.white54, peso: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Convidados em ${Formatos.nomeMes(agora)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(plano.nome, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormularioConvidado extends StatefulWidget {
  const _FormularioConvidado({
    required this.usuarioId,
    required this.limitePorMes,
    this.convidado,
  });

  final int usuarioId;
  final int limitePorMes;
  final Convidado? convidado;

  @override
  State<_FormularioConvidado> createState() => _FormularioConvidadoState();
}

class _FormularioConvidadoState extends State<_FormularioConvidado> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.convidado?.nome ?? '');
  late DateTime _data = widget.convidado?.dataVisita ?? DateTime.now();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(hoje.year - 1, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 1, hoje.month, hoje.day),
      helpText: 'Dia da visita',
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await ConvidadoService().salvar(
        Convidado(
          id: widget.convidado?.id,
          nome: _nome.text.trim(),
          dataVisita: _data,
          usuarioId: widget.usuarioId,
        ),
        limitePorMes: widget.limitePorMes,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on LimiteConvidadosException catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Seu plano permite ${e.limite} ${e.limite == 1 ? 'convidado' : 'convidados'} por mês, '
            'e ${Formatos.nomeMes(_data)} já está completo. Escolha outro mês.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Não foi possível salvar. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.convidado == null ? 'Novo convidado' : 'Editar convidado', style: estiloTitulo(28)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Nome do convidado',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: Validadores.nome,
              ),
              const SizedBox(height: 6),
              Cartao(
                aoTocar: _escolherData,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: CoresPowerFit.cinza),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Visita em ${Formatos.data(_data)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text('Alterar', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                MensagemErro(_erro!),
              ],
              const SizedBox(height: 20),
              BotaoPrincipal(
                texto: 'Salvar convidado',
                icone: Icons.check_rounded,
                carregando: _salvando,
                aoPressionar: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
