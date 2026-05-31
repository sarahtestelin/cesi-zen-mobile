import 'package:flutter/material.dart';

import '../models/cesi_resource.dart';
import '../services/resource_api_service.dart';
import 'resource_detail_screen.dart';
import '../widgets/app_drawer.dart';

class ResourcesScreen extends StatefulWidget {
  static const String routeName = '/resources';

  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final _resourceApiService = ResourceApiService();

  late Future<List<CesiResource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _resourcesFuture = _resourceApiService.getResources();
  }

  void _reloadResources() {
    setState(() {
      _resourcesFuture = _resourceApiService.getResources();
    });
  }

  void _openResourceDetail(CesiResource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(resourceId: resource.id),
      ),
    );
  }

  Widget _buildResourceCard(CesiResource resource) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text(resource.title),
        subtitle: Text(resource.category),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openResourceDetail(resource),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ressources')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<CesiResource>>(
        future: _resourcesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42),
                    const SizedBox(height: 12),
                    const Text(
                      'Impossible de charger les ressources.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reloadResources,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final resources = snapshot.data ?? [];

          if (resources.isEmpty) {
            return const Center(child: Text('Aucune ressource disponible.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: resources.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildResourceCard(resources[index]);
            },
          );
        },
      ),
    );
  }
}
