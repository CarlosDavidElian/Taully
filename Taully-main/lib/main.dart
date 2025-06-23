import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Carrito
import 'cart.dart';

// Páginas
import 'pages/abarrotes_page.dart';
import 'pages/golosinas_page.dart';
import 'pages/limpieza_page.dart';
import 'pages/ricocan_page.dart';
import 'pages/productos_busqueda_page.dart';
import 'pages/admin_productos.dart';
import 'pages/pantalla_bienvenida.dart';
import 'pages/pantalla_finaliza.dart';
import 'pages/pantalla_login.dart';
import 'pages/pantalla_registro.dart';

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
      title: 'Minimarket Taully',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 166, 0),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
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
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchTerm.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchTerm = '';
                                      _searchController.clear();
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                  if (_searchTerm.isEmpty)
                    const TabBar(
                      labelColor: Colors.black,
                      indicatorColor: Colors.orange,
                      tabs: [
                        Tab(text: 'Abarrotes'),
                        Tab(text: 'Golosinas'),
                        Tab(text: 'Limpieza'),
                        Tab(text: 'Mascotas'),
                      ],
                    ),
                ],
              ),
            ),
          ),
          body:
              _searchTerm.isEmpty
                  ? TabBarView(
                    children: [
                      AbarrotesPage(searchTerm: ''),
                      GolosinasPage(searchTerm: ''),
                      LimpiezaPage(searchTerm: ''),
                      RicocanPage(searchTerm: ''),
                    ],
                  )
                  : ProductosBusquedaPage(searchTerm: _searchTerm),
        ),
      ),
    );
  }
}
