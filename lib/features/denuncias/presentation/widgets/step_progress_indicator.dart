import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que exibe o indicador de progresso dos steps
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? AppSizes.spacing8 : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryRed : AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
