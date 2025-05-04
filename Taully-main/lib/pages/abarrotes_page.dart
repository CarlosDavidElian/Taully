import 'package:flutter/material.dart';
import '../widgets/product_list.dart';
// Importamos la clase Cart

class AbarrotesPage extends StatelessWidget {
  const AbarrotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListPage(
      category: 'Abarrotes',
      products: const [
        {
          'name': 'Aceite Primor 900 Ml',
          'price': 1.80,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/30632030-450-450/20281566.jpg?v=638758944609130000',
        },
        {
          'name': 'Harina maíz Pan',
          'price': 1.20,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/25710950-450-450/20073368.jpg?v=638122176248600000',
        },
        {
          'name': 'Coca-Cola 1.5L',
          'price': 3.50,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/29148582-418-418/76296.jpg',
        },
        {
          'name': 'Arroz Costeño 5kg',
          'price': 17.90,
          'image':
              'https://realplaza.vtexassets.com/arquivos/ids/20646711/image-120f38a72a3a456184945648c36cb3f5.jpg?v=637800393551500000',
        },
        {
          'name': 'Fideos Spaghetti DON VITTORIO Bolsa 450g',
          'price': 3.00,
          'image':
              'https://vegaperu.vtexassets.com/arquivos/ids/165289-800-auto?v=638313466131730000&width=800&height=auto&aspect=true',
        },
        {
          'name': 'Azúcar Rubia 1kg',
          'price': 3.20,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/30578637-512-512/20283176.jpg',
        },
        {
          'name': 'Sal Lobos 1kg',
          'price': 1.00,
          'image':
              'https://http2.mlstatic.com/D_NQ_NP_664897-MLC52299997528_112022-O.webp',
        },
        {
          'name': 'Leche Gloria Entera 400g',
          'price': 4.80,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbZqS4RhlLBxq4jDyXE15AlXTQSOSkVxHqSw&s',
        },
        {
          'name': 'Atún Florida en agua 170g',
          'price': 3.50,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/1087859-450-450/20191578.jpg?v=637503861045000000',
        },
        {
          'name': 'Salsa de Tomate Natura 200g',
          'price': 1.20,
          'image':
              'https://latinfoodsatyourdoor.com/cdn/shop/files/3f8c838a75a1bf970200bf2f3bd69a34.png?v=1693272974',
        },
        {
          'name': 'Aceitunas Negras Envasadas 220g',
          'price': 4.50,
          'image':
              'https://wongfood.vtexassets.com/arquivos/ids/437493/Aceituna-Negra-Deshuesada-Pote-220-g-1-192867156.jpg?v=637566246486430000',
        },
        {
          'name': 'Café Altomayo 200g',
          'price': 10.50,
          'image':
              'https://plazavea.vteximg.com.br/arquivos/ids/29956190-450-450/20209019.jpg?v=638657856807300000',
        },
        {
          'name': 'Huevos Pardos (docena)',
          'price': 6.50,
          'image':
              'https://metroio.vtexassets.com/arquivos/ids/240765-800-auto?v=638173829753730000&width=800&height=auto&aspect=true',
        },
        {
          'name': 'Papel Higiénico Suave 4 rollos',
          'price': 3.80,
          'image':
              'https://metroio.vtexassets.com/arquivos/ids/522482-800-auto?v=638495769715130000&width=800&height=auto&aspect=true',
        },
        {
          'name': 'Detergente Bolívar 1kg',
          'price': 5.50,
          'image':
              'https://promart.vteximg.com.br/arquivos/ids/8725249-1000-1000/130955.jpg?v=638785317038230000',
        },
      ],
    );
  }
}
