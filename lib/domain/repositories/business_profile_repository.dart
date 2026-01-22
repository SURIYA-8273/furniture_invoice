import '../../domain/entities/business_profile_entity.dart';

/// Repository interface for Business Profile operations.
/// Defines the contract for data access.
abstract class BusinessProfileRepository {
  /// Get the business profile
  /// Returns null if no profile exists
  Future<BusinessProfileEntity?> getProfile();

  /// Save or update the business profile
  Future<void> saveProfile(BusinessProfileEntity profile);

  /// Update business logo
  Future<void> updateLogo(String profileId, String logoPath);

  /// Delete the business profile
  Future<void> deleteProfile();

  /// Check if profile exists
  Future<bool> hasProfile();
}
