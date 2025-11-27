import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    // Carrega TODAS as denúncias ao abrir o mapa (não só do usuário)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(denunciasNotifierProvider.notifier).loadAllDenuncias();
    });
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });

        // Centraliza o mapa na localização do usuário
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_userLocation!, 14),
        );
      }
    } catch (e) {
      // Ignora erros de localização
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza marcadores quando as dependências mudarem
    _updateMarkers();
  }

  void _updateMarkers() {
    final denunciasState = ref.read(denunciasNotifierProvider);

    // Debug: verifica se as denúncias foram carregadas
    print(
      '🗺️ Atualizando marcadores: ${denunciasState.denuncias.length} denúncias',
    );

    if (denunciasState.denuncias.isEmpty) return;

    final newMarkers = <Marker>{};

    for (final denuncia in denunciasState.denuncias) {
      newMarkers.add(
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

    print('🗺️ Marcadores criados: ${newMarkers.length}');

    if (mounted && newMarkers.isNotEmpty) {
      setState(() {
        _markers = newMarkers;
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

    // Atualiza marcadores somente quando as denúncias mudarem
    ref.listen<DenunciasState>(denunciasNotifierProvider, (previous, next) {
      if (previous?.denuncias != next.denuncias) {
        _updateMarkers();
      }
    });

    final denuncias = denunciasState.denuncias;

    // Usa localização do usuário se disponível, senão usa São Paulo
    LatLng centerPosition =
        _userLocation ?? const LatLng(-23.550520, -46.633308);

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
            onPressed: () async {
              if (_userLocation != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_userLocation!, 14),
                );
              } else {
                // Tenta obter localização novamente
                await _getUserLocation();
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
            // Otimizações de performance
            buildingsEnabled: false,
            trafficEnabled: false,
            indoorViewEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
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
