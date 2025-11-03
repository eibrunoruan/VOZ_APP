
import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;
  final String? firstName;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
    };
  }

  @override
  List<Object?> get props => [username, email, password, firstName];
}
