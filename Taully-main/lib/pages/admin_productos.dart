import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';

import '../services/product_service.dart';

class AdminProductosPage extends StatefulWidget {
  const AdminProductosPage({Key? key}) : super(key: key);

  @override
  State<AdminProductosPage> createState() => _AdminProductosPageState();
}

class _AdminProductosPageState extends State<AdminProductosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ---------- PRODUCTOS ----------
  Future<void> _seleccionarImagen() async {
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
            content: Text('Formato no válido. Usa JPG, PNG, GIF...'),
          ),
        );
      }
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

    if (nombre.isEmpty || precioTexto.isEmpty) return;

    final precio = double.tryParse(precioTexto);
    if (precio == null) return;

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
      'address': _direccionController.text.trim(),
    };

    if (_editId != null) {
      await _productService.updateProduct(_editId!, data);
    } else {
      await _productService.addProduct(data);
    }

    _resetFormulario();
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
      _direccionController.clear();
    });
  }

  Future<void> _eliminarProducto(String id) async {
    await _productService.deleteProduct(id);
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
                headers: ['Nombre', 'Precio', 'Categoría', 'Dirección'],
                data:
                    productos
                        .map(
                          (p) => [
                            p['name'],
                            'S/ ${p['price']}',
                            p['category'],
                            p['address'] ?? '',
                          ],
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
    await _exportarPDF(productos);
  }

  Widget _buildFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              hintText: 'Ej: Av. Principal 123',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _categoriaSeleccionada,
            items:
                _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL de imagen (opcional)',
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  _imageFile = null;
                  _imageUrlManual = val;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar desde galería'),
            onPressed: _seleccionarImagen,
          ),
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
              const SizedBox(width: 12),
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

  Widget _buildListaProductos() {
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
                _categorias
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
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
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final productos =
                  snapshot.data!
                      .where(
                        (p) => p['name'].toString().toLowerCase().contains(
                          _filtroNombre,
                        ),
                      )
                      .toList();
              return ListView.builder(
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

                      subtitle: Text(
                        'S/ ${p['price']} · ${p['category']}\n📍 ${p['address'] ?? ''}',
                      ),
                      isThreeLine: true,
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
                                _direccionController.text = p['address'] ?? '';
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

  Widget _buildListaPedidos() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('pedidos')
              .orderBy('fecha', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final pedido = docs[index];
            final data = pedido.data() as Map<String, dynamic>;
            final estado = data['estado'] ?? 'Pendiente';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${data['nombre']} - $estado'),
                subtitle: Text('Total: S/ ${data['total']}'),
                onTap: () => _mostrarDetallePedido(context, data),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        estado == 'Pendiente'
                            ? Icons.cancel
                            : Icons.check_circle,
                        color:
                            estado == 'Pendiente' ? Colors.red : Colors.green,
                      ),
                      tooltip:
                          estado == 'Pendiente'
                              ? 'Marcar como finalizado'
                              : 'Marcar como pendiente',
                      onPressed: () async {
                        final nuevoEstado =
                            estado == 'Pendiente' ? 'Finalizado' : 'Pendiente';

                        await FirebaseFirestore.instance
                            .collection('pedidos')
                            .doc(pedido.id)
                            .update({'estado': nuevoEstado});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pedido marcado como $nuevoEstado'),
                            backgroundColor:
                                nuevoEstado == 'Finalizado'
                                    ? Colors.green
                                    : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 228, 151, 9),
                      ),
                      tooltip: 'Eliminar pedido',
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('pedidos')
                            .doc(pedido.id)
                            .delete();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- UI PRINCIPAL ----------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Productos'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.inventory), text: 'Productos'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _isAdding ? _buildFormulario() : _buildListaProductos(),
            _buildListaPedidos(),
          ],
        ),
        floatingActionButton:
            _tabController.index == 0 && !_isAdding
                ? FloatingActionButton(
                  onPressed: () => setState(() => _isAdding = true),
                  child: const Icon(Icons.add),
                )
                : null,
      ),
    );
  }

  void _mostrarDetallePedido(
    BuildContext context,
    Map<String, dynamic> pedido,
  ) {
    final List<dynamic> items = pedido['items'] ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '🧾 Detalle del Pedido',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight:
                    600, // Limita la altura para hacer scroll si es necesario
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.orange),
                      title: Text(pedido['nombre'] ?? 'Sin nombre'),
                      subtitle: const Text('Cliente'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(pedido['email'] ?? 'Sin correo'),
                      subtitle: const Text('Correo electrónico'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text(pedido['telefono'] ?? 'Sin teléfono'),
                      subtitle: const Text('Teléfono'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(pedido['direccion'] ?? 'No especificada'),
                      subtitle: const Text('Dirección'),
                    ),
                    const Divider(height: 32),
                    const Text(
                      '🛍️ Productos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) {
                      final subtotal = (item['price'] * item['quantity'])
                          .toStringAsFixed(2);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['name']} x${item['quantity']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text('S/ $subtotal'),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'S/ ${pedido['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado:'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                pedido['estado'] == 'Finalizado'
                                    ? Colors.green[100]
                                    : Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pedido['estado'] ?? 'Pendiente',
                            style: TextStyle(
                              color:
                                  pedido['estado'] == 'Finalizado'
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
