import 'package:flutter/material.dart';

// Cores
class AppColors {
  static const Color primaryRed = Color(0xFFEE151F);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFEF5350);
}

// Tamanhos
class AppSizes {
  // Border Radius
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 40.0;

  // Spacing
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

  // Button Height
  static const double buttonHeight = 56.0;

  // Input Height (controlled by padding)
  static const double inputPaddingVertical = 16.0;
  static const double inputPaddingHorizontal = 16.0;

  // Icon Size
  static const double iconSize = 20.0;
  static const double iconSizeButton = 28.0;
}

// Text Styles
class AppTextStyles {
  // Títulos
  static const TextStyle titleLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Botões
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Links
  static const TextStyle link = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  // Body
  static const TextStyle body = TextStyle(fontSize: 16, color: AppColors.black);
}

// Input Decoration
class AppInputDecoration {
  static InputDecoration standard({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.inputPaddingHorizontal,
        vertical: AppSizes.inputPaddingVertical,
      ),
      suffixIcon: suffixIcon,
    );
  }
}

// Button Styles
class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryRed,
    foregroundColor: AppColors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryRed,
    side: const BorderSide(color: AppColors.primaryRed, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    ),
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.primaryRed,
    textStyle: AppTextStyles.link,
  );
}
