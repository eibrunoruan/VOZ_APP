import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Column(
                children: [

                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      size: 64,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing32),

                  Text(
                    'Voz do Povo',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 32,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing12),

                  Text(
                    'Sua voz faz a diferença',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(flex: 3),

              Column(
                children: [

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: AppButtonStyles.primary,
                      child: Text('Entrar', style: AppTextStyles.button),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing16),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: AppButtonStyles.secondary,
                      child: Text(
                        'Cadastrar',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing32),

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: AppColors.greyLight,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing16,
                        ),
                        child: Text(
                          'ou',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: AppColors.greyLight,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  TextButton.icon(
                    onPressed: () => context.push('/guest-profile'),
                    style: AppButtonStyles.text,
                    icon: const Icon(Icons.person_outline, size: 20),
                    label: Text(
                      'Continuar como visitante',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
