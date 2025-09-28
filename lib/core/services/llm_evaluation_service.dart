import 'dart:convert';
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/core/services/llm_service.dart';
import 'package:learning_app/core/services/prompt_engine.dart';

class LlmEvaluationService {
  final LlmService _llmService;
  final LocalStorageRepository _repository;

  LlmEvaluationService({
    required LlmService llmService,
    required LocalStorageRepository repository,
  }) : _llmService = llmService,
       _repository = repository;

  String _extractJsonString(String rawResponse) {
    final startIndex = rawResponse.indexOf('{');
    final endIndex = rawResponse.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return rawResponse.substring(startIndex, endIndex + 1);
    }

    return rawResponse;
  }

  Future<Attempt> evaluateAttempt(String attemptId) async {
    final attempt = _repository.getAttemptById(attemptId);
    if (attempt == null) throw Exception('Attempt tidak ditemukan');

    final material = _repository.getMaterialById(attempt.materialId);
    if (material == null) throw Exception('Materi tidak ditemukan');

    int totalScore = 0;
    List<String> allMastered = [];
    List<String> allUnmastered = [];

    for (int i = 0; i < material.questions.length; i++) {
      final question = material.questions[i];
      final answer = attempt.userAnswers[i];

      if (answer.trim().isEmpty) continue;

      final prompt = PromptEngine.createEvaluationPrompt(
        question: question,
        userAnswer: answer,
      );
      final llmResponse = await _llmService.run(prompt);
      print(llmResponse);

      try {
        final cleanJsonString = _extractJsonString(llmResponse);
        final jsonResponse =
            jsonDecode(cleanJsonString) as Map<String, dynamic>;

        totalScore += (jsonResponse['score'] as num).toInt();
        if (jsonResponse['mastered'] != null) {
          allMastered.addAll(List<String>.from(jsonResponse['mastered']));
        }
        if (jsonResponse['unmastered'] != null) {
          allUnmastered.addAll(List<String>.from(jsonResponse['unmastered']));
        }
      } catch (e) {
        print('Gagal parsing JSON dari LLM, menggunakan fallback: $e');
        totalScore += _fallbackKeywordMatching(
          answer,
          question.evaluationCriteria,
        );
      }
    }

    final evaluatedAttempt = Attempt(
      id: attempt.id,
      materialId: attempt.materialId,
      userId: attempt.userId,
      userAnswers: attempt.userAnswers,
      completedAt: attempt.completedAt,
      score: totalScore,
      masteredTopics: allMastered.toSet().toList(),
      unmasteredTopics: allUnmastered.toSet().toList(),
      isSynced: attempt.isSynced,
    );

    await _repository.saveAttempt(evaluatedAttempt);
    return evaluatedAttempt;
  }

  int _fallbackKeywordMatching(String answer, List<String> criteria) {
    int score = 0;
    for (var item in criteria) {
      if (answer.toLowerCase().contains(item.toLowerCase().split(' ').first)) {
        score++;
      }
    }
    return score;
  }
}
