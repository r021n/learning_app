import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:learning_app/core/models/material_model.dart' as mt;
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';

enum QuizStatus { loading, active, finished }

class QuizProvider with ChangeNotifier {
  final LocalStorageRepository _repository;
  final String _materialId;
  final String _userId;
  final AttemptProvider _attemptProvider;

  QuizProvider({
    required LocalStorageRepository repository,
    required String materialId,
    required String userId,
    required AttemptProvider attemptProvider,
  }) : _repository = repository,
       _materialId = materialId,
       _userId = userId,
       _attemptProvider = attemptProvider;

  QuizStatus _status = QuizStatus.loading;
  QuizStatus get status => _status;

  mt.Material? _material;
  mt.Material? get material => _material;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  late List<String> _userAnswers;
  List<String> get userAnswers => _userAnswers;

  Timer? _timer;
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  Future<void> initializeQuiz() async {
    _status = QuizStatus.loading;
    notifyListeners();

    _material = _repository.getMaterialById(_materialId);

    if (_material != null) {
      _userAnswers = List.filled(_material!.questions.length, '');
      _remainingSeconds = _material!.durationInMinutes * 60;
      _status = QuizStatus.active;
      startTimer();
    } else {
      _status = QuizStatus.finished;
    }
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        finishAttempt(isAutoSubmit: true);
      }
    });
  }

  void updateAnswer(String answer) {
    if (_status == QuizStatus.active) {
      _userAnswers[_currentIndex] = answer;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _material!.questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<String> finishAttempt({bool isAutoSubmit = false}) async {
    if (_status != QuizStatus.active) {
      throw Exception('Attempt sudah selesai atau sedang diproses.');
    }
    _status = QuizStatus.finished;
    _timer?.cancel();
    notifyListeners();

    final attempt = Attempt(
      id: const Uuid().v4(),
      materialId: _materialId,
      userId: _userId,
      userAnswers: _userAnswers,
      completedAt: DateTime.now(),
      score: 0,
      masteredTopics: [],
      unmasteredTopics: [],
      isSynced: false,
      feedback: [],
    );

    await _attemptProvider.saveAttempt(attempt);

    return attempt.id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
