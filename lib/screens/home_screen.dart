import 'package:flutter/material.dart';

import '../services/token_storage_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'register_screen.dart';
import 'resources_screen.dart';
import 'diagnostic_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tokenStorageService = TokenStorageService();

  bool _isLoading = true;
  bool _isConnected = false;
  String? _pseudo;

  @override
  void initState() {
    super.initState();
    _loadConnectionState();
  }

  Future<void> _loadConnectionState() async {
    final token = await _tokenStorageService.getAccessToken();
    final pseudo = await _tokenStorageService.getPseudoFromToken();

    if (!mounted) return;

    setState(() {
      _isConnected = token != null && token.isNotEmpty;
      _pseudo = pseudo;
      _isLoading = false;
    });
  }

  void _goToLogin() {
    Navigator.pushNamed(context, LoginScreen.routeName).then((_) {
      _loadConnectionState();
    });
  }

  void _goToRegister() {
    Navigator.pushNamed(context, RegisterScreen.routeName).then((_) {
      _loadConnectionState();
    });
  }

  void _goToProfile() {
    Navigator.pushNamed(context, ProfileScreen.routeName).then((_) {
      _loadConnectionState();
    });
  }

  void _showAuthChoices() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            children: [
              const Text(
                'Mon espace',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connectez-vous ou créez un compte pour accéder à votre espace personnel.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToLogin();
                  },
                  child: const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToRegister();
                  },
                  child: const Text('Créer un compte'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderAction() {
    if (_isConnected) {
      return TextButton(
        onPressed: _goToProfile,
        child: Text(
          'Bonjour ${_pseudo ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return IconButton(
      onPressed: _showAuthChoices,
      icon: const Icon(Icons.person_outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CESIZen'),
        actions: [_buildHeaderAction()],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "CESIZen est une application mobile dédiée à la gestion du stress et à la santé mentale.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Ressources'),
                subtitle: const Text('Consulter les contenus d’information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, ResourcesScreen.routeName);
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('Diagnostic'),
                subtitle: const Text('Évaluer son niveau de stress'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, DiagnosticScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
