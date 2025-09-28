import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:learning_app/core/models/question_model.dart';

part 'material_model.g.dart';

@HiveType(typeId: 0)
class Material extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<Question> questions;

  @HiveField(3)
  final int durationInMinutes;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  Material({
    required this.id,
    required this.title,
    required this.questions,
    required this.durationInMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Material.fromJson(String id, Map<String, dynamic> json) {
    return Material(
      id: id,
      title: json['title'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      durationInMinutes: json['durationInMinutes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
      'durationInMinutes': durationInMinutes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
