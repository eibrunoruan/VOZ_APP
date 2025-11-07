import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [

          _buildSectionHeader('Conta'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            onTap: () => context.push('/perfil'),
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          const Divider(height: 32),

          _buildSectionHeader('Notificações'),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Notificações Push',
            trailing: Switch(
              value: true,
              onChanged: (value) {

              },
              activeColor: AppColors.primaryRed,
            ),
            onTap: null,
          ),
          const Divider(height: 32),

          _buildSectionHeader('Sobre'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voz do Povo v1.0.0')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Política de Privacidade',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'Termos de Uso',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento')),
              );
            },
          ),
          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: SizedBox(
              height: AppSizes.buttonHeight,
              child: OutlinedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                      title: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navbarText,
                        ),
                      ),
                      content: const Text(
                        'Deseja realmente sair da sua conta?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.navbarText,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryRed,
                          ),
                          child: const Text('Sair'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    await authNotifier.logout();
                    if (context.mounted) {
                      context.go('/');
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 1.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                ),
                child: const Text(
                  'Sair da Conta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing16,
        AppSizes.spacing24,
        AppSizes.spacing16,
        AppSizes.spacing8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.grey)
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
    );
  }
}
