import '../../repositories/business_profile_repository.dart';

/// Use case for updating the business logo.
class UpdateBusinessLogo {
  final BusinessProfileRepository repository;

  UpdateBusinessLogo(this.repository);

  Future<void> call(String profileId, String logoPath) async {
    if (logoPath.trim().isEmpty) {
      throw Exception('Logo path cannot be empty');
    }

    await repository.updateLogo(profileId, logoPath);
  }
}
