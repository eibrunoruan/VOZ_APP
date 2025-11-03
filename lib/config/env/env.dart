// lib/config/env/env.dart

abstract class Env {
  static String get apiUrl {
    // Verifica se foi passada via --dart-define
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Para dispositivo físico Android, use o IP da máquina na rede Wi-Fi
    // IP descoberto: 192.168.1.10
    return 'http://192.168.1.10:8000';

    /* Código original para detectar plataforma automaticamente:
    try {
      if (Platform.isAndroid) {
        // Emulador Android usa IP especial para acessar host
        return 'http://10.0.2.2:8000';
      } else if (Platform.isIOS) {
        // iOS Simulator pode usar localhost
        return 'http://127.0.0.1:8000';
      } else {
        // Web/Desktop
        return 'http://localhost:8000';
      }
    } catch (e) {
      // Fallback para Web (Platform não disponível)
      return 'http://localhost:8000';
    }
    */
  }
}
