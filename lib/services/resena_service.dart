import 'package:recetasapp/db/database.dart';
import 'package:recetasapp/models/resena.dart';

class ResenaService {
  Future<int> guardarResena(Resena resena) async {
    final db = await DatabaseHelper.instance.database;

    return await db.insert(
      'resenas',
      resena.toMap(),
    );
  }

  Future<List<Resena>> obtenerResenas(int idReceta) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> resultados =
        await db.query(
      'resenas',
      where: 'id_receta = ?',
      whereArgs: [idReceta],
      orderBy: 'id DESC',
    );

    return resultados.map((map) => Resena.fromMap(map)).toList();
  }
}
