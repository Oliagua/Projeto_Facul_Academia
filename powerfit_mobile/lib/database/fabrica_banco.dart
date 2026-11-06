// No celular usa o sqflite normal; no navegador usa SQLite em WebAssembly.
export 'fabrica_banco_nativo.dart'
    if (dart.library.js_interop) 'fabrica_banco_web.dart';
