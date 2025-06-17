import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/product_service.dart';

class AdminProductosPage extends StatefulWidget {
  const AdminProductosPage({Key? key}) : super(key: key);

  @override
  _AdminProductosPageState createState() => _AdminProductosPageState();
}

class _AdminProductosPageState extends State<AdminProductosPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categorias = [
    'Abarrotes',
    'Golosinas',
    'Prod.Limpieza',
    'Comd.Animales',
  ];

  String _categoriaSeleccionada = 'Abarrotes';
  String _filtroNombre = '';
  File? _imageFile;
  String? _imageUrlManual;
  final ImagePicker _picker = ImagePicker();
  bool _isAdding = false;
  String? _editId;

  Future<void> _seleccionarImagen() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final ext = path.extension(pickedFile.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _imageUrlManual = null;
            _urlController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formato no válido. Usa JPG, PNG, GIF, etc.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<String?> _subirImagen(File imagen) async {
    try {
      final fileName = path.basename(imagen.path);
      final ref = FirebaseStorage.instance.ref().child('productos/$fileName');
      await ref.putFile(imagen);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final precioTexto = _precioController.text.trim();
    final urlManual = _urlController.text.trim();

    if (nombre.isEmpty || precioTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son obligatorios')),
      );
      return;
    }

    final precio = double.tryParse(precioTexto);
    if (precio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Precio inválido')));
      return;
    }

    String imageUrl = 'https://via.placeholder.com/150';
    if (_imageFile != null) {
      final url = await _subirImagen(_imageFile!);
      if (url != null) imageUrl = url;
    } else if (urlManual.isNotEmpty) {
      imageUrl = urlManual;
    }

    final data = {
      'name': nombre,
      'price': precio,
      'category': _categoriaSeleccionada,
      'image': imageUrl,
    };

    try {
      if (_editId != null) {
        await _productService.updateProduct(_editId!, data);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
      } else {
        await _productService.addProduct(data);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto agregado')));
      }
      _resetFormulario();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _resetFormulario() {
    setState(() {
      _isAdding = false;
      _editId = null;
      _imageFile = null;
      _imageUrlManual = null;
      _urlController.clear();
      _nombreController.clear();
      _precioController.clear();
    });
  }

  Future<void> _eliminarProducto(String id) async {
    try {
      await _productService.deleteProduct(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _exportarPDF(List<Map<String, dynamic>> productos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text('Lista de Productos - $_categoriaSeleccionada'),
              ),
              pw.Table.fromTextArray(
                headers: ['Nombre', 'Precio', 'Categoría'],
                data:
                    productos
                        .map(
                          (p) => [p['name'], 'S/ ${p['price']}', p['category']],
                        )
                        .toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _exportarTodosLosProductos() async {
    final productos = await _productService.getAllProducts().first;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text('Lista completa de productos'),
              ),
              pw.Table.fromTextArray(
                headers: ['Nombre', 'Precio', 'Categoría'],
                data:
                    productos
                        .map(
                          (p) => [p['name'], 'S/ ${p['price']}', p['category']],
                        )
                        .toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Productos')),
      body: _isAdding ? _buildFormulario() : _buildLista(),
      floatingActionButton:
          !_isAdding
              ? FloatingActionButton(
                onPressed: () => setState(() => _isAdding = true),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre del producto'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _categoriaSeleccionada,
            items:
                _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
            onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL de imagen (opcional)',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _imageFile = null;
                  _imageUrlManual = value;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar imagen desde galería'),
            onPressed: _seleccionarImagen,
          ),
          const SizedBox(height: 8),
          if (_imageFile != null)
            Image.file(_imageFile!, height: 120, fit: BoxFit.cover),
          if (_imageFile == null && _imageUrlManual != null)
            Image.network(_imageUrlManual!, height: 120, fit: BoxFit.cover),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _guardarProducto,
                  child: const Text('Guardar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFormulario,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                  ),
                  onChanged:
                      (val) => setState(
                        () => _filtroNombre = val.trim().toLowerCase(),
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Exportar esta categoría',
                onPressed: () {
                  _productService
                      .getProductsByCategory(_categoriaSeleccionada)
                      .first
                      .then((productos) {
                        final filtrados =
                            productos
                                .where(
                                  (p) => p['name']
                                      .toString()
                                      .toLowerCase()
                                      .contains(_filtroNombre),
                                )
                                .toList();
                        _exportarPDF(filtrados);
                      });
                },
              ),
              IconButton(
                icon: const Icon(Icons.file_copy),
                tooltip: 'Exportar todo',
                onPressed: _exportarTodosLosProductos,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: _categoriaSeleccionada,
            items:
                _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
            onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
            decoration: const InputDecoration(
              labelText: 'Filtrar por categoría',
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _productService.getProductsByCategory(
              _categoriaSeleccionada,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(child: Text('No hay productos'));

              final productos =
                  snapshot.data!
                      .where(
                        (p) => p['name'].toString().toLowerCase().contains(
                          _filtroNombre,
                        ),
                      )
                      .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        p['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(p['name']),
                      subtitle: Text('S/ ${p['price']} - ${p['category']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _editId = p['id'];
                                _nombreController.text = p['name'];
                                _precioController.text = p['price'].toString();
                                _categoriaSeleccionada = p['category'];
                                _imageUrlManual = p['image'];
                                _urlController.text = p['image'];
                                _imageFile = null;
                                _isAdding = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarProducto(p['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
