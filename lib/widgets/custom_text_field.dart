import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
  final bool showBorder;
  final bool filled;

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
    this.showBorder = true,
    this.filled = true,
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
          filled: filled,
          fillColor: isDark
              ? colorScheme.surfaceContainerHighest
              : Colors.white,
          contentPadding: contentPadding,
          border: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ) : InputBorder.none,
          enabledBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ) : InputBorder.none,
          focusedBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ) : InputBorder.none,
        ),
      ),
    );
  }
}
