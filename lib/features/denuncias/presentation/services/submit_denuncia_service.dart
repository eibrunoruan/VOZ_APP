import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/image_compression_service.dart';
import '../../data/models/create_denuncia_request.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';
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
      // Comprime a imagem se existir
      var fotoParaEnviar = controller.selectedFoto;
      if (fotoParaEnviar != null) {
        print('📸 Comprimindo imagem antes do upload...');
        final compressedImage = await ImageCompressionService.compressImage(
          fotoParaEnviar,
          quality: 70,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        
        if (compressedImage != null) {
          fotoParaEnviar = compressedImage;
          print('✅ Imagem comprimida - pronta para upload');
        } else {
          print('⚠️ Falha na compressão - usando imagem original');
        }
      }

      // Analisa localização
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.analyzeLocation(
        latitude: controller.selectedLat!,
        longitude: controller.selectedLng!,
      );

      // Arredonda coordenadas
      final latitudeArredondada = LocationService.roundCoordinate(controller.selectedLat!);
      final longitudeArredondada = LocationService.roundCoordinate(controller.selectedLng!);

      // Obtém o nome do convidado se for usuário guest
      final authState = ref.read(authNotifierProvider);
      final nomeConvidado = authState.isGuest ? authState.guestNickname : null;
      
      print('\n🔐 === ESTADO DE AUTENTICAÇÃO ===');
      print('   isLoggedIn: ${authState.isLoggedIn}');
      print('   isGuest: ${authState.isGuest}');
      print('   guestNickname: ${authState.guestNickname}');
      print('   hasAccess: ${authState.hasAccess}');
      print('   nomeConvidado a enviar: ${nomeConvidado ?? "(null)"}');
      print('================================\n');

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
        foto: fotoParaEnviar, // Usa imagem comprimida
        nomeConvidado: nomeConvidado,
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
