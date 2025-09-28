import 'package:hive/hive.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;
import 'package:learning_app/core/models/attempt_model.dart';

class LocalStorageRepository {
  final Box<mt.Material> _materialBox = Hive.box<mt.Material>('materials');
  final Box<Attempt> _attemptBox = Hive.box<Attempt>('attempts');

  // --- operasi materi ---

  Future<void> saveMaterials(List<mt.Material> materials) async {
    final Map<String, mt.Material> materialMap = {
      for (var m in materials) m.id: m,
    };
    await _materialBox.putAll(materialMap);
  }

  List<mt.Material> getAllMaterials() {
    return _materialBox.values.toList();
  }

  mt.Material? getMaterialById(String id) {
    return _materialBox.get(id);
  }

  // --- operasi attempt ---

  Future<void> saveAttempt(Attempt attempt) async {
    await _attemptBox.put(attempt.id, attempt);
  }

  List<Attempt> getAllAttempts() {
    var attempts = _attemptBox.values.toList();
    attempts.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return attempts;
  }

  List<Attempt> getUnsyncedAttemtps() {
    return _attemptBox.values.where((attempt) => !attempt.isSynced).toList();
  }

  Attempt? getAttemptById(String id) {
    return _attemptBox.get(id);
  }

  Future<void> deleteAttempt(String attemptId) async {
    await _attemptBox.delete(attemptId);
  }
}
