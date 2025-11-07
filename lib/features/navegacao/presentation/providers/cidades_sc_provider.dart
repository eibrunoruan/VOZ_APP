import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CidadeSC {
  final String nome;
  final LatLng coordenadas;

  CidadeSC({required this.nome, required this.coordenadas});
}

final cidadesSCProvider = Provider<List<CidadeSC>>((ref) {
  return [
    CidadeSC(
      nome: 'Florianópolis',
      coordenadas: const LatLng(-27.5954, -48.5480),
    ),
    CidadeSC(nome: 'Joinville', coordenadas: const LatLng(-26.3045, -48.8487)),
    CidadeSC(nome: 'Blumenau', coordenadas: const LatLng(-26.9194, -49.0661)),
    CidadeSC(nome: 'São José', coordenadas: const LatLng(-27.5969, -48.6336)),
    CidadeSC(nome: 'Chapecó', coordenadas: const LatLng(-27.0965, -52.6169)),
    CidadeSC(nome: 'Criciúma', coordenadas: const LatLng(-28.6773, -49.3695)),
    CidadeSC(nome: 'Itajaí', coordenadas: const LatLng(-26.9077, -48.6619)),
    CidadeSC(
      nome: 'Jaraguá do Sul',
      coordenadas: const LatLng(-26.4867, -49.0779),
    ),
    CidadeSC(nome: 'Lages', coordenadas: const LatLng(-27.8157, -50.3262)),
    CidadeSC(nome: 'Palhoça', coordenadas: const LatLng(-27.6446, -48.6702)),
    CidadeSC(
      nome: 'Balneário Camboriú',
      coordenadas: const LatLng(-26.9906, -48.6356),
    ),
    CidadeSC(nome: 'Brusque', coordenadas: const LatLng(-27.0979, -48.9139)),
    CidadeSC(nome: 'Tubarão', coordenadas: const LatLng(-28.4667, -49.0069)),
    CidadeSC(
      nome: 'São Bento do Sul',
      coordenadas: const LatLng(-26.2503, -49.3797),
    ),
    CidadeSC(nome: 'Caçador', coordenadas: const LatLng(-26.7754, -51.0159)),
    CidadeSC(nome: 'Camboriú', coordenadas: const LatLng(-27.0236, -48.6548)),
    CidadeSC(nome: 'Navegantes', coordenadas: const LatLng(-26.8979, -48.6545)),
    CidadeSC(nome: 'Concórdia', coordenadas: const LatLng(-27.2342, -52.0278)),
    CidadeSC(nome: 'Rio do Sul', coordenadas: const LatLng(-27.2144, -49.6431)),
    CidadeSC(nome: 'Araranguá', coordenadas: const LatLng(-28.9358, -49.4917)),
    CidadeSC(nome: 'Gaspar', coordenadas: const LatLng(-26.9306, -48.9567)),
    CidadeSC(nome: 'Biguaçu', coordenadas: const LatLng(-27.4937, -48.6552)),
    CidadeSC(nome: 'Indaial', coordenadas: const LatLng(-26.8985, -49.2318)),
    CidadeSC(nome: 'Itapema', coordenadas: const LatLng(-27.0917, -48.6114)),
    CidadeSC(nome: 'Mafra', coordenadas: const LatLng(-26.1137, -49.8047)),
    CidadeSC(nome: 'Canoinhas', coordenadas: const LatLng(-26.1773, -50.3892)),
    CidadeSC(nome: 'Içara', coordenadas: const LatLng(-28.7139, -49.3014)),
    CidadeSC(nome: 'Videira', coordenadas: const LatLng(-27.0083, -51.1517)),
    CidadeSC(nome: 'Araquari', coordenadas: const LatLng(-26.3708, -48.7208)),
    CidadeSC(
      nome: 'Massaranduba',
      coordenadas: const LatLng(-26.6093, -49.0018),
    ),
    CidadeSC(nome: 'Tijucas', coordenadas: const LatLng(-27.2405, -48.6336)),
    CidadeSC(
      nome: 'Braço do Norte',
      coordenadas: const LatLng(-28.2756, -49.1669),
    ),
    CidadeSC(
      nome: 'São Francisco do Sul',
      coordenadas: const LatLng(-26.2431, -48.6384),
    ),
    CidadeSC(nome: 'Guaramirim', coordenadas: const LatLng(-26.4708, -49.0007)),
    CidadeSC(nome: 'Schroeder', coordenadas: const LatLng(-26.4138, -49.0714)),
    CidadeSC(nome: 'Pomerode', coordenadas: const LatLng(-26.7406, -49.1764)),
    CidadeSC(nome: 'Laguna', coordenadas: const LatLng(-28.4800, -48.7789)),
    CidadeSC(nome: 'Penha', coordenadas: const LatLng(-26.7708, -48.6442)),
    CidadeSC(nome: 'Imbituba', coordenadas: const LatLng(-28.2400, -48.6703)),
    CidadeSC(nome: 'Garopaba', coordenadas: const LatLng(-28.0250, -48.6169)),
  ];
});
