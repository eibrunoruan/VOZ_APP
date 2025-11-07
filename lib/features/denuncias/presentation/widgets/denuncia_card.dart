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
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: const Color(0xFF232229),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.primaryRed, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getCategoriaIcon(),
                          size: 20,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            denuncia.categoria,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.navbarText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(denuncia.dataCriacao),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navbarText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing12),

              Text(
                denuncia.titulo,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppColors.navbarText,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacing8),

              Text(
                denuncia.descricao,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.navbarText,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacing12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Text(
                  denuncia.status,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spacing12),

              Row(
                children: [

                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            denuncia.endereco,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.navbarText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (denuncia.fotos.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          size: 18,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${denuncia.fotos.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navbarText,
                          ),
                        ),
                      ],
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
