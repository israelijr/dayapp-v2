import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final String? localImagePath;
  final String? networkImageUrl;
  final VoidCallback onPickImage;

  const ProfileAvatarPicker({
    required this.onPickImage,
    super.key,
    this.localImagePath,
    this.networkImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageContent = localImagePath != null
        ? ClipOval(
            child: SizedBox(
              width: 120,
              height: 120,
              child: kIsWeb
                  ? Image.network(
                      localImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(colorScheme),
                    )
                  : Image.file(
                      File(localImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(colorScheme),
                    ),
            ),
          )
        : networkImageUrl != null
        ? ClipOval(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                networkImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(colorScheme),
              ),
            ),
          )
        : _buildPlaceholder(colorScheme);

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          imageContent,
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary,
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: colorScheme.onPrimary,
                  size: 16,
                ),
                onPressed: onPickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant),
    );
  }
}
