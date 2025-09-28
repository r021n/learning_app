import 'package:flutter/foundation.dart';
import 'package:learning_app/core/providers/connectivity_provider.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/core/services/firestore_service.dart';
import 'package:learning_app/features/auth/providers/auth_provider.dart';

class SyncProvider with ChangeNotifier {
  final LocalStorageRepository _localRepo;
  final FirestoreService _firestoreService;
  final ConnectivityProvider _connectivityProvider;
  final AuthProvider _authProvider;

  SyncProvider({
    required LocalStorageRepository localRepo,
    required FirestoreService firestoreService,
    required ConnectivityProvider connectivityProvider,
    required AuthProvider authProvider,
  }) : _localRepo = localRepo,
       _firestoreService = firestoreService,
       _connectivityProvider = connectivityProvider,
       _authProvider = authProvider;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<bool> syncAllUsynced() async {
    if (!_connectivityProvider.isOnline) {
      print('Sinkronisasi gagal: tidak ada koneksi internet.');
      return false;
    }

    final userId = _authProvider.currentUser?.uid;
    if (userId == null) {
      print('Sinkronisasi gagal: pengguna tidak login');
      return false;
    }

    _isSyncing = true;
    notifyListeners();

    final unsyncedAttempts = _localRepo.getUnsyncedAttemtps();
    if (unsyncedAttempts.isEmpty) {
      print('Tidak ada data untuk disinkronkan.');
      _isSyncing = false;
      notifyListeners();
      return true;
    }

    int successCount = 0;
    for (final attempt in unsyncedAttempts) {
      try {
        await _firestoreService.uploadAttempt(attempt, userId);

        attempt.isSynced = true;
        await attempt.save();
        successCount++;
      } catch (e) {
        print(
          'Gagal menyinkronkan attempt ${attempt.id}. Akan dicoba lagi nanti',
        );
      }
    }

    _isSyncing = false;
    notifyListeners();

    return successCount == unsyncedAttempts.length;
  }
}
