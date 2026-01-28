import '../entities/description_entity.dart';

abstract class DescriptionRepository {
  Future<List<DescriptionEntity>> getDescriptions();
  Future<void> addDescription(DescriptionEntity description);
  Future<void> updateDescription(DescriptionEntity description);
  Future<void> deleteDescription(String id);
}
