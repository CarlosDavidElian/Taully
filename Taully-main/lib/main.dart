import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Páginas del sistema
import 'pages/abarrotes_page.dart';
import 'pages/golosinas_page.dart';
import 'pages/limpieza_page.dart';
import 'pages/ricocan_page.dart';
import 'pages/pantalla_login.dart';
import 'pages/admin_productos.dart';
import 'pages/pantalla_bienvenida.dart';
import 'pages/pantalla_finaliza.dart';
import 'pages/pantalla_registro.dart';

// Carrito
import 'cart.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        '/registro': (context) => const PantallaRegistro(),
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
          body: TabBarView(
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
