import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';


class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack ?? () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: AppSizes.iconSizeButton),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: AppSizes.spacing40),

        Text(title, style: AppTextStyles.titleMedium),

        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spacing8),
          Text(subtitle!, style: AppTextStyles.subtitle),
        ],
      ],
    );
  }
}
