import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/m3_expressive_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;
  final Widget? prefixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final String? hintText;
  final TextStyle? style;
  final int? minLines;
  final int? maxLines;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final String? suffixText;
  final String? helperText;
  final TextStyle? helperStyle;

  const CustomTextField({
    required this.label,
    required this.controller,
    super.key,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
    this.prefixIcon,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.hintText,
    this.style,
    this.minLines,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.suffixText,
    this.helperText,
    this.helperStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveMinLines = obscureText ? 1 : minLines;
    final effectiveMaxLines = obscureText ? 1 : maxLines;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLength: maxLength,
        selectAllOnFocus: false,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: style ?? TextStyle(color: colorScheme.onSurface),
        // Quando o campo é do tipo obscuro (senha), o TextField exige
        // que seja single-line. Forçamos min/max para 1 nessa situação
        // para evitar a asserção interna do Flutter.
        minLines: effectiveMinLines,
        maxLines: effectiveMaxLines,
        textAlign: textAlign,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          hintText: hintText,
          helperText: helperText,
          helperStyle: helperStyle,
          helperMaxLines: 3,
          prefixIcon: prefixIcon,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          contentPadding: contentPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryVariant, width: 2),
          ),
        ),
      ),
    );
  }
}
