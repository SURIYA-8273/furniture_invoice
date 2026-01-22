import '../../entities/business_profile_entity.dart';
import '../../repositories/business_profile_repository.dart';

/// Use case for getting the business profile.
class GetBusinessProfile {
  final BusinessProfileRepository repository;

  GetBusinessProfile(this.repository);

  Future<BusinessProfileEntity?> call() async {
    return await repository.getProfile();
  }
}
