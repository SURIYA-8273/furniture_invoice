/// Business Profile Entity
/// Represents the business identity used across the application.
/// Only business name is mandatory, all other fields are optional.
class BusinessProfileEntity {
  final String id;
  final String businessName; // REQUIRED
  final String? logoPath; // Optional - path to business logo
  final String? whatsappNumber; // Optional - for invoice sharing
  final String? primaryPhone; // Optional
  final String? additionalPhone; // Optional
  final String? instagramId; // Optional
  final String? websiteUrl; // Optional
  final String? gstNumber; // Optional
  final String? businessAddress; // Optional
  final String? businessNameTamil; // Optional (Required in UI)
  final String? businessAddressTamil; // Optional (Required in UI)
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessProfileEntity({
    required this.id,
    required this.businessName,
    this.logoPath,
    this.whatsappNumber,
    this.primaryPhone,
    this.additionalPhone,
    this.instagramId,
    this.websiteUrl,
    this.gstNumber,
    this.businessAddress,
    this.businessNameTamil,
    this.businessAddressTamil,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  BusinessProfileEntity copyWith({
    String? id,
    String? businessName,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessProfileEntity(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      logoPath: logoPath ?? this.logoPath,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      additionalPhone: additionalPhone ?? this.additionalPhone,
      instagramId: instagramId ?? this.instagramId,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      gstNumber: gstNumber ?? this.gstNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      businessNameTamil: businessNameTamil ?? this.businessNameTamil,
      businessAddressTamil: businessAddressTamil ?? this.businessAddressTamil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BusinessProfileEntity(id: $id, businessName: $businessName, whatsappNumber: $whatsappNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessProfileEntity &&
        other.id == id &&
        other.businessName == businessName &&
        other.logoPath == logoPath &&
        other.whatsappNumber == whatsappNumber &&
        other.primaryPhone == primaryPhone &&
        other.additionalPhone == additionalPhone &&
        other.instagramId == instagramId &&
        other.websiteUrl == websiteUrl &&
        other.gstNumber == gstNumber &&
        other.businessAddress == businessAddress &&
        other.businessNameTamil == businessNameTamil &&
        other.businessAddressTamil == businessAddressTamil;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        businessName.hashCode ^
        logoPath.hashCode ^
        whatsappNumber.hashCode ^
        primaryPhone.hashCode ^
        additionalPhone.hashCode ^
        instagramId.hashCode ^
        websiteUrl.hashCode ^
        gstNumber.hashCode ^
        businessAddress.hashCode ^
        businessNameTamil.hashCode ^
        businessAddressTamil.hashCode;
  }
}
