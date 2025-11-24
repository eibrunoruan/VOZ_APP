import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressionService {
  /// Comprime uma imagem para otimizar upload
  /// 
  /// Parâmetros:
  /// - [file]: Arquivo de imagem original
  /// - [quality]: Qualidade da compressão (0-100), padrão 70
  /// - [maxWidth]: Largura máxima em pixels, padrão 1024
  /// - [maxHeight]: Altura máxima em pixels, padrão 1024
  /// 
  /// Retorna o arquivo comprimido ou null se falhar
  static Future<File?> compressImage(
    File file, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      // Obtém o diretório temporário
      final tempDir = await getTemporaryDirectory();
      
      // Gera nome único para o arquivo comprimido
      final fileName = path.basename(file.path);
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );

      print('📦 Comprimindo imagem...');
      print('   Original: ${file.path}');
      print('   Destino: $targetPath');
      print('   Qualidade: $quality%');
      print('   Max: ${maxWidth}x$maxHeight');

      // Comprime a imagem
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      if (result == null) {
        print('❌ Falha na compressão');
        return null;
      }

      // Verifica se o arquivo comprimido foi criado
      final compressedFile = File(result.path);
      final compressedExists = await compressedFile.exists();
      
      if (!compressedExists) {
        print('❌ Arquivo comprimido não existe no path: ${result.path}');
        return null;
      }

      // Obtém tamanhos dos arquivos
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);

      print('✅ Imagem comprimida com sucesso!');
      print('   Path comprimido: ${result.path}');
      print('   Arquivo existe: $compressedExists');
      print('   Tamanho original: ${_formatBytes(originalSize)}');
      print('   Tamanho comprimido: ${_formatBytes(compressedSize)}');
      print('   Redução: $reduction%');

      return compressedFile;
    } catch (e) {
      print('❌ Erro ao comprimir imagem: $e');
      return null;
    }
  }

  /// Comprime múltiplas imagens em paralelo
  static Future<List<File>> compressMultipleImages(
    List<File> files, {
    int quality = 70,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    print('📦 Comprimindo ${files.length} imagens...');
    
    final results = await Future.wait(
      files.map((file) => compressImage(
        file,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      )),
    );

    // Remove nulls (imagens que falharam na compressão)
    final compressed = results.whereType<File>().toList();
    
    print('✅ ${compressed.length}/${files.length} imagens comprimidas');
    
    return compressed;
  }

  /// Formata bytes em KB ou MB
  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
