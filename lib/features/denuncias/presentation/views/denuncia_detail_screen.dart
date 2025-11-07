import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/denuncias_provider.dart';

class DenunciaDetailScreen extends StatefulWidget {
  final DenunciaModel denuncia;

  const DenunciaDetailScreen({super.key, required this.denuncia});

  @override
  State<DenunciaDetailScreen> createState() => _DenunciaDetailScreenState();
}

class _DenunciaDetailScreenState extends State<DenunciaDetailScreen> {
  Color _getStatusColor() {
    switch (widget.denuncia.status) {
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
    switch (widget.denuncia.categoria.toLowerCase()) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navbarText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.denuncia.titulo,
          style: const TextStyle(
            color: AppColors.navbarText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.navbarText),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.denuncia.fotos.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.denuncia.fotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: AppColors.black,
                      child: Image.network(
                        widget.denuncia.fotos[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF232229),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: AppColors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 300,
                color: const Color(0xFF232229),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: AppColors.grey,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.denuncia.status,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        dateFormat.format(widget.denuncia.dataCriacao),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.navbarText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spacing16),

                  Row(
                    children: [
                      Icon(
                        _getCategoriaIcon(),
                        size: 20,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.denuncia.categoria,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spacing16),

                  Text(
                    widget.denuncia.descricao,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.navbarText,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing20),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.denuncia.endereco,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.navbarText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spacing12),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    child: SizedBox(
                      height: 250,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.denuncia.latitude,
                            widget.denuncia.longitude,
                          ),
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('denuncia_location'),
                            position: LatLng(
                              widget.denuncia.latitude,
                              widget.denuncia.longitude,
                            ),
                            infoWindow: InfoWindow(
                              title: widget.denuncia.titulo,
                            ),
                          ),
                        },
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
