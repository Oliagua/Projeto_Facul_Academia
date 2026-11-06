import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/sessao_aluno.dart';
import '../theme.dart';
import '../utils/formatos.dart';
import '../utils/validadores.dart';
import '../widgets/componentes.dart';

/// Edita nome e telefone. O e-mail é o login e não muda.
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.sessao.usuario.nome);
  late final _telefone = TextEditingController(text: Formatos.telefone(widget.sessao.usuario.telefone));
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    final atualizado = await AuthService().atualizarPerfil(
      widget.sessao.usuario,
      nome: _nome.text,
      telefone: _telefone.text,
    );
    widget.sessao.atualizarUsuario(atualizado);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados atualizados.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus dados')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline)),
              validator: Validadores.nome,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              inputFormatters: [MascaraTelefone()],
              decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone_outlined)),
              validator: Validadores.telefone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: widget.sessao.usuario.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                helperText: 'O e-mail é usado para entrar e não pode ser alterado.',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 28),
            BotaoPrincipal(texto: 'Salvar', icone: Icons.check_rounded, carregando: _salvando, aoPressionar: _salvar),
          ],
        ),
      ),
    );
  }
}

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({super.key, required this.sessao});

  final SessaoAluno sessao;

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final _form = GlobalKey<FormState>();
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmacao = TextEditingController();
  bool _ocultar = true;
  bool _salvando = false;
  String? _erroAtual;

  @override
  void dispose() {
    _atual.dispose();
    _nova.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroAtual = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final atualizado = await AuthService().alterarSenha(
        widget.sessao.usuario,
        senhaAtual: _atual.text,
        novaSenha: _nova.text,
      );
      widget.sessao.atualizarUsuario(atualizado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada.')));
      Navigator.of(context).pop();
    } on SenhaIncorretaException {
      if (mounted) {
        setState(() {
          _erroAtual = 'Senha atual incorreta';
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final olho = IconButton(
      tooltip: _ocultar ? 'Mostrar senhas' : 'Ocultar senhas',
      icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      onPressed: () => setState(() => _ocultar = !_ocultar),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextFormField(
              controller: _atual,
              obscureText: _ocultar,
              decoration: InputDecoration(
                labelText: 'Senha atual',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: olho,
                errorText: _erroAtual,
              ),
              validator: Validadores.senhaObrigatoria,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nova,
              obscureText: _ocultar,
              decoration: const InputDecoration(
                labelText: 'Nova senha',
                helperText: 'Mínimo de 6 caracteres',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
              validator: Validadores.novaSenha,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmacao,
              obscureText: _ocultar,
              decoration: const InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
              validator: (v) => v != _nova.text ? 'As senhas não conferem' : null,
            ),
            const SizedBox(height: 28),
            BotaoPrincipal(texto: 'Alterar senha', icone: Icons.check_rounded, carregando: _salvando, aoPressionar: _salvar),
            const SizedBox(height: 12),
            const Text(
              'A senha é guardada como hash (SHA-256 com salt), nunca em texto.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: CoresPowerFit.cinzaClaro),
            ),
          ],
        ),
      ),
    );
  }
}
