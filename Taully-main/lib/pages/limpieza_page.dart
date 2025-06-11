import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../widgets/product_list.dart';

class LimpiezaPage extends StatelessWidget {
  final ProductService _productService = ProductService();

  LimpiezaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _productService.getProductsByCategory('Prod.Limpieza'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Scaffold(body: Center(child: Text('No hay productos')));

        final productos = snapshot.data!;
        return ProductListPage(category: 'Prod.Limpieza', products: productos);
      },
    );
  }
}
