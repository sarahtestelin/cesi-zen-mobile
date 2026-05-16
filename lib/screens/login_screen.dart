import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Formulaire de connexion.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
