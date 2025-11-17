import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../controllers/create_denuncia_controller.dart';

/// Widget for step 4: Location selection with map
class LocalizacaoStepWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final Set<Marker> markers;
  final bool hasError;
  final bool loadingLocation;
  final double? selectedLat;
  final double? selectedLng;
  final TextEditingController localizacaoController;
  final VoidCallback onGetCurrentLocation;
  final Function(LatLng) onMapTap;
  final Function(GoogleMapController) onMapCreated;

  const LocalizacaoStepWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.hasError,
    required this.loadingLocation,
    required this.selectedLat,
    required this.selectedLng,
    required this.localizacaoController,
    required this.onGetCurrentLocation,
    required this.onMapTap,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onde está localizado o problema?',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Toque no mapa para marcar a localização',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: hasError ? AppColors.error : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: CreateDenunciaController.initialPosition,
                  zoom: 15,
                ),
                onMapCreated: onMapCreated,
                onTap: onMapTap,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing24),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: loadingLocation ? null : onGetCurrentLocation,
            style: AppButtonStyles.secondary,
            icon: loadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryRed,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              loadingLocation
                  ? 'Obtendo localização...'
                  : 'Usar minha localização',
              style: AppTextStyles.button.copyWith(color: AppColors.primaryRed),
            ),
          ),
        ),
        if (selectedLat != null) ...[
          const SizedBox(height: AppSizes.spacing16),
          TextFormField(
            controller: localizacaoController,
            decoration: InputDecoration(
              hintText: 'Ex: Rua Principal, 123',
              hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
              ),
            ),
            style: const TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ],
      ],
    );
  }
}
