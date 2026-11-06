import 'package:flutter_test/flutter_test.dart';
import 'package:powerfit_mobile/models/atividade.dart';
import 'package:powerfit_mobile/services/estatisticas.dart';

Atividade _treino(DateTime data, int minutos) => Atividade(
      usuarioId: 1,
      titulo: 'Treino',
      data: data,
      duracaoMin: minutos,
      intensidade: Intensidade.moderada,
    );

void main() {
  // Quinta-feira, 15 de outubro de 2026.
  final agora = DateTime(2026, 10, 15, 19);

  test('conta treinos e minutos da semana (a partir de segunda)', () {
    final stats = Estatisticas.calcular([
      _treino(DateTime(2026, 10, 15, 8), 60),
      _treino(DateTime(2026, 10, 12, 7), 45), // segunda
      _treino(DateTime(2026, 10, 11, 9), 30), // domingo anterior: fora da semana
    ], agora: agora);

    expect(stats.treinosNaSemana, 2);
    expect(stats.minutosNaSemana, 105);
    expect(stats.totalTreinos, 3);
    expect(stats.progressoMeta, 0.5);
  });

  test('sequência conta dias seguidos até hoje ou ontem', () {
    final ateOntem = Estatisticas.calcular([
      _treino(DateTime(2026, 10, 14), 30),
      _treino(DateTime(2026, 10, 13), 30),
      _treino(DateTime(2026, 10, 11), 30),
    ], agora: agora);
    expect(ateOntem.sequenciaDias, 2);

    final quebrada = Estatisticas.calcular([_treino(DateTime(2026, 10, 12), 30)], agora: agora);
    expect(quebrada.sequenciaDias, 0);
  });

  test('gráfico soma os minutos de cada um dos últimos 7 dias', () {
    final stats = Estatisticas.calcular([
      _treino(DateTime(2026, 10, 15, 7), 30),
      _treino(DateTime(2026, 10, 15, 18), 20),
      _treino(DateTime(2026, 10, 9), 40),
      _treino(DateTime(2026, 10, 8), 99), // 8 dias atrás: fora
    ], agora: agora);

    expect(stats.minutosUltimos7Dias, [40, 0, 0, 0, 0, 0, 50]);
  });
}
