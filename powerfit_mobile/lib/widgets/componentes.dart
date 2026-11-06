import 'package:flutter/material.dart';

import '../theme.dart';

/// Título de seção no estilo do site: linha pequena amarela + título grande.
class TituloSecao extends StatelessWidget {
  const TituloSecao({
    super.key,
    required this.chamada,
    required this.titulo,
    this.acao,
    this.aoTocarAcao,
    this.claro = false,
  });

  final String chamada;
  final String titulo;
  final String? acao;
  final VoidCallback? aoTocarAcao;
  final bool claro;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chamada.toUpperCase(),
                style: const TextStyle(
                  color: CoresPowerFit.destaque,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: estiloTitulo(26, cor: claro ? Colors.white : CoresPowerFit.tinta),
              ),
            ],
          ),
        ),
        if (acao != null)
          TextButton(
            onPressed: aoTocarAcao,
            style: TextButton.styleFrom(
              foregroundColor: claro ? CoresPowerFit.destaque : CoresPowerFit.tinta,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text(acao!), const SizedBox(width: 4), const Icon(Icons.arrow_forward, size: 18)],
            ),
          ),
      ],
    );
  }
}

/// Foto dos arquivos do app com cantos arredondados e degradê opcional.
class Foto extends StatelessWidget {
  const Foto(
    this.caminho, {
    super.key,
    this.raio = 16,
    this.degrade = false,
    this.alinhamento = Alignment.center,
  });

  final String caminho;
  final double raio;
  final bool degrade;
  final Alignment alinhamento;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            caminho,
            fit: BoxFit.cover,
            alignment: alinhamento,
            errorBuilder: (_, _, _) => Container(color: CoresPowerFit.grafite),
          ),
          if (degrade)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x33000000), Color(0xDD000000)],
                  stops: [0.3, 0.55, 1],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selo redondo com a letra do treino (A, B, C...).
class SeloLetra extends StatelessWidget {
  const SeloLetra(this.letra, {super.key, this.tamanho = 40});

  final String letra;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: CoresPowerFit.destaque, shape: BoxShape.circle),
      child: Text(letra, style: estiloTitulo(tamanho * 0.55)),
    );
  }
}

/// Ícone + texto pequeno, usado nas informações dos treinos.
class InfoPequena extends StatelessWidget {
  const InfoPequena(this.icone, this.texto, {super.key, this.cor});

  final IconData icone;
  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? CoresPowerFit.cinza;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: c),
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(fontSize: 13, color: c, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// Avatar com as iniciais do aluno.
class AvatarIniciais extends StatelessWidget {
  const AvatarIniciais(this.iniciais, {super.key, this.tamanho = 48});

  final String iniciais;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CoresPowerFit.destaque,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: tamanho / 20),
      ),
      child: Text(iniciais, style: estiloTitulo(tamanho * 0.4)),
    );
  }
}

/// Botão amarelo que mostra um indicador enquanto salva.
class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.carregando = false,
    this.icone,
  });

  final String texto;
  final VoidCallback? aoPressionar;
  final bool carregando;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: carregando ? null : aoPressionar,
      child: carregando
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: CoresPowerFit.tinta),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icone != null) ...[Icon(icone, size: 20), const SizedBox(width: 8)],
                Text(texto),
              ],
            ),
    );
  }
}

/// Mensagem quando uma lista está vazia.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: CoresPowerFit.destaqueSuave,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 42, color: CoresPowerFit.destaque),
          ),
          const SizedBox(height: 20),
          Text(titulo, textAlign: TextAlign.center, style: estiloTitulo(24)),
          const SizedBox(height: 8),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: CoresPowerFit.cinza, height: 1.4),
          ),
          if (acao != null) ...[const SizedBox(height: 24), acao!],
        ],
      ),
    );
  }
}

/// Caixa de erro usada nos formulários.
class MensagemErro extends StatelessWidget {
  const MensagemErro(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cor),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: TextStyle(color: cor))),
        ],
      ),
    );
  }
}

/// Etiqueta amarela pequena, como a "Recomendado" dos planos no site.
class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.escura = false});

  final String texto;
  final bool escura;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: escura ? CoresPowerFit.tinta : CoresPowerFit.destaque,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: escura ? CoresPowerFit.destaque : CoresPowerFit.tinta,
        ),
      ),
    );
  }
}

/// Cartão branco com borda fina, padrão das telas.
class Cartao extends StatelessWidget {
  const Cartao({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.aoTocar});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CoresPowerFit.linha),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
