import 'package:flutter/material.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
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

    // Validar fuerza de contraseña
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
      
      // Aumentar fuerza si tiene caracteres especiales o números
      final hasNumber = RegExp(r'[0-9]').hasMatch(value);
      final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
      
      if (value.length >= 8 && hasNumber && hasSpecialChar) {
        _passwordStrength = 'Muy fuerte';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color scaffoldBackgroundColor = isDarkMode ? Colors.black : Colors.white;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: const Color.fromARGB(208, 243, 236, 33),
        elevation: 0,
        // Se eliminó el botón de cambio de tema (icono de noche)
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con animación
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30, top: 20),
                        child: Image.asset(
                          'lib/imgtaully/Taully_remo.png',
                          width: 180,
                          height: 180,
                        ),
                      ),
                    );
                  },
                ),
                
                // Mensaje de bienvenida
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Column(
                    children: [
                      Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bienvenido a Taully, tu aplicación para hacer compras de manera rápida y sencilla.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Campo de email con validación
                TextField(
                  controller: _emailController,
                  onChanged: _checkEmailValidity,
                  decoration: InputDecoration(
                    labelText: 'Administrador',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    errorText: _isEmailValid ? null : 'Correo electrónico inválido',
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _emailController.clear();
                                _isEmailValid = true;
                              });
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 20),
                
                // Campo de contraseña con indicador de fuerza
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _checkPasswordStrength,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        errorText: _isPasswordValid ? null : 'La contraseña debe tener al menos 6 caracteres',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
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
                                value: _passwordStrength == 'Débil'
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
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Opción "Recordarme"
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    const Text('Recordarme'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Recuperar contraseña'),
                            content: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'Ingresa tu correo para recuperar tu contraseña',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Se ha enviado un correo para recuperar tu contraseña'),
                                    ),
                                  );
                                },
                                child: const Text('Enviar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // Botón de ingreso con animación
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.95, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_emailController.text.isNotEmpty && 
                                _passwordController.text.isNotEmpty &&
                                _isEmailValid &&
                                _isPasswordValid) {
                              // Animación al presionar
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Iniciando sesión...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.pushReplacementNamed(context, '/admin-productos');
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, completa todos los campos correctamente'),
                                  backgroundColor: Color.fromARGB(255, 244, 165, 54),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Ingresar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Opciones de inicio de sesión con redes sociales - solo Facebook
                Column(
                  children: [
                    const Text(
                      'O inicia sesión con',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    // Solo se mantiene el botón de Facebook
                    _socialLoginButton(
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Iniciando sesión con Facebook')),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}