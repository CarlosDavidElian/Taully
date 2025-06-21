import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});
  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showCodigo = false;

  Future<void> _registrarUsuario() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final codigo = _codigoController.text.trim();

    if (email.isEmpty || password.isEmpty || codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (codigo != "Taully_2207") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código de administrador inválido")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Verifica si el correo ya existe en Firestore
      final existing =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .where('email', isEqualTo: email)
              .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Este correo ya está registrado")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Registrar en Firebase Auth
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCred.user!.uid)
          .set({'email': email, 'rol': 'admin', 'creado': Timestamp.now()});

      if (!mounted) return;
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("¡Registro exitoso!"),
              content: Text("Bienvenido administrador: $email"),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text("Ir al login"),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("ERROR AUTH: ${e.code} - ${e.message}");
      String mensaje = 'Error al registrar';
      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña debe tener al menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo ingresado no es válido';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e, stack) {
      debugPrint("ERROR GENERAL: $e");
      debugPrint("STACKTRACE: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Administrador"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Correo electrónico",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: "Contraseña",
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _codigoController,
              obscureText: !_showCodigo,
              decoration: InputDecoration(
                labelText: "Código de administrador",
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCodigo ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCodigo = !_showCodigo;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Registrar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
