// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  // Aquí se deberían verificar las credenciales. Para simplificar, usaremos valores fijos.
  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Aquí se verificarían las credenciales, pero por ahora, siempre dejamos acceder al usuario.
      Navigator.pushReplacementNamed(context, '/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
