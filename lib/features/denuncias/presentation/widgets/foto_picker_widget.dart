import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget para seleção de fotos
class FotoPickerWidget extends StatefulWidget {
  final File? selectedFoto;
  final Function(File?) onFotoSelected;

  const FotoPickerWidget({
    super.key,
    required this.selectedFoto,
    required this.onFotoSelected,
  });

  @override
  State<FotoPickerWidget> createState() => _FotoPickerWidgetState();
}

class _FotoPickerWidgetState extends State<FotoPickerWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onFotoSelected(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed),
                title: const Text(
                  'Câmera',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryRed),
                title: const Text(
                  'Galeria',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione uma foto (opcional)',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.navbarText,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Uma imagem ajuda a entender melhor o problema',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.navbarText),
        ),
        const SizedBox(height: AppSizes.spacing32),
        if (widget.selectedFoto != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: Image.file(
                  widget.selectedFoto!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => widget.onFotoSelected(null),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          OutlinedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.edit),
            label: const Text('Trocar Foto'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: const BorderSide(color: AppColors.primaryRed),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Adicionar Foto'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: const BorderSide(color: AppColors.primaryRed),
              minimumSize: const Size(double.infinity, 120),
            ),
          ),
        ],
      ],
    );
  }
}
