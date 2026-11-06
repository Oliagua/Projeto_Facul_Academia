import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import 'auth_service.dart';

/// Guarda quem está logado e avisa as telas quando algo muda
/// (dados do perfil, plano ou atividades registradas).
class SessaoAluno extends ChangeNotifier {
  SessaoAluno(this._usuario);

  static const _chave = 'usuario_logado';

  Usuario _usuario;
  int _versaoAtividades = 0;

  Usuario get usuario => _usuario;

  /// Muda sempre que uma atividade é criada, alterada ou excluída.
  int get versaoAtividades => _versaoAtividades;

  void atualizarUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void atividadesMudaram() {
    _versaoAtividades++;
    notifyListeners();
  }

  static Future<void> lembrar(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chave, usuario.id!);
  }

  static Future<void> esquecer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }

  /// Usuário que deixou o app aberto da última vez, se ainda existir.
  static Future<Usuario?> restaurar(AuthService auth) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_chave);
    if (id == null) return null;
    final usuario = await auth.buscar(id);
    if (usuario == null) await prefs.remove(_chave);
    return usuario;
  }
}
