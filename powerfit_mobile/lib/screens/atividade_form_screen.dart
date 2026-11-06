import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/atividade_dao.dart';
import '../database/catalogo_dao.dart';
import '../models/atividade.dart';
import '../models/treino.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../utils/validadores.dart';
import '../widgets/componentes.dart';

/// Abre o formulário e devolve true se algo foi salvo ou excluído.
Future<bool> abrirFormularioAtividade(
  BuildContext context,
  SessaoAluno sessao, {
  Atividade? atividade,
  Treino? treino,
  String? tituloSugerido,
}) async {
  final mudou = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AtividadeFormScreen(
        sessao: sessao,
        atividade: atividade,
        treinoInicial: treino,
        tituloSugerido: tituloSugerido,
      ),
    ),
  );
  return mudou ?? false;
}

class AtividadeFormScreen extends StatefulWidget {
  const AtividadeFormScreen({
    super.key,
    required this.sessao,
    this.atividade,
    this.treinoInicial,
    this.tituloSugerido,
  });

  final SessaoAluno sessao;

  /// Preenchido quando o aluno está editando um registro existente.
  final Atividade? atividade;
  final Treino? treinoInicial;
  final String? tituloSugerido;

  @override
  State<AtividadeFormScreen> createState() => _AtividadeFormScreenState();
}

class _AtividadeFormScreenState extends State<AtividadeFormScreen> {
  static const _outra = -1;

  final _form = GlobalKey<FormState>();
  final _dao = AtividadeDao();
  late final Future<List<Treino>> _treinos = CatalogoDao().treinos();

  late final TextEditingController _titulo;
  late final TextEditingController _duracao;
  late final TextEditingController _observacao;
  late int? _treinoId;
  late DateTime _data;
  late Intensidade _intensidade;
  bool _salvando = false;
  String? _erroTreino;

  bool get _editando => widget.atividade != null;

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    final t = widget.treinoInicial;
    _treinoId = a != null ? (a.treinoId ?? _outra) : (t?.id ?? (widget.tituloSugerido != null ? _outra : null));
    _titulo = TextEditingController(
      text: a != null && a.treinoId == null ? a.titulo : (widget.tituloSugerido ?? ''),
    );
    _duracao = TextEditingController(text: '${a?.duracaoMin ?? t?.duracaoMin ?? 45}');
    _observacao = TextEditingController(text: a?.observacao ?? '');
    _data = a?.data ?? DateTime.now();
    _intensidade = a?.intensidade ?? Intensidade.moderada;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _duracao.dispose();
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(hoje.year - 1, hoje.month, hoje.day),
      lastDate: hoje,
      helpText: 'Quando você treinou?',
    );
    if (escolhida != null) {
      setState(() => _data = DateTime(escolhida.year, escolhida.month, escolhida.day, _data.hour, _data.minute));
    }
  }

  Future<void> _salvar(List<Treino> treinos) async {
    FocusScope.of(context).unfocus();
    setState(() => _erroTreino = _treinoId == null ? 'Escolha o que você treinou' : null);
    final valido = _form.currentState!.validate();
    if (!valido || _treinoId == null) return;

    final treino = treinos.where((t) => t.id == _treinoId).firstOrNull;
    final atividade = Atividade(
      id: widget.atividade?.id,
      usuarioId: widget.sessao.usuario.id!,
      treinoId: treino?.id,
      titulo: treino?.titulo ?? _titulo.text.trim(),
      data: _data,
      duracaoMin: int.parse(_duracao.text.trim()),
      intensidade: _intensidade,
      observacao: _observacao.text.trim(),
    );

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _dao.atualizar(atividade);
      } else {
        await _dao.inserir(atividade);
      }
      widget.sessao.atividadesMudaram();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editando ? 'Atividade atualizada.' : 'Treino registrado. Mandou bem!')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar. Tente novamente.')),
        );
      }
    }
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusaoAtividade(context);
    if (!confirmou) return;
    await _dao.excluir(widget.atividade!.id!, widget.sessao.usuario.id!);
    widget.sessao.atividadesMudaram();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atividade excluída.')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar atividade' : 'Registrar treino'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _salvando ? null : _excluir,
            ),
        ],
      ),
      body: FutureBuilder<List<Treino>>(
        future: _treinos,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final treinos = snap.data!;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _Rotulo('O que você treinou?'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in treinos)
                      ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: _treinoId == t.id ? CoresPowerFit.tinta : CoresPowerFit.destaqueSuave,
                          child: Text(
                            t.letra,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _treinoId == t.id ? CoresPowerFit.destaque : CoresPowerFit.tinta,
                            ),
                          ),
                        ),
                        label: Text(t.nome),
                        selected: _treinoId == t.id,
                        showCheckmark: false,
                        onSelected: (_) => setState(() {
                          _treinoId = t.id;
                          _erroTreino = null;
                          if (!_editando) _duracao.text = '${t.duracaoMin}';
                        }),
                      ),
                    ChoiceChip(
                      avatar: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Outra atividade'),
                      selected: _treinoId == _outra,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _treinoId = _outra;
                        _erroTreino = null;
                      }),
                    ),
                  ],
                ),
                if (_erroTreino != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      _erroTreino!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                if (_treinoId == _outra) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titulo,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome da atividade',
                      hintText: 'Ex.: Spinning, corrida, alongamento',
                      prefixIcon: Icon(Icons.directions_run),
                    ),
                    validator: (v) {
                      final texto = v?.trim() ?? '';
                      if (texto.length < 2) return 'Descreva a atividade';
                      if (texto.length > 80) return 'Use no máximo 80 caracteres';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const _Rotulo('Quando?'),
                Cartao(
                  aoTocar: _escolherData,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: CoresPowerFit.cinza),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${Formatos.diaRelativo(_data)} · ${Formatos.data(_data)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Text('Alterar', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _Rotulo('Duração'),
                TextFormField(
                  controller: _duracao,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.timer_outlined),
                    suffixText: 'minutos',
                  ),
                  validator: Validadores.duracao,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in const [30, 45, 60, 90])
                      ChoiceChip(
                        label: Text('$m min'),
                        selected: _duracao.text == '$m',
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _duracao.text = '$m'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const _Rotulo('Intensidade'),
                SegmentedButton<Intensidade>(
                  segments: const [
                    ButtonSegment(value: Intensidade.leve, label: Text('Leve'), icon: Icon(Icons.spa_outlined)),
                    ButtonSegment(value: Intensidade.moderada, label: Text('Moderada'), icon: Icon(Icons.bolt_outlined)),
                    ButtonSegment(
                      value: Intensidade.intensa,
                      label: Text('Intensa'),
                      icon: Icon(Icons.local_fire_department_outlined),
                    ),
                  ],
                  selected: {_intensidade},
                  onSelectionChanged: (s) => setState(() => _intensidade = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: CoresPowerFit.tinta,
                    selectedForegroundColor: CoresPowerFit.destaque,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: CoresPowerFit.linha),
                  ),
                ),
                const SizedBox(height: 24),
                const _Rotulo('Observações (opcional)'),
                TextFormField(
                  controller: _observacao,
                  maxLines: 3,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Como foi o treino? Aumentou carga? Sentiu algo?',
                  ),
                ),
                const SizedBox(height: 16),
                BotaoPrincipal(
                  texto: _editando ? 'Salvar alterações' : 'Registrar treino',
                  icone: Icons.check_rounded,
                  carregando: _salvando,
                  aoPressionar: () => _salvar(treinos),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<bool> confirmarExclusaoAtividade(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Excluir atividade?'),
      content: const Text('Este registro será removido do seu histórico.'),
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
  return ok ?? false;
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texto, style: estiloTitulo(20, peso: FontWeight.w700)),
    );
  }
}
