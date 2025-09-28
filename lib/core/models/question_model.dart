import 'package:hive/hive.dart';

part 'question_model.g.dart';

@HiveType(typeId: 1)
class Question extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String questionText;

  @HiveField(2)
  final String? imageUrl;

  @HiveField(3)
  final List<String> evaluationCriteria;

  @HiveField(4)
  final int maxScore;

  Question({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.evaluationCriteria,
    required this.maxScore,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      imageUrl: json['imageUrl'],
      evaluationCriteria: List<String>.from(json['evaluationCriteria']),
      maxScore: json['maxScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'imageUrl': imageUrl,
      'evaluationCriteria': evaluationCriteria,
      'maxScore': maxScore,
    };
  }
}
