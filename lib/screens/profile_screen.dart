import 'package:flutter/material.dart';

import '../services/token_storage_service.dart';
import 'diagnostic_history_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _tokenStorageService = TokenStorageService();

  bool _isLoading = true;
  String? _pseudo;
  String? _mail;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final pseudo = await _tokenStorageService.getPseudoFromToken();
    final mail = await _tokenStorageService.getMailFromToken();
    final role = await _tokenStorageService.getRoleFromToken();

    if (!mounted) return;

    setState(() {
      _pseudo = pseudo;
      _mail = mail;
      _role = role;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _tokenStorageService.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vous êtes déconnecté')));

    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
      (route) => false,
    );
  }

  Widget _buildInfoLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 42)),
            const SizedBox(height: 24),
            Text(
              'Bonjour ${_pseudo ?? 'utilisateur'}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Voici votre profil CESIZen.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_pseudo != null)
              _buildInfoLine(
                icon: Icons.badge_outlined,
                label: 'Pseudo',
                value: _pseudo!,
              ),
            if (_pseudo != null) const SizedBox(height: 20),
            if (_mail != null)
              _buildInfoLine(
                icon: Icons.mail_outline,
                label: 'Adresse mail',
                value: _mail!,
              ),
            if (_mail != null) const SizedBox(height: 20),
            if (_role != null)
              _buildInfoLine(
                icon: Icons.security_outlined,
                label: 'Rôle',
                value: _role!,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    DiagnosticHistoryScreen.routeName,
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Historique des diagnostics'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _logout,
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
