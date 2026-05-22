import 'package:flutter/material.dart';

import 'diagnostic_question_screen.dart';
import '../widgets/app_drawer.dart';

class DiagnosticScreen extends StatelessWidget {
  static const String routeName = '/diagnostic';

  const DiagnosticScreen({super.key});

  void _startDiagnostic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiagnosticQuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diagnostic de stress',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ce questionnaire permet d’obtenir une première indication sur votre niveau de stress.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _startDiagnostic(context),
                child: const Text('Commencer le diagnostic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
