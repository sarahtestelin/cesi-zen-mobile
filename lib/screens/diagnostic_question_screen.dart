import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/diagnostic_question.dart';
import '../services/diagnostic_api_service.dart';
import 'diagnostic_result_screen.dart';

class DiagnosticQuestionScreen extends StatefulWidget {
  const DiagnosticQuestionScreen({super.key});

  @override
  State<DiagnosticQuestionScreen> createState() =>
      _DiagnosticQuestionScreenState();
}

class _DiagnosticQuestionScreenState extends State<DiagnosticQuestionScreen> {
  final _diagnosticApiService = DiagnosticApiService();

  late Future<List<DiagnosticQuestion>> _questionsFuture;

  final Set<String> _selectedQuestionIds = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _diagnosticApiService.getQuestions();
  }

  void _reloadQuestions() {
    setState(() {
      _questionsFuture = _diagnosticApiService.getQuestions();
    });
  }

  void _toggleQuestion(String questionId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedQuestionIds.add(questionId);
      } else {
        _selectedQuestionIds.remove(questionId);
      }
    });
  }

  Future<void> _submitDiagnostic() async {
    if (_selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une réponse.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _diagnosticApiService.submitDiagnostic(
        questionIds: _selectedQuestionIds.toList(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosticResultScreen(result: result),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      final responseData = error.response?.data;
      final message =
          responseData is Map && responseData['message'] != null
              ? responseData['message'].toString()
              : 'Impossible de calculer le diagnostic.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur inattendue est survenue.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildIntroText() {
    return const Text(
      'Cochez les affirmations qui vous concernent afin d’obtenir une estimation de votre niveau de stress. Veuillez sélectionner les événements que vous avez vécus au cours de la dernière année.',
      style: TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _buildQuestionCard(DiagnosticQuestion question) {
    final isSelected = _selectedQuestionIds.contains(question.id);

    return Card(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          _toggleQuestion(question.id, value ?? false);
        },
        title: Text(question.question),
        subtitle: Text('Score associé : ${question.score} point(s)'),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _isSubmitting ? null : _submitDiagnostic,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Voir mon résultat'),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<List<DiagnosticQuestion>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Problème dans le chargement du questionnaire.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _reloadQuestions,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final questions = snapshot.data ?? [];

        if (questions.isEmpty) {
          return const Center(child: Text('Aucune question disponible.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: questions.length + 2,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildIntroText();
            }

            if (index == questions.length + 1) {
              return _buildSubmitButton();
            }

            return _buildQuestionCard(questions[index - 1]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaire')),
      body: _buildContent(),
    );
  }
}
