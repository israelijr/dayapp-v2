import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../widgets/custom_text_field.dart';

class SetupPinScreen extends StatefulWidget {
  final bool isChanging;

  const SetupPinScreen({super.key, this.isChanging = false});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );

    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isChanging
                ? localizations.changePin
                : localizations.configurePin,
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme
                  .colorScheme
                  .onPrimaryContainer, // Ajustado para contraste padrão de AppBar
            ),
          ),
        ), // <- Corrigido o fechamento do AppBar
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.security,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isChanging
                      ? localizations.changePin
                      : localizations.configurePin,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.pinLengthError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.7 * 255).round(),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (widget.isChanging) ...[
                  CustomTextField(
                    controller: _currentPinController,
                    label: localizations.currentPinLabel,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureCurrentPin,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPin
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscureCurrentPin = !_obscureCurrentPin,
                      ),
                    ),
                    maxLength: 8,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _newPinController,
                  label: widget.isChanging
                      ? localizations.newPinLabel
                      : localizations.pinLabel,
                  keyboardType: TextInputType.number,
                  obscureText: _obscureNewPin,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPin ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNewPin = !_obscureNewPin),
                  ),
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPinController,
                  label: localizations.confirmPin,
                  keyboardType: TextInputType.number,
                  obscureText: _obscureConfirmPin,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPin
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPin = !_obscureConfirmPin,
                    ),
                  ),
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _setupPin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isChanging
                              ? localizations.changePin
                              : localizations.configurePin,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setupPin() async {
    // Captura o localizations antes do contexto se tornar inválido/assíncrono
    final localizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    setState(() {
      _errorMessage = null;
    });

    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (widget.isChanging && currentPin.isEmpty) {
      setState(() => _errorMessage = localizations.enterCurrentPin);
      return;
    }

    if (newPin.isEmpty) {
      setState(() => _errorMessage = localizations.enterPin);
      return;
    }

    if (newPin.length < 4 || newPin.length > 8) {
      setState(() => _errorMessage = localizations.pinLengthError);
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorMessage = localizations.pinsDoNotMatch);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pinProvider = Provider.of<PinProvider>(context, listen: false);
      bool success;

      if (widget.isChanging) {
        success = await pinProvider.changePin(currentPin, newPin);
        if (!success) {
          if (!mounted) return;
          setState(() => _errorMessage = localizations.pinIncorrect);
          return;
        }
      } else {
        success = await pinProvider.enablePin(newPin);
      }

      if (!mounted) return;

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.isChanging
                  ? localizations.pinChangedSuccess
                  : localizations.pinConfiguredSuccess,
            ),
            backgroundColor: theme
                .colorScheme
                .primary, // Substituído para evitar erro de compilação
          ),
        );
        navigator.pop(true);
      } else {
        setState(() => _errorMessage = localizations.tryAgain);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizations.tryAgain);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
