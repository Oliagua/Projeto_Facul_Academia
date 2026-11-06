import 'package:flutter/material.dart';

/// Mesmas cores usadas no site (style.css).
class CoresPowerFit {
  static const tinta = Color(0xFF111111);
  static const escuro = Color(0xFF1A1A1A);
  static const grafite = Color(0xFF2A2A2A);
  static const cinza = Color(0xFF555555);
  static const cinzaClaro = Color(0xFF8A8A8A);
  static const linha = Color(0xFFDEDEDE);
  static const creme = Color(0xFFF5F3ED);
  static const destaque = Color(0xFFFFB400);
  static const destaqueSuave = Color(0xFFFFF3D6);
  static const sucesso = Color(0xFF2E7D32);
}

/// Fonte dos títulos, como no site.
const fonteTitulo = 'BarlowCondensed';

TextStyle estiloTitulo(double tamanho, {Color? cor, FontWeight peso = FontWeight.w800}) {
  return TextStyle(
    fontFamily: fonteTitulo,
    fontSize: tamanho,
    fontWeight: peso,
    height: 1.05,
    letterSpacing: 0.2,
    color: cor ?? CoresPowerFit.tinta,
  );
}

ThemeData temaPowerFit() {
  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: CoresPowerFit.linha),
  );

  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: CoresPowerFit.destaque,
      primary: CoresPowerFit.tinta,
      onPrimary: Colors.white,
      secondary: CoresPowerFit.destaque,
      onSecondary: CoresPowerFit.tinta,
      surface: Colors.white,
      onSurface: CoresPowerFit.tinta,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: CoresPowerFit.creme,
    textTheme: base.textTheme.copyWith(
      headlineLarge: estiloTitulo(36),
      headlineMedium: estiloTitulo(30),
      headlineSmall: estiloTitulo(26),
      titleLarge: estiloTitulo(22, peso: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CoresPowerFit.creme,
      foregroundColor: CoresPowerFit.tinta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: estiloTitulo(26),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: borda,
      enabledBorder: borda,
      focusedBorder: borda.copyWith(
        borderSide: const BorderSide(color: CoresPowerFit.destaque, width: 2),
      ),
      prefixIconColor: CoresPowerFit.cinza,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CoresPowerFit.destaque,
        foregroundColor: CoresPowerFit.tinta,
        disabledBackgroundColor: CoresPowerFit.destaque.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CoresPowerFit.tinta,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: CoresPowerFit.tinta, width: 1.5),
        textStyle: const TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CoresPowerFit.tinta,
        textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CoresPowerFit.destaque,
      foregroundColor: CoresPowerFit.tinta,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CoresPowerFit.tinta,
      indicatorColor: CoresPowerFit.destaque,
      surfaceTintColor: Colors.transparent,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (estados) => IconThemeData(
          color: estados.contains(WidgetState.selected) ? CoresPowerFit.tinta : Colors.white70,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: estados.contains(WidgetState.selected) ? CoresPowerFit.destaque : Colors.white70,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: CoresPowerFit.tinta,
      contentTextStyle: const TextStyle(fontFamily: 'DMSans', color: Colors.white),
      actionTextColor: CoresPowerFit.destaque,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: const BorderSide(color: CoresPowerFit.linha),
      selectedColor: CoresPowerFit.destaque,
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: CoresPowerFit.tinta),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(color: CoresPowerFit.linha, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
