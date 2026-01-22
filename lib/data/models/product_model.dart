import 'package:hive/hive.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final double mrp;

  @HiveField(4)
  final String? size;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.mrp,
    this.size,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      mrp: entity.mrp,
      size: entity.size,
      category: entity.category,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      mrp: mrp,
      size: size,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mrp': mrp,
      'size': size,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mrp: (json['mrp'] as num).toDouble(),
      size: json['size'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
