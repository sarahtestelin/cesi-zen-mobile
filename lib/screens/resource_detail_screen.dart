import 'package:flutter/material.dart';

import '../models/cesi_resource.dart';
import '../services/resource_api_service.dart';

class ResourceDetailScreen extends StatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final _resourceApiService = ResourceApiService();

  late Future<CesiResource> _resourceFuture;

  @override
  void initState() {
    super.initState();
    _resourceFuture = _resourceApiService.getResourceById(widget.resourceId);
  }

  void _reloadResource() {
    setState(() {
      _resourceFuture = _resourceApiService.getResourceById(widget.resourceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail ressource')),
      body: FutureBuilder<CesiResource>(
        future: _resourceFuture,
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
                      'Impossible de charger cette ressource.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reloadResource,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final resource = snapshot.data;

          if (resource == null) {
            return const Center(child: Text('Ressource introuvable.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(label: Text(resource.category)),
                const SizedBox(height: 16),
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  resource.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
