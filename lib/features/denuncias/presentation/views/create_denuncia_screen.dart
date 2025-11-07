import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/denuncias_provider.dart';

class CreateDenunciaScreen extends ConsumerStatefulWidget {
  const CreateDenunciaScreen({super.key});

  @override
  ConsumerState<CreateDenunciaScreen> createState() =>
      _CreateDenunciaScreenState();
}

class _CreateDenunciaScreenState extends ConsumerState<CreateDenunciaScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5; // Aumentado para 5 etapas

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localizacaoController = TextEditingController();

  String? _categoriaSelecionada;

  double? _selectedLat;
  double? _selectedLng;

  final List<String> _selectedPhotos = [];

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  static const LatLng _initialPosition = LatLng(-23.5505, -46.6333);

  bool _mapError = false;
  bool _loadingLocation = false;
  bool _locationLoaded = false;

  final List<Map<String, dynamic>> _categorias = [
    {'nome': 'Infraestrutura', 'icon': Icons.construction},
    {'nome': 'Saúde', 'icon': Icons.local_hospital},
    {'nome': 'Educação', 'icon': Icons.school},
    {'nome': 'Segurança', 'icon': Icons.security},
    {'nome': 'Meio Ambiente', 'icon': Icons.nature},
    {'nome': 'Transporte', 'icon': Icons.directions_bus},
    {'nome': 'Iluminação', 'icon': Icons.lightbulb},
    {'nome': 'Outros', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {

      if (_currentStep == 0 && _tituloController.text.trim().isEmpty) {
        _showErrorDialog('Digite um título para a denúncia');
        return;
      }
      if (_currentStep == 1 && _categoriaSelecionada == null) {
        _showErrorDialog('Selecione uma categoria');
        return;
      }
      if (_currentStep == 2 && _descricaoController.text.trim().isEmpty) {
        _showErrorDialog('Digite uma descrição para a denúncia');
        return;
      }
      if (_currentStep == 3 && _selectedLat == null) {
        _showErrorDialog('Selecione a localização no mapa');
        return;
      }

      setState(() {
        _currentStep++;
      });
    } else {

      _handleCreateDenuncia();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {

      if (GoRouter.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.primaryRed,
              size: 28,
            ),
            const SizedBox(width: AppSizes.spacing12),
            const Text(
              'Atenção',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateDenuncia() {

    final denuncia = DenunciaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      categoria: _categoriaSelecionada ?? 'Outros',
      descricao: _descricaoController.text,
      latitude: _selectedLat!,
      longitude: _selectedLng!,
      endereco: _localizacaoController.text,
      fotos: _selectedPhotos,
      dataCriacao: DateTime.now(),
    );

    ref.read(denunciasProvider.notifier).addDenuncia(denuncia);

    context.go('/home');
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog(
          'Serviço de localização desabilitado.\n\nAtive o GPS nas configurações do dispositivo.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
          'Permissão de localização negada permanentemente.\n\nAtive nas configurações do app.',
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Obtendo localização...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;

      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
      });

      if (_mapController != null && !_mapError) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }

      _addMarker(LatLng(position.latitude, position.longitude));

      await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        _locationLoaded = true;
        _loadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('Localização obtida!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on TimeoutException {
      setState(() {
        _loadingLocation = false;
      });
      if (mounted) {
        _showErrorDialog(
          'Tempo esgotado ao obter localização.\n\nVerifique se o GPS está ativado.',
        );
      }
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      if (mounted) {
        _showErrorDialog('Erro ao obter localização:\n${e.toString()}');
      }
      debugPrint('Erro getCurrentLocation: $e');
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        String endereco = '';

        if (place.street != null && place.street!.isNotEmpty) {
          endereco += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          endereco += endereco.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality!}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          endereco += endereco.isEmpty
              ? place.locality!
              : ', ${place.locality!}';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          endereco += ' - ${place.administrativeArea!}';
        }

        setState(() {
          _localizacaoController.text = endereco.isNotEmpty
              ? endereco
              : 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localizacaoController.text =
              'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
        });
        debugPrint('Erro no geocoding: $e');
      }
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLat = position.latitude;
      _selectedLng = position.longitude;
    });

    _addMarker(position);
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Widget _buildMapErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade700),
          const SizedBox(height: AppSizes.spacing16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
            child: Column(
              children: [
                Text(
                  'Google Maps não configurado',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 18,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Configure a API Key do Google Maps\nConsulte: GOOGLE_MAPS_SETUP.md',
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacing16),
                ElevatedButton.icon(
                  onPressed: () {

                    setState(() {
                      _selectedLat = _initialPosition.latitude;
                      _selectedLng = _initialPosition.longitude;
                      _localizacaoController.text = 'São Paulo, SP (fallback)';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.location_on, size: 20),
                  label: const Text('Usar localização padrão'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              children: [

                Row(
                  children: [
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.navbarText,
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    Text(
                      'Nova Denúncia',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 20,
                        color: AppColors.navbarText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spacing24),

                _buildStepIndicator(),

                const SizedBox(height: AppSizes.spacing32),

                Expanded(
                  child: SingleChildScrollView(

                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildStepContent(),
                  ),
                ),

                const SizedBox(height: AppSizes.spacing24),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: AppButtonStyles.primary,
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? 'Criar Denúncia'
                          : 'Continuar',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < _totalSteps - 1 ? AppSizes.spacing8 : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryRed : AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTituloStep();
      case 1:
        return _buildCategoriaStep();
      case 2:
        return _buildDescricaoStep();
      case 3:
        return _buildLocalizacaoStep();
      case 4:
        return _buildFotosStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTituloStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual o título da sua denúncia?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Seja breve e direto',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título',
              style: AppTextStyles.label.copyWith(color: AppColors.navbarText),
            ),
            const SizedBox(height: AppSizes.spacing8),
            TextFormField(
              controller: _tituloController,
              autofocus: true,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Ex: Buraco na rua principal',
                hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing16,
                  vertical: AppSizes.spacing12,
                ),
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.white),
              onFieldSubmitted: (_) => _nextStep(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual a categoria?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Selecione a categoria que melhor descreve sua denúncia',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: AppColors.primaryRed, width: 1.5),
          ),
          child: DropdownButtonFormField<String>(
            value: _categoriaSelecionada,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing12,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
            dropdownColor: AppColors.background,
            hint: Text(
              'Selecione uma categoria',
              style: TextStyle(color: AppColors.grey.withOpacity(0.5)),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primaryRed,
            ),
            style: const TextStyle(color: AppColors.white, fontSize: 16),
            items: _categorias.map((categoria) {
              return DropdownMenuItem<String>(
                value: categoria['nome'],
                child: Row(
                  children: [
                    Icon(
                      categoria['icon'],
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.spacing12),
                    Text(categoria['nome']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _categoriaSelecionada = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescricaoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descreva a situação',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Forneça o máximo de detalhes possível',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: AppTextStyles.label.copyWith(color: AppColors.navbarText),
            ),
            const SizedBox(height: AppSizes.spacing8),
            TextFormField(
              controller: _descricaoController,
              autofocus: true,
              maxLines: 8,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Descreva com detalhes o problema...',
                hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing16,
                  vertical: AppSizes.spacing12,
                ),
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocalizacaoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Onde está localizado o problema?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Toque no mapa para marcar a localização',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing24),

        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          child: SizedBox(
            width: double.infinity,
            height: 300, // Altura reduzida para dar espaço ao botão
            child: _mapError
                ? _buildMapErrorWidget()
                : GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _initialPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      try {
                        _mapController = controller;
                        setState(() {
                          _mapError = false;
                          _locationLoaded = false;
                        });

                        if (!_locationLoaded) {
                          _getCurrentLocation();
                        }
                      } catch (e) {
                        setState(() => _mapError = true);
                      }
                    },
                    onTap: _onMapTap,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                  ),
          ),
        ),

        const SizedBox(height: AppSizes.spacing24),

        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _loadingLocation ? null : _getCurrentLocation,
            style: AppButtonStyles.secondary,
            icon: _loadingLocation
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
              _loadingLocation
                  ? 'Obtendo localização...'
                  : 'Usar minha localização',
              style: AppTextStyles.button.copyWith(color: AppColors.primaryRed),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spacing16),

        if (_selectedLat != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Endereço (opcional)',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.navbarText,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(
                  hintText: 'Ex: Rua Principal, 123',
                  hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                    vertical: AppSizes.spacing12,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: AppColors.white),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione fotos do problema',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Opcional - até 3 fotos',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),

        if (_selectedPhotos.isEmpty)

          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPhotos.add('foto_${_selectedPhotos.length + 1}.jpg');
              });
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.primaryRed, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 64,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(height: AppSizes.spacing16),
                  Text(
                    'Adicionar fotos',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else

          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.spacing16,
                  mainAxisSpacing: AppSizes.spacing16,
                  childAspectRatio: 1,
                ),
                itemCount:
                    _selectedPhotos.length +
                    (_selectedPhotos.length < 3 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _selectedPhotos.length) {

                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            border: Border.all(
                              color: AppColors.black,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 48,
                                  color: AppColors.white,
                                ),
                                const SizedBox(height: AppSizes.spacing8),
                                Text(
                                  _selectedPhotos[index],
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPhotos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {

                    return GestureDetector(
                      onTap: () {
                        if (_selectedPhotos.length < 3) {
                          setState(() {
                            _selectedPhotos.add(
                              'foto_${_selectedPhotos.length + 1}.jpg',
                            );
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          border: Border.all(
                            color: AppColors.primaryRed,
                            width: 1.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: AppColors.primaryRed,
                            ),
                            SizedBox(height: AppSizes.spacing8),
                            Text(
                              'Adicionar',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: AppSizes.spacing16),

              Text(
                '${_selectedPhotos.length}/3 fotos adicionadas',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
