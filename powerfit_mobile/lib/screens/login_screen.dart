import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/validadores.dart';
import '../widgets/componentes.dart';
import '../widgets/logo_powerfit.dart';
import 'cadastro_screen.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.auth});

  final AuthService? auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  late final AuthService _auth = widget.auth ?? AuthService();

  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _auth.entrar(_email.text, _senha.text);
      if (!mounted) return;
      if (usuario == null) {
        setState(() => _erro = 'E-mail ou senha incorretos.');
        return;
      }
      await SessaoAluno.lembrar(usuario);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ShellScreen(usuario: usuario)),
      );
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirCadastro() async {
    final emailCadastrado = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => CadastroScreen(auth: _auth)),
    );
    if (emailCadastrado == null || !mounted) return;

    setState(() {
      _email.text = emailCadastrado;
      _senha.clear();
      _erro = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada! Agora entre com seu e-mail e senha.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: CoresPowerFit.creme,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const _Capa(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: CoresPowerFit.creme,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _formulario(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Acesse sua conta', style: estiloTitulo(30)),
          const SizedBox(height: 4),
          const Text(
            'Entre para ver seus treinos e registrar sua evolução.',
            style: TextStyle(color: CoresPowerFit.cinza),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: Validadores.email,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _senha,
            obscureText: _ocultarSenha,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _entrar(),
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(_ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
              ),
            ),
            validator: Validadores.senhaObrigatoria,
          ),
          if (_erro != null) ...[
            const SizedBox(height: 14),
            MensagemErro(_erro!),
          ],
          const SizedBox(height: 22),
          BotaoPrincipal(texto: 'Entrar', carregando: _carregando, aoPressionar: _entrar),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Primeira vez aqui?', style: TextStyle(color: CoresPowerFit.cinza)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _carregando ? null : _abrirCadastro,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Criar conta'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Projeto acadêmico · academia, pessoas e contatos fictícios.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: CoresPowerFit.cinzaClaro),
          ),
        ],
      ),
    );
  }
}

/// Foto do site com a chamada principal por cima.
class _Capa extends StatelessWidget {
  const _Capa();

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 360 + topo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/imagens/hero.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.55, 0),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xAA111111), Color(0x33111111), Color(0xEE111111)],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topo + 20, 24, 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoPowerFit(claro: true, tamanho: 24),
                const Spacer(),
                const Text(
                  'SUA MELHOR VERSÃO COMEÇA AQUI',
                  style: TextStyle(
                    color: CoresPowerFit.destaque,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: estiloTitulo(40, cor: Colors.white),
                    children: const [
                      TextSpan(text: 'Transforme seu corpo.\n'),
                      TextSpan(
                        text: 'Supere seus limites.',
                        style: TextStyle(color: CoresPowerFit.destaque, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
