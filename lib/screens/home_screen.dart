import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  void _goToRegister(BuildContext context) {
    Navigator.pushNamed(context, RegisterScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CESIZen')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "CESIZen est une application mobile dédiée à la gestion du stress et à la santé mentale.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _goToLogin(context),
                child: const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _goToRegister(context),
                child: const Text('Créer un compte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
