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
      initialRoute: '/Bienvenida',
      routes: {
        '/Bienvenida': (context) => const PantallaBienvenida(),
        '/home': (context) => const HomePage(),
        '/Finaliza': (context) => PantallaFinaliza(),
        '/login': (context) => PantallaLogin(),
        '/admin-productos': (context) => const AdminProductosPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/Bienvenida');
        return false;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Minimarket Taully'),
            backgroundColor: const Color.fromARGB(255, 241, 226, 10),
            actions: [
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Administrador',
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Abarrotes'),
                Tab(text: 'Golosinas'),
                Tab(text: 'Prod.Limpieza'),
                Tab(text: 'Comd.Animales'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              AbarrotesPage(),
              GolosinasPage(),
              LimpiezaPage(),
              RicocanPage(),
            ],
          ),
        ),
      ),
    );
  }
}
