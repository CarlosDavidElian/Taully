import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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

  final List<String> _categorias = [
    'Abarrotes',
    'Golosinas',
    'Prod.Limpieza',
    'Comd.Animales',
  ];
  String _categoriaSeleccionada = 'Abarrotes';
  File? _imageFile;
  String? _imageUrlManual;
  final ImagePicker _picker = ImagePicker();
  bool _isAdding = false;
  String? _editId;

  void _mostrarFormulario({Map<String, dynamic>? producto}) {
    if (producto != null) {
      _editId = producto['id'];
      _nombreController.text = producto['name'];
      _precioController.text = producto['price'].toString();
      _categoriaSeleccionada = producto['category'];
      _imageUrlManual = producto['image'];
      _urlController.text = producto['image'] ?? '';
      _imageFile = null;
    } else {
      _editId = null;
      _nombreController.clear();
      _precioController.clear();
      _urlController.clear();
      _imageUrlManual = null;
      _categoriaSeleccionada = _categorias[0];
      _imageFile = null;
    }
    setState(() => _isAdding = true);
  }

  void _ocultarFormulario() {
    setState(() {
      _isAdding = false;
      _editId = null;
      _imageFile = null;
      _imageUrlManual = null;
      _urlController.clear();
    });
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrlManual = null;
        _urlController.clear();
      });
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
    final String nombre = _nombreController.text.trim();
    final String precioTexto = _precioController.text.trim();
    final String urlManual = _urlController.text.trim();

    if (nombre.isEmpty || precioTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son obligatorios')),
      );
      return;
    }

    double? precio = double.tryParse(precioTexto);
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

    final productoData = {
      'name': nombre,
      'price': precio,
      'category': _categoriaSeleccionada,
      'image': imageUrl,
    };

    try {
      if (_editId != null) {
        await _productService.updateProduct(_editId!, productoData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
      } else {
        await _productService.addProduct(productoData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto agregado')));
      }
      _ocultarFormulario();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Productos')),
      body: _isAdding ? _buildFormulario() : _buildLista(),
      floatingActionButton:
          !_isAdding
              ? FloatingActionButton(
                onPressed: () => _mostrarFormulario(),
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
                  onPressed: _ocultarFormulario,
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
          padding: const EdgeInsets.all(16),
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

              final productos = snapshot.data!;
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
                            onPressed: () => _mostrarFormulario(producto: p),
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
