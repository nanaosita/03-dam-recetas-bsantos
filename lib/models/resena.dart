class Resena {
  final int? id;
  final String usuario;
  final int idReceta;
  final int calificacion;
  final String comentario;

  Resena({
    this.id,
    required this.usuario,
    required this.idReceta,
    required this.calificacion,
    required this.comentario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_receta': idReceta,
      'usuario': usuario,
      'calificacion': calificacion,
      'comentario': comentario,
    };
  }

  factory Resena.fromMap(Map<String, dynamic> map) {
    return Resena(
      id: map['id'],
      usuario: map['usuario'],
      idReceta: map['id_receta'],
      calificacion: map['calificacion'],
      comentario: map['comentario'],
    );
  }
}
