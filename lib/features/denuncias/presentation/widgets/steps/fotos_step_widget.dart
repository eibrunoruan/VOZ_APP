import 'dart:io';
import 'package:flutter/material.dart';
import '../foto_picker_widget.dart';

/// Widget for step 5: Photo selection
class FotosStepWidget extends StatelessWidget {
  final File? selectedFoto;
  final ValueChanged<File?> onFotoSelected;

  const FotosStepWidget({
    super.key,
    required this.selectedFoto,
    required this.onFotoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FotoPickerWidget(
      selectedFoto: selectedFoto,
      onFotoSelected: onFotoSelected,
    );
  }
}
