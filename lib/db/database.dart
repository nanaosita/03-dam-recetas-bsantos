import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
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
            fecha TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
