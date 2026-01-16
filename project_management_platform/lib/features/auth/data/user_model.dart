import 'package:project_management_platform/features/auth/domain/user.dart';

class UserModel extends User {
  const UserModel({
    required int id,
    required String email,
    String? fullName,
    required String role,
  }) : super(id: id, email: email, fullName: fullName, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'full_name': fullName, 'role': role};
  }
}
