import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final String? fotoPerfil;
  final double radius;
  final VoidCallback? onTap;

  const UserProfileAvatar({
    super.key,
    this.fotoPerfil,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: _buildImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    const placeholder = AssetImage('assets/image/icon.png');

    if (fotoPerfil == null || fotoPerfil!.isEmpty) {
      return const Image(image: placeholder, fit: BoxFit.cover);
    }

    if (fotoPerfil!.startsWith('http') || kIsWeb) {
      return Image.network(
        fotoPerfil!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Image(image: placeholder, fit: BoxFit.cover);
        },
      );
    }

    return Image.file(
      File(fotoPerfil!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return const Image(image: placeholder, fit: BoxFit.cover);
      },
    );
  }
}
