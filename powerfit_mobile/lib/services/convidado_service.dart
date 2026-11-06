import '../database/convidado_dao.dart';
import '../models/convidado.dart';
import '../utils/formatos.dart';

class LimiteConvidadosException implements Exception {
  const LimiteConvidadosException(this.limite);

  final int limite;
}

/// Regra do site: cada plano dá direito a um número de convidados por mês.
class ConvidadoService {
  ConvidadoService({ConvidadoDao? dao}) : _dao = dao ?? ConvidadoDao();

  final ConvidadoDao _dao;

  /// Cria ou atualiza o convidado, desde que o mês da visita tenha vaga.
  Future<void> salvar(Convidado convidado, {required int limitePorMes}) async {
    final usados = await _dao.contarNoMes(
      convidado.usuarioId,
      Formatos.anoMes(convidado.dataVisita),
      ignorarId: convidado.id,
    );
    if (usados >= limitePorMes) throw LimiteConvidadosException(limitePorMes);

    if (convidado.id == null) {
      await _dao.inserir(convidado);
    } else {
      await _dao.atualizar(convidado);
    }
  }
}
