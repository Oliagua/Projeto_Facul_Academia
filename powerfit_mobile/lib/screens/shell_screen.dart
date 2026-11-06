import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/usuario.dart';
import '../services/sessao_aluno.dart';
import 'atividades_tab.dart';
import 'inicio_tab.dart';
import 'perfil_tab.dart';
import 'treinos_tab.dart';

/// Área logada: quatro abas com a barra de navegação inferior.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late final SessaoAluno _sessao = SessaoAluno(widget.usuario);
  int _aba = 0;

  @override
  void dispose() {
    _sessao.dispose();
    super.dispose();
  }

  void _irPara(int aba) => setState(() => _aba = aba);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _aba == 0 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: IndexedStack(
          index: _aba,
          children: [
            InicioTab(sessao: _sessao, irParaAba: _irPara),
            TreinosTab(sessao: _sessao),
            AtividadesTab(sessao: _sessao),
            PerfilTab(sessao: _sessao),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _aba,
          onDestinationSelected: _irPara,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Treinos',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Atividades',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
