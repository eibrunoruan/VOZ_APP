import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;

  const AuthFormField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: AppSizes.spacing8),
        ],
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16, color: AppColors.white),
          decoration: AppInputDecoration.standard(
            hintText: hintText,
          ).copyWith(suffixIcon: suffixIcon),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          validator: validator,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
