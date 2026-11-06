import 'package:flutter/material.dart';

import '../theme.dart';

/// Marca igual à do site: selo "PF" amarelo + "PowerFit Academia".
class LogoPowerFit extends StatelessWidget {
  const LogoPowerFit({super.key, this.claro = false, this.tamanho = 26});

  /// true para texto branco sobre fundo escuro.
  final bool claro;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final cor = claro ? Colors.white : CoresPowerFit.tinta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: tamanho * 1.45,
          height: tamanho * 1.45,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: CoresPowerFit.destaque,
            shape: BoxShape.circle,
          ),
          child: Text(
            'PF',
            style: estiloTitulo(tamanho * 0.62, cor: CoresPowerFit.tinta),
          ),
        ),
        SizedBox(width: tamanho * 0.4),
        Text('PowerFit', style: estiloTitulo(tamanho, cor: cor, peso: FontWeight.w700)),
        SizedBox(width: tamanho * 0.25),
        Padding(
          padding: EdgeInsets.only(top: tamanho * 0.2),
          child: Text(
            'Academia',
            style: TextStyle(
              fontSize: tamanho * 0.5,
              color: claro ? Colors.white70 : CoresPowerFit.cinza,
            ),
          ),
        ),
      ],
    );
  }
}
