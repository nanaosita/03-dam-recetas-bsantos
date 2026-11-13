class Resena {
  final int? id;
  final int idReceta;
  final int calificacion;
  final String comentario;
  final String fecha;

  Resena({
    this.id,
    required this.idReceta,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_receta': idReceta,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha,
    };
  }

  factory Resena.fromMap(Map<String, dynamic> map) {
    return Resena(
      id: map['id'],
      idReceta: map['id_receta'],
      calificacion: map['calificacion'],
      comentario: map['comentario'],
      fecha: map['fecha'],
    );
  }
}
