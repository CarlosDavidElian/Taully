import 'package:flutter/material.dart';
import '../widgets/product_list.dart';

class GolosinasPage extends StatelessWidget {
  const GolosinasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      category: 'Golosinas',
      products: const [
        {
          'name': 'Chocolate Sublime',
          'price': 1.20,
          'image':
              'https://tiendanestle.pe/cdn/shop/products/folia-Sublime-sonrisa_2022__2048X2048_1bae59a1-29c0-4add-bc47-fdceebc732e4.jpg?v=1666047011&width=1946',
        },
        {
          'name': 'Galletas Oreo',
          'price': 0.80,
          'image':
              'https://vegaperu.vtexassets.com/arquivos/ids/166991/142306.jpg?v=638596859419770000',
        },
        {
          'name': 'Chicle Trident Hierbabuena',
          'price': 0.50,
          'image':
              'https://lacolonia.vtexassets.com/arquivos/ids/161212-800-800?v=636797088184530000&width=800&height=800&aspect=true',
        },
        {
          'name': 'Caramelo Halls Mentho Lyptus',
          'price': 0.60,
          'image':
              'https://realplaza.vtexassets.com/arquivos/ids/35491007-800-auto?v=638519310861870000&width=800&height=auto&aspect=true',
        },
        {
          'name': 'Galleta Casino Fresa',
          'price': 0.70,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/27516668-512-512/165259-3.jpg',
        },
        {
          'name': 'Snickers Bar',
          'price': 1.30,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJa8MHeNjM0B6_5HWVcYI-RpnlRRDHMatASw&s',
        },
        {
          'name': 'Galleta Tentación Vainilla',
          'price': 0.85,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/28238123-450-450/20390135.jpg?v=638340204676700000',
        },
        {
          'name': 'Chupetín Globo Pop',
          'price': 0.50,
          'image':
              'https://imagedelivery.net/4fYuQyy-r8_rpBpcY7lH_A/tottusPE/41911895_1/w=1500,h=1500,fit=pad',
        },
        {
          'name': 'Chocolate Princesa',
          'price': 1.00,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/2188129-1000-1000/64381.jpg?v=637635953045400000',
        },
        {
          'name': 'Chocolate Doña Pepa',
          'price': 1.00,
          'image':
              'https://www.tiendaperuonline.com/cdn/shop/products/GALLETADONAPEPA_grande.jpg?v=1667378975',
        },
      ],
    );
  }
}
