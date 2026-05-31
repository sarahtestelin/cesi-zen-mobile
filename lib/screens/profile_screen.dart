import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/token_storage_service.dart';
import '../services/user_api_service.dart';
import 'change_password_screen.dart';
import 'diagnostic_history_screen.dart';
import 'edit_profile_screen.dart';
import 'export_data_screen.dart';
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

  bool _isDeleting = false;

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

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text(
            'Cette action est définitive. Votre compte sera supprimé et vous serez déconnecté.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _userApiService.deleteMyAccount();
      await _tokenStorageService.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte supprimé avec succès')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (route) => false,
      );
    } on DioException catch (error) {
      if (!mounted) return;

      final responseData = error.response?.data;
      final message =
          responseData is Map && responseData['message'] != null
              ? responseData['message'].toString()
              : 'Impossible de supprimer le compte';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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
            'Votre profil CESIZen.',
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
            onPressed: () {
              Navigator.pushNamed(context, EditProfileScreen.routeName).then((
                updated,
              ) {
                if (updated == true) {
                  _reloadProfile();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.lock_outline,
            label: 'Changer mon mot de passe',
            onPressed: () {
              Navigator.pushNamed(context, ChangePasswordScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Exporter mes données',
            onPressed: () {
              Navigator.pushNamed(context, ExportDataScreen.routeName);
            },
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
            label: _isDeleting ? 'Suppression...' : 'Supprimer mon compte',
            danger: true,
            onPressed: _isDeleting ? () {} : _confirmDeleteAccount,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isDeleting ? null : _logout,
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
