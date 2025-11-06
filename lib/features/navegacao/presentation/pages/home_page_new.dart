import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Nova Home Page inspirada no design do Reclame Aqui
class HomePageNew extends ConsumerStatefulWidget {
  const HomePageNew({super.key});

  @override
  ConsumerState<HomePageNew> createState() => _HomePageNewState();
}

class _HomePageNewState extends ConsumerState<HomePageNew> {
  final _searchController = TextEditingController();
  int _currentBannerIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        child: Column(
          children: [
            // Header com logo e perfil
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Voz do Povo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  // Ícone de perfil
                  CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: AppColors.primaryRed,
                      ),
                      onPressed: () => context.go('/perfil'),
                    ),
                  ),
                ],
              ),
            ),

            // Barra de busca
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Busque por cidades',
                    hintStyle: TextStyle(
                      color: AppColors.grey.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing16),

            // Conteúdo scrollável
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.spacing20),
                  child: Column(
                    children: [
                      // 4 Categorias
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCategoryItem(
                            icon: Icons.star,
                            label: 'Populares',
                            color: const Color(0xFFB4D96C),
                            onTap: () {},
                          ),
                          _buildCategoryItem(
                            icon: Icons.location_city,
                            label: 'Cidades',
                            color: const Color(0xFFB4D96C),
                            onTap: () {},
                          ),
                          _buildCategoryItem(
                            icon: Icons.article,
                            label: 'Categorias',
                            color: const Color(0xFFB4D96C),
                            onTap: () {},
                          ),
                          _buildCategoryItem(
                            icon: Icons.help_outline,
                            label: 'Ajuda',
                            color: const Color(0xFFB4D96C),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacing24),

                      // Banner grande com PageView
                      SizedBox(
                        height: 180,
                        child: PageView(
                          onPageChanged: (index) {
                            setState(() => _currentBannerIndex = index);
                          },
                          children: [
                            _buildBanner(
                              title: 'Minhas\nDenúncias',
                              color: const Color(0xFFFDB94E),
                              imagePath: 'assets/images/megaphone.png',
                              onTap: () => context.go('/denuncias'),
                            ),
                            _buildBanner(
                              title: 'Faça sua\nDenúncia',
                              color: AppColors.primaryRed,
                              icon: Icons.campaign,
                              onTap: () => context.go('/create-denuncia'),
                            ),
                            _buildBanner(
                              title: 'Ver todas\nDenúncias',
                              color: const Color(0xFF4CAF50),
                              icon: Icons.visibility,
                              onTap: () => context.go('/map'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing12),

                      // Indicador de páginas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index
                                  ? AppColors.primaryRed
                                  : AppColors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing24),

                      // Cards adicionais (2x2 grid)
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallCard(
                              title: 'Cadastre sua\nempresa',
                              icon: Icons.business,
                              color: const Color(0xFFB4D96C),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing12),
                          Expanded(
                            child: _buildSmallCard(
                              title: 'Detector de\nsite confiável',
                              icon: Icons.security,
                              color: AppColors.grey,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppColors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required String title,
    required Color color,
    IconData? icon,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(AppSizes.spacing20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  height: 1.2,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, size: 80, color: AppColors.black.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: AppColors.black),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
