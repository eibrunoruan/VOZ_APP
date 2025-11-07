import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/denuncias_provider.dart';
import '../widgets/denuncia_card.dart';
import 'denuncia_detail_screen.dart';

class DenunciasListScreen extends ConsumerStatefulWidget {
  const DenunciasListScreen({super.key});

  @override
  ConsumerState<DenunciasListScreen> createState() =>
      _DenunciasListScreenState();
}

class _DenunciasListScreenState extends ConsumerState<DenunciasListScreen> {
  String _selectedFilter = 'Todas';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    'Todas',
    'Aguardando Análise',
    'Em Análise',
    'Resolvida',
    'Rejeitada',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.primaryRed),
                  SizedBox(width: 12),
                  Text(
                    'Filtrar por Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navbarText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ...List.generate(_filters.length, (index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.primaryRed
                      : AppColors.navbarText,
                ),
                title: Text(
                  filter,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.navbarText,
                  ),
                ),
                onTap: () {
                  setState(() => _selectedFilter = filter);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final denuncias = ref.watch(denunciasProvider);

    var filteredDenuncias = _selectedFilter == 'Todas'
        ? denuncias
        : denuncias.where((d) => d.status == _selectedFilter).toList();

    if (_searchQuery.isNotEmpty) {
      filteredDenuncias = filteredDenuncias.where((d) {
        return d.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.descricao.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.categoria.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.endereco.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Minhas Denúncias',
          style: TextStyle(
            color: AppColors.navbarText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navbarText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Column(
        children: [

          Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Row(
              children: [

                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeight,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar denúncias...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryRed,
                          size: AppSizes.iconSize,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.navbarText,
                                  size: AppSizes.iconSize,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.inputPaddingHorizontal,
                          vertical: AppSizes.inputPaddingVertical,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing12),

                Container(
                  height: AppSizes.buttonHeight,
                  width: AppSizes.buttonHeight,
                  decoration: BoxDecoration(
                    color: _selectedFilter != 'Todas'
                        ? AppColors.primaryRed
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    border: Border.all(color: AppColors.primaryRed, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _selectedFilter != 'Todas'
                              ? AppColors.white
                              : AppColors.primaryRed,
                          size: AppSizes.iconSizeButton,
                        ),
                        onPressed: _showFilterBottomSheet,
                      ),
                      if (_selectedFilter != 'Todas')
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredDenuncias.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    itemCount: filteredDenuncias.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.spacing16),
                    itemBuilder: (context, index) {
                      final denuncia = filteredDenuncias[index];
                      return DenunciaCard(
                        denuncia: denuncia,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DenunciaDetailScreen(denuncia: denuncia),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {

    final hasSearch = _searchQuery.isNotEmpty;
    final hasFilter = _selectedFilter != 'Todas';

    IconData icon;
    String message;

    if (hasSearch) {
      icon = Icons.search_off;
      message = 'Nenhuma denúncia encontrada\npara "$_searchQuery"';
    } else if (hasFilter) {
      icon = Icons.filter_list_off;
      message = 'Nenhuma denúncia com status\n"$_selectedFilter"';
    } else {
      icon = Icons.inbox_outlined;
      message = 'Nenhuma denúncia cadastrada';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.navbarText),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.navbarText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasSearch && !hasFilter)
            ElevatedButton.icon(
              onPressed: () => context.push('/create-denuncia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Criar primeira denúncia'),
            ),
        ],
      ),
    );
  }
}
