import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto 1er Departamental',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainActivity(),
    );
  }
}

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  int currentImageIndex = 0;
  List<String> images = [
    'assets/images/gundam_1.jpg',
    'assets/images/gundam_2.jpg',
    'assets/images/rx_0_1.jpg',
    'assets/images/rx_0_2.jpg',
    'assets/images/unicorn.jpg',
  ];
  Set<String> favoriteImages = {};

  double _rotation = 0.0;
  double _scale = 1.0;
  bool _isBlackAndWhite = false;
  
  bool _isDrawingEnabled = false;
  Color _brushColor = Colors.red;
  List<DrawnPath> _paths = [];
  DrawnPath? _currentPath;

  void resetEffects() {
    setState(() {
      _rotation = 0.0;
      _scale = 1.0;
      _isBlackAndWhite = false;
      _isDrawingEnabled = false;
      _paths.clear();
      _currentPath = null;
    });
  }

  void updateFavorite() {
    if (images.isEmpty) return;
    final currentImage = images[currentImageIndex];
    if (favoriteImages.contains(currentImage)) {
      favoriteImages.remove(currentImage);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
    } else {
      favoriteImages.add(currentImage);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añadido a favoritos')));
    }
    setState(() {});
  }

  void deleteImage() {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay imágenes para eliminar')));
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar imagen'),
          content: const Text('¿Estás seguro de que deseas eliminar esta imagen de la galería?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final removedImage = images.removeAt(currentImageIndex);
                favoriteImages.remove(removedImage);
                if (images.isEmpty) {
                  currentImageIndex = 0;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No quedan más imágenes')));
                } else {
                  if (currentImageIndex >= images.length) {
                    currentImageIndex = images.length - 1;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen eliminada')));
                }
                resetEffects();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      }
    );
  }

  void showEditOptions() {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay imágenes para editar')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones de Edición'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Rotar 90°'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _rotation += 90.0;
                  });
                },
              ),
              ListTile(
                title: const Text('Filtro: Blanco y Negro'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isBlackAndWhite = true;
                  });
                },
              ),
              ListTile(
                title: const Text('Redimensionar'),
                onTap: () {
                  Navigator.pop(context);
                  showResizeDialog();
                },
              ),
              ListTile(
                title: const Text('Pintar'),
                onTap: () {
                  Navigator.pop(context);
                  showPaintColorOptions();
                },
              ),
              ListTile(
                title: const Text('Restablecer'),
                onTap: () {
                  Navigator.pop(context);
                  resetEffects();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void showResizeDialog() {
    double tempScale = _scale;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajustar Tamaño'),
              content: Slider(
                min: 0.1,
                max: 3.0,
                value: tempScale,
                onChanged: (value) {
                  setDialogState(() {
                    tempScale = value;
                  });
                  setState(() {
                    _scale = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void showPaintColorOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Elige un color de pincel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Rojo'),
                onTap: () {
                  Navigator.pop(context);
                  enablePainting(Colors.red);
                },
              ),
              ListTile(
                title: const Text('Azul'),
                onTap: () {
                  Navigator.pop(context);
                  enablePainting(Colors.blue);
                },
              ),
              ListTile(
                title: const Text('Verde'),
                onTap: () {
                  Navigator.pop(context);
                  enablePainting(Colors.green);
                },
              ),
              ListTile(
                title: const Text('Negro'),
                onTap: () {
                  Navigator.pop(context);
                  enablePainting(Colors.black);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void enablePainting(Color color) {
    setState(() {
      _isDrawingEnabled = true;
      _brushColor = color;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modo pintar activado')));
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = images.isNotEmpty && favoriteImages.contains(images[currentImageIndex]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyecto 1er Departamental'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (images.isNotEmpty)
                  Transform.scale(
                    scale: _scale,
                    child: Transform.rotate(
                      angle: _rotation * 3.141592653589793 / 180,
                      child: _isBlackAndWhite 
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.33, 0.33, 0.33, 0, 0,
                              0.33, 0.33, 0.33, 0, 0,
                              0.33, 0.33, 0.33, 0, 0,
                              0,    0,    0,    1, 0,
                            ]),
                            child: Image.asset(images[currentImageIndex]),
                          )
                        : Image.asset(images[currentImageIndex]),
                    ),
                  )
                else
                  const Icon(Icons.image, size: 100, color: Colors.grey),

                if (_isDrawingEnabled || _paths.isNotEmpty)
                  GestureDetector(
                    onPanStart: _isDrawingEnabled ? (details) {
                      setState(() {
                        _currentPath = DrawnPath(
                          path: Path()..moveTo(details.localPosition.dx, details.localPosition.dy),
                          color: _brushColor,
                        );
                      });
                    } : null,
                    onPanUpdate: _isDrawingEnabled ? (details) {
                      setState(() {
                        _currentPath?.path.lineTo(details.localPosition.dx, details.localPosition.dy);
                      });
                    } : null,
                    onPanEnd: _isDrawingEnabled ? (details) {
                      setState(() {
                        if (_currentPath != null) {
                          _paths.add(_currentPath!);
                          _currentPath = null;
                        }
                      });
                    } : null,
                    child: Container(
                      color: Colors.transparent, // Ensures it captures gestures over transparent parts
                      child: CustomPaint(
                        painter: DrawingPainter(paths: _paths, currentPath: _currentPath),
                        size: Size.infinite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Navigation arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 40),
                onPressed: () {
                  if (images.isNotEmpty) {
                    setState(() {
                      currentImageIndex = currentImageIndex - 1 < 0 ? images.length - 1 : currentImageIndex - 1;
                      resetEffects();
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 40),
                onPressed: () {
                  if (images.isNotEmpty) {
                    setState(() {
                      currentImageIndex = (currentImageIndex + 1) % images.length;
                      resetEffects();
                    });
                  }
                },
              ),
            ],
          ),
          
          // Bottom toolbar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.edit, 'Editar', showEditOptions),
                _buildActionButton(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  'Favorito',
                  updateFavorite,
                  color: isFavorite ? Colors.pink : Colors.grey,
                ),
                _buildActionButton(Icons.delete, 'Eliminar', deleteImage),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color color = Colors.black87}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class DrawnPath {
  final Path path;
  final Color color;

  DrawnPath({required this.path, required this.color});
}

class DrawingPainter extends CustomPainter {
  final List<DrawnPath> paths;
  final DrawnPath? currentPath;

  DrawingPainter({required this.paths, this.currentPath});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawnPath in paths) {
      final paint = Paint()
        ..color = drawnPath.color
        ..strokeWidth = 15.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(drawnPath.path, paint);
    }
    
    if (currentPath != null) {
      final paint = Paint()
        ..color = currentPath!.color
        ..strokeWidth = 15.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(currentPath!.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
