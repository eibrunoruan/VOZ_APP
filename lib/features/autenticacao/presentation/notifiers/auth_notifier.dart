import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isGuest; // Visitante (pode criar denúncias sem login)
  final String? guestNickname; // Apelido do visitante

  AuthState({
    required this.isLoggedIn,
    this.isGuest = false,
    this.guestNickname,
  });

  bool get hasAccess => isLoggedIn || isGuest;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;

  AuthNotifier(this._storage) : super(AuthState(isLoggedIn: false)) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {

    final accessToken = await _storage.read(key: 'access_token');

    if (accessToken != null && accessToken.isNotEmpty) {

      state = AuthState(isLoggedIn: true, isGuest: false);
      return;
    }

    final guestNickname = await _storage.read(key: 'guest_nickname');
    if (guestNickname != null && guestNickname.isNotEmpty) {

      state = AuthState(
        isLoggedIn: false,
        isGuest: true,
        guestNickname: guestNickname,
      );
      return;
    }

    state = AuthState(isLoggedIn: false, isGuest: false);
  }

  Future<void> login() async {

    await _storage.delete(key: 'guest_nickname');
    state = AuthState(isLoggedIn: true, isGuest: false);
  }

  Future<void> logout() async {

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'guest_nickname');
    state = AuthState(isLoggedIn: false, isGuest: false);
  }


  Future<void> enterAsGuest(String nickname) async {
    await _storage.write(key: 'guest_nickname', value: nickname);
    state = AuthState(
      isLoggedIn: false,
      isGuest: true,
      guestNickname: nickname,
    );
  }

  Future<void> updateGuestNickname(String newNickname) async {
    if (!state.isGuest) {
      throw Exception('Usuário não está em modo convidado');
    }
    await _storage.write(key: 'guest_nickname', value: newNickname);
    state = AuthState(
      isLoggedIn: false,
      isGuest: true,
      guestNickname: newNickname,
    );
  }

  String? getGuestNickname() {
    return state.guestNickname;
  }

  Future<bool> hasActiveSession() async {
    await _loadAuthState();
    return state.hasAccess;
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
    state = AuthState(isLoggedIn: false, isGuest: false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {

  const storage = FlutterSecureStorage();
  return AuthNotifier(storage);
});
