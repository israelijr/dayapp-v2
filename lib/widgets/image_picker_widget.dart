import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';
import '../theme/m3_expressive_theme.dart';

/// Widget de seleção de imagem que oferece opção de tirar foto ou buscar na galeria.
/// Suporta seleção múltipla de imagens da galeria.
/// Segue o mesmo padrão de UX do AudioRecorderWidget e VideoRecorderWidget.
class ImagePickerWidget extends StatefulWidget {
  /// Callback para quando uma única imagem é selecionada (compatibilidade)
  final Function(Uint8List image)? onImagePicked;

  /// Callback para quando múltiplas imagens são selecionadas
  final Function(List<Uint8List> images)? onMultipleImagesPicked;

  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;

  /// Se true, permite seleção múltipla na galeria
  final bool allowMultiple;

  const ImagePickerWidget({
    this.onImagePicked,
    this.onMultipleImagesPicked,
    super.key,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
    this.allowMultiple = true,
  }) : assert(
         onImagePicked != null || onMultipleImagesPicked != null,
         'Deve fornecer onImagePicked ou onMultipleImagesPicked',
       );

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera, size: 64, color: AppColors.primaryVariant),
            const SizedBox(height: 16),
            Text(
              widget.allowMultiple
                  ? AppLocalizations.of(context)!.imagePickerTitleMultiple
                  : AppLocalizations.of(context)!.imagePickerTitleSingle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.labelColor(context),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              Text(
                widget.allowMultiple
                    ? AppLocalizations.of(
                        context,
                      )!.imagePickerChooseOptionMultiple
                    : AppLocalizations.of(
                        context,
                      )!.imagePickerChooseOptionSingle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.labelColor(context),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.allowMultiple
                    ? _pickMultipleFromGallery
                    : _pickFromGallery,
                icon: Icon(
                  widget.allowMultiple ? Icons.photo_library : Icons.photo,
                ),
                label: Text(
                  widget.allowMultiple
                      ? AppLocalizations.of(context)!.imagePickerGalleryMultiple
                      : AppLocalizations.of(context)!.imagePickerGallerySingle,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryVariant,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(AppLocalizations.of(context)!.imagePickerTakePhoto),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  /// Seleciona múltiplas imagens da galeria
  Future<void> _pickMultipleFromGallery() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (pickedFiles.isEmpty) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }
      setState(() => _isLoading = true);

      final List<Uint8List> imageBytes = [];
      for (final xFile in pickedFiles) {
        final bytes = await xFile.readAsBytes();
        imageBytes.add(bytes);
      }

      // Usa callback de múltiplas imagens se disponível, senão chama o de única para cada
      if (widget.onMultipleImagesPicked != null) {
        widget.onMultipleImagesPicked!(imageBytes);
      } else if (widget.onImagePicked != null) {
        for (final bytes in imageBytes) {
          widget.onImagePicked!(bytes);
        }
      }

      // Reseta a flag após processar as imagens
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();

      // Mensagem de sucesso
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imageBytes.length == 1
                ? loc.successImageAdded
                : loc.successImagesAdded(imageBytes.length),
          ),
        ),
      );
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      setState(() => _isLoading = false);
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.errorSelectImages(e.toString()))),
      );
    }
  }

  /// Seleciona uma imagem da galeria (modo único)
  Future<void> _pickFromGallery() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (picked == null) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final bytes = await picked.readAsBytes();

      if (widget.onImagePicked != null) {
        widget.onImagePicked!(bytes);
      } else if (widget.onMultipleImagesPicked != null) {
        widget.onMultipleImagesPicked!([bytes]);
      }

      // Reseta a flag após processar a imagem
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.errorSelectImages(e.toString()))),
      );
    }
  }

  /// Tira uma foto usando a câmera
  Future<void> _takePhoto() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      // Se o usuário cancelou, reseta a flag e retorna
      if (photo == null) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final bytes = await photo.readAsBytes();

      if (widget.onImagePicked != null) {
        widget.onImagePicked!(bytes);
      } else if (widget.onMultipleImagesPicked != null) {
        widget.onMultipleImagesPicked!([bytes]);
      }

      // Reseta a flag após processar a foto
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();

      // Mensagem de sucesso
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.successPhotoCaptured)));
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      // Permissão negada: apenas fecha o dialog sem exibir mensagem de erro
      if (e is PlatformException &&
          (e.code == 'camera_access_denied' ||
              e.code == 'photo_access_denied')) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.errorTakePhoto(e.toString()))));
    }
  }
}
