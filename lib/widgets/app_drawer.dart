import 'package:flutter/material.dart';

import '../services/token_storage_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _tokenStorageService = TokenStorageService();

  bool _isLoading = true;
  bool _isConnected = false;
  String? _pseudo;

  @override
  void initState() {
    super.initState();
    _loadUserState();
  }

  Future<void> _loadUserState() async {
    final token = await _tokenStorageService.getAccessToken();
    final pseudo = await _tokenStorageService.getPseudoFromToken();

    if (!mounted) return;

    setState(() {
      _isConnected = token != null && token.isNotEmpty;
      _pseudo = pseudo;
      _isLoading = false;
    });
  }

  void _goTo(String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  void _goToHome() {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future<void> _logout() async {
    await _tokenStorageService.clear();

    if (!mounted) return;

    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CESIZen',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isConnected
                                ? 'Bonjour ${_pseudo ?? 'utilisateur'}'
                                : 'Bienvenue',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Accueil'),
                      onTap: _goToHome,
                    ),
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: const Text('Ressources'),
                      onTap: () => _goTo('/resources'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.psychology_outlined),
                      title: const Text('Diagnostic'),
                      onTap: () => _goTo('/diagnostic'),
                    ),
                    const Divider(),
                    if (_isConnected) ...[
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Mon profil'),
                        onTap: () => _goTo('/profile'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Se déconnecter'),
                        onTap: _logout,
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Se connecter'),
                        onTap: () => _goTo('/login'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add_outlined),
                        title: const Text('Créer un compte'),
                        onTap: () => _goTo('/register'),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
