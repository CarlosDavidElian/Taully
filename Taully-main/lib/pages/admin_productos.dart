import 'package:flutter/material.dart';

class AdminProductos extends StatefulWidget {
  const AdminProductos({super.key});

  @override
  State<AdminProductos> createState() => _AdminProductosState();
}

class _AdminProductosState extends State<AdminProductos> {
  final List<Map<String, dynamic>> _productos = [
    {'id': 1, 'nombre': 'Producto 1', 'precio': 10.0},
    {'id': 2, 'nombre': 'Producto 2', 'precio': 20.0},
  ];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();
  int? _idEditando;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _buscarProductos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _busquedaController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => _buscarProductos(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                return ListTile(
                  title: Text(producto['nombre']),
                  subtitle: Text('\$${producto['precio'].toString()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarProducto(producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarProducto(producto['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _mostrarFormulario,
      ),
    );
  }

  void _mostrarFormulario() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_idEditando == null ? 'Agregar Producto' : 'Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _guardarProducto,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarProducto() {
    if (_nombreController.text.isEmpty || _precioController.text.isEmpty) return;

    final nuevoProducto = {
      'id': _idEditando ?? DateTime.now().millisecondsSinceEpoch,
      'nombre': _nombreController.text,
      'precio': double.parse(_precioController.text),
    };

    setState(() {
      if (_idEditando != null) {
        final index = _productos.indexWhere((p) => p['id'] == _idEditando);
        _productos[index] = nuevoProducto;
      } else {
        _productos.add(nuevoProducto);
      }
      _nombreController.clear();
      _precioController.clear();
      _idEditando = null;
      Navigator.pop(context);
    });
  }

  void _editarProducto(Map<String, dynamic> producto) {
    _nombreController.text = producto['nombre'];
    _precioController.text = producto['precio'].toString();
    _idEditando = producto['id'];
    _mostrarFormulario();
  }

  void _eliminarProducto(int id) {
    setState(() {
      _productos.removeWhere((producto) => producto['id'] == id);
    });
  }

  void _buscarProductos() {
    // Implementación básica de búsqueda
    // En una app real, esto se conectaría a una API o base de datos
    final query = _busquedaController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) return;
      _productos.retainWhere((p) => 
          p['nombre'].toLowerCase().contains(query));
    });
  }
}