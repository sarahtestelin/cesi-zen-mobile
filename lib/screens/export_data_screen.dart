import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/user_api_service.dart';

class ExportDataScreen extends StatefulWidget {
  static const String routeName = '/export-data';

  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final _userApiService = UserApiService();

  late Future<Map<String, dynamic>> _exportFuture;

  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _exportFuture = _userApiService.exportMyData();
  }

  void _reloadExport() {
    setState(() {
      _exportFuture = _userApiService.exportMyData();
    });
  }

  String _formatJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  Future<void> _downloadData(Map<String, dynamic> data) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final formattedData = _formatJson(data);
      final directory = await getApplicationDocumentsDirectory();

      final now = DateTime.now();
      final fileName =
          'cesizen_export_${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}.json';

      final file = File('${directory.path}/$fileName');

      await file.writeAsString(formattedData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export de mes données CESIZen');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier d’export généré avec succès')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le fichier d’export'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildContent(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exporter mes données',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Téléchargez les données associées à votre compte.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isDownloading ? null : () => _downloadData(data),
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.download),
              label: Text(
                _isDownloading ? 'Génération...' : 'Télécharger mes données',
              ),
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
              'Impossible d’exporter les données.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _reloadExport,
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
      appBar: AppBar(title: const Text('Export des données')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _exportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }
}
