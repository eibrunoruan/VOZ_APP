import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isEmailVerified;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  const UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isEmailVerified,
    required this.dateJoined,
    this.lastLogin,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_email_verified': isEmailVerified,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    // Apenas campos editáveis
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  UserProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isEmailVerified,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        isEmailVerified,
        dateJoined,
        lastLogin,
      ];
}
