import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../localidades/data/repositories/localidades_repository.dart';
import '../../../localidades/presentation/notifiers/localidades_notifier.dart';

/// Resultado da análise de localização
class LocationResult {
  final int cidadeId;
  final int estadoId;
  final String? jurisdicao;
  final String? cidadeNome;
  final String? estadoNome;

  const LocationResult({
    required this.cidadeId,
    required this.estadoId,
    this.jurisdicao,
    this.cidadeNome,
    this.estadoNome,
  });
}

/// Serviço para gerenciar análise de localização
class LocationService {
  final Ref ref;

  LocationService(this.ref);

  /// Analisa coordenadas e retorna IDs de cidade/estado
  Future<LocationResult> analyzeLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Tenta analisar localização pela API
      final localidadesRepo = ref.read(localidadesRepositoryProvider);
      final localizacao = await localidadesRepo.analisarLocalizacao(
        latitude: latitude,
        longitude: longitude,
      );
      
      final estadoId = localizacao.estadoId;
      final jurisdicao = localizacao.jurisdicaoSugerida;
      
      print('📍 Localização identificada: ${localizacao.cidadeNome}/${localizacao.estadoNome}');
      print('🆔 Estado ID: $estadoId');
      print('🏛️ Jurisdição: $jurisdicao');
      
      // Verifica se cidade foi identificada
      if (localizacao.cidadeIdentificada == true && localizacao.cidadeId != null) {
        final cidadeId = localizacao.cidadeId!;
        print('✅ Cidade identificada: ${localizacao.cidadeNome} (ID: $cidadeId)');
        
        return LocationResult(
          cidadeId: cidadeId,
          estadoId: estadoId,
          jurisdicao: jurisdicao,
          cidadeNome: localizacao.cidadeNome,
          estadoNome: localizacao.estadoNome,
        );
      } else {
        // Cidade não identificada: busca primeira cidade do estado
        print('⚠️ Cidade não identificada. Buscando primeira cidade do estado...');
        
        final cidadesNotifier = ref.read(cidadesNotifierProvider.notifier);
        await cidadesNotifier.loadCidades(estadoId);
        
        final cidades = ref.read(cidadesNotifierProvider).cidades;
        if (cidades.isEmpty) {
          throw Exception('Nenhuma cidade disponível para o estado');
        }
        
        final cidadeId = cidades.first.id;
        print('🛠️ Usando primeira cidade: ${cidades.first.nome} (ID: $cidadeId)');
        
        return LocationResult(
          cidadeId: cidadeId,
          estadoId: estadoId,
          jurisdicao: jurisdicao,
          cidadeNome: cidades.first.nome,
          estadoNome: localizacao.estadoNome,
        );
      }
    } catch (e) {
      print('⚠️ Erro ao analisar localização: $e');
      // Fallback: busca primeira cidade/estado disponível
      return _getFallbackLocation();
    }
  }

  /// Retorna localização fallback (primeira cidade/estado disponível)
  Future<LocationResult> _getFallbackLocation() async {
    try {
      final estadosNotifier = ref.read(estadosNotifierProvider.notifier);
      await estadosNotifier.loadEstados();
      final estados = ref.read(estadosNotifierProvider).estados;
      
      if (estados.isEmpty) {
        throw Exception('Nenhum estado disponível');
      }
      
      final estadoId = estados.first.id;
      
      // Carrega cidades do primeiro estado
      final cidadesNotifier = ref.read(cidadesNotifierProvider.notifier);
      await cidadesNotifier.loadCidades(estadoId);
      final cidades = ref.read(cidadesNotifierProvider).cidades;
      
      if (cidades.isEmpty) {
        throw Exception('Nenhuma cidade disponível');
      }
      
      final cidadeId = cidades.first.id;
      print('🛠️ Usando fallback: ${cidades.first.nome}/${estados.first.sigla}');
      
      return LocationResult(
        cidadeId: cidadeId,
        estadoId: estadoId,
        jurisdicao: 'MUNICIPAL',
        cidadeNome: cidades.first.nome,
        estadoNome: estados.first.nome,
      );
    } catch (fallbackError) {
      throw Exception(
        'Não foi possível determinar a localização.\n\nVerifique sua conexão e tente novamente.',
      );
    }
  }

  /// Arredonda coordenadas para 6 casas decimais
  static double roundCoordinate(double coordinate) {
    return double.parse(coordinate.toStringAsFixed(6));
  }
}

/// Provider para o serviço de localização
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref);
});
