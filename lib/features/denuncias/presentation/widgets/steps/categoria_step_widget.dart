import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/categoria_model.dart';
import '../../notifiers/categorias_notifier.dart';

/// Widget for step 2: Category selection
class CategoriaStepWidget extends ConsumerWidget {
  final int? selectedCategoriaId;
  final bool hasError;
  final String? errorMessage;
  final Function(int?) onChanged;

  const CategoriaStepWidget({
    super.key,
    required this.selectedCategoriaId,
    required this.hasError,
    this.errorMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasState = ref.watch(categoriasNotifierProvider);

    if (categoriasState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoriasState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar categorias',
              style: TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(categoriasNotifierProvider.notifier).refresh(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual a categoria?',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Selecione a categoria que melhor descreve sua denúncia',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.primaryRed,
              width: hasError ? 2 : 1.5,
            ),
          ),
          child: DropdownButtonFormField<int>(
            value: selectedCategoriaId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing12,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
            dropdownColor: AppColors.background,
            hint: Text(
              'Selecione uma categoria',
              style: TextStyle(color: AppColors.grey.withOpacity(0.5)),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryRed),
            style: const TextStyle(color: AppColors.white, fontSize: 16),
            items: categoriasState.categorias.map((categoria) {
              return DropdownMenuItem<int>(
                value: categoria.id,
                child: Row(
                  children: [
                    const Icon(
                      Icons.label_outline,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(categoria.nome),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        if (hasError && errorMessage != null) ...
        [
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
