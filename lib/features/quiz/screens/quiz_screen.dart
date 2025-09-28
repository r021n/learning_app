import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:learning_app/features/quiz/providers/quiz_provider.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/features/auth/providers/auth_provider.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';

class QuizScreen extends StatelessWidget {
  final String materialId;
  const QuizScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser!.uid;

    return ChangeNotifierProvider(
      create: (context) => QuizProvider(
        repository: context.read<LocalStorageRepository>(),
        attemptProvider: context.read<AttemptProvider>(),
        materialId: materialId,
        userId: userId,
      )..initializeQuiz(),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatefulWidget {
  const _QuizView();

  @override
  State<_QuizView> createState() => __QuizViewState();
}

class __QuizViewState extends State<_QuizView> {
  late final TextEditingController _answerController;
  bool _isSubmitting = false;

  Future<void> _submitAndNavigate() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<QuizProvider>();

    try {
      final newAttemptId = await provider.finishAttempt();
      if (mounted) {
        context.go('/evaluate/$newAttemptId');
      }
    } catch (e) {
      print('Error saat submit: $e');
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    if (provider.remainingSeconds == 0 && !_isSubmitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _submitAndNavigate();
      });
    }

    final currentAnswer = provider.userAnswers.isNotEmpty
        ? provider.userAnswers[provider.currentIndex]
        : '';
    if (_answerController.text != currentAnswer) {
      _answerController.text = currentAnswer;
    }

    if (provider.status == QuizStatus.loading || _isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              if (_isSubmitting) const Text('Menyelesaikan kuis...'),
            ],
          ),
        ),
      );
    }

    // if (provider.status == QuizStatus.finished) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.go('/home');
    //   });
    //   return const Scaffold(body: Center(child: Text('Kuis Selesai')));
    // }

    final material = provider.material!;
    final question = material.questions[provider.currentIndex];
    final progress = (provider.currentIndex + 1) / material.questions.length;

    final isFirstQuestion = provider.currentIndex == 0;
    final isLastQuestion =
        provider.currentIndex == material.questions.length - 1;
    final isAnswerEmpty = _answerController.text.isEmpty;

    // Timer
    final minutes = (provider.remainingSeconds ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (provider.remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${provider.currentIndex + 1} dari ${material.questions.length}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: progress),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (question.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CachedNetworkImage(
                  imageUrl: question.imageUrl!,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _answerController,
              onChanged: provider.updateAnswer,
              decoration: const InputDecoration(
                labelText: 'Jawaban Anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 100,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: isFirstQuestion ? null : provider.previousQuestion,
              child: const Text('Sebelumnya'),
            ),
            ElevatedButton(
              onPressed: isAnswerEmpty
                  ? null
                  : () {
                      if (isLastQuestion) {
                        _submitAndNavigate();
                      } else {
                        provider.nextQuestion();
                      }
                    },
              child: Text(isLastQuestion ? 'Selesai' : 'Selanjutnya'),
            ),
          ],
        ),
      ),
    );
  }
}
