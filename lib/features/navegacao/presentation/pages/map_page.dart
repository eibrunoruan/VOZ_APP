import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/data/models/categoria_model.dart';
import '../../../denuncias/data/models/denuncia_model.dart';
import '../../../denuncias/data/repositories/denuncias_repository.dart';
import '../../../denuncias/presentation/notifiers/denuncias_notifier.dart';
import '../widgets/map_denuncias_list.dart';
import '../widgets/map_filter_modal.dart';
import '../widgets/map_section.dart';

class MapPage extends ConsumerStatefulWidget {
  final double? searchLat;
  final double? searchLng;
  final String? searchCity;

  const MapPage({super.key, this.searchLat, this.searchLng, this.searchCity});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;
  MapFilterResult? _currentFilters;
  List<CategoriaModel> _categorias = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategorias();
      ref.read(denunciasNotifierProvider.notifier).loadAllDenuncias();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text);
      }
    });
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await ref
          .read(denunciasRepositoryProvider)
          .getCategorias();
      if (mounted) {
        setState(() => _categorias = categorias);
      }
    } catch (e) {
      // Erro ao carregar categorias
    }
  }

  Future<void> _showFilters() async {
    final result = await MapFilterModal.show(
      context: context,
      categorias: _categorias,
      currentFilters: _currentFilters,
    );

    if (result != null && mounted) {
      setState(() => _currentFilters = result);
      _applyFilters();
    }
  }

  void _applyFilters() {
    ref
        .read(denunciasNotifierProvider.notifier)
        .loadAllDenuncias(
          status: _currentFilters?.status,
          categoria: _currentFilters?.categoriaId,
        );
  }

  List<DenunciaModel> _getFilteredDenuncias(List<DenunciaModel> denuncias) {
    var filtered = denuncias;

    // Filtro de busca textual (endereço apenas)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        final searchLower = _searchQuery.toLowerCase();
        return (d.endereco?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Filtro de tempo (últimos X dias)
    if (_currentFilters?.days != null) {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: _currentFilters!.days!));
      filtered = filtered.where((d) {
        return d.dataCriacao.isAfter(cutoffDate);
      }).toList();
    }

    return filtered;
  }

  void _handleMarkerTap(DenunciaModel denuncia) {
    context.push('/denuncia/${denuncia.id}');
  }

  @override
  Widget build(BuildContext context) {
    final denunciasState = ref.watch(denunciasNotifierProvider);
    final filteredDenuncias = _getFilteredDenuncias(denunciasState.denuncias);
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.40;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: mapHeight,
              child: MapSection(
                denuncias: filteredDenuncias,
                initialLat: widget.searchLat,
                initialLng: widget.searchLng,
                onMarkerTap: _handleMarkerTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF232229),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.primaryRed,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        style: const TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por cidade...',
                          hintStyle: const TextStyle(
                            color: AppColors.navbarText,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.navbarText,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.navbarText,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF232229),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      border: Border.all(
                        color: AppColors.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.filter_list,
                          color: AppColors.primaryRed,
                          size: 24,
                        ),
                        onPressed: _showFilters,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: MapDenunciasList(
                  denuncias: filteredDenuncias,
                  isLoading: denunciasState.isLoading,
                  onRefresh: () {
                    ref
                        .read(denunciasNotifierProvider.notifier)
                        .loadAllDenuncias(
                          status: _currentFilters?.status,
                          categoria: _currentFilters?.categoriaId,
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
