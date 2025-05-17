import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  // Estructura modificada para contar productos idénticos
  final Map<String, Map<String, dynamic>> _cartItems = {};

  // Getter para obtener los elementos del carrito con su cantidad
  List<Map<String, dynamic>> get items {
    return _cartItems.values.toList();
  }

  // Getter para el número total de productos diferentes en el carrito
  int get itemCount {
    return _cartItems.length;
  }

  // Getter para el número total de productos contando cantidades
  int get totalQuantity {
    int total = 0;
    _cartItems.forEach((key, item) {
      total += item['quantity'] as int;
    });
    return total;
  }

  // Getter para el monto total del carrito
  double get totalAmount {
    double total = 0;
    _cartItems.forEach((key, item) {
      total += (item['price'] as double) * (item['quantity'] as int);
    });
    return total;
  }

  // Método para agregar al carrito
  void addToCart(Map<String, dynamic> product) {
    // Usamos el nombre del producto como clave única
    final productId = product['name'] as String;
    
    if (_cartItems.containsKey(productId)) {
      // Si ya existe, incrementamos la cantidad
      _cartItems.update(
        productId,
        (existingItem) => {
          ...existingItem,
          'quantity': (existingItem['quantity'] as int) + 1,
        },
      );
    } else {
      // Si no existe, lo agregamos con cantidad 1
      _cartItems.putIfAbsent(
        productId,
        () => {
          ...product,
          'quantity': 1,
        },
      );
    }
    notifyListeners();
  }

  // Método para remover un producto del carrito
  void removeFromCart(Map<String, dynamic> product) {
    final productId = product['name'] as String;
    
    if (!_cartItems.containsKey(productId)) return;
    
    if (_cartItems[productId]!['quantity'] > 1) {
      // Si hay más de uno, reducimos la cantidad
      _cartItems.update(
        productId,
        (existingItem) => {
          ...existingItem,
          'quantity': (existingItem['quantity'] as int) - 1,
        },
      );
    } else {
      // Si solo hay uno, eliminamos el producto
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  // Método para eliminar completamente un producto del carrito
  void removeCompleteItem(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.remove(productId);
      notifyListeners();
    }
  }

  // Método para vaciar el carrito
  void clear() {
    _cartItems.clear();
    notifyListeners();
  }
}
