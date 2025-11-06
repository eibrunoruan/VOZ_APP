import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/denuncias_provider.dart';

class DenunciaCard extends StatelessWidget {
  final DenunciaModel denuncia;
  final VoidCallback onTap;

  const DenunciaCard({super.key, required this.denuncia, required this.onTap});

  Color _getStatusColor() {
    switch (denuncia.status) {
      case 'Aguardando Análise':
        return const Color(0xFFFF9800);
      case 'Em Análise':
        return const Color(0xFF2196F3);
      case 'Resolvida':
        return const Color(0xFF4CAF50);
      case 'Rejeitada':
        return AppColors.primaryRed;
      default:
        return AppColors.grey;
    }
  }

  IconData _getCategoriaIcon() {
    switch (denuncia.categoria.toLowerCase()) {
      case 'infraestrutura':
        return Icons.construction_outlined;
      case 'segurança':
        return Icons.shield_outlined;
      case 'saúde':
        return Icons.local_hospital_outlined;
      case 'meio ambiente':
        return Icons.eco_outlined;
      case 'transporte':
        return Icons.directions_bus_outlined;
      case 'educação':
        return Icons.school_outlined;
      default:
        return Icons.report_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status + Data
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      denuncia.status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Data
                  Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(denuncia.dataCriacao),
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing12),

              // Título
              Text(
                denuncia.titulo,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacing8),

              // Categoria com ícone
              Row(
                children: [
                  Icon(
                    _getCategoriaIcon(),
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    denuncia.categoria,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing12),

              // Descrição
              Text(
                denuncia.descricao,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.grey,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacing12),

              // Divider
              Container(height: 1, color: AppColors.greyLight),

              const SizedBox(height: AppSizes.spacing12),

              // Footer: Localização + Fotos
              Row(
                children: [
                  // Localização
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            denuncia.endereco,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fotos (se houver)
                  if (denuncia.fotos.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 14,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${denuncia.fotos.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
