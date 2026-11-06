import 'package:flutter/material.dart';

import '../models/catalogo.dart';
import '../database/catalogo_dao.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../utils/validadores.dart';
import '../widgets/componentes.dart';

/// Ao concluir, volta para o login devolvendo o e-mail cadastrado.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  late final Future<List<Plano>> _planos = CatalogoDao().planos();

  int? _planoId;
  bool _ocultarSenha = true;
  bool _salvando = false;
  String? _erroEmail;
  String? _erroPlano;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _erroEmail = null;
      _erroPlano = _planoId == null ? 'Escolha um plano para continuar' : null;
    });
    final valido = _form.currentState!.validate();
    if (!valido || _planoId == null) return;

    setState(() => _salvando = true);
    try {
      final usuario = await widget.auth.cadastrar(
        nome: _nome.text,
        email: _email.text,
        telefone: _telefone.text,
        senha: _senha.text,
        planoId: _planoId!,
      );
      if (mounted) Navigator.of(context).pop(usuario.email);
    } on EmailJaCadastradoException {
      if (mounted) setState(() => _erroEmail = 'Este e-mail já está cadastrado');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível criar a conta. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final olho = IconButton(
      tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(_ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'O primeiro passo é agora. Preencha seus dados — você vai usar o e-mail e a senha para entrar no app.',
                      style: TextStyle(color: CoresPowerFit.cinza, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    const _Etapa(numero: 1, titulo: 'Seus dados'),
                    TextFormField(
                      controller: _nome,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validadores.nome,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      onChanged: (_) {
                        if (_erroEmail != null) setState(() => _erroEmail = null);
                      },
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.mail_outline),
                        errorText: _erroEmail,
                      ),
                      validator: Validadores.email,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _telefone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [MascaraTelefone()],
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(11) 99999-9999',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validadores.telefone,
                    ),
                    const SizedBox(height: 28),
                    const _Etapa(numero: 2, titulo: 'Escolha seu plano'),
                    FutureBuilder<List<Plano>>(
                      future: _planos,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return Column(
                          children: [
                            for (final plano in snap.data!)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _OpcaoPlano(
                                  plano: plano,
                                  selecionado: plano.id == _planoId,
                                  aoTocar: () => setState(() {
                                    _planoId = plano.id;
                                    _erroPlano = null;
                                  }),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (_erroPlano != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          _erroPlano!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 18),
                    const _Etapa(numero: 3, titulo: 'Crie sua senha'),
                    TextFormField(
                      controller: _senha,
                      obscureText: _ocultarSenha,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        helperText: 'Mínimo de 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: olho,
                      ),
                      validator: Validadores.novaSenha,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmacao,
                      obscureText: _ocultarSenha,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _cadastrar(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) return 'Confirme a senha';
                        if (valor != _senha.text) return 'As senhas não conferem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    BotaoPrincipal(
                      texto: 'Criar minha conta',
                      icone: Icons.check_rounded,
                      carregando: _salvando,
                      aoPressionar: _cadastrar,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _salvando ? null : () => Navigator.of(context).pop(),
                      child: const Text('Já tenho conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Etapa extends StatelessWidget {
  const _Etapa({required this.numero, required this.titulo});

  final int numero;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: CoresPowerFit.tinta, shape: BoxShape.circle),
            child: Text(
              '$numero',
              style: const TextStyle(color: CoresPowerFit.destaque, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Text(titulo, style: estiloTitulo(22, peso: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _OpcaoPlano extends StatelessWidget {
  const _OpcaoPlano({required this.plano, required this.selecionado, required this.aoTocar});

  final Plano plano;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selecionado,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selecionado ? CoresPowerFit.tinta : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado ? CoresPowerFit.destaque : CoresPowerFit.linha,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    selecionado ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selecionado ? CoresPowerFit.destaque : CoresPowerFit.cinzaClaro,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plano.nomeCurto,
                              style: estiloTitulo(
                                21,
                                peso: FontWeight.w700,
                                cor: selecionado ? Colors.white : CoresPowerFit.tinta,
                              ),
                            ),
                            if (plano.recomendado) ...[
                              const SizedBox(width: 8),
                              const Etiqueta('Recomendado'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plano.descricao,
                          style: TextStyle(
                            fontSize: 13,
                            color: selecionado ? Colors.white70 : CoresPowerFit.cinza,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatos.moeda(plano.precoMensal),
                        style: estiloTitulo(
                          24,
                          cor: selecionado ? CoresPowerFit.destaque : CoresPowerFit.tinta,
                        ),
                      ),
                      Text(
                        'por mês',
                        style: TextStyle(
                          fontSize: 12,
                          color: selecionado ? Colors.white70 : CoresPowerFit.cinza,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
