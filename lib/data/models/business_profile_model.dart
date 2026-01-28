import 'package:hive/hive.dart';
import '../../domain/entities/business_profile_entity.dart';

part 'business_profile_model.g.dart';

/// Business Profile Model for Hive storage
/// Includes JSON serialization and Hive adapter
@HiveType(typeId: 0)
class BusinessProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String businessName;

  @HiveField(2)
  final String? logoPath;

  @HiveField(3)
  final String? whatsappNumber;

  @HiveField(4)
  final String? primaryPhone;

  @HiveField(5)
  final String? additionalPhone;

  @HiveField(6)
  final String? instagramId;

  @HiveField(7)
  final String? websiteUrl;

  @HiveField(8)
  final String? gstNumber;

  @HiveField(9)
  final String? businessAddress;

  @HiveField(12)
  final String? businessNameTamil;

  @HiveField(13)
  final String? businessAddressTamil;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  BusinessProfileModel({
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

  /// Convert from Entity to Model
  factory BusinessProfileModel.fromEntity(BusinessProfileEntity entity) {
    return BusinessProfileModel(
      id: entity.id,
      businessName: entity.businessName,
      logoPath: entity.logoPath,
      whatsappNumber: entity.whatsappNumber,
      primaryPhone: entity.primaryPhone,
      additionalPhone: entity.additionalPhone,
      instagramId: entity.instagramId,
      websiteUrl: entity.websiteUrl,
      gstNumber: entity.gstNumber,
      businessAddress: entity.businessAddress,
      businessNameTamil: entity.businessNameTamil,
      businessAddressTamil: entity.businessAddressTamil,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Model to Entity
  BusinessProfileEntity toEntity() {
    return BusinessProfileEntity(
      id: id,
      businessName: businessName,
      logoPath: logoPath,
      whatsappNumber: whatsappNumber,
      primaryPhone: primaryPhone,
      additionalPhone: additionalPhone,
      instagramId: instagramId,
      websiteUrl: websiteUrl,
      gstNumber: gstNumber,
      businessAddress: businessAddress,
      businessNameTamil: businessNameTamil,
      businessAddressTamil: businessAddressTamil,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'logoPath': logoPath,
      'whatsappNumber': whatsappNumber,
      'primaryPhone': primaryPhone,
      'additionalPhone': additionalPhone,
      'instagramId': instagramId,
      'websiteUrl': websiteUrl,
      'gstNumber': gstNumber,
      'businessAddress': businessAddress,
      'businessNameTamil': businessNameTamil,
      'businessAddressTamil': businessAddressTamil,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      id: json['id'] as String,
      businessName: json['businessName'] as String,
      logoPath: json['logoPath'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      primaryPhone: json['primaryPhone'] as String?,
      additionalPhone: json['additionalPhone'] as String?,
      instagramId: json['instagramId'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      gstNumber: json['gstNumber'] as String?,
      businessAddress: json['businessAddress'] as String?,
      businessNameTamil: json['businessNameTamil'] as String?,
      businessAddressTamil: json['businessAddressTamil'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  BusinessProfileModel copyWith({
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
    return BusinessProfileModel(
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
}
