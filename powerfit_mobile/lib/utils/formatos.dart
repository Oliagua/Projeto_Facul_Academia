import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatos {
  static final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

  static String moeda(double valor) => _moeda.format(valor);

  static String data(DateTime d) => DateFormat('dd/MM/yyyy', 'pt_BR').format(d);

  /// Formato das colunas DATE do banco: "2026-11-05".
  static String dataSql(DateTime d) => '${anoMes(d)}-${d.day.toString().padLeft(2, '0')}';

  /// "2026-11"
  static String anoMes(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  /// "novembro"
  static String nomeMes(DateTime d) => DateFormat('MMMM', 'pt_BR').format(d);

  /// 55 → "55 min"; 135 → "2h15"
  static String duracao(int minutos) {
    if (minutos < 60) return '$minutos min';
    final resto = minutos % 60;
    return '${minutos ~/ 60}h${resto == 0 ? '' : resto.toString().padLeft(2, '0')}';
  }

  /// "Hoje", "Ontem" ou "seg., 12 de out."
  static String diaRelativo(DateTime d, {DateTime? agora}) {
    final hoje = _dia(agora ?? DateTime.now());
    final dia = _dia(d);
    if (dia == hoje) return 'Hoje';
    if (dia == DateTime(hoje.year, hoje.month, hoje.day - 1)) return 'Ontem';
    final formato = dia.year == hoje.year ? "EEE, d 'de' MMM" : "d 'de' MMM 'de' y";
    return DateFormat(formato, 'pt_BR').format(dia);
  }

  /// Letra do dia da semana para o gráfico: S, T, Q...
  static String inicialDiaSemana(DateTime d) =>
      const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][d.weekday - 1];

  static String saudacao({DateTime? agora}) {
    final hora = (agora ?? DateTime.now()).hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// 11987654321 → (11) 98765-4321
  static String telefone(String digitos) {
    if (digitos.length < 10) return digitos;
    final ddd = digitos.substring(0, 2);
    final resto = digitos.substring(2);
    final corte = resto.length - 4;
    return '($ddd) ${resto.substring(0, corte)}-${resto.substring(corte)}';
  }

  static DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Aplica a máscara (11) 98765-4321 enquanto o usuário digita.
class MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue antigo, TextEditingValue novo) {
    var digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final texto = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 0) texto.write('(');
      if (i == 2) texto.write(') ');
      if (i == (digitos.length == 11 ? 7 : 6)) texto.write('-');
      texto.write(digitos[i]);
    }
    final resultado = texto.toString();
    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(offset: resultado.length),
    );
  }
}
