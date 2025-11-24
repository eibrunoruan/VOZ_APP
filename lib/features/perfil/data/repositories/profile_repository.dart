import '../datasources/profile_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepository(this._datasource);

  Future<UserProfileModel> getProfile() async {
    return await _datasource.getProfile();
  }

  Future<UserProfileModel> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    final data = <String, dynamic>{};
    
    if (username != null) data['username'] = username;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;

    return await _datasource.updateProfile(data);
  }
}
