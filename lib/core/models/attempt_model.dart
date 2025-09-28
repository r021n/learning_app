import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'attempt_model.g.dart';

@HiveType(typeId: 2)
class Attempt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String materialId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final List<String> userAnswers;

  @HiveField(4)
  final int score;

  @HiveField(5)
  final List<String> masteredTopics;

  @HiveField(6)
  final List<String> unmasteredTopics;

  @HiveField(7)
  final DateTime completedAt;

  @HiveField(8)
  bool isSynced;

  Attempt({
    required this.id,
    required this.materialId,
    required this.userId,
    required this.userAnswers,
    required this.score,
    required this.masteredTopics,
    required this.unmasteredTopics,
    required this.completedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'userAnswers': userAnswers,
      'score': score,
      'masteredTopics': masteredTopics,
      'unmasteredTopics': unmasteredTopics,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
