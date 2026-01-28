import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/business_profile_entity.dart';
import '../../domain/usecases/business_profile/get_business_profile.dart';
import '../../domain/usecases/business_profile/save_business_profile.dart';
import '../../domain/usecases/business_profile/update_business_logo.dart';

/// Provider for managing business profile state.
/// Handles CRUD operations and state updates for business profile.
class BusinessProfileProvider extends ChangeNotifier {
  final GetBusinessProfile getBusinessProfileUseCase;
  final SaveBusinessProfile saveBusinessProfileUseCase;
  final UpdateBusinessLogo updateBusinessLogoUseCase;

  BusinessProfileEntity? _profile;
  bool _isLoading = false;
  String? _error;

  BusinessProfileProvider({
    required this.getBusinessProfileUseCase,
    required this.saveBusinessProfileUseCase,
    required this.updateBusinessLogoUseCase,
  });

  // Getters
  BusinessProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Initialize and load business profile
  Future<void> initialize() async {
    await loadProfile();
  }

  /// Load business profile from repository
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await getBusinessProfileUseCase();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading business profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save or update business profile
  Future<bool> saveProfile({
    required String businessName,
    String? logoPath,
    String? whatsappNumber,
    String? primaryPhone,
    String? additionalPhone,
    String? instagramId,
    String? websiteUrl,
    String? gstNumber,
    String? businessAddress,
    String? businessNameTamil,
    String? businessAddressTamil,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final profileEntity = BusinessProfileEntity(
        id: _profile?.id ?? const Uuid().v4(),
        businessName: businessName,
        logoPath: logoPath ?? _profile?.logoPath,
        whatsappNumber: whatsappNumber,
        primaryPhone: primaryPhone,
        additionalPhone: additionalPhone,
        instagramId: instagramId,
        websiteUrl: websiteUrl,
        gstNumber: gstNumber,
        businessAddress: businessAddress,
        businessNameTamil: businessNameTamil,
        businessAddressTamil: businessAddressTamil,
        createdAt: _profile?.createdAt ?? now,
        updatedAt: now,
      );

      await saveBusinessProfileUseCase(profileEntity);
      _profile = profileEntity;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving business profile: $e');
      return false;
    }
  }

  /// Update business logo
  Future<bool> updateLogo(String logoPath) async {
    if (_profile == null) {
      _error = 'No business profile found';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await updateBusinessLogoUseCase(_profile!.id, logoPath);
      _profile = _profile!.copyWith(
        logoPath: logoPath,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating logo: $e');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
