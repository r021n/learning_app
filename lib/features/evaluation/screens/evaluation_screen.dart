import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/core/services/llm_evaluation_service.dart';
import 'package:learning_app/core/services/llm_service.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';

class EvaluationScreen extends StatefulWidget {
  final String attemptId;
  const EvaluationScreen({super.key, required this.attemptId});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startEvaluation());
  }

  Future<void> _startEvaluation() async {
    final evaluationService = LlmEvaluationService(
      llmService: context.read<LlmService>(),
      repository: context.read<LocalStorageRepository>(),
    );

    try {
      final evaluatedAttempt = await evaluationService.evaluateAttempt(
        widget.attemptId,
      );
      if (mounted) {
        context.go('/history/overview/${evaluatedAttempt.id}');
      }
    } catch (e) {
      print('Evaluasi gagal total: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengevaluasi jawaban, silahkan coba lagi'),
          ),
        );
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Mengevaluasi jawaban anda...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
