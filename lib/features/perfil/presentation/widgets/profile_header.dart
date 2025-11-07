import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

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

        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: AppColors.primaryRed, width: 3),
          ),
          child: Icon(
            isGuest ? Icons.person_outline : Icons.person,
            size: 50,
            color: AppColors.primaryRed,
          ),
        ),

        const SizedBox(height: AppSizes.spacing16),

        Text(
          displayName,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.spacing8),

        Text(
          '@$username',
          style: AppTextStyles.subtitle.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
