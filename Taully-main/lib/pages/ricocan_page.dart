import 'package:flutter/material.dart';
import '../widgets/product_list.dart';

class RicocanPage extends StatelessWidget {
  const RicocanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      category: 'Ricocan',
      products: const [
        {
          'name': 'Ricocan Adulto Carne y Cereales 16kg',
          'price': 94.00,
          'image':
              'https://wongfood.vtexassets.com/arquivos/ids/371220/387014-01-1421.jpg?v=637312320471600000',
        },
        {
          'name': 'Ricocan Cachorro Pollo y Leche 8kg',
          'price': 67.00,
          'image':
              'https://media.falabella.com/tottusPE/41876518_1/w=800,h=800,fit=pad',
        },
        {
          'name': 'Ricocan Adulto Pollo y Cereales 2kg',
          'price': 22.50,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/30295069-512-512/20212907.jpg',
        },
        {
          'name': 'Ricocan Sachet Adulto Carne en Salsa 100g',
          'price': 2.00,
          'image':
              'https://mascotify.pe/wp-content/uploads/2022/05/Ricocan-trocitos-en-salsa-pollo-sachet-cachorros.png',
        },
        {
          'name': 'Ricocan Galletas para Perros 1kg',
          'price': 15.90,
          'image':
              'https://wongfood.vtexassets.com/arquivos/ids/675991/Fun-Pack-Ricocan-1-351661946.jpg?v=638358397939230000',
        },
        {
          'name': 'Ricocan Adulto Pollo y Vegetales 15kg',
          'price': 93.00,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREWpdbfQu-OzMoN69Ah79MOB4aerPGZ0mbvNFdS81aP-Vz0ylcP9xjscovAF2KZdTJOTE&usqp=CAU',
        },
      ],
    );
  }
}
