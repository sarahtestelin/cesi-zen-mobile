import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Formulaire d’inscription.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
