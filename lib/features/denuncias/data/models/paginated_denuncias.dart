import 'denuncia_model.dart';

/// Resposta paginada da API de denúncias
class PaginatedDenuncias {
  final int count;
  final String? next;
  final String? previous;
  final List<DenunciaModel> results;

  const PaginatedDenuncias({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedDenuncias.fromJson(Map<String, dynamic> json) {
    return PaginatedDenuncias(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => DenunciaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasMore => next != null;
}
