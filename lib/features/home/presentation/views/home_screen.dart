import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../denuncias/presentation/providers/denuncias_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapPage(),
    const DenunciasListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Denúncias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-denuncia'),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Página temporária do Mapa
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Mapa',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: AppColors.grey),
            const SizedBox(height: AppSizes.spacing16),
            Text('Mapa em desenvolvimento', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

// Página de Lista de Denúncias
class DenunciasListPage extends ConsumerWidget {
  const DenunciasListPage({super.key});

  // Ícone para cada categoria
  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Infraestrutura':
        return Icons.construction;
      case 'Saúde':
        return Icons.local_hospital;
      case 'Educação':
        return Icons.school;
      case 'Segurança':
        return Icons.security;
      case 'Meio Ambiente':
        return Icons.nature;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Iluminação':
        return Icons.lightbulb;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denuncias = ref.watch(denunciasProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Denúncias',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: denuncias.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 80,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: AppSizes.spacing16),
                  Text(
                    'Nenhuma denúncia criada',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    'Toque no botão + para criar',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              itemCount: denuncias.length,
              itemBuilder: (context, index) {
                final denuncia = denuncias[denuncias.length - 1 - index];
                return _buildDenunciaCard(denuncia);
              },
            ),
    );
  }

  Widget _buildDenunciaCard(DenunciaModel denuncia) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: AppColors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoria badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borderRadius),
                topRight: Radius.circular(AppSizes.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(denuncia.categoria),
                  color: AppColors.white,
                  size: 16,
                ),
                const SizedBox(width: AppSizes.spacing8),
                Text(
                  denuncia.categoria,
                  style: AppTextStyles.label.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  denuncia.titulo,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSizes.spacing12),

                // Descrição
                Text(
                  denuncia.descricao,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacing16),

                // Localização
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    Expanded(
                      child: Text(
                        denuncia.endereco,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Fotos
                if (denuncia.fotos.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacing16),
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16, color: AppColors.grey),
                      const SizedBox(width: AppSizes.spacing8),
                      Text(
                        '${denuncia.fotos.length} foto(s)',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSizes.spacing16),

                // Status e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Text(
                            denuncia.status,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(denuncia.dataCriacao),
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }
}

// Página temporária de Perfil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Perfil',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: AppColors.grey),
            const SizedBox(height: AppSizes.spacing16),
            Text('Perfil em desenvolvimento', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}
