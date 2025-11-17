/// Resposta da API ao deletar uma denúncia
class DeleteDenunciaResponse {
  final String message;
  final int? apoiosTransferidos;
  final int? denunciaDestinoId;
  final int? novaDenunciaId;
  final int? apoiosPreservados;

  const DeleteDenunciaResponse({
    required this.message,
    this.apoiosTransferidos,
    this.denunciaDestinoId,
    this.novaDenunciaId,
    this.apoiosPreservados,
  });

  factory DeleteDenunciaResponse.fromJson(Map<String, dynamic> json) {
    return DeleteDenunciaResponse(
      message: json['message'] as String,
      apoiosTransferidos: json['apoios_transferidos'] as int?,
      denunciaDestinoId: json['denuncia_destino_id'] as int?,
      novaDenunciaId: json['nova_denuncia_id'] as int?,
      apoiosPreservados: json['apoios_preservados'] as int?,
    );
  }

  /// Retorna true se houve transferência de apoios
  bool get hasApoiosTransferidos => apoiosTransferidos != null && apoiosTransferidos! > 0;

  /// Retorna true se foi criada nova denúncia (promoção de apoio)
  bool get hasNovaDenuncia => novaDenunciaId != null;
}
