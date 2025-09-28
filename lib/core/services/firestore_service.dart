import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:learning_app/core/models/material_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<List<Material>> getAllMaterials() async {
    try {
      final snapshot = await _db.collection('materials').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs
          .map((doc) => Material.fromJson(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      print('Error fetching materials: $e');
      throw Exception('Gagal mengambil materi dari server.');
    }
  }

  Future<void> uploadAttempt(Attempt attempt, String userId) async {
    try {
      await _db
          .collection('user')
          .doc(userId)
          .collection('attempts')
          .doc(attempt.id)
          .set(attempt.toJson());
    } on FirebaseException catch (e) {
      print('Gagal mengunggah attempt ${attempt.id}: $e');
    }
  }
}
