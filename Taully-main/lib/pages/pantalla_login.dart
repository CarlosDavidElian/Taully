import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkEmailValidity(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = value.isEmpty || emailRegex.hasMatch(value);
    });
  }

  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
        _isPasswordValid = true;
      });
      return;
    }

    setState(() {
      _isPasswordValid = value.length >= 6;

      if (value.length < 6) {
        _passwordStrength = 'Débil';
        _passwordStrengthColor = Colors.red;
      } else if (value.length < 10) {
        _passwordStrength = 'Media';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Fuerte';
        _passwordStrengthColor = Colors.green;
      }

      final hasNumber = RegExp(r'[0-9]').hasMatch(value);
      final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

      if (value.length >= 8 && hasNumber && hasSpecialChar) {
        _passwordStrength = 'Muy fuerte';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _loginWithFirebase() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Iniciando sesión...')));

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/admin-productos');
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';

      if (e.code == 'user-not-found') {
        mensaje = 'Usuario no registrado';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController();
    final parentContext = context; // Guarda el contexto antes del await

    showDialog(
      context: parentContext,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Restablecer contraseña'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'Ingresa tu correo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(parentContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = controller.text.trim();
                  Navigator.of(parentContext).pop(); // Cierra el diálogo

                  if (email.isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, escribe tu correo'),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );

                    if (!mounted) return;
                    // Muestra el diálogo de éxito usando el contexto padre válido
                    showDialog(
                      context: parentContext,
                      builder:
                          (_) => AlertDialog(
                            title: const Text('¡Correo enviado!'),
                            content: const Text(
                              'Revisa tu bandeja de entrada o spam para restablecer tu contraseña.',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(parentContext).pop(),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                    );
                  } on FirebaseAuthException catch (e) {
                    String mensaje = 'Error al enviar el correo';
                    if (e.code == 'user-not-found') {
                      mensaje = 'No hay una cuenta con ese correo';
                    } else if (e.code == 'invalid-email') {
                      mensaje = 'Correo inválido';
                    }

                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text(mensaje)));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: const Color.fromARGB(208, 243, 236, 33),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Image.asset(
                      'lib/imgtaully/Taully_remo.png',
                      width: 180,
                      height: 180,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Inicia Sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bienvenido a Taully, tu aplicación para hacer compras de manera rápida y sencilla.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                onChanged: _checkEmailValidity,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText:
                      _isEmailValid ? null : 'Correo electrónico inválido',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _checkPasswordStrength,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _isPasswordValid ? null : 'Mínimo 6 caracteres',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              if (_passwordStrength.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Fuerza: $_passwordStrength',
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value:
                              _passwordStrength == 'Débil'
                                  ? 0.25
                                  : _passwordStrength == 'Media'
                                  ? 0.5
                                  : _passwordStrength == 'Fuerte'
                                  ? 0.75
                                  : 1.0,
                          color: _passwordStrengthColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loginWithFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/registro'),
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
