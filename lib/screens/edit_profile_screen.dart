import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/user_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _userApiService = UserApiService();
  final _formKey = GlobalKey<FormState>();

  final _pseudoController = TextEditingController();
  final _mailController = TextEditingController();

  late Future<AppUser> _userFuture;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  Future<AppUser> _loadUser() async {
    final user = await _userApiService.getCurrentUser();

    _pseudoController.text = user.pseudo;
    _mailController.text = user.mail;

    return user;
  }

  String? _validatePseudo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un pseudo';
    }

    if (value.trim().length < 3) {
      return 'Le pseudo doit contenir au moins 3 caractères';
    }

    return null;
  }

  String? _validateMail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre adresse mail';
    }

    if (!value.contains('@')) {
      return 'Adresse mail invalide';
    }

    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userApiService.updateCurrentUser(
        pseudo: _pseudoController.text.trim(),
        mail: _mailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil modifié avec succès')),
      );

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      final responseData = error.response?.data;
      final message =
          responseData is Map && responseData['message'] != null
              ? responseData['message'].toString()
              : 'Impossible de modifier le profil';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur inattendue est survenue')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modifier mon profil',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mettez à jour les informations de votre compte.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _pseudoController,
              decoration: const InputDecoration(
                labelText: 'Pseudo',
                border: OutlineInputBorder(),
              ),
              validator: _validatePseudo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse mail',
                border: OutlineInputBorder(),
              ),
              validator: _validateMail,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
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
              'Impossible de charger les informations du profil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _userFuture = _loadUser();
                });
              },
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
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: FutureBuilder<AppUser>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          return _buildForm();
        },
      ),
    );
  }
}
