import 'package:flutter/foundation.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/core/services/firestore_service.dart';

class MaterialProvider with ChangeNotifier {
  final LocalStorageRepository _repository;
  final FirestoreService _firestoreService;

  MaterialProvider({
    required LocalStorageRepository repository,
    required FirestoreService firestoreService,
  }) : _repository = repository,
       _firestoreService = firestoreService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<mt.Material> _materials = [];
  List<mt.Material> get materials => _materials;

  Future<void> loadMaterialsFromLocal() async {
    _isLoading = true;
    notifyListeners();

    _materials = _repository.getAllMaterials();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> syncMaterials({bool isOnline = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!isOnline) {
      _errorMessage =
          'Tidak ada koneksi internet. Data tidak dapat disinkronkan.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final remoteMaterials = await _firestoreService.getAllMaterials();

      await _repository.saveMaterials(remoteMaterials);
      _materials = _repository.getAllMaterials();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
