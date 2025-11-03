# 🤖 GUIA COMPLETO PARA COPILOT - VOZ DO POVO

> **Propósito:** Este arquivo contém TODAS as informações necessárias para que o GitHub Copilot/IA entenda o projeto, sua arquitetura, o que foi feito e o que precisa ser implementado.

**Última atualização:** 01 de Novembro de 2025  
**Versão:** 3.0 FINAL

---

## 📱 VISÃO GERAL DO PROJETO

### O que é?
Aplicativo móvel em Flutter para conectar cidadãos e gestão pública, permitindo:
- Criar denúncias georreferenciadas com fotos
- Visualizar denúncias no mapa interativo
- Apoiar denúncias de outros cidadãos
- Comentar e acompanhar resoluções
- Modo visitante para usuários sem cadastro

### Stack Tecnológica
```yaml
Flutter: 3.9.0
Dart: 3.9.0
State Management: Riverpod 2.5.1
Navegação: GoRouter 13.2.0
HTTP Client: Dio 5.4.0
Storage: FlutterSecureStorage 9.0.0
Mapas: Google Maps Flutter 2.5.3
Backend: Django REST API (http://192.168.1.10:8000)
```

---

## 🏗️ ARQUITETURA

### Clean Architecture + Feature-First

```
lib/
├── main.dart                 # Entry point com ProviderScope
├── config/
│   ├── dio/                  # HTTP client configurado
│   ├── env/                  # Variáveis de ambiente
│   └── router/               # GoRouter com guards
├── core/
│   ├── exceptions/           # 7 exceções customizadas
│   ├── widgets/              # Widgets compartilhados
│   ├── utils/                # Utilidades
│   └── services/             # Serviços (location, etc)
└── features/
    ├── autenticacao/         # ✅ COMPLETO
    │   ├── data/
    │   │   ├── datasources/  # AuthDataSource (API calls)
    │   │   ├── models/       # User, LoginResponse, etc
    │   │   └── repositories/ # AuthRepository
    │   └── presentation/
    │       ├── notifiers/    # AuthNotifier (Riverpod)
    │       └── views/        # 10 telas
    ├── denuncias/            # 🔴 IMPLEMENTAR
    │   ├── data/
    │   └── presentation/
    ├── home/                 # 🔴 IMPLEMENTAR
    │   └── presentation/
    └── profile/              # 🔴 IMPLEMENTAR
        └── presentation/
```

### Fluxo de Dados
```
UI (Views) 
  ↓ usa
StateNotifier (Notifiers)
  ↓ chama
Repository
  ↓ chama
DataSource
  ↓ faz requisição HTTP
Backend API
```

---

## ✅ O QUE ESTÁ IMPLEMENTADO (100%)

### 1. SISTEMA DE AUTENTICAÇÃO

#### Telas (10/10)
1. **WelcomeScreen** - Tela inicial com 3 botões
2. **LoginScreen** - Login com username/senha
3. **RegisterScreen** - Cadastro com validação completa
4. **VerifyEmailScreen** - Código de 5 dígitos, auto-submit
5. **ForgotPasswordScreen** - Solicitar reset por email
6. **ValidateResetCodeScreen** - Validar código ANTES da senha
7. **SetNewPasswordScreen** - Definir nova senha
8. **ResetPasswordScreen** - Versão antiga (mantida)
9. **GuestProfileScreen** - Coletar apelido do visitante
10. **GuestSettingsScreen** - Configurações do visitante

#### AuthDataSource (auth_datasource.dart)
```dart
abstract class AuthDatasource {
  Future<LoginResponse> login(String username, String password);
  Future<User> register(RegisterRequest request);
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerificationCode(String email);
  Future<void> requestPasswordReset(String email);
  Future<void> validatePasswordResetCode(String email, String code);
  Future<void> confirmPasswordReset(String email, String code, String password);
  Future<void> logout();
}
```

**Endpoints utilizados:**
- POST /api/auth/login/
- POST /api/auth/register/
- POST /api/auth/verify-email/
- POST /api/auth/resend-verification-code/
- POST /api/auth/password-reset/request/
- POST /api/auth/password-reset/validate-code/
- POST /api/auth/password-reset/confirm/
- POST /api/auth/logout/

#### AuthNotifier (auth_notifier.dart)
```dart
class AuthState {
  final bool isLoggedIn;
  final bool isGuest;
  final String? guestNickname;
  
  bool get hasAccess => isLoggedIn || isGuest;
}

class AuthNotifier extends StateNotifier<AuthState> {
  // 12 métodos implementados
  Future<void> _loadAuthState();        // Auto-restaura sessão
  Future<void> login();
  Future<void> register();
  Future<void> verifyEmail();
  Future<void> resendVerificationCode();
  Future<void> requestPasswordReset();
  Future<void> confirmPasswordReset();
  Future<void> enterAsGuest(String nickname);
  Future<void> updateGuestNickname(String newNickname);
  Future<void> logout();
  Future<bool> hasActiveSession();
  Future<void> clearSession();
}
```

#### Models
```dart
// User (user_model.dart)
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final bool isActive;
}

// LoginResponse (login_response_model.dart)
class LoginResponse {
  final String access;
  final String refresh;
}

// RegisterRequest (register_request_model.dart)
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
}
```

#### Exceções (auth_exceptions.dart)
```dart
1. EmailNotVerifiedException
2. InvalidVerificationCodeException
3. InvalidCredentialsException
4. EmailAlreadyExistsException
5. UsernameAlreadyExistsException
6. NetworkException
7. UnknownAuthException
```

#### Router (router.dart)
```dart
11 rotas implementadas:
/ → WelcomeScreen
/login → LoginScreen
/register → RegisterScreen
/verify-email → VerifyEmailScreen
/forgot-password → ForgotPasswordScreen
/validate-reset-code → ValidateResetCodeScreen
/set-new-password → SetNewPasswordScreen
/reset-password → ResetPasswordScreen
/guest-profile → GuestProfileScreen
/guest-settings → GuestSettingsScreen
/home → HomeScreen (placeholder)

Guards de autenticação:
- Verifica authState.hasAccess
- Redireciona não autenticados para /
- Redireciona autenticados para /home
```

### 2. PERSISTÊNCIA DE DADOS

#### FlutterSecureStorage
```dart
Keys utilizadas:
- 'access_token' → JWT access token
- 'refresh_token' → JWT refresh token
- 'guest_nickname' → Apelido do visitante

Características:
- Criptografia nativa (Keychain iOS / KeyStore Android)
- Dados persistem após fechar app
- Dados persistem após reiniciar dispositivo
- Dados persistem indefinidamente
- Auto-restauração ao iniciar app (_loadAuthState)
```

### 3. NETWORKING

#### Dio Client (dio_client.dart)
```dart
Configurações:
- Base URL: http://192.168.1.10:8000
- Timeout: 30 segundos
- Content-Type: application/json

Interceptors:
- Logging detalhado (🌐 REQUEST, ✅ SUCCESS, ❌ ERROR)
- Whitelist de endpoints públicos (não envia token)
- Tratamento automático de erros

Endpoints públicos (sem token):
[
  '/api/auth/login/',
  '/api/auth/register/',
  '/api/auth/verify-email/',
  '/api/auth/password-reset/request/',
  '/api/auth/password-reset/validate-code/',
  '/api/auth/password-reset/confirm/',
  '/api/health/',
]
```

---

## 🔴 O QUE PRECISA SER IMPLEMENTADO

### PRIORIDADE #1: HOME COM MAPA (PRÓXIMA FEATURE)

#### Arquivos a criar:

**1. Models (lib/features/denuncias/data/models/)**
```dart
// denuncia_model.dart
class DenunciaModel {
  final int id;
  final String titulo;
  final String descricao;
  final double latitude;
  final double longitude;
  final String status; // 'aberta', 'em_analise', 'resolvida'
  final DateTime dataCriacao;
  final int totalApoios;
  final bool usuarioApoiou;
  final CategoriaModel categoria;
  final AutorModel? autor;
  final String? autorConvidado; // Para visitantes
  final List<FotoModel> fotos;
  final LocalidadeModel? localidade;
  
  factory DenunciaModel.fromJson(Map<String, dynamic> json);
}

// categoria_model.dart
class CategoriaModel {
  final int id;
  final String nome;
  final String icone;
  
  factory CategoriaModel.fromJson(Map<String, dynamic> json);
}

// foto_model.dart
class FotoModel {
  final int id;
  final String imagem; // URL da foto
  
  factory FotoModel.fromJson(Map<String, dynamic> json);
}

// localidade_model.dart
class LocalidadeModel {
  final int id;
  final String nome;
  final String tipo;
  
  factory LocalidadeModel.fromJson(Map<String, dynamic> json);
}
```

**2. DataSource (lib/features/denuncias/data/datasources/)**
```dart
// denuncias_datasource.dart
abstract class DenunciasDataSource {
  Future<List<DenunciaModel>> getDenuncias({
    String? categoria,
    String? status,
    double? latitude,
    double? longitude,
    double? raio,
  });
  
  Future<DenunciaModel> getDenunciaById(int id);
  
  Future<DenunciaModel> createDenuncia({
    required String titulo,
    required String descricao,
    required double latitude,
    required double longitude,
    required List<File> fotos,
    required int categoriaId,
    String? autorConvidado,
  });
  
  Future<void> apoiarDenuncia(int denunciaId);
  Future<void> removerApoio(int denunciaId);
}

// Implementação
class DenunciasDataSourceImpl implements DenunciasDataSource {
  final Dio _dio;
  
  @override
  Future<List<DenunciaModel>> getDenuncias({...}) async {
    final response = await _dio.get('/api/denuncias/denuncias/', queryParameters: {...});
    return (response.data as List).map((json) => DenunciaModel.fromJson(json)).toList();
  }
  
  @override
  Future<DenunciaModel> createDenuncia({...}) async {
    final formData = FormData();
    formData.fields.add(MapEntry('titulo', titulo));
    formData.fields.add(MapEntry('descricao', descricao));
    formData.fields.add(MapEntry('latitude', latitude.toString()));
    formData.fields.add(MapEntry('longitude', longitude.toString()));
    formData.fields.add(MapEntry('categoria', categoriaId.toString()));
    
    if (autorConvidado != null) {
      formData.fields.add(MapEntry('autor_convidado', autorConvidado));
    }
    
    for (var foto in fotos) {
      formData.files.add(await MultipartFile.fromFile(foto.path, filename: 'foto.jpg'));
    }
    
    final response = await _dio.post('/api/denuncias/denuncias/', data: formData);
    return DenunciaModel.fromJson(response.data);
  }
}
```

**3. Repository (lib/features/denuncias/data/repositories/)**
```dart
// denuncias_repository.dart
class DenunciasRepository {
  final DenunciasDataSource _dataSource;
  
  DenunciasRepository(this._dataSource);
  
  Future<List<DenunciaModel>> getDenuncias({...}) => _dataSource.getDenuncias(...);
  Future<DenunciaModel> getDenunciaById(int id) => _dataSource.getDenunciaById(id);
  Future<DenunciaModel> createDenuncia({...}) => _dataSource.createDenuncia(...);
  Future<void> apoiarDenuncia(int id) => _dataSource.apoiarDenuncia(id);
  Future<void> removerApoio(int id) => _dataSource.removerApoio(id);
}
```

**4. Notifier (lib/features/denuncias/presentation/notifiers/)**
```dart
// denuncias_notifier.dart
class DenunciasState {
  final List<DenunciaModel> denuncias;
  final bool isLoading;
  final String? error;
}

class DenunciasNotifier extends StateNotifier<DenunciasState> {
  final DenunciasRepository _repository;
  
  DenunciasNotifier(this._repository) : super(DenunciasState(denuncias: [], isLoading: false));
  
  Future<void> loadDenuncias({double? latitude, double? longitude, double? raio}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final denuncias = await _repository.getDenuncias(latitude: latitude, longitude: longitude, raio: raio);
      state = state.copyWith(denuncias: denuncias, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> apoiarDenuncia(int id) async {
    try {
      await _repository.apoiarDenuncia(id);
      await loadDenuncias(); // Recarrega lista
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider
final denunciasNotifierProvider = StateNotifierProvider<DenunciasNotifier, DenunciasState>((ref) {
  final repository = ref.watch(denunciasRepositoryProvider);
  return DenunciasNotifier(repository);
});
```

**5. HomeScreen (lib/features/home/presentation/views/)**
```dart
// home_screen.dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _loadDenuncias();
  }
  
  Future<void> _loadDenuncias() async {
    await ref.read(denunciasNotifierProvider.notifier).loadDenuncias();
  }
  
  @override
  Widget build(BuildContext context) {
    final denunciasState = ref.watch(denunciasNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voz do Povo'),
        actions: [
          if (authState.isGuest)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(label: Text('Visitante')),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (authState.isGuest) {
                context.push('/guest-settings');
              } else {
                context.push('/profile');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-15.7801, -47.9292), // Brasília
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          
          // Barra de pesquisa flutuante
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SearchBarWidget(
              onSearch: (query) {
                // Implementar busca
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navegação
        },
      ),
    );
  }
  
  void _buildMarkers(List<DenunciaModel> denuncias) {
    _markers.clear();
    for (var denuncia in denuncias) {
      _markers.add(
        Marker(
          markerId: MarkerId(denuncia.id.toString()),
          position: LatLng(denuncia.latitude, denuncia.longitude),
          icon: _getMarkerIcon(denuncia.status),
          onTap: () => _showDenunciaBottomSheet(denuncia),
        ),
      );
    }
  }
  
  BitmapDescriptor _getMarkerIcon(String status) {
    // Verde: resolvida, Laranja: em_analise, Vermelho: aberta
    switch (status) {
      case 'resolvida':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'em_analise':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }
  
  void _showDenunciaBottomSheet(DenunciaModel denuncia) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DenunciaBottomSheet(denuncia: denuncia),
    );
  }
}
```

**6. Widgets (lib/features/home/presentation/widgets/ ou lib/core/widgets/)**
```dart
// custom_bottom_navigation_bar.dart
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.search, 'Buscar', 1),
          SizedBox(width: 40), // Espaço para FAB
          _buildNavItem(Icons.map, 'Mapa', 3),
          _buildNavItem(Icons.person, 'Perfil', 4),
        ],
      ),
    );
  }
}

// Botão FAB central (maior)
floatingActionButton: FloatingActionButton.large(
  onPressed: () => context.push('/create-denuncia'),
  child: Icon(Icons.add),
);
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked;

// denuncia_bottom_sheet.dart
class DenunciaBottomSheet extends StatelessWidget {
  final DenunciaModel denuncia;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Thumbnail da foto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  denuncia.fotos.first.imagem,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(denuncia.titulo, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Chip(label: Text(denuncia.status)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16),
                        SizedBox(width: 4),
                        Text('${denuncia.totalApoios} Apoios'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.push('/denuncia/${denuncia.id}');
            },
            child: Text('Ver Detalhes'),
          ),
        ],
      ),
    );
  }
}

// search_bar_widget.dart
class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar por endereço...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {
              // Abrir filtros
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}
```

---

## 🎨 PADRÕES E CONVENÇÕES

### Nomenclatura
```dart
// Arquivos: snake_case
auth_notifier.dart
denuncia_model.dart

// Classes: PascalCase
class AuthNotifier {}
class DenunciaModel {}

// Variáveis/métodos: camelCase
final authState = ...
void loadDenuncias() {}

// Constantes: camelCase com const
const baseUrl = '...';

// Private: _prefixo
final _dio = Dio();
void _loadAuthState() {}
```

### Estrutura de Métodos
```dart
// 1. Construtor
MyClass(this._dependency);

// 2. Lifecycle
@override
void initState() {}

// 3. Métodos públicos
Future<void> loadData() {}

// 4. Métodos privados
void _internalMethod() {}

// 5. Build
@override
Widget build(BuildContext context) {}
```

### Tratamento de Erros
```dart
try {
  final result = await repository.method();
  // Sucesso
} on EmailNotVerifiedException catch (e) {
  // Tratamento específico
} on NetworkException catch (e) {
  // Sem conexão
} catch (e) {
  // Erro genérico
}
```

### Provider Pattern
```dart
// Provider de repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepository(dataSource);
});

// Provider de notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Usar no widget
final authState = ref.watch(authNotifierProvider);
final authNotifier = ref.read(authNotifierProvider.notifier);
```

---

## 🔧 CONFIGURAÇÕES IMPORTANTES

### Dio Client (lib/config/dio/dio_client.dart)
```dart
// Para adicionar novo endpoint público (sem token)
final publicEndpoints = [
  '/api/auth/login/',
  '/api/novo-endpoint/', // Adicionar aqui
];
```

### Router (lib/config/router/router.dart)
```dart
// Para adicionar nova rota
GoRoute(
  path: '/nova-rota',
  builder: (context, state) => NovaScreen(),
),

// Para rota protegida (apenas autenticados)
// Adicionar na lista isAuthScreen se for pública
final isAuthScreen = [
  '/', '/login', '/register', // rotas públicas
];
```

### FlutterSecureStorage
```dart
// Para adicionar nova key
await _storage.write(key: 'nova_key', value: 'valor');
final valor = await _storage.read(key: 'nova_key');
await _storage.delete(key: 'nova_key');
```

---

## 🐛 PROBLEMAS COMUNS E SOLUÇÕES

### Erro 403 em endpoint público
**Problema:** Endpoint recebendo token expirado  
**Solução:** Adicionar endpoint na whitelist do Dio Client

### Connection refused
**Problema:** Backend em localhost (127.0.0.1)  
**Solução:** Rodar backend em IP local (192.168.1.10)
```bash
python manage.py runserver 0.0.0.0:8000
```

### Token expirado
**Problema:** Access token expirou  
**Solução:** Implementar refresh token (TODO)

### Dados de visitante "perdidos"
**Problema:** Mal-entendido sobre FlutterSecureStorage  
**Solução:** Storage é PERMANENTE, persiste após fechar app

---

## 📊 PROGRESSO ATUAL

```
✅ Autenticação:          100% (10 telas, 8 endpoints, persistência)
✅ Networking:            100% (Dio configurado, interceptors)
✅ State Management:      100% (Riverpod, AuthNotifier)
✅ Navegação:             100% (GoRouter, 11 rotas, guards)
🔴 Home com Mapa:         0%   (PRÓXIMA PRIORIDADE)
🔴 Criar Denúncia:        0%
🔴 Detalhes:              0%
🔴 Comentários:           0%
🔴 Perfil:                0%

PROGRESSO TOTAL: ████░░░░░░░░░░░░░░░░ 25%
```

---

## 🎯 PRÓXIMOS PASSOS (EM ORDEM)

### 1. Home com Mapa (5-6 dias)
- Criar models de Denúncia
- Criar datasource e repository
- Criar DenunciasNotifier
- Implementar HomeScreen com Google Maps
- Criar Bottom Navigation Bar customizada
- Criar widgets (bottom sheet, search bar)

### 2. Criar Denúncia (5-6 dias)
- Formulário multi-step
- Seleção de localização (GPS/manual)
- Upload de fotos (câmera/galeria)
- Compressão de imagens
- Geocoding reverso
- Integração com autor_convidado

### 3. Detalhes e Comentários (4-5 dias)
- Tela de detalhes
- Galeria de fotos (carousel)
- Sistema de apoios
- Lista e criação de comentários

### 4. Perfil (3-4 dias)
- ProfileScreen
- MyDenunciasScreen
- Estatísticas

---

## 📚 REFERÊNCIAS DA API

### Endpoints Disponíveis

**Autenticação:**
```
POST /api/auth/login/
POST /api/auth/register/
POST /api/auth/verify-email/
POST /api/auth/resend-verification-code/
POST /api/auth/password-reset/request/
POST /api/auth/password-reset/validate-code/
POST /api/auth/password-reset/confirm/
POST /api/auth/logout/
```

**Denúncias:**
```
GET    /api/denuncias/denuncias/          # Listar
POST   /api/denuncias/denuncias/          # Criar
GET    /api/denuncias/denuncias/{id}/     # Detalhes
PUT    /api/denuncias/denuncias/{id}/     # Atualizar
DELETE /api/denuncias/denuncias/{id}/     # Deletar
POST   /api/denuncias/denuncias/{id}/apoiar/      # Apoiar
DELETE /api/denuncias/denuncias/{id}/desapoiar/   # Desapoiar
```

**Comentários:**
```
GET  /api/denuncias/denuncias/{id}/comentarios/       # Listar
POST /api/denuncias/denuncias/{id}/comentarios/       # Criar
DELETE /api/denuncias/comentarios/{id}/               # Deletar
```

**Categorias:**
```
GET /api/categorias/  # Listar todas
```

---

## 💡 DICAS PARA O COPILOT

### Ao criar models:
- Sempre adicionar `factory fromJson(Map<String, dynamic> json)`
- Sempre adicionar `Map<String, dynamic> toJson()`
- Usar `Equatable` para comparação

### Ao criar datasources:
- Usar `try-catch` com exceções customizadas
- Logar requisições e respostas
- Tratar status codes específicos (400, 401, 403, 404, etc)

### Ao criar notifiers:
- Estado inicial sempre definido
- Métodos assíncronos com loading state
- Tratamento de erros atualiza state.error
- Sempre usar `state.copyWith()` para imutabilidade

### Ao criar telas:
- ConsumerWidget ou ConsumerStatefulWidget
- ref.watch para observar estado
- ref.read para executar ações
- Loading states com CircularProgressIndicator
- Tratamento de erro com SnackBar ou Dialog

### Ao fazer upload de arquivos:
- Usar FormData do Dio
- MultipartFile.fromFile() para fotos
- Compressão de imagem antes do upload
- Progress indicator durante upload

---

**🚀 Este é o contexto completo. Use como referência para implementar novas features!**
