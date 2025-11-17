import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/create_denuncia_request.dart';
import '../controllers/create_denuncia_controller.dart';
import '../notifiers/denuncias_notifier.dart';
import 'location_service.dart';

/// Resultado do submit da denúncia
class SubmitResult {
  final bool success;
  final bool isApoio;
  final String? message;
  final String? error;

  const SubmitResult({
    required this.success,
    this.isApoio = false,
    this.message,
    this.error,
  });

  factory SubmitResult.success({bool isApoio = false, String? message}) {
    return SubmitResult(
      success: true,
      isApoio: isApoio,
      message: message,
    );
  }

  factory SubmitResult.error(String error) {
    return SubmitResult(
      success: false,
      error: error,
    );
  }
}

/// Serviço para processar o submit da denúncia
class SubmitDenunciaService {
  final WidgetRef ref;
  final CreateDenunciaController controller;

  SubmitDenunciaService({
    required this.ref,
    required this.controller,
  });

  /// Processa o submit da denúncia
  Future<SubmitResult> submit() async {
    try {
      // Analisa localização
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.analyzeLocation(
        latitude: controller.selectedLat!,
        longitude: controller.selectedLng!,
      );

      // Arredonda coordenadas
      final latitudeArredondada = LocationService.roundCoordinate(controller.selectedLat!);
      final longitudeArredondada = LocationService.roundCoordinate(controller.selectedLng!);

      // Cria request
      final request = CreateDenunciaRequest(
        titulo: controller.tituloController.text.trim(),
        descricao: controller.descricaoController.text.trim(),
        categoria: controller.categoriaSelecionada!,
        cidade: location.cidadeId,
        estado: location.estadoId,
        latitude: latitudeArredondada,
        longitude: longitudeArredondada,
        endereco: controller.localizacaoController.text.trim().isNotEmpty
            ? controller.localizacaoController.text.trim()
            : null,
        jurisdicao: location.jurisdicao ?? 'MUNICIPAL',
        foto: controller.selectedFoto,
      );

      // Envia para API
      final response = await ref.read(denunciasNotifierProvider.notifier).createDenuncia(request);

      // Retorna resultado
      if (response.apoioAdicionado) {
        return SubmitResult.success(
          isApoio: true,
          message: response.message ?? 'Já existe uma denúncia similar próxima. Seu apoio foi registrado!',
        );
      } else {
        return SubmitResult.success(
          message: 'Sua denúncia foi registrada com sucesso e está aguardando análise.',
        );
      }
    } catch (e) {
      return SubmitResult.error('Erro ao criar denúncia: $e');
    }
  }
}
