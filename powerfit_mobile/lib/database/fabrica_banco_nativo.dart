import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

DatabaseFactory get fabricaBanco => databaseFactory;

Future<String> caminhoBanco(String nomeArquivo) async {
  return join(await getDatabasesPath(), nomeArquivo);
}
