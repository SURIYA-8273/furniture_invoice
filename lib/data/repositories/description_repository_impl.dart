import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/description_entity.dart';
import '../../domain/repositories/description_repository.dart';
import '../models/description_model.dart';

class DescriptionRepositoryImpl implements DescriptionRepository {
  final Box<DescriptionModel> _box;

  DescriptionRepositoryImpl(this._box);

  @override
  Future<void> addDescription(DescriptionEntity description) async {
    final model = DescriptionModel.fromEntity(description);
    await _box.put(model.id, model);
  }

  @override
  Future<void> deleteDescription(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<DescriptionEntity>> getDescriptions() async {
    return _box.values.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> updateDescription(DescriptionEntity description) async {
    final model = DescriptionModel.fromEntity(description);
    await _box.put(model.id, model);
  }
}
