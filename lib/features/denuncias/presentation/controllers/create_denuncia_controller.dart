import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Controller para gerenciar a lógica da tela de criação de denúncia
class CreateDenunciaController {
  // Controllers de texto
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final localizacaoController = TextEditingController();

  // Estado
  int currentStep = 0;
  final int totalSteps = 5;
  int? categoriaSelecionada;
  int? estadoSelecionado;
  int? cidadeSelecionada;
  double? selectedLat;
  double? selectedLng;
  File? selectedFoto;

  // Mapa
  GoogleMapController? mapController;
  final markers = <Marker>{};
  bool mapError = false;
  bool loadingLocation = false;

  static const LatLng initialPosition = LatLng(-23.5505, -46.6333);

  /// Limpa os recursos
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    localizacaoController.dispose();
    mapController?.dispose();
  }

  /// Valida se pode avançar para o próximo step
  String? validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (tituloController.text.trim().isEmpty) {
          return 'Digite um título para a denúncia';
        }
        break;
      case 1:
        if (categoriaSelecionada == null) {
          return 'Selecione uma categoria';
        }
        break;
      case 2:
        if (descricaoController.text.trim().isEmpty) {
          return 'Digite uma descrição para a denúncia';
        }
        break;
      case 3:
        if (selectedLat == null || selectedLng == null) {
          return 'Selecione a localização no mapa';
        }
        break;
    }
    return null;
  }

  /// Obtém a localização atual do dispositivo
  Future<Position?> getCurrentLocation() async {
    // Verifica se o serviço de localização está ativado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Serviço de localização desabilitado.\n\nAtive o GPS nas configurações do dispositivo.',
      );
    }

    // Verifica permissões
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente.\n\nAtive nas configurações do app.',
      );
    }

    // Obtém a posição
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      throw Exception(
        'Tempo esgotado ao obter localização.\n\nVerifique se o GPS está ativado.',
      );
    }
  }

  /// Converte coordenadas em endereço
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String endereco = '';

        if (place.street != null && place.street!.isNotEmpty) {
          endereco += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          endereco += endereco.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality!}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          endereco += endereco.isEmpty ? place.locality! : ', ${place.locality!}';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          endereco += ' - ${place.administrativeArea!}';
        }

        return endereco.isNotEmpty
            ? endereco
            : 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
      }
    } catch (e) {
      debugPrint('Erro no geocoding: $e');
    }

    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }

  /// Adiciona um marcador no mapa
  void addMarker(LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  /// Valida se todos os dados estão preenchidos
  bool isValid() {
    return tituloController.text.trim().isNotEmpty &&
        categoriaSelecionada != null &&
        descricaoController.text.trim().isNotEmpty &&
        selectedLat != null &&
        selectedLng != null;
  }
}
