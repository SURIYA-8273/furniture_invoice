import '../../entities/business_profile_entity.dart';
import '../../repositories/business_profile_repository.dart';

/// Use case for saving or updating the business profile.
class SaveBusinessProfile {
  final BusinessProfileRepository repository;

  SaveBusinessProfile(this.repository);

  Future<void> call(BusinessProfileEntity profile) async {
    // Validate business name
    if (profile.businessName.trim().isEmpty) {
      throw Exception('Business name is required');
    }

    if (profile.businessName.trim().length < 3) {
      throw Exception('Business name must be at least 3 characters');
    }

    // Update the updatedAt timestamp
    final updatedProfile = profile.copyWith(
      updatedAt: DateTime.now(),
    );

    await repository.saveProfile(updatedProfile);
  }
}
