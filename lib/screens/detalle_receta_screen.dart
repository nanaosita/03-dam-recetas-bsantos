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

  bool _mostrarFormulario = false;
  int _calificacionSeleccionada = 5;

  final comentarioController = TextEditingController();
  final nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  void _cargarResenas() {
    _resenasFuture = _resenaService.obtenerResenas(widget.receta.id);
  }

  Future<void> _guardarResena() async {
    if (nombreController.text.trim().isEmpty ||
        comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa tu nombre y comentario"),
        ),
      );
      return;
    }

    try {
      final nuevaResena = Resena(
        idReceta: widget.receta.id,
        usuario: nombreController.text.trim(),
        calificacion: _calificacionSeleccionada,
        comentario: comentarioController.text.trim(),
      );

      await _resenaService.guardarResena(nuevaResena);
      if (!mounted) return;

      setState(() {
        _mostrarFormulario = false;
        _calificacionSeleccionada = 5;
        nombreController.clear();
        comentarioController.clear();
        _resenasFuture =
            _resenaService.obtenerResenas(widget.receta.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reseña guardada correctamente"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar la reseña: $e")),
      );
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    comentarioController.dispose();
    super.dispose();
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

          const SizedBox(height: 16),
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
                  const SizedBox(width: 8),
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

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Reseñas de la receta",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _mostrarFormulario = !_mostrarFormulario;
              });
            },
            icon: const Icon(Icons.rate_review),
            label: Text(
              _mostrarFormulario ? "Cancelar reseña" : "Agregar reseña",
            ),
          ),

          if (_mostrarFormulario) ...[
            const SizedBox(height: 15),
            const Text(
              "Escribe tu reseña",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Tu nombre",
                hintText: "Escribe tu nombre",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            const Text("¿Qué calificación le das a esta receta?"),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _calificacionSeleccionada = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _calificacionSeleccionada
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),

            TextField(
              controller: comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Comentario",
                hintText: "Escribe tu comentario...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarResena,
                child: const Text("Guardar reseña"),
              ),
            ),
          ],

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
                          Text(
                            resena.usuario,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),
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