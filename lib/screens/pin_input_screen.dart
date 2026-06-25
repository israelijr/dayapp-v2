import 'dart:ui';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';

class PinInputScreen extends StatefulWidget {
  const PinInputScreen({super.key});

  @override
  State<PinInputScreen> createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen>
    with TickerProviderStateMixin {
  final List<String> _digits = ['', '', '', '', '', '', '', ''];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isPinVisible = false;
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    // Garante que o teclado do sistema seja ocultado
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    final double buttonSize = isSmallScreen ? 68 : 80;
    final double keyboardSpacing = isSmallScreen ? 10 : 16;
    final double generalSpacing = isSmallScreen ? 12 : 24;
    final double sectionSpacing = isSmallScreen ? 16 : 32;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Impede que a tela redimensione quando o teclado aparecer
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        Text(
                          'Digite seu PIN',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 24 : null,
                              ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),

                        Text(
                          'Para acessar o DayApp',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: isSmallScreen ? 14 : null,
                              ),
                        ),

                        SizedBox(height: sectionSpacing),

                        // Círculos do PIN com botão de revelar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    _shakeAnimation.value *
                                        10 *
                                        (1 - _shakeAnimation.value) *
                                        2,
                                    0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(8, (index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _digits[index].isNotEmpty
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .outline
                                                    .withValues(
                                                      alpha: 0.3 * 255,
                                                    ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.5 * 255),
                                            width: 1,
                                          ),
                                        ),
                                        child:
                                            _isPinVisible &&
                                                _digits[index].isNotEmpty
                                            ? Center(
                                                child: Text(
                                                  _digits[index],
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () => setState(
                                () => _isPinVisible = !_isPinVisible,
                              ),
                              icon: Icon(
                                _isPinVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),

                        if (_errorMessage != null) ...[
                          SizedBox(height: generalSpacing),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        SizedBox(height: sectionSpacing),

                        // Teclado numérico
                        _buildNumericKeypad(buttonSize, keyboardSpacing),

                        SizedBox(height: generalSpacing),

                        // Botão "Esqueceu PIN"
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/pin_recovery');
                          },
                          child: Text(
                            AppLocalizations.of(context)!.forgotPin,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(double buttonSize, double keyboardSpacing) {
    return Column(
      children: [
        // Primeira linha (1, 2, 3)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1', buttonSize),
            _buildKeypadButton('2', buttonSize),
            _buildKeypadButton('3', buttonSize),
          ],
        ),
        SizedBox(height: keyboardSpacing),

        // Segunda linha (4, 5, 6)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4', buttonSize),
            _buildKeypadButton('5', buttonSize),
            _buildKeypadButton('6', buttonSize),
          ],
        ),
        SizedBox(height: keyboardSpacing),

        // Terceira linha (7, 8, 9)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7', buttonSize),
            _buildKeypadButton('8', buttonSize),
            _buildKeypadButton('9', buttonSize),
          ],
        ),
        SizedBox(height: keyboardSpacing),

        // Quarta linha (OK, 0, apagar)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOkButton(buttonSize),
            _buildKeypadButton('0', buttonSize),
            _buildBackspaceButton(buttonSize),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit, double size) {
    return InkWell(
      onTap: _isLoading ? null : () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.3 * 255),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: size * 0.425,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(double size) {
    return InkWell(
      onTap: _isLoading ? null : _onBackspacePressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.3 * 255),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: size * 0.3,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildOkButton(double size) {
    final bool isEnabled = _currentIndex >= 4;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: (_isLoading || !isEnabled) ? null : _tryAuthenticate,
      borderRadius: BorderRadius.circular(size / 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled
                ? Theme.of(context).colorScheme.primary
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            border: Border.all(
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size * 0.25,
                color: isEnabled
                    ? Theme.of(context).colorScheme.onPrimary
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDigitPressed(String digit) {
    if (_currentIndex < 8) {
      setState(() {
        _digits[_currentIndex] = digit;
        _currentIndex++;
        _errorMessage = null;
      });

      HapticFeedback.lightImpact();
    }
  }

  void _onBackspacePressed() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _digits[_currentIndex] = '';
        _errorMessage = null;
      });

      HapticFeedback.selectionClick();
    }
  }

  void _tryAuthenticate() async {
    if (_currentIndex < 4) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final pin = _digits.take(_currentIndex).join();
    final pinProvider = Provider.of<PinProvider>(context, listen: false);

    final success = await pinProvider.authenticate(pin);

    if (success) {
      HapticFeedback.lightImpact();
      // O PinProvider notificará os listeners e a tela será ocultada automaticamente
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.reset();
      _shakeController.forward();

      setState(() {
        _errorMessage = 'PIN incorreto';
        _currentIndex = 0;
        _digits.fillRange(0, 8, '');
        _isLoading = false;
      });
    }
  }
}
