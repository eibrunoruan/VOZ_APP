import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/create_denuncia_controller.dart';

/// Serviço para gerenciar interações com o mapa
class MapInteractionService {
  final CreateDenunciaController controller;
  final BuildContext context;

  MapInteractionService({
    required this.controller,
    required this.context,
  });

  /// Obtém localização atual do usuário
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await controller.getCurrentLocation();
      if (position == null) return null;

      // Atualiza coordenadas no controller
      controller.selectedLat = position.latitude;
      controller.selectedLng = position.longitude;

      // Anima câmera do mapa
      if (controller.mapController != null && !controller.mapError) {
        controller.mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }

      // Adiciona marcador
      controller.addMarker(LatLng(position.latitude, position.longitude));

      // Busca endereço
      final address = await controller.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      controller.localizacaoController.text = address;

      return position;
    } catch (e) {
      rethrow;
    }
  }

  /// Processa tap no mapa
  Future<void> handleMapTap(LatLng position) async {
    controller.selectedLat = position.latitude;
    controller.selectedLng = position.longitude;

    controller.addMarker(position);

    final address = await controller.getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );

    controller.localizacaoController.text = address;
  }

  /// Cria o mapa
  void handleMapCreated(GoogleMapController mapController) {
    try {
      controller.mapController = mapController;
      controller.mapError = false;
    } catch (e) {
      controller.mapError = true;
    }
  }
}
