import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int id;
  final String title;
  final String description;
  final int ownerId;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
  });

  @override
  List<Object> get props => [id, title, description, ownerId];
}
