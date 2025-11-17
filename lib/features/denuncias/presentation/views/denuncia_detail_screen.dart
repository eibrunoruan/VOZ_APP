import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/exceptions/denuncia_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../notifiers/denuncias_notifier.dart';

class DenunciaDetailScreen extends ConsumerStatefulWidget {
  final int denunciaId;

  const DenunciaDetailScreen({super.key, required this.denunciaId});

  @override
  ConsumerState<DenunciaDetailScreen> createState() =>
      _DenunciaDetailScreenState();
}

class _DenunciaDetailScreenState extends ConsumerState<DenunciaDetailScreen> {
  bool _isProcessing = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AGUARDANDO_ANALISE':
        return const Color(0xFFFF9800);
      case 'EM_ANALISE':
        return const Color(0xFF2196F3);
      case 'RESOLVIDA':
        return const Color(0xFF4CAF50);
      case 'REJEITADA':
        return AppColors.primaryRed;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'AGUARDANDO_ANALISE':
        return 'Aguardando Análise';
      case 'EM_ANALISE':
        return 'Em Análise';
      case 'RESOLVIDA':
        return 'Resolvida';
      case 'REJEITADA':
        return 'Rejeitada';
      default:
        return status;
    }
  }

  IconData _getCategoriaIcon(String? categoria) {
    final cat = (categoria ?? '').toLowerCase();
    if (cat.contains('infraestrutura') || cat.contains('buraco')) {
      return Icons.construction_outlined;
    } else if (cat.contains('segurança')) {
      return Icons.shield_outlined;
    } else if (cat.contains('saúde')) {
      return Icons.local_hospital_outlined;
    } else if (cat.contains('ambiente') || cat.contains('lixo')) {
      return Icons.eco_outlined;
    } else if (cat.contains('transporte')) {
      return Icons.directions_bus_outlined;
    } else if (cat.contains('educação')) {
      return Icons.school_outlined;
    } else if (cat.contains('iluminação')) {
      return Icons.lightbulb_outlined;
    } else {
      return Icons.report_outlined;
    }
  }

  Future<void> _handleApoiar() async {
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(denunciasNotifierProvider.notifier)
          .apoiarDenuncia(widget.denunciaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apoio registrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DenunciaException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleResolver() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Marcar como Resolvida',
          style: TextStyle(color: AppColors.navbarText),
        ),
        content: const Text(
          'Deseja marcar esta denúncia como resolvida?',
          style: TextStyle(color: AppColors.navbarText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      await ref
          .read(denunciasNotifierProvider.notifier)
          .resolverDenuncia(widget.denunciaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia marcada como resolvida!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DenunciaException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDeletar() async {
    print('🗑️ _handleDeletar chamado');
    
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

    print('✅ Modal fechado. Confirmação: $confirm');

    if (confirm != true) {
      print('❌ Usuário cancelou ou fechou modal');
      return;
    }

    print('🚀 Iniciando exclusão da denúncia ${widget.denunciaId}');
    setState(() => _isProcessing = true);

    try {
      final deleteResponse = await ref
          .read(denunciasNotifierProvider.notifier)
          .deleteDenuncia(widget.denunciaId);

      print('✅ Denúncia deletada. Resposta: ${deleteResponse.message}');

      if (!mounted) return;

      setState(() => _isProcessing = false);

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

      if (mounted) {
        // Volta para a lista
        context.pop();
      }
    } on DenunciaException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      
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
      if (!mounted) return;
      setState(() => _isProcessing = false);
      
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
  Widget build(BuildContext context) {
    final denunciaAsync = ref.watch(denunciaByIdProvider(widget.denunciaId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navbarText),
          onPressed: () => context.pop(),
        ),
        title: denunciaAsync.when(
          data: (denuncia) => Text(
            denuncia.titulo,
            style: const TextStyle(
              color: AppColors.navbarText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          loading: () => const Text('Carregando...'),
          error: (_, __) => const Text('Erro'),
        ),
        actions: [
          if (denunciaAsync.hasValue && !_isProcessing)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.navbarText),
              color: AppColors.background,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'resolver',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Marcar como resolvida', style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deletar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Deletar', style: TextStyle(color: AppColors.white)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                print('🔘 Menu selecionado: $value');
                if (value == 'resolver') {
                  _handleResolver();
                } else if (value == 'deletar') {
                  _handleDeletar();
                }
              },
            ),
        ],
      ),
      body: denunciaAsync.when(
        data: (denuncia) => _buildContent(denuncia),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar denúncia',
                style: TextStyle(fontSize: 16, color: AppColors.navbarText),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(denunciaByIdProvider(widget.denunciaId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: denunciaAsync.when(
        data: (denuncia) => _buildBottomBar(denuncia),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(denuncia) {
    final dateFormat = DateFormat('dd/MM/yyyy \'às\' HH:mm');
    final statusColor = _getStatusColor(denuncia.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto (se houver)
          if (denuncia.foto != null)
            Container(
              height: 300,
              color: AppColors.black,
              child: Image.network(
                denuncia.foto!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF232229),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: AppColors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoria e Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoriaIcon(denuncia.categoriaNome),
                            size: 18,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            denuncia.categoriaNome ?? 'Sem categoria',
                            style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(denuncia.status),
                        style: TextStyle(
                          color: statusColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Título
                Text(
                  denuncia.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navbarText,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing16),

                // Informações
                _buildInfoRow(
                  Icons.person_outline,
                  'Autor',
                  denuncia.autorUsername ?? 'Anônimo',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Data',
                  dateFormat.format(denuncia.dataCriacao),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Localização',
                  denuncia.endereco ?? '${denuncia.cidadeNome}, ${denuncia.estadoNome}',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.people_outline,
                  'Apoios',
                  '${denuncia.totalApoios} ${denuncia.totalApoios == 1 ? 'pessoa' : 'pessoas'}',
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Descrição
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navbarText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  denuncia.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),

                // Mapa
                const Text(
                  'Localização no Mapa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navbarText,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  child: SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(denuncia.latitude, denuncia.longitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('denuncia'),
                          position: LatLng(denuncia.latitude, denuncia.longitude),
                        ),
                      },
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.navbarText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(denuncia) {
    final jaApoiou = denuncia.usuarioApoiou;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing || jaApoiou ? null : _handleApoiar,
            style: ElevatedButton.styleFrom(
              backgroundColor: jaApoiou ? AppColors.grey : AppColors.primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(jaApoiou ? Icons.check_circle : Icons.people),
            label: Text(
              jaApoiou ? 'Você já apoiou' : 'Apoiar Denúncia',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
