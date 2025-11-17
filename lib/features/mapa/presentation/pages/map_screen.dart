import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/presentation/notifiers/denuncias_notifier.dart';
import '../../../denuncias/presentation/views/denuncia_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Carrega denúncias ao abrir o mapa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(denunciasNotifierProvider.notifier).loadDenuncias();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createMarkers();
  }

  void _createMarkers() {
    final denunciasState = ref.read(denunciasNotifierProvider);
    final markers = <Marker>{};

    for (final denuncia in denunciasState.denuncias) {
      markers.add(
        Marker(
          markerId: MarkerId(denuncia.id.toString()),
          position: LatLng(denuncia.latitude, denuncia.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(denuncia.status),
          ),
          infoWindow: InfoWindow(
            title: denuncia.titulo,
            snippet: denuncia.categoriaNome ?? 'Denúncia',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DenunciaDetailScreen(denunciaId: denuncia.id),
                ),
              );
            },
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  double _getMarkerColor(String status) {
    switch (status) {
      case 'AGUARDANDO_ANALISE':
        return BitmapDescriptor.hueOrange;
      case 'EM_ANALISE':
        return BitmapDescriptor.hueBlue;
      case 'RESOLVIDA':
        return BitmapDescriptor.hueGreen;
      case 'REJEITADA':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final denunciasState = ref.watch(denunciasNotifierProvider);
    
    // Atualiza marcadores quando denúncias mudarem
    if (denunciasState.denuncias.isNotEmpty) {
      _createMarkers();
    }

    final denuncias = denunciasState.denuncias;

    LatLng centerPosition = const LatLng(
      -23.550520,
      -46.633308,
    ); // São Paulo padrão

    if (denuncias.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (final denuncia in denuncias) {
        sumLat += denuncia.latitude;
        sumLng += denuncia.longitude;
      }
      centerPosition = LatLng(
        sumLat / denuncias.length,
        sumLng / denuncias.length,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mapa de Denúncias',
          style: TextStyle(
            color: AppColors.navbarText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.navbarText),
            onPressed: () {

              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(centerPosition, 12),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: centerPosition,
              zoom: 12,
            ),
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.primaryRed, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navbarText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem('Aguardando', Colors.orange),
                  _buildLegendItem('Em Análise', Colors.blue),
                  _buildLegendItem('Resolvida', Colors.green),
                  _buildLegendItem('Rejeitada', Colors.red),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryRed, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${denuncias.length} denúncias',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navbarText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.navbarText),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
