import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Estado de autenticação com suporte a visitante
class AuthState {
  final bool isLoggedIn;
  final bool isGuest; // Visitante (pode criar denúncias sem login)
  final String? guestNickname; // Apelido do visitante

  AuthState({
    required this.isLoggedIn,
    this.isGuest = false,
    this.guestNickname,
  });

  // Usuário tem acesso (logado OU visitante)
  bool get hasAccess => isLoggedIn || isGuest;
}

// Notifier para gerenciar o estado de autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;

  AuthNotifier(this._storage) : super(AuthState(isLoggedIn: false)) {
    _loadAuthState();
  }

  // Carrega o estado de autenticação do storage
  Future<void> _loadAuthState() async {
    // Verifica se há token de acesso (usuário autenticado)
    final accessToken = await _storage.read(key: 'access_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      // Usuário está logado
      state = AuthState(isLoggedIn: true, isGuest: false);
      return;
    }

    // Verifica se há apelido de convidado
    final guestNickname = await _storage.read(key: 'guest_nickname');
    if (guestNickname != null && guestNickname.isNotEmpty) {
      // Usuário está como convidado
      state = AuthState(
        isLoggedIn: false,
        isGuest: true,
        guestNickname: guestNickname,
      );
      return;
    }

    // Nenhuma sessão ativa
    state = AuthState(isLoggedIn: false, isGuest: false);
  }

  // Login de usuário autenticado
  Future<void> login() async {
    // Remove apelido de convidado se existir (usuário se cadastrou)
    await _storage.delete(key: 'guest_nickname');
    state = AuthState(isLoggedIn: true, isGuest: false);
  }

  // Logout
  Future<void> logout() async {
    // Remove tokens e apelido
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'guest_nickname');
    state = AuthState(isLoggedIn: false, isGuest: false);
  }

  // Entrar como visitante (guest mode) com apelido
  // IMPORTANTE: Dados salvos PERMANENTEMENTE no dispositivo
  Future<void> enterAsGuest(String nickname) async {
    await _storage.write(key: 'guest_nickname', value: nickname);
    state = AuthState(
      isLoggedIn: false,
      isGuest: true,
      guestNickname: nickname,
    );
  }

  // Atualizar apelido do convidado
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

  // Obtém o apelido do convidado (para usar ao criar denúncias/comentários)
  String? getGuestNickname() {
    return state.guestNickname;
  }

  // Verifica se há sessão ativa (logado OU convidado)
  Future<bool> hasActiveSession() async {
    await _loadAuthState();
    return state.hasAccess;
  }

  // Limpa completamente a sessão (para testes ou reset)
  Future<void> clearSession() async {
    await _storage.deleteAll();
    state = AuthState(isLoggedIn: false, isGuest: false);
  }
}

// Provider para o AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  // Cria uma instância do FlutterSecureStorage
  const storage = FlutterSecureStorage();
  return AuthNotifier(storage);
});
