import 'package:flutter/material.dart';

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatImage;
  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, -0.2); // desde arriba

  @override
  void initState() {
    super.initState();

    // Animación de imagen flotante
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatImage = Tween<Offset>(
      begin: const Offset(0, -0.02),
      end: const Offset(0, 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Activar animación del texto después de un pequeño delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _textOpacity = 1.0;
        _textOffset = Offset.zero;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 242, 64),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen flotante
            SlideTransition(
              position: _floatImage,
              child: Image.asset(
                'lib/imgtaully/Taully_remo.png',
                width: 200,
                height: 200,
              ),
            ),

            const SizedBox(height: 10),

            // Texto "Bienvenido" animado
            AnimatedSlide(
              offset: _textOffset,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Tu solución de compras',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 145, 124, 240),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                foregroundColor: Colors.black,
              ),
              child: const Text('Comenzar'),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 50),
              color: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            const Text('ADMINISTRADOR', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
