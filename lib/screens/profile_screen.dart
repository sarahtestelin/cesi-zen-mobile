import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/token_storage_service.dart';
import '../services/user_api_service.dart';
import 'diagnostic_history_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userApiService = UserApiService();
  final _tokenStorageService = TokenStorageService();

  late Future<AppUser> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userApiService.getCurrentUser();
  }

  void _reloadProfile() {
    setState(() {
      _userFuture = _userApiService.getCurrentUser();
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

  void _showFeatureComingSoon(String featureName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$featureName à venir')));
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    if (danger) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _buildProfileContent(AppUser user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 24),
          Text(
            'Bonjour ${user.pseudo}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Voici les informations de votre compte CESIZen.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          _buildInfoLine(
            icon: Icons.badge_outlined,
            label: 'Pseudo',
            value: user.pseudo,
          ),
          const SizedBox(height: 20),
          _buildInfoLine(
            icon: Icons.mail_outline,
            label: 'Adresse mail',
            value: user.mail,
          ),
          const SizedBox(height: 20),
          _buildInfoLine(
            icon: Icons.security_outlined,
            label: 'Rôle',
            value: user.role,
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Modifier mon profil',
            onPressed: () => _showFeatureComingSoon('Modification du profil'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.lock_outline,
            label: 'Changer mon mot de passe',
            onPressed:
                () => _showFeatureComingSoon('Changement de mot de passe'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Exporter mes données',
            onPressed: () => _showFeatureComingSoon('Export des données'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.history,
            label: 'Historique des diagnostics',
            onPressed: () {
              Navigator.pushNamed(context, DiagnosticHistoryScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Supprimer mon compte',
            danger: true,
            onPressed: () => _showFeatureComingSoon('Suppression du compte'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _logout,
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger le profil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _reloadProfile,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: FutureBuilder<AppUser>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          return _buildProfileContent(snapshot.data!);
        },
      ),
    );
  }
}
