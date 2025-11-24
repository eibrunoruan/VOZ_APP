import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/cidades_sc_provider.dart';

class HomePageNew extends ConsumerStatefulWidget {
  const HomePageNew({super.key});

  @override
  ConsumerState<HomePageNew> createState() => _HomePageNewState();
}

class _HomePageNewState extends ConsumerState<HomePageNew> {
  int _currentBannerIndex = 0;

  void _searchCity(CidadeSC cidade) {

    context.go(
      '/map?lat=${cidade.coordenadas.latitude}&lng=${cidade.coordenadas.longitude}&city=${cidade.nome}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      resizeToAvoidBottomInset: false, // Evita que o layout suba com o teclado
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [

                Container(
                  color: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                    vertical: 50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Image.asset(
                        'assets/images/logo-voz-do-povo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.account_circle,
                          color: AppColors.background,
                          size: 40,
                        ),
                        onPressed: () => context.go('/perfil'),
                      ),
                    ],
                  ),
                ),

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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.spacing20,
                        60,
                        AppSizes.spacing20,
                        AppSizes.spacing20,
                      ),
                      child: Column(
                        children: [

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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top:
                  165, // Posicionada para ficar metade no vermelho, metade no escuro
              left: 16,
              right: 16,
              child: Autocomplete<CidadeSC>(
                displayStringForOption: (CidadeSC cidade) => cidade.nome,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<CidadeSC>.empty();
                  }
                  final cidades = ref.read(cidadesSCProvider);
                  return cidades.where((CidadeSC cidade) {
                    return cidade.nome.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (CidadeSC cidade) {
                  _searchCity(cidade);
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      return Container(
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
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                            hintText: 'Busque por cidades de SC',
                            hintStyle: TextStyle(
                              color: AppColors.navbarText,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.navbarText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),
                      );
                    },
                optionsViewBuilder:
                    (
                      BuildContext context,
                      AutocompleteOnSelected<CidadeSC> onSelected,
                      Iterable<CidadeSC> options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 32,
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryRed,
                                  width: 1.5,
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final CidadeSC cidade = options.elementAt(
                                    index,
                                  );
                                  return InkWell(
                                    onTap: () => onSelected(cidade),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.primaryRed
                                                .withOpacity(0.3),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_city,
                                            size: 20,
                                            color: AppColors.primaryRed,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            cidade.nome,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: AppColors.navbarText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
              color: AppColors.white,
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
}
