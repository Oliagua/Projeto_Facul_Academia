import 'package:flutter/material.dart';

import '../models/catalogo.dart';
import '../database/catalogo_dao.dart';
import '../services/auth_service.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../widgets/componentes.dart';

/// Os mesmos planos da seção "Planos" do site, com a opção de troca.
class PlanosScreen extends StatefulWidget {
  const PlanosScreen({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<PlanosScreen> createState() => _PlanosScreenState();
}

class _PlanosScreenState extends State<PlanosScreen> {
  late final Future<List<Plano>> _planos = CatalogoDao().planos();
  int? _trocando;

  Future<void> _escolher(Plano plano) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Mudar para o ${plano.nome}?'),
        content: Text(
          '${plano.meses} ${plano.meses == 1 ? 'mês' : 'meses'} · ${Formatos.moeda(plano.precoMensal)}/mês '
          '(${Formatos.moeda(plano.precoTotal)} no total).\n\n'
          'Neste protótipo a troca é registrada no app; a cobrança é feita na recepção.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmou != true) return;

    setState(() => _trocando = plano.id);
    final atualizado = await AuthService().trocarPlano(widget.sessao.usuario, plano.id);
    widget.sessao.atualizarUsuario(atualizado);
    if (!mounted) return;
    setState(() => _trocando = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agora você está no ${plano.nome}.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planos')),
      body: FutureBuilder<List<Plano>>(
        future: _planos,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListenableBuilder(
            listenable: widget.sessao,
            builder: (context, _) {
              final atual = widget.sessao.usuario.planoId;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  const TituloSecao(chamada: 'Planos para evoluir', titulo: 'Seu compromisso, sua conquista.'),
                  const SizedBox(height: 18),
                  for (final p in snap.data!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CartaoPlano(
                        plano: p,
                        atual: p.id == atual,
                        carregando: _trocando == p.id,
                        aoEscolher: _trocando == null ? () => _escolher(p) : null,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CartaoPlano extends StatelessWidget {
  const _CartaoPlano({
    required this.plano,
    required this.atual,
    required this.carregando,
    required this.aoEscolher,
  });

  final Plano plano;
  final bool atual;
  final bool carregando;
  final VoidCallback? aoEscolher;

  @override
  Widget build(BuildContext context) {
    final escuro = plano.recomendado;
    final corTexto = escuro ? Colors.white : CoresPowerFit.tinta;
    final corSecundaria = escuro ? Colors.white70 : CoresPowerFit.cinza;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: escuro ? CoresPowerFit.tinta : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: atual ? CoresPowerFit.destaque : (escuro ? CoresPowerFit.tinta : CoresPowerFit.linha),
          width: atual ? 2.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(plano.nome, style: estiloTitulo(26, cor: corTexto))),
              if (atual)
                const Etiqueta('Seu plano')
              else if (plano.recomendado)
                const Etiqueta('Recomendado'),
            ],
          ),
          Text(
            '${plano.meses} ${plano.meses == 1 ? 'mês' : 'meses'} · ${Formatos.moeda(plano.precoTotal)} no total',
            style: TextStyle(fontSize: 13, color: corSecundaria),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: Formatos.moeda(plano.precoMensal),
                  style: estiloTitulo(44, cor: escuro ? CoresPowerFit.destaque : CoresPowerFit.tinta),
                ),
                TextSpan(text: ' /mês', style: TextStyle(fontSize: 14, color: corSecundaria)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(plano.descricao, style: TextStyle(color: corSecundaria, fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),
          for (final b in plano.beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: CoresPowerFit.destaque),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b, style: TextStyle(color: corTexto))),
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (atual)
            Row(
              children: [
                const Icon(Icons.verified, color: CoresPowerFit.destaque, size: 20),
                const SizedBox(width: 6),
                Text('Plano atual', style: TextStyle(fontWeight: FontWeight.w700, color: corTexto)),
              ],
            )
          else
            BotaoPrincipal(texto: 'Escolher plano', carregando: carregando, aoPressionar: aoEscolher),
        ],
      ),
    );
  }
}
