import 'package:learning_app/core/models/question_model.dart';

class PromptEngine {
  static String createEvaluationPrompt({
    required Question question,
    required String userAnswer,
  }) {
    final criteriaString = question.evaluationCriteria
        .map((criteria) => '- $criteria')
        .join('\n');
    return '''
Evaluasi jawaban berikut berdasarkan kriteria yang diberikan:

Pertanyaan: ${question.questionText}
Jawaban Siswa: $userAnswer

Kriteria Penilaian:
$criteriaString

Berikan evaluasi dalam format JSON yang ketat dan hanya JSON saja, tanpa teks tambahan:
{
  "score": 0-${question.maxScore},
  "mastered": ["kriteria yang terpenuhi"],
  "unmastered": ["kriteria yang tidak terpenuhi"],
  "feedback": "Umpan balik singkat dan jelas untuk siswa."
}
''';
  }
}
