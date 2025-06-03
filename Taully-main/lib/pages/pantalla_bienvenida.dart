import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatImage;
  late VideoPlayerController _videoController;

  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, -0.2);

  @override
  void initState() {
    super.initState();

    // Controlador del video
    _videoController = VideoPlayerController.asset(
        'assets/videos/Taully_remo.mp4',
      )
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    // Evitar que se repita
    _videoController.setLooping(false);

    // Animación de flotación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatImage = Tween<Offset>(
      begin: const Offset(0, -0.02),
      end: const Offset(0, 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Mostrar texto después de un pequeño delay
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
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 208, 36),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Video flotante en forma ovalada
            SlideTransition(
              position: _floatImage,
              child:
                  _videoController.value.isInitialized
                      ? ClipOval(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: VideoPlayer(_videoController),
                        ),
                      )
                      : const CircularProgressIndicator(),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                foregroundColor: Colors.black,
              ),
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}
