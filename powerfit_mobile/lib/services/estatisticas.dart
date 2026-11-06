import '../models/atividade.dart';

/// Números exibidos no início, calculados a partir das atividades.
class Estatisticas {
  static const metaSemanal = 4;

  final int treinosNaSemana;
  final int minutosNaSemana;
  final int sequenciaDias;
  final int totalTreinos;

  /// Minutos treinados em cada um dos últimos 7 dias (o último é hoje).
  final List<int> minutosUltimos7Dias;

  const Estatisticas({
    required this.treinosNaSemana,
    required this.minutosNaSemana,
    required this.sequenciaDias,
    required this.totalTreinos,
    required this.minutosUltimos7Dias,
  });

  double get progressoMeta => (treinosNaSemana / metaSemanal).clamp(0, 1).toDouble();

  factory Estatisticas.calcular(List<Atividade> atividades, {DateTime? agora}) {
    final hoje = _dia(agora ?? DateTime.now());
    final inicioSemana = _somarDias(hoje, 1 - hoje.weekday);

    final minutosPorDia = <DateTime, int>{};
    for (final a in atividades) {
      final dia = _dia(a.data);
      minutosPorDia[dia] = (minutosPorDia[dia] ?? 0) + a.duracaoMin;
    }

    final daSemana = atividades.where((a) => !_dia(a.data).isBefore(inicioSemana)).toList();

    // Dias seguidos com treino, contando de hoje (ou de ontem, se hoje ainda não treinou).
    var sequencia = 0;
    var cursor = minutosPorDia.containsKey(hoje) ? hoje : _somarDias(hoje, -1);
    while (minutosPorDia.containsKey(cursor)) {
      sequencia++;
      cursor = _somarDias(cursor, -1);
    }

    return Estatisticas(
      treinosNaSemana: daSemana.length,
      minutosNaSemana: daSemana.fold(0, (soma, a) => soma + a.duracaoMin),
      sequenciaDias: sequencia,
      totalTreinos: atividades.length,
      minutosUltimos7Dias: [
        for (var i = 6; i >= 0; i--) minutosPorDia[_somarDias(hoje, -i)] ?? 0,
      ],
    );
  }

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _somarDias(DateTime d, int dias) => DateTime(d.year, d.month, d.day + dias);
}
