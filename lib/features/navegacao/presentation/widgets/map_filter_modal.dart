import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/data/models/categoria_model.dart';

class MapFilterResult {
  final int? categoriaId;
  final String? status;
  final int? days; // Últimos X dias

  const MapFilterResult({
    this.categoriaId,
    this.status,
    this.days,
  });

  bool get hasFilters =>
      categoriaId != null || status != null || days != null;

  String get description {
    final parts = <String>[];
    if (categoriaId != null) parts.add('Categoria');
    if (status != null) parts.add('Status');
    if (days != null) parts.add('Tempo');
    return parts.isEmpty ? 'Sem filtros' : parts.join(', ');
  }
}

class MapFilterModal extends StatefulWidget {
  final List<CategoriaModel> categorias;
  final MapFilterResult? currentFilters;

  const MapFilterModal({
    super.key,
    required this.categorias,
    this.currentFilters,
  });

  static Future<MapFilterResult?> show({
    required BuildContext context,
    required List<CategoriaModel> categorias,
    MapFilterResult? currentFilters,
  }) {
    return showModalBottomSheet<MapFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterModal(
        categorias: categorias,
        currentFilters: currentFilters,
      ),
    );
  }

  @override
  State<MapFilterModal> createState() => _MapFilterModalState();
}

class _MapFilterModalState extends State<MapFilterModal> {
  int? _selectedCategoriaId;
  String? _selectedStatus;
  int? _selectedDays;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Todas', 'value': null},
    {'label': 'Aguardando Análise', 'value': 'AGUARDANDO_ANALISE'},
    {'label': 'Em Análise', 'value': 'EM_ANALISE'},
    {'label': 'Resolvida', 'value': 'RESOLVIDA'},
    {'label': 'Rejeitada', 'value': 'REJEITADA'},
  ];

  final List<Map<String, dynamic>> _timeOptions = [
    {'label': 'Todas', 'value': null},
    {'label': 'Últimos 7 dias', 'value': 7},
    {'label': 'Últimos 15 dias', 'value': 15},
    {'label': 'Últimos 30 dias', 'value': 30},
    {'label': 'Últimos 90 dias', 'value': 90},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters != null) {
      _selectedCategoriaId = widget.currentFilters!.categoriaId;
      _selectedStatus = widget.currentFilters!.status;
      _selectedDays = widget.currentFilters!.days;
    }
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      MapFilterResult(
        categoriaId: _selectedCategoriaId,
        status: _selectedStatus,
        days: _selectedDays,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoriaId = null;
      _selectedStatus = null;
      _selectedDays = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.spacing24),
            topRight: Radius.circular(AppSizes.spacing24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSizes.spacing12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: AppSizes.spacing32),

            // Icon + Title
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.filter_list,
                size: 40,
                color: AppColors.primaryRed,
              ),
            ),

            const SizedBox(height: AppSizes.spacing24),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing24,
              ),
              child: Text(
                'Filtrar Denúncias',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSizes.spacing12),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing32,
              ),
              child: Text(
                'Escolha os filtros que deseja aplicar',
                style: AppTextStyles.body.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSizes.spacing32),

            // Scrollable content (Dropdowns)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoria Dropdown
                    const Text(
                      'Categoria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navbarText,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    DropdownButtonFormField<int?>(
                      value: _selectedCategoriaId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF232229),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF232229),
                      style: const TextStyle(color: AppColors.white),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas as Categorias'),
                        ),
                        ...widget.categorias.map((cat) {
                          return DropdownMenuItem<int?>(
                            value: cat.id,
                            child: Text(cat.nome),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoriaId = value);
                      },
                    ),

                    const SizedBox(height: AppSizes.spacing24),

                    // Status Dropdown
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navbarText,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    DropdownButtonFormField<String?>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF232229),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF232229),
                      style: const TextStyle(color: AppColors.white),
                      items: _statusOptions.map((option) {
                        return DropdownMenuItem<String?>(
                          value: option['value'],
                          child: Text(option['label']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStatus = value);
                      },
                    ),

                    const SizedBox(height: AppSizes.spacing24),

                    // Período Dropdown
                    const Text(
                      'Período',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navbarText,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    DropdownButtonFormField<int?>(
                      value: _selectedDays,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF232229),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF232229),
                      style: const TextStyle(color: AppColors.white),
                      items: _timeOptions.map((option) {
                        return DropdownMenuItem<int?>(
                          value: option['value'],
                          child: Text(option['label']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDays = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Actions at bottom
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spacing24,
                AppSizes.spacing16,
                AppSizes.spacing24,
                AppSizes.spacing24 + MediaQuery.of(context).viewPadding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Aplicar Filtros',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primaryRed,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Limpar Filtros',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
