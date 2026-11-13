import 'package:flutter/material.dart';
import 'package:recetasapp/models/receta.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:recetasapp/services/resena_service.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});
  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final ResenaService _resenaService = ResenaService();
  late Future<List<Resena>> _resenasFuture;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  void _cargarResenas() {
    _resenasFuture = _resenaService.obtenerResenas(widget.receta.id);
  }

  Future<void> _mostrarFormulario() async {
    int calificacionSeleccionada = 5;
    final comentarioController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text("Agregar reseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("¿Qué calificación le das a esta receta?"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          actualizarDialogo(() {
                            calificacionSeleccionada = index + 1;
                          });
                        },
                        icon: Icon(
                          index < calificacionSeleccionada
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Escribe tu comentario...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (comentarioController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true) {
      try {
        final nuevaResena = Resena(
          idReceta: widget.receta.id,
          calificacion: calificacionSeleccionada,
          comentario: comentarioController.text.trim(),
          fecha: DateTime.now().toIso8601String(),
        );

        await _resenaService.guardarResena(nuevaResena);

        if (!mounted) return;

        setState(() {
          _cargarResenas();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reseña guardada correctamente")),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar la reseña: $e")),
        );
      }
    }

    comentarioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la receta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(14),
            child: Image.network(
              receta.imagenURL,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                "assets/images/imagen_default.png",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ingredientes: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.orange),
                  const SizedBox(height: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Preparación: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entrada.key + 1}',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),

          // SECCION DE RESEÑAS
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Reseñas de la receta",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: _mostrarFormulario,
            icon: const Icon(Icons.rate_review),
            label: const Text("Agregar reseña"),
          ),

          const SizedBox(height: 15),

          FutureBuilder<List<Resena>>(
            future: _resenasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text("Error al cargar las reseñas: ${snapshot.error}");
              }

              final resenas = snapshot.data ?? [];

              if (resenas.isEmpty) {
                return const Text(
                  "Todavía no hay reseñas. ¡Sé el primero en comentar!",
                );
              }

              return Column(
                children: resenas.map((resena) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < resena.calificacion
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(resena.comentario),
                          const SizedBox(height: 8),
                          Text(
                            resena.fecha.split('T').first,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
