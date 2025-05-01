import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taully/pages/limpieza_page.dart';
import 'pages/abarrotes_page.dart';
import 'pages/Golosinas_page.dart'; 
import 'pages/ricocan_page.dart'; 
import 'pages/pantalla_login.dart';
import 'pages/admin_productos.dart';
import 'package:taully/pages/pantalla_Bienvenida.dart';
import 'package:taully/pages/pantalla_Finaliza.dart';

import 'cart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => Cart(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimarket App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 166, 0),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/Bienvenida',  // Con /
        routes: {
        '/Bienvenida': (context) => PantallaBienvenida(),  // Sin /
        '/home': (context) => const HomePage(), 
        '/Finaliza': (context) => PantallaFinaliza(),
        '/login': (context) => PantallaLogin(),
        '/admin-productos': (context) => const AdminProductos(),
      },
      //home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4 , 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minimarket Taully'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Abarrotes'),
              Tab(text: 'Golosinas'),
              Tab(text: 'Prod.Limpieza'),
              Tab(text: 'Comd.Animales'), // 
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 241, 226, 10),
        ),
        body: const TabBarView(
          children: [
            AbarrotesPage(),
            GolosinasPage(),
            LimpiezaPage(),
             RicocanPage(), // 
          ],
        ),
      ),
    );
  }
}

