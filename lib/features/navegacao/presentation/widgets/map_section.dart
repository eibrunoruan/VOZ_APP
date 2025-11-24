import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/data/models/denuncia_model.dart';

class MapSection extends ConsumerStatefulWidget {
  final List<DenunciaModel> denuncias;
  final double? initialLat;
  final double? initialLng;
  final Function(DenunciaModel) onMarkerTap;

  const MapSection({
    super.key,
    required this.denuncias,
    this.initialLat,
    this.initialLng,
    required this.onMarkerTap,
  });

  @override
  ConsumerState<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<MapSection> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkers();
    });
  }

  @override
  void didUpdateWidget(MapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.denuncias != widget.denuncias) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    for (final denuncia in widget.denuncias) {
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
            onTap: () => widget.onMarkerTap(denuncia),
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

  LatLng _getCenterPosition() {
    if (widget.initialLat != null && widget.initialLng != null) {
      return LatLng(widget.initialLat!, widget.initialLng!);
    }

    if (widget.denuncias.isEmpty) {
      return const LatLng(-23.550520, -46.633308); // São Paulo padrão
    }

    double sumLat = 0;
    double sumLng = 0;
    for (final denuncia in widget.denuncias) {
      sumLat += denuncia.latitude;
      sumLng += denuncia.longitude;
    }
    return LatLng(
      sumLat / widget.denuncias.length,
      sumLng / widget.denuncias.length,
    );
  }

  void _centerMap() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_getCenterPosition(), 12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerPosition = _getCenterPosition();

    return Stack(
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

        // Counter - moved to top left
        Positioned(
          top: 16,
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
                  '${widget.denuncias.length} denúncias',
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

        // Center button - moved to top right
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.background,
            onPressed: _centerMap,
            child: const Icon(
              Icons.my_location,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
