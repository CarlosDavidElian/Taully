import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/abarrotes_page.dart';
import 'pages/golosinas_page.dart';
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minimarket Taully'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Abarrotes'), Tab(text: 'Golosinas')],
          ),
          backgroundColor: const Color.fromARGB(255, 241, 226, 10),
        ),
        body: const TabBarView(children: [AbarrotesPage(), GolosinasPage()]),
      ),
    );
  }
}
