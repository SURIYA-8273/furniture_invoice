import 'package:equatable/equatable.dart';

class DescriptionEntity extends Equatable {
  final String id;
  final String text;

  const DescriptionEntity({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];
}
