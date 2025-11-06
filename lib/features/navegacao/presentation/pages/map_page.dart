import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Página do mapa - visualização de denúncias no mapa
/// TODO: Implementar integração com Google Maps
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Mapa de Denúncias',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 120, color: AppColors.grey.withOpacity(0.3)),
            const SizedBox(height: AppSizes.spacing24),
            const Text(
              'Mapa em Desenvolvimento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing40,
              ),
              child: Text(
                'Em breve você poderá visualizar todas as denúncias em um mapa interativo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
