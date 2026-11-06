import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Versão sem worker: roda em qualquer hospedagem estática, sem depender de
// SharedWorker (que algumas páginas bloqueiam).
DatabaseFactory get fabricaBanco => databaseFactoryFfiWebNoWebWorker;

Future<String> caminhoBanco(String nomeArquivo) async => nomeArquivo;
