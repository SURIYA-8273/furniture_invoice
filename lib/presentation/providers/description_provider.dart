import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/description_entity.dart';
import '../../domain/repositories/description_repository.dart';

class DescriptionProvider extends ChangeNotifier {
  final DescriptionRepository _repository;
  List<DescriptionEntity> _descriptions = [];
  bool _isLoading = false;

  DescriptionProvider({required DescriptionRepository repository})
      : _repository = repository {
    loadDescriptions();
  }

  List<DescriptionEntity> get descriptions => _descriptions;
  bool get isLoading => _isLoading;

  Future<void> loadDescriptions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _descriptions = await _repository.getDescriptions();
    } catch (e) {
      debugPrint('Error loading descriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDescription(String text) async {
    final newDescription = DescriptionEntity(
      id: const Uuid().v4(),
      text: text,
    );
    await _repository.addDescription(newDescription);
    await loadDescriptions();
  }

  Future<void> updateDescription(DescriptionEntity description) async {
    await _repository.updateDescription(description);
    await loadDescriptions();
  }

  Future<void> deleteDescription(String id) async {
    await _repository.deleteDescription(id);
    await loadDescriptions();
  }
}
