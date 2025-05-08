import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addToCart(Map<String, dynamic> product) {
    _items.add(product);
    notifyListeners(); // Notifica a todos los listeners para actualizar la UI
  }

  void removeFromCart(Map<String, dynamic> product) {
    _items.remove(product);
    notifyListeners(); // Notifica a todos los listeners para actualizar la UI
  }

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item['price'];
    }
    return total;
  }
  
  //el método clear para limpiar el carrito
  void clear() {
    _items.clear();
    notifyListeners(); // Notifica a todos los listeners para actualizar la UI
  }
}

