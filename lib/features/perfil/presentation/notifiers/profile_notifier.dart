import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dio/dio_client.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

// Provider do datasource
final profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileDatasourceImpl(dio);
});

// Provider do repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final datasource = ref.watch(profileDatasourceProvider);
  return ProfileRepository(datasource);
});

// Estado do perfil
class ProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier do perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedProfile = await _repository.updateProfile(
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// Provider do notifier
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
