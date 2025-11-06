import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/denuncias_provider.dart';
import '../widgets/denuncia_card.dart';

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
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Título
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.black),
                  SizedBox(width: 12),
                  Text(
                    'Filtrar por Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Lista de filtros
            ...List.generate(_filters.length, (index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primaryRed : AppColors.grey,
                ),
                title: Text(
                  filter,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? AppColors.primaryRed : AppColors.black,
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

    // Filtrar por status
    var filteredDenuncias = _selectedFilter == 'Todas'
        ? denuncias
        : denuncias.where((d) => d.status == _selectedFilter).toList();

    // Filtrar por pesquisa
    if (_searchQuery.isNotEmpty) {
      filteredDenuncias = filteredDenuncias.where((d) {
        return d.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.descricao.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.categoria.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.endereco.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Minhas Denúncias',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
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
          // Barra de Pesquisa + Filtro
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Row(
              children: [
                // Barra de Pesquisa
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeight,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar denúncias...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.greyLight,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.black,
                          size: AppSizes.iconSize,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.black,
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
                          borderSide: const BorderSide(color: AppColors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          borderSide: const BorderSide(color: AppColors.black),
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
                // Botão de Filtro
                Container(
                  height: AppSizes.buttonHeight,
                  width: AppSizes.buttonHeight,
                  decoration: BoxDecoration(
                    color: _selectedFilter != 'Todas'
                        ? AppColors.primaryRed
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    border: Border.all(
                      color: _selectedFilter != 'Todas'
                          ? AppColors.primaryRed
                          : AppColors.black,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _selectedFilter != 'Todas'
                              ? AppColors.white
                              : AppColors.black,
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

          // Divider
          const Divider(height: 1, color: AppColors.greyLight),

          // Lista de denúncias
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
                          // TODO: Navegar para detalhes da denúncia
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Detalhes: ${denuncia.titulo}'),
                              backgroundColor: AppColors.primaryRed,
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
    // Mensagem diferente se houver busca ativa
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
          Icon(icon, size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.grey,
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
