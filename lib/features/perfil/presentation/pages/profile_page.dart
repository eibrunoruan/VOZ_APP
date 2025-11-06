import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';

/// Página de perfil do usuário
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
      // Desloga o visitante
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        // Vai para a tela de registro
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            children: [
              // Header com botão voltar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
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

              // Foto de perfil
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryRed, width: 3),
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.grey,
                ),
              ),

              const SizedBox(height: AppSizes.spacing24),

              // Nome do usuário
              Text(
                displayName,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 28,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: AppSizes.spacing8),

              // Username
              Text(
                isGuest
                    ? '@visitante'
                    : '@${displayName.toLowerCase().replaceAll(' ', '_')}',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.grey),
              ),

              const Spacer(),

              // Botões de ação
              Column(
                children: [
                  // Botão Editar Perfil
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isGuest) {
                          context.push('/guest-settings');
                        } else {
                          // TODO: Implementar edição de perfil para usuário logado
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

                  // Botão Configurações (apenas para usuários logados)
                  if (!isGuest)
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implementar configurações
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

                  // Botão Sair
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutModal(context, ref),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Sair da Conta',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing32),

                  // Informação adicional
                  if (isGuest)
                    InkWell(
                      onTap: () => _showCreateAccountModal(context, ref),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.spacing16),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
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
