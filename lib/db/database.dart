import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseR {
  static final DatabaseR instance = DatabaseR._init();
  static Database? _database;

  DatabaseR._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('recetas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE resenas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_receta INTEGER NOT NULL,
            calificacion INTEGER NOT NULL,
            comentario TEXT NOT NULL,
            usuario TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertarResena(Map<String, dynamic> datos) async {
    final db = await database;
    return await db.insert('resenas', datos);
  }

  Future<List<Map<String, dynamic>>> obtenerResenas(int idReceta) async {
    final db = await database;

    return await db.query(
      'resenas',
      where: 'id_receta = ?',
      whereArgs: [idReceta],
      orderBy: 'id DESC',
    );
  }

  Future<int> actualizarResena(
    int id,
    Map<String, dynamic> datos,
  ) async {
    final db = await database;

    return await db.update(
      'resenas',
      datos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarResena(int id) async {
    final db = await database;
    return await db.delete(
      'resenas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
