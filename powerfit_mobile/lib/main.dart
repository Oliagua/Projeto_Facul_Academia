import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/usuario.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'services/auth_service.dart';
import 'services/sessao_aluno.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  Usuario? usuario;
  try {
    usuario = await SessaoAluno.restaurar(AuthService());
  } catch (_) {
    // Se o banco não abrir, o aluno simplesmente faz login de novo.
  }

  runApp(PowerFitApp(usuarioInicial: usuario));
}

class PowerFitApp extends StatelessWidget {
  const PowerFitApp({super.key, this.usuarioInicial});

  final Usuario? usuarioInicial;

  @override
  Widget build(BuildContext context) {
    final usuario = usuarioInicial;
    return MaterialApp(
      title: 'PowerFit Academia',
      debugShowCheckedModeBanner: false,
      theme: temaPowerFit(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: usuario == null ? const LoginScreen() : ShellScreen(usuario: usuario),
    );
  }
}
