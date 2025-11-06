import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Campo de senha com toggle de visibilidade
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final void Function(String)? onFieldSubmitted;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.label),
          const SizedBox(height: AppSizes.spacing8),
        ],
        TextFormField(
          controller: widget.controller,
          decoration: AppInputDecoration.standard(
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ],
    );
  }
}
