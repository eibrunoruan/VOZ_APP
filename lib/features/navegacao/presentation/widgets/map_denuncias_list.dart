import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/data/models/denuncia_model.dart';
import '../../../denuncias/presentation/widgets/denuncia_card.dart';

class MapDenunciasList extends ConsumerStatefulWidget {
  final List<DenunciaModel> denuncias;
  final bool isLoading;
  final VoidCallback onRefresh;

  const MapDenunciasList({
    super.key,
    required this.denuncias,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  ConsumerState<MapDenunciasList> createState() => _MapDenunciasListState();
}

class _MapDenunciasListState extends ConsumerState<MapDenunciasList> {
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      );
    }

    if (widget.denuncias.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 64,
                color: AppColors.grey,
              ),
              const SizedBox(height: AppSizes.spacing16),
              Text(
                'Nenhuma denúncia disponível',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacing16,
          0,
          AppSizes.spacing16,
          AppSizes.spacing16,
        ),
        itemCount: widget.denuncias.length,
        separatorBuilder: (_, __) => const SizedBox(
          height: AppSizes.spacing16,
        ),
        itemBuilder: (context, index) {
          final denuncia = widget.denuncias[index];
          return DenunciaCard(
            denuncia: denuncia,
            onTap: () {
              context.push('/denuncia/${denuncia.id}');
            },
          );
        },
      ),
    );
  }
}
