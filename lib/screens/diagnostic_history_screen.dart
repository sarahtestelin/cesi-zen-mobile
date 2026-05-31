import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/diagnostic_result.dart';
import '../services/diagnostic_api_service.dart';

class DiagnosticHistoryScreen extends StatefulWidget {
  static const String routeName = '/diagnostic-history';

  const DiagnosticHistoryScreen({super.key});

  @override
  State<DiagnosticHistoryScreen> createState() =>
      _DiagnosticHistoryScreenState();
}

class _DiagnosticHistoryScreenState extends State<DiagnosticHistoryScreen> {
  final _diagnosticApiService = DiagnosticApiService();

  late Future<List<DiagnosticResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _diagnosticApiService.getMyResults();
  }

  void _reloadHistory() {
    setState(() {
      _resultsFuture = _diagnosticApiService.getMyResults();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date inconnue';
    }

    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  Widget _buildResultCard(DiagnosticResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.level,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Score : ${result.finalScore}'),
            const SizedBox(height: 8),
            Text(
              _formatDate(result.createdAt),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(result.message, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: FutureBuilder<List<DiagnosticResult>>(
        future: _resultsFuture,
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
                      'Impossible de charger l’historique.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reloadHistory,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return const Center(
              child: Text('Aucun diagnostic enregistré pour le moment.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildResultCard(results[index]);
            },
          );
        },
      ),
    );
  }
}
