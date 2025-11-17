import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/exceptions/denuncia_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../../data/models/denuncia_model.dart';
import '../notifiers/denuncias_notifier.dart';

class DenunciaCard extends ConsumerWidget {
  final DenunciaModel denuncia;
  final VoidCallback onTap;

  const DenunciaCard({super.key, required this.denuncia, required this.onTap});

  Color _getStatusColor() {
    switch (denuncia.status) {
      case 'AGUARDANDO_ANALISE':
        return const Color(0xFFFDB94E); // Amarelo
      case 'EM_ANALISE':
        return const Color(0xFFA7CF35); // Verde
      case 'RESOLVIDA':
        return AppColors.grey; // Cinza
      case 'REJEITADA':
        return AppColors.error; // Vermelho
      default:
        return AppColors.grey;
    }
  }

  String _getStatusLabel() {
    switch (denuncia.status) {
      case 'AGUARDANDO_ANALISE':
        return 'Aguardando Análise';
      case 'EM_ANALISE':
        return 'Em Análise';
      case 'RESOLVIDA':
        return 'Resolvida';
      case 'REJEITADA':
        return 'Rejeitada';
      default:
        return denuncia.status;
    }
  }

  IconData _getCategoriaIcon() {
    final categoria = (denuncia.categoriaNome ?? '').toLowerCase();
    if (categoria.contains('infraestrutura') || categoria.contains('buraco')) {
      return Icons.construction_outlined;
    } else if (categoria.contains('segurança')) {
      return Icons.shield_outlined;
    } else if (categoria.contains('saúde')) {
      return Icons.local_hospital_outlined;
    } else if (categoria.contains('ambiente') || categoria.contains('lixo')) {
      return Icons.eco_outlined;
    } else if (categoria.contains('transporte')) {
      return Icons.directions_bus_outlined;
    } else if (categoria.contains('educação')) {
      return Icons.school_outlined;
    } else if (categoria.contains('iluminação')) {
      return Icons.lightbulb_outlined;
    } else {
      return Icons.report_outlined;
    }
  }

  String _extractCity() {
    if (denuncia.cidadeNome != null) {
      return denuncia.cidadeNome!;
    }
    // Fallback: extrair da string de endereço
    final endereco = denuncia.endereco ?? '';
    final parts = endereco.split(RegExp(r'[,\-]'));
    return parts.isNotEmpty ? parts.last.trim() : endereco;
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmationBottomSheet.show(
      context: context,
      title: 'Deletar Denúncia',
      message: 'Tem certeza que deseja deletar esta denúncia? Esta ação não pode ser desfeita.',
      icon: Icons.delete_forever,
      iconColor: AppColors.error,
      confirmText: 'Deletar',
      cancelText: 'Cancelar',
      isDanger: true,
    );

    if (confirm != true) return;

    try {
      final deleteResponse = await ref
          .read(denunciasNotifierProvider.notifier)
          .deleteDenuncia(denuncia.id);

      if (!context.mounted) return;

      // Exibe modal de sucesso
      String successMessage = deleteResponse.message;
      IconData feedbackIcon = Icons.check_circle_rounded;
      Color feedbackColor = Colors.green;

      // Adiciona informações extras se houver
      if (deleteResponse.hasApoiosTransferidos) {
        successMessage += '\n\n${deleteResponse.apoiosTransferidos} apoio(s) foram transferidos para uma denúncia similar.';
      }
      if (deleteResponse.hasNovaDenuncia) {
        successMessage += '\n\nO apoio mais antigo foi promovido como nova denúncia principal.';
        feedbackIcon = Icons.published_with_changes;
        feedbackColor = Colors.blue;
      }

      // Mostra modal de feedback
      await ConfirmationBottomSheet.show(
        context: context,
        title: deleteResponse.hasNovaDenuncia ? 'Apoio Promovido!' : 'Denúncia Deletada!',
        message: successMessage,
        icon: feedbackIcon,
        iconColor: feedbackColor,
        confirmText: 'OK',
        cancelText: '',
        isDanger: false,
      );
    } on DenunciaException catch (e) {
      if (!context.mounted) return;
      
      // Mostra modal de erro
      await ConfirmationBottomSheet.show(
        context: context,
        title: 'Erro ao Deletar',
        message: e.message,
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        confirmText: 'OK',
        cancelText: '',
        isDanger: true,
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Mostra modal de erro genérico
      await ConfirmationBottomSheet.show(
        context: context,
        title: 'Erro ao Deletar',
        message: 'Erro inesperado: $e',
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        confirmText: 'OK',
        cancelText: '',
        isDanger: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeFormat = DateFormat('dd/MM/yyyy \'às\' HH:mm');
    final statusColor = _getStatusColor();
    final cityName = _extractCity();

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: const Color(0xFF232229),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main row: Icon + City/Date Column + Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon in green circle (smaller)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoriaIcon(),
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Column with city name and date/time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          denuncia.endereco ?? denuncia.cidadeNome ?? 'Localização não informada',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navbarText,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateTimeFormat.format(denuncia.dataCriacao),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.navbarText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Three dots menu
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.navbarText,
                      size: 24,
                    ),
                    onPressed: () => _handleDelete(context, ref),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing12),

              // Title
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

              const SizedBox(height: AppSizes.spacing12),

              // Status chip
              Builder(builder: (context) {
                final bg = statusColor;
                final textColor = bg.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusLarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: textColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Apoios counter (se houver)
              if (denuncia.totalApoios > 0) ...[
                const SizedBox(height: AppSizes.spacing8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${denuncia.totalApoios} ${denuncia.totalApoios == 1 ? 'apoio' : 'apoios'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
