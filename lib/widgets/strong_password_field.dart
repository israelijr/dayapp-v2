import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'custom_text_field.dart';

class StrongPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Widget? prefixIcon;
  final ValueChanged<bool>? onValidChanged;
  final TextInputAction? textInputAction;
  final Color? textColor;
  final Color? successColor;

  const StrongPasswordField({
    required this.controller,
    required this.label,
    super.key,
    this.helperText,
    this.prefixIcon,
    this.onValidChanged,
    this.textInputAction,
    this.textColor,
    this.successColor,
  });

  @override
  State<StrongPasswordField> createState() => _StrongPasswordFieldState();
}

class _StrongPasswordFieldState extends State<StrongPasswordField> {
  bool _obscureText = true;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validatePassword);
    _validatePassword();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    final text = widget.controller.text;

    final hasMinLength = text.length >= 8;
    final hasUppercase = text.contains(RegExp(r'[A-Z]'));
    final hasLowercase = text.contains(RegExp(r'[a-z]'));
    final hasNumber = text.contains(RegExp(r'[0-9]'));
    final hasSpecial = text.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=\[\]\/\\]'),
    );

    if (_hasMinLength != hasMinLength ||
        _hasUppercase != hasUppercase ||
        _hasLowercase != hasLowercase ||
        _hasNumber != hasNumber ||
        _hasSpecial != hasSpecial) {
      setState(() {
        _hasMinLength = hasMinLength;
        _hasUppercase = hasUppercase;
        _hasLowercase = hasLowercase;
        _hasNumber = hasNumber;
        _hasSpecial = hasSpecial;
      });

      if (widget.onValidChanged != null) {
        final isValid =
            hasMinLength &&
            hasUppercase &&
            hasLowercase &&
            hasNumber &&
            hasSpecial;
        widget.onValidChanged!(isValid);
      }
    }
  }

  Widget _buildCriterion(String text, bool isMet) {
    final inactiveColor = Colors.grey.shade800;
    final activeColor = Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? activeColor : inactiveColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isMet ? activeColor : inactiveColor,
                fontWeight: isMet ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: widget.controller,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          label: widget.label,
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCriterion(loc.pwdCriteriaMinLength, _hasMinLength),
              _buildCriterion(loc.pwdCriteriaUppercase, _hasUppercase),
              _buildCriterion(loc.pwdCriteriaLowercase, _hasLowercase),
              _buildCriterion(loc.pwdCriteriaNumber, _hasNumber),
              _buildCriterion(loc.pwdCriteriaSpecial, _hasSpecial),
            ],
          ),
        ),
      ],
    );
  }
}
