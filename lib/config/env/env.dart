

abstract class Env {
  static String get apiUrl {

    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;


    return 'http://192.168.1.10:8000';

    /* Código original para detectar plataforma automaticamente:
    try {
      if (Platform.isAndroid) {

        return 'http://10.0.2.2:8000';
      } else if (Platform.isIOS) {

        return 'http://127.0.0.1:8000';
      } else {

        return 'http://localhost:8000';
      }
    } catch (e) {

      return 'http://localhost:8000';
    }
    */
  }
}
