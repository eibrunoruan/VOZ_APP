import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _showLogoutModal(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmationBottomSheet.show(
      context: context,
      title: 'Sair da Conta',
      message:
          'Tem certeza que deseja sair da sua conta? Você precisará fazer login novamente.',
      icon: Icons.logout,
      iconColor: AppColors.error,
      confirmText: 'Sair',
      cancelText: 'Cancelar',
      isDanger: true,
    );

    if (confirm == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go('/');
      }
    }
  }

  Future<void> _showCreateAccountModal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await ConfirmationBottomSheet.show(
      context: context,
      title: 'Criar Conta Completa',
      message:
          'Tenha acesso a recursos exclusivos como editar denúncias, '
          'acompanhar status, receber notificações e perfil personalizado.',
      icon: Icons.person_add,
      iconColor: AppColors.primaryRed,
      confirmText: 'Criar Conta',
      cancelText: 'Agora Não',
      isDanger: false,
    );

    if (confirm == true && context.mounted) {

      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {

        context.go('/register');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isGuest = authState.isGuest;
    final displayName = authState.guestNickname ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            children: [

              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.navbarText,
                    ),
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: AppSizes.spacing24),

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryRed, width: 3),
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.primaryRed,
                ),
              ),

              const SizedBox(height: AppSizes.spacing24),

              Text(
                displayName,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 28),
              ),

              const SizedBox(height: AppSizes.spacing8),

              Text(
                isGuest
                    ? '@visitante'
                    : '@${displayName.toLowerCase().replaceAll(' ', '_')}',
                style: AppTextStyles.subtitle,
              ),

              const Spacer(),

              Column(
                children: [

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isGuest) {
                          context.push('/guest-settings');
                        } else {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edição de perfil em breve!'),
                            ),
                          );
                        }
                      },
                      style: AppButtonStyles.primary,
                      child: Text(
                        isGuest ? 'Editar Apelido' : 'Editar Perfil',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing16),

                  if (!isGuest)
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Configurações em breve!'),
                            ),
                          );
                        },
                        style: AppButtonStyles.secondary,
                        child: Text(
                          'Configurações',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ),

                  if (!isGuest) const SizedBox(height: AppSizes.spacing16),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutModal(context, ref),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: AppColors.primaryRed,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Sair da Conta',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing32),

                  if (isGuest)
                    InkWell(
                      onTap: () => _showCreateAccountModal(context, ref),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.spacing16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          border: Border.all(
                            color: AppColors.primaryRed,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_add_outlined,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            Expanded(
                              child: Text(
                                'Clique aqui para se cadastrar',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryRed,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
