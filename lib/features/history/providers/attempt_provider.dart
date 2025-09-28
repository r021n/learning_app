import 'package:flutter/foundation.dart';
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';

class AttemptProvider with ChangeNotifier {
  final LocalStorageRepository _repository;

  AttemptProvider({required LocalStorageRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Attempt> _attempts = [];
  List<Attempt> get attempts => _attempts;

  Future<void> loadAttempts() async {
    _isLoading = true;
    notifyListeners();

    _attempts = _repository.getAllAttempts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAttempt(Attempt attempt) async {
    await _repository.saveAttempt(attempt);
    await loadAttempts();
  }

  Future<void> deleteAttempt(String attemptId) async {
    await _repository.deleteAttempt(attemptId);
    _attempts.removeWhere((attempt) => attempt.id == attemptId);
    notifyListeners();
  }
}
