import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductos extends StatefulWidget {
  const AdminProductos({super.key});

  @override
  State<AdminProductos> createState() => _AdminProductosState();
}

class _AdminProductosState extends State<AdminProductos> {
  final List<Product> _productos = [
    Product(
      id: '1',
      name: 'Producto 1',
      price: 10.0,
      imageType: ImageType.network,
      imagePath: 'https://via.placeholder.com/150',
      description: 'Descripción del producto 1',
    ),
    Product(
      id: '2',
      name: 'Producto 2',
      price: 20.0,
      imageType: ImageType.network,
      imagePath: 'https://via.placeholder.com/150',
      description: 'Descripción del producto 2',
    ),
    Product(
      id: '3',
      name: 'Producto 3',
      price: 32.0,
      imageType: ImageType.network,
      imagePath: 'https://via.placeholder.com/150',
      description: 'Descripción del producto 3',
    ),
  ];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isAddingProduct = false;
  String? _idEditando;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _mostrarFormularioAgregar() {
    setState(() {
      _isAddingProduct = true;
      _nombreController.clear();
      _precioController.clear();
      _descripcionController.clear();
      _imageFile = null;
      _idEditando = null;
    });
  }

  void _ocultarFormulario() {
    setState(() {
      _isAddingProduct = false;
    });
  }

  void _guardarProducto() {
    // Validación básica
    if (_nombreController.text.isEmpty || _precioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y precio son obligatorios')),
      );
      return;
    }

    final double? price = double.tryParse(_precioController.text.replaceAll(',', '.'));
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser un número válido')),
      );
      return;
    }

    if (_idEditando != null) {
      // Editar producto existente
      final index = _productos.indexWhere((p) => p.id == _idEditando);
      if (index != -1) {
        final Product updatedProduct = Product(
          id: _idEditando!,
          name: _nombreController.text,
          price: price,
          description: _descripcionController.text,
          imageType: _imageFile != null ? ImageType.file : _productos[index].imageType,
          imagePath: _imageFile != null ? _imageFile!.path : _productos[index].imagePath,
        );

        setState(() {
          _productos[index] = updatedProduct;
          _isAddingProduct = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado con éxito')),
        );
      }
    } else {
      // Crear nuevo producto
      final Product newProduct = Product(
        id: DateTime.now().toString(),
        name: _nombreController.text,
        price: price,
        description: _descripcionController.text,
        // Si no hay imagen seleccionada, usamos una imagen de placeholder
        imageType: _imageFile != null ? ImageType.file : ImageType.network,
        imagePath: _imageFile != null ? _imageFile!.path : 'https://via.placeholder.com/150',
      );

      setState(() {
        _productos.add(newProduct);
        _isAddingProduct = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado con éxito')),
      );
    }
  }

  void _eliminarProducto(String id) {
    setState(() {
      _productos.removeWhere((product) => product.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado')),
    );
  }

  void _editarProducto(Product product) {
    setState(() {
      _isAddingProduct = true;
      _idEditando = product.id;
      _nombreController.text = product.name;
      _precioController.text = product.price.toString();
      _descripcionController.text = product.description ?? '';
      _imageFile = product.imageType == ImageType.file ? File(product.imagePath) : null;
    });
  }

  void _buscarProductos() {
    final query = _busquedaController.text.toLowerCase();
    if (query.isEmpty) {
      // Mostrar un SnackBar indicando que se debe ingresar un término de búsqueda
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un término para buscar')),
      );
      return;
    }
    
    setState(() {
      _productos.removeWhere((product) => 
          !product.name.toLowerCase().contains(query) &&
          !(product.description?.toLowerCase().contains(query) ?? false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Mostrar diálogo de búsqueda
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Buscar productos'),
                  content: TextField(
                    controller: _busquedaController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre o descripción...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _buscarProductos();
                        Navigator.pop(context);
                      },
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isAddingProduct ? _buildFormularioProducto() : _buildListaProductos(),
      floatingActionButton: !_isAddingProduct
          ? FloatingActionButton(
              onPressed: _mostrarFormularioAgregar,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildListaProductos() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final product = _productos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product),
                ),
                const SizedBox(width: 16),
                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (product.description != null && product.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            product.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Botones de acción
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editarProducto(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarProducto(product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    try {
      switch (product.imageType) {
        case ImageType.network:
          return Image.network(
            product.imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          );
        case ImageType.file:
          return Image.file(
            File(product.imagePath),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          );
        case ImageType.asset:
          return Image.asset(
            product.imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          );
      }
    } catch (e) {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }

  Widget _buildFormularioProducto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _idEditando == null ? 'Agregar Producto' : 'Editar Producto',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Selector de imagen
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Agregar imagen',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Campo nombre
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del producto',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.shopping_bag),
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo precio
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Precio',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo descripción
          TextField(
            controller: _descripcionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 32),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _ocultarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _guardarProducto,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Enumeración para manejar diferentes tipos de imágenes
enum ImageType { network, file, asset }

class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final ImageType imageType;
  final String imagePath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageType,
    required this.imagePath,
    this.description,
  });
}
