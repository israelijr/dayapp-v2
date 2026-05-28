import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../theme/m3_expressive_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isChanging
              ? AppLocalizations.of(context)!.changePin
              : AppLocalizations.of(context)!.configurePin,
        ),
      ),
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
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isChanging
                    ? AppLocalizations.of(context)!.changePin
                    : AppLocalizations.of(context)!.configurePin,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pinLengthError,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7 * 255),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (widget.isChanging) ...[
                CustomTextField(
                  controller: _currentPinController,
                  label: AppLocalizations.of(context)!.currentPinLabel,
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
                    ? AppLocalizations.of(context)!.newPinLabel
                    : AppLocalizations.of(context)!.pinLabel,
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
                label: AppLocalizations.of(context)!.confirmPin,
                keyboardType: TextInputType.number,
                obscureText: _obscureConfirmPin,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPin
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                ),
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
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
                            ? AppLocalizations.of(context)!.changePin
                            : AppLocalizations.of(context)!.configurePin,
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _setupPin() async {
    setState(() {
      _errorMessage = null;
    });

    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    // Validações
    if (widget.isChanging && currentPin.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterCurrentPin;
      });
      return;
    }

    if (newPin.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterPin;
      });
      return;
    }

    if (newPin.length < 4 || newPin.length > 8) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pinLengthError;
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pinsDoNotMatch;
      });
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
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.pinIncorrect;
          });
          return;
        }
      } else {
        success = await pinProvider.enablePin(newPin);
      }

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isChanging
                  ? AppLocalizations.of(context)!.pinChangedSuccess
                  : AppLocalizations.of(context)!.pinConfiguredSuccess,
            ),
            backgroundColor: AppColors.emoticonGreen,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.tryAgain;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.tryAgain;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
