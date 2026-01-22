import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/business_profile_entity.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../models/business_profile_model.dart';

/// Implementation of Business Profile Repository using Hive.
/// Handles local storage of business profile data.
class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  static const String _profileKey = 'business_profile';

  Box get _box => Hive.box(HiveBoxNames.businessProfile);

  @override
  Future<BusinessProfileEntity?> getProfile() async {
    try {
      final model = _box.get(_profileKey) as BusinessProfileModel?;
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get business profile: $e');
    }
  }

  @override
  Future<void> saveProfile(BusinessProfileEntity profile) async {
    try {
      final model = BusinessProfileModel.fromEntity(profile);
      await _box.put(_profileKey, model);
    } catch (e) {
      throw Exception('Failed to save business profile: $e');
    }
  }

  @override
  Future<void> updateLogo(String profileId, String logoPath) async {
    try {
      final model = _box.get(_profileKey) as BusinessProfileModel?;
      if (model == null) {
        throw Exception('Business profile not found');
      }

      final updatedModel = model.copyWith(
        logoPath: logoPath,
        updatedAt: DateTime.now(),
      );

      await _box.put(_profileKey, updatedModel);
    } catch (e) {
      throw Exception('Failed to update logo: $e');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      await _box.delete(_profileKey);
    } catch (e) {
      throw Exception('Failed to delete business profile: $e');
    }
  }

  @override
  Future<bool> hasProfile() async {
    try {
      return _box.containsKey(_profileKey);
    } catch (e) {
      throw Exception('Failed to check profile existence: $e');
    }
  }
}
