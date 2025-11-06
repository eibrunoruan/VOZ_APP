import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Botão de editar perfil
class EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditProfileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.primary,
        child: Text('Editar Perfil', style: AppTextStyles.button),
      ),
    );
  }
}
