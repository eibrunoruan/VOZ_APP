import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Widget que exibe o cabeçalho do perfil com foto, nome e username
class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String username;
  final bool isGuest;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.username,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Foto de perfil
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withOpacity(0.1),
            border: Border.all(color: AppColors.primaryRed, width: 3),
          ),
          child: Icon(
            isGuest ? Icons.person_outline : Icons.person,
            size: 50,
            color: AppColors.primaryRed,
          ),
        ),

        const SizedBox(height: AppSizes.spacing16),

        // Nome do usuário
        Text(
          displayName,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 24,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.spacing8),

        // Username
        Text(
          '@$username',
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 16,
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
