import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart.dart'; // Importamos la clase Cart

class ProductListPage extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> products;

  const ProductListPage({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context); // Accedemos al carrito global

    return Scaffold(
      appBar: AppBar(
        title: Text('Minimarket $category'),
        backgroundColor: Colors.orange,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  _showCartDialog(context, cart);
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'S/ ${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed:
                              () => cart.addToCart(
                                item,
                              ), // Agregar al carrito global
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCartDialog(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Carrito de compras'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cart.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Tu carrito está vacío'),
                  )
                else
                  ...cart.items.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('S/ ${item['price'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cart.removeFromCart(item);
                          // Actualizamos el diálogo
                          Navigator.of(context).pop();
                          if (cart.items.isNotEmpty) {
                            _showCartDialog(context, cart);
                          }
                        },
                      ),
                    );
                  }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
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
                        'S/ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            if (cart.items.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Mostramos la pantalla de pago
                  _showPaymentScreen(context, cart);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Pagar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showPaymentScreen(BuildContext context, Cart cart) {
    String? selectedPaymentMethod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Selecciona un método de pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPaymentOption(
                    'Yape',
                    'assets/images/yape_icon.png',
                    selectedPaymentMethod == 'Yape',
                    () {
                      setState(() {
                        selectedPaymentMethod = 'Yape';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    'Tarjeta de crédito/débito',
                    'assets/images/card_icon.png',
                    selectedPaymentMethod == 'Tarjeta',
                    () {
                      setState(() {
                        selectedPaymentMethod = 'Tarjeta';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    'Efectivo',
                    'assets/images/cash_icon.png',
                    selectedPaymentMethod == 'Efectivo',
                    () {
                      setState(() {
                        selectedPaymentMethod = 'Efectivo';
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a pagar:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'S/ ${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPaymentMethod == null
                          ? null
                          : () {
                              // Procesamos el pago según el método seleccionado
                              _processPayment(context, selectedPaymentMethod!, cart);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar pago',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    String title,
    String iconPath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Aquí normalmente iría la imagen del método de pago
            // Ya que no tenemos acceso a las imágenes, usamos iconos
            Icon(
              _getPaymentIcon(title),
              size: 30,
              color: isSelected ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Yape':
        return Icons.mobile_friendly;
      case 'Tarjeta de crédito/débito':
        return Icons.credit_card;
      case 'Efectivo':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _processPayment(BuildContext context, String paymentMethod, Cart cart) {
    // Simulamos un proceso de pago
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Procesando tu pago...'),
            ],
          ),
        );
      },
    );

    // Simulamos un tiempo de espera para el procesamiento
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Cerramos el diálogo de carga

      // Mostramos el diálogo de éxito
      _showPaymentSuccessDialog(context, paymentMethod, cart);
    });
  }

  void _showPaymentSuccessDialog(BuildContext context, String paymentMethod, Cart cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Pago exitoso!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text('Has pagado S/ ${cart.totalAmount.toStringAsFixed(2)} con $paymentMethod'),
              const SizedBox(height: 10),
              const Text(
                'Tu pedido será procesado y enviado a la brevedad.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Limpiamos el carrito
                cart.clear();
                // Cerramos todos los diálogos
                Navigator.of(context).pop();
                // Podríamos navegar a una pantalla de confirmación o regresar a la tienda
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}