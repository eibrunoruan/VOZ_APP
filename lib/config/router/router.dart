import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/autenticacao/presentation/notifiers/auth_notifier.dart';
import '../../features/autenticacao/presentation/views/welcome_screen.dart';
import '../../features/autenticacao/presentation/views/login_screen.dart';
import '../../features/autenticacao/presentation/views/register_screen.dart';
import '../../features/autenticacao/presentation/views/verify_email_screen.dart';
import '../../features/autenticacao/presentation/views/forgot_password_screen.dart';
import '../../features/autenticacao/presentation/views/validate_reset_code_screen.dart';
import '../../features/autenticacao/presentation/views/set_new_password_screen.dart';
import '../../features/autenticacao/presentation/views/reset_password_screen.dart';
import '../../features/autenticacao/presentation/views/guest_profile_screen.dart';
import '../../features/autenticacao/presentation/views/guest_settings_screen.dart';
import '../../features/denuncias/presentation/views/create_denuncia_screen.dart';
import '../../features/denuncias/presentation/views/denuncias_list_screen.dart';
import '../../features/navegacao/presentation/pages/home_page_new.dart';
import '../../features/navegacao/presentation/pages/map_page.dart';
import '../../features/navegacao/presentation/pages/settings_page.dart';
import '../../features/navegacao/presentation/widgets/main_scaffold.dart';
import '../../features/perfil/presentation/pages/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/', // Rota inicial
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/guest-profile',
        builder: (context, state) => const GuestProfileScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        redirect: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String?;

          // Redirect to home if no email provided
          if (email == null || email.isEmpty) {
            return '/';
          }
          return null;
        },
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String? ?? '';
          final name = args?['name'] as String?;

          return VerifyEmailScreen(email: email, name: name);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/validate-reset-code',
        redirect: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String?;

          // Redirect to forgot-password if no email provided
          if (email == null || email.isEmpty) {
            return '/forgot-password';
          }
          return null;
        },
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String? ?? '';

          return ValidateResetCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/set-new-password',
        redirect: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String?;
          final code = args?['code'] as String?;

          // Redirect to forgot-password if no email or code provided
          if (email == null || email.isEmpty || code == null || code.isEmpty) {
            return '/forgot-password';
          }
          return null;
        },
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String? ?? '';
          final code = args?['code'] as String? ?? '';

          return SetNewPasswordScreen(email: email, code: code);
        },
      ),
      GoRoute(
        path: '/reset-password',
        redirect: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String?;

          // Redirect to forgot-password if no email provided
          if (email == null || email.isEmpty) {
            return '/forgot-password';
          }
          return null;
        },
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final email = args?['email'] as String? ?? '';

          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/guest-settings',
        builder: (context, state) => const GuestSettingsScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/map', child: MapPage()),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/home', child: HomePageNew()),
      ),
      GoRoute(
        path: '/denuncias',
        builder: (context, state) => const MainScaffold(
          currentPath: '/denuncias',
          child: DenunciasListScreen(),
        ),
      ),
      GoRoute(
        path: '/create-denuncia',
        builder: (context, state) => const CreateDenunciaScreen(),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/perfil', child: ProfilePage()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const MainScaffold(currentPath: '/settings', child: SettingsPage()),
      ),
      // TODO: Adicionar rota para /mapa quando implementada
      // Adicione outras rotas aqui
    ],
    redirect: (context, state) {
      final hasAccess = authState.hasAccess; // Logado OU visitante
      final isAuthScreen =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/validate-reset-code' ||
          state.matchedLocation == '/set-new-password' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/guest-profile';

      // Se não tem acesso (nem logado, nem visitante) e não está em tela de auth
      // Redireciona para WelcomeScreen
      if (!hasAccess && !isAuthScreen) {
        return '/';
      }

      // Se tem acesso (logado ou visitante) e está tentando acessar tela de auth
      // Redireciona para mapa
      if (hasAccess &&
          (state.matchedLocation == '/' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/register')) {
        return '/map';
      }

      return null; // Não redireciona
    },
  );
});
