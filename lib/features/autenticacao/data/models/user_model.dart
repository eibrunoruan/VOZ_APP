import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final bool isActive;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.isActive = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, username, email, firstName, isActive];
}
