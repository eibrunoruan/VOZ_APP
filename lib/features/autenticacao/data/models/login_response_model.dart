
import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String refresh;
  final String access;

  const LoginResponse({
    required this.refresh,
    required this.access,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      refresh: json['refresh'],
      access: json['access'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
    };
  }

  @override
  List<Object?> get props => [refresh, access];
}
