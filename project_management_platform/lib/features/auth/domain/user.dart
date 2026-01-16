import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? fullName;
  final String role; // admin, buyer, developer

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, fullName, role];
}
