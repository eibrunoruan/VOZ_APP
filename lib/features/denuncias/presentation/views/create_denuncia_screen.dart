import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/exceptions/denuncia_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirmation_bottom_sheet.dart';
import '../../data/models/create_denuncia_request.dart';
import '../controllers/create_denuncia_controller.dart';
import '../notifiers/categorias_notifier.dart';
import '../notifiers/denuncias_notifier.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/steps/titulo_step_widget.dart';
import '../widgets/steps/categoria_step_widget.dart';
import '../widgets/steps/descricao_step_widget.dart';
import '../widgets/steps/localizacao_step_widget.dart';
import '../widgets/steps/fotos_step_widget.dart';
import '../services/location_service.dart';
import '../services/denuncia_validator.dart';
import '../services/map_interaction_service.dart';
import '../services/submit_denuncia_service.dart';
import '../services/feedback_service.dart';
import '../../../localidades/presentation/notifiers/localidades_notifier.dart';

/// Tela de criação de denúncia refatorada
class CreateDenunciaScreen extends ConsumerStatefulWidget {
  const CreateDenunciaScreen({super.key});

  @override
  ConsumerState<CreateDenunciaScreen> createState() =>
      _CreateDenunciaScreenState();
}

class _CreateDenunciaScreenState extends ConsumerState<CreateDenunciaScreen>
    with SingleTickerProviderStateMixin {
  late final CreateDenunciaController _controller;
  bool _isSubmitting = false;
  
  // Animação de tremor
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // Estados de erro dos campos
  bool _tituloError = false;
  bool _categoriaError = false;
  bool _descricaoError = false;
  bool _localizacaoError = false;
  
  // Mensagens de erro
  String? _tituloErrorMessage;
  String? _categoriaErrorMessage;
  String? _descricaoErrorMessage;
  String? _localizacaoErrorMessage;

  @override
  void initState() {
    super.initState();
    _controller = CreateDenunciaController();
    
    // Configura animação de tremor
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
    
    // Carrega categorias e estados ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriasNotifierProvider.notifier).loadCategorias();
      ref.read(estadosNotifierProvider.notifier).loadEstados();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final error = _controller.validateCurrentStep();
    if (error != null) {
      _showErrorDialog(error);
      return;
    }

    if (_controller.currentStep < _controller.totalSteps - 1) {
      setState(() => _controller.currentStep++);
    } else {
      _handleSubmit();
    }
  }

  void _previousStep() {
    if (_controller.currentStep > 0) {
      setState(() => _controller.currentStep--);
    } else {
      context.canPop() ? context.pop() : context.go('/home');
    }
  }

  Future<void> _handleSubmit() async {
    // Valida campos obrigatórios
    final validation = DenunciaValidator.validate(
      titulo: _controller.tituloController.text,
      categoriaId: _controller.categoriaSelecionada,
      descricao: _controller.descricaoController.text,
      latitude: _controller.selectedLat,
      longitude: _controller.selectedLng,
      endereco: _controller.localizacaoController.text,
    );
    
    // Atualiza estados de erro
    setState(() {
      _tituloError = validation.tituloError;
      _categoriaError = validation.categoriaError;
      _descricaoError = validation.descricaoError;
      _localizacaoError = validation.localizacaoError;
      
      _tituloErrorMessage = validation.tituloErrorMessage;
      _categoriaErrorMessage = validation.categoriaErrorMessage;
      _descricaoErrorMessage = validation.descricaoErrorMessage;
      _localizacaoErrorMessage = validation.localizacaoErrorMessage;
    });
    
    if (validation.hasError) {
      _shakeController.forward();
      
      // Se o erro é de endereço, mostra mensagem específica
      if (validation.enderecoError) {
        FeedbackService(context).showErrorSnackbar(
          'Endereço não foi carregado. Selecione a localização novamente no mapa.',
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Usa serviço para processar submit
      final submitService = SubmitDenunciaService(
        ref: ref,
        controller: _controller,
      );
      
      final result = await submitService.submit();

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (result.success) {
        final feedback = FeedbackService(context);
        final title = result.isApoio ? 'Apoio Registrado!' : 'Denúncia Criada!';
        final modalResult = await feedback.showSuccessDialog(
          title: title,
          message: result.message!,
        );
        
        if (mounted) {
          // modalResult == true: clicou em "Ver Denúncias"
          // modalResult == false ou null: clicou em "Fechar" ou dismiss
          if (modalResult == true) {
            context.go('/denuncias');
          } else {
            context.go('/home');
          }
        }
      } else {
        FeedbackService(context).showErrorSnackbar(result.error!);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        FeedbackService(context).showErrorSnackbar('Erro inesperado: $e');
      }
    }
  }

  Future<void> _handleGetCurrentLocation() async {
    setState(() => _controller.loadingLocation = true);

    try {
      final feedback = FeedbackService(context);
      feedback.showLoadingSnackbar('Obtendo localização...');

      final mapService = MapInteractionService(
        controller: _controller,
        context: context,
      );

      final position = await mapService.getCurrentLocation();

      if (!mounted) return;

      setState(() => _controller.loadingLocation = false);

      if (position != null) {
        feedback.showSuccessSnackbar('Localização obtida!');
      }
    } catch (e) {
      setState(() => _controller.loadingLocation = false);
      if (mounted) {
        FeedbackService(context).showErrorSnackbar(e.toString());
      }
    }
  }

  void _onMapTap(LatLng position) async {
    final mapService = MapInteractionService(
      controller: _controller,
      context: context,
    );
    
    await mapService.handleMapTap(position);
    setState(() {}); // Atualiza UI
  }
  
  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        margin: const EdgeInsets.all(AppSizes.spacing16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasState = ref.watch(categoriasNotifierProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacing24),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isSubmitting ? null : _previousStep,
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

                  // Progress Indicator
                  StepProgressIndicator(
                    currentStep: _controller.currentStep,
                    totalSteps: _controller.totalSteps,
                  ),
                  const SizedBox(height: AppSizes.spacing32),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildStepContent(categoriasState),
                    ),
                ),
                const SizedBox(height: AppSizes.spacing24),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: AppButtonStyles.primary,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _controller.currentStep ==
                                    _controller.totalSteps - 1
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
    ),
    );
  }

  Widget _buildStepContent(CategoriasState categoriasState) {
    switch (_controller.currentStep) {
      case 0:
        return TituloStepWidget(
          controller: _controller.tituloController,
          hasError: _tituloError,
          errorMessage: _tituloErrorMessage,
          onChanged: () {
            if (_tituloError) {
              setState(() {
                _tituloError = false;
                _tituloErrorMessage = null;
              });
            }
          },
          onSubmit: _nextStep,
        );
      case 1:
        return CategoriaStepWidget(
          selectedCategoriaId: _controller.categoriaSelecionada,
          hasError: _categoriaError,
          errorMessage: _categoriaErrorMessage,
          onChanged: (value) {
            setState(() {
              _controller.categoriaSelecionada = value;
              if (_categoriaError) {
                _categoriaError = false;
                _categoriaErrorMessage = null;
              }
            });
          },
        );
      case 2:
        return DescricaoStepWidget(
          controller: _controller.descricaoController,
          hasError: _descricaoError,
          errorMessage: _descricaoErrorMessage,
          onChanged: () {
            if (_descricaoError) {
              setState(() {
                _descricaoError = false;
                _descricaoErrorMessage = null;
              });
            }
          },
        );
      case 3:
        return LocalizacaoStepWidget(
          mapController: _controller.mapController,
          markers: _controller.markers,
          hasError: _localizacaoError,
          loadingLocation: _controller.loadingLocation,
          selectedLat: _controller.selectedLat,
          selectedLng: _controller.selectedLng,
          localizacaoController: _controller.localizacaoController,
          onGetCurrentLocation: _handleGetCurrentLocation,
          onMapTap: (position) {
            _onMapTap(position);
            if (_localizacaoError) {
              setState(() => _localizacaoError = false);
            }
          },
          onMapCreated: (controller) {
            final mapService = MapInteractionService(
              controller: _controller,
              context: context,
            );
            mapService.handleMapCreated(controller);
            setState(() {});
          },
        );
      case 4:
        return FotosStepWidget(
          selectedFoto: _controller.selectedFoto,
          onFotoSelected: (File? foto) {
            setState(() => _controller.selectedFoto = foto);
          },
        );
      default:
        return const SizedBox();
    }
  }
}
