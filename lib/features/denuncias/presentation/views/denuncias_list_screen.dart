import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../autenticacao/presentation/notifiers/auth_notifier.dart';
import '../notifiers/denuncias_notifier.dart';
import '../widgets/denuncia_card.dart';
import 'denuncia_detail_screen.dart';

class DenunciasListScreen extends ConsumerStatefulWidget {
  const DenunciasListScreen({super.key});

  @override
  ConsumerState<DenunciasListScreen> createState() =>
      _DenunciasListScreenState();
}

class _DenunciasListScreenState extends ConsumerState<DenunciasListScreen> {
  String? _selectedFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  final List<Map<String, String?>> _filters = [
    {'label': 'Todas', 'value': null},
    {'label': 'Aberta', 'value': 'ABERTA'},
    {'label': 'Em Análise', 'value': 'EM_ANALISE'},
    {'label': 'Resolvida', 'value': 'RESOLVIDA'},
    {'label': 'Rejeitada', 'value': 'REJEITADA'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Listener para debounce na busca
    _searchController.addListener(_onSearchChanged);
    
    // Carrega denúncias ao abrir a tela (apenas para usuários autenticados)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      
      // Só carrega se estiver autenticado (não guest)
      if (authState.isLoggedIn && !authState.isGuest) {
        ref.read(denunciasNotifierProvider.notifier).loadDenuncias();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancela timer anterior se existir
    _debounceTimer?.cancel();
    
    // Cria novo timer de 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Carrega mais quando chegar perto do fim
      ref.read(denunciasNotifierProvider.notifier).loadMore();
    }
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
              final isSelected = _selectedFilter == filter['value'];
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.primaryRed
                      : AppColors.navbarText,
                ),
                title: Text(
                  filter['label']!,
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
                  setState(() => _selectedFilter = filter['value']);
                  Navigator.pop(context);
                  ref
                      .read(denunciasNotifierProvider.notifier)
                      .updateFilters(status: filter['value']);
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
    final denunciasState = ref.watch(denunciasNotifierProvider);

    // Filtra localmente apenas por busca de texto
    var filteredDenuncias = denunciasState.denuncias;
    
    // Filtro de busca textual
    if (_searchQuery.isNotEmpty) {
      filteredDenuncias = filteredDenuncias.where((d) {
        return d.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.descricao.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (d.categoriaNome?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (d.endereco?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Green header section (like Home)
                Container(
                  color: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.black,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        filteredDenuncias.isEmpty
                            ? 'Minhas Denúncias'
                            : 'Minhas Denúncias (${filteredDenuncias.length})',
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Space for the overlapping search bar

                // Dark content area with rounded top corners
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: _buildContent(denunciasState, filteredDenuncias),
                  ),
                ),
              ],
            ),

            // Overlapping search bar + filter (positioned exactly like Home)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                        // onChanged removido - usando listener com debounce
                        style: const TextStyle(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar denúncias...',
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
                  
                  // Filter button with green border
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF232229),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(
                        color: AppColors.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.filter_list,
                          color: AppColors.primaryRed,
                          size: AppSizes.iconSizeButton,
                        ),
                        onPressed: _showFilterBottomSheet,
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

  Widget _buildContent(DenunciasState state, List<dynamic> filteredDenuncias) {
    // Verificar se é usuário guest
    final authState = ref.watch(authNotifierProvider);
    
    if (authState.isGuest || !authState.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.login,
                size: 80,
                color: AppColors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Faça login para ver suas denúncias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navbarText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Você precisa estar autenticado para acessar esta seção',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.login),
                label: const Text(
                  'Fazer Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Loading inicial
    if (state.isLoading && state.denuncias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Erro
    if (state.error != null && state.denuncias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar denúncias',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.navbarText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(denunciasNotifierProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Vazio
    if (filteredDenuncias.isEmpty) {
      return _buildEmptyState();
    }

    // Lista com dados
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(denunciasNotifierProvider.notifier).refresh();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacing16,
          60,
          AppSizes.spacing16,
          AppSizes.spacing16,
        ),
        itemCount: filteredDenuncias.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacing16),
        itemBuilder: (context, index) {
          // Loading indicator no final
          if (index == filteredDenuncias.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }

          final denuncia = filteredDenuncias[index];
          return DenunciaCard(
            denuncia: denuncia,
            onTap: () {
              context.push('/denuncia/${denuncia.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasFilter = _selectedFilter != null;

    IconData icon;
    String message;

    if (hasSearch) {
      icon = Icons.search_off;
      message = 'Nenhuma denúncia encontrada\npara "$_searchQuery"';
    } else if (hasFilter) {
      final filterLabel = _filters.firstWhere(
        (f) => f['value'] == _selectedFilter,
        orElse: () => {'label': 'selecionado'},
      )['label'];
      icon = Icons.filter_list_off;
      message = 'Nenhuma denúncia com status\n"$filterLabel"';
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
                  borderRadius: BorderRadius.circular(30),
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
