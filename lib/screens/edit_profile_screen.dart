import 'dart:io';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/file_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/profile_avatar_picker.dart';
import '../widgets/strong_password_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  DateTime? _selectedDate;
  String? _errorMessage;
  bool _isLoading = false;
  String? _pickedImagePath;
  // Helper para mostrar SnackBar
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void initState() {
    super.initState();
    // Inicializar controllers vazios
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _birthDateController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.nome;
      _emailController.text = user.email;
      _selectedDate = user.dtNascimento;
      _birthDateController.text = user.dtNascimento != null
          ? _formatBirthDate(user.dtNascimento!)
          : '';
      _pickedImagePath = user.fotoPerfil;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = _formatBirthDate(picked);
      });
    }
  }

  String _formatBirthDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  DateTime? _parseBirthDate(String text) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final birthDateText = _birthDateController.text.trim();
    DateTime? birthDate;
    if (birthDateText.isNotEmpty) {
      birthDate = _parseBirthDate(birthDateText);
      if (birthDate == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.invalidBirthDate;
        });
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (birthDate.isAfter(today)) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.birthDateCannotBeFuture;
        });
        return;
      }

      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      if (age < 14) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.birthDateMinAge;
        });
        return;
      }
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateUser(
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dtNascimento: birthDate,
      fotoPerfil: _pickedImagePath ?? authProvider.user!.fotoPerfil,
    );
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Mostrar mensagem de sucesso
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
          duration: const Duration(seconds: 2),
        ),
      );

      // Aguardar um pouco para usuário ver a mensagem
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Remover o SnackBar antes de voltar
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      // Pequeno delay para garantir que o SnackBar foi removido
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.profileUpdateError;
      });
    }
  }

  void _showChangeEmailDialog() {
    final loc = AppLocalizations.of(context)!;
    final newEmailController = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(loc.changeEmail),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: newEmailController,
                  label: loc.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade900,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dialogError!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newEmail = newEmailController.text.trim();
                final emailRegex = RegExp(
                  r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,}$',
                );
                if (newEmail.isEmpty) {
                  setDialogState(() => dialogError = loc.emailRequired);
                  return;
                }
                if (!emailRegex.hasMatch(newEmail)) {
                  setDialogState(() => dialogError = loc.emailInvalid);
                  return;
                }

                Navigator.of(dialogCtx).pop();
                final auth = context.read<AuthProvider>();
                final success = await auth.updateEmail(newEmail);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? loc.emailChangedSuccess
                          : loc.emailAlreadyRegistered,
                    ),
                    backgroundColor: success
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                );

                if (success) {
                  // Atualiza o campo de e-mail visível na tela
                  setState(() {
                    _emailController.text = newEmail;
                  });
                }
              },
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final loc = AppLocalizations.of(context)!;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureConfirm = true;
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(loc.changePassword),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: currentPasswordController,
                    label: loc.currentPassword,
                    obscureText: obscureCurrent,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setDialogState(
                        () => obscureCurrent = !obscureCurrent,
                      ),
                    ),
                  ),
                  StrongPasswordField(
                    controller: newPasswordController,
                    label: loc.newPasswordTitle,
                    prefixIcon: const Icon(Icons.lock),
                    onValidChanged: (valid) {
                      setDialogState(() {});
                    },
                  ),
                  CustomTextField(
                    controller: confirmPasswordController,
                    label: loc.confirmPassword,
                    obscureText: obscureConfirm,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setDialogState(
                        () => obscureConfirm = !obscureConfirm,
                      ),
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade900,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dialogError!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentPasswordController.text;
                final newPass = newPasswordController.text;
                final confirm = confirmPasswordController.text;

                if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                  setDialogState(() => dialogError = loc.fillAllFields);
                  return;
                }

                final hasMinLength = newPass.length >= 8;
                final hasUppercase = newPass.contains(RegExp(r'[A-Z]'));
                final hasLowercase = newPass.contains(RegExp(r'[a-z]'));
                final hasNumber = newPass.contains(RegExp(r'[0-9]'));
                final hasSpecial = newPass.contains(
                  RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=\[\]\/\\]'),
                );

                if (!hasMinLength ||
                    !hasUppercase ||
                    !hasLowercase ||
                    !hasNumber ||
                    !hasSpecial) {
                  setDialogState(() => dialogError = loc.newPasswordMinLength);
                  return;
                }
                if (newPass != confirm) {
                  setDialogState(() => dialogError = loc.passwordsDoNotMatch);
                  return;
                }

                Navigator.of(dialogCtx).pop();
                final auth = context.read<AuthProvider>();
                final result = await auth.changePassword(
                  currentPassword: current,
                  newPassword: newPass,
                );

                if (!mounted) return;
                String message;
                bool isError = false;
                if (result == 'ok') {
                  message = loc.passwordChangedSuccess;
                } else if (result == 'wrongPassword') {
                  message = loc.wrongCurrentPassword;
                  isError = true;
                } else {
                  message = loc.profileUpdateError;
                  isError = true;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: isError
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                  ),
                );
              },
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      // Reseta a flag após retornar do app externo (independente de sucesso ou cancelamento)
      pinProvider.isPickingExternalMedia = false;

      if (picked != null) {
        if (kIsWeb) {
          if (!mounted) return;
          setState(() {
            _pickedImagePath = picked.path;
          });
          return;
        }

        final File tmpFile = File(picked.path);
        final oldPath = _pickedImagePath;
        final savedPath = await FileUtils.copyProfileImageToApp(tmpFile);

        if (oldPath != null && oldPath.isNotEmpty && oldPath != savedPath) {
          await FileUtils.deleteFileIfExists(oldPath);
        }

        if (!mounted) return;
        setState(() {
          _pickedImagePath = savedPath;
        });
      }
    } catch (e) {
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.errorSelectImage);
    }
  }

  String? _selectedImagePath(BuildContext context) {
    if (_pickedImagePath != null) return _pickedImagePath;
    final user = context.watch<AuthProvider>().user;
    if (user?.fotoPerfil != null && !user!.fotoPerfil!.startsWith('http')) {
      return user.fotoPerfil;
    }
    return null;
  }

  String? _selectedNetworkImageUrl(BuildContext context) {
    if (_pickedImagePath != null) return null;
    final user = context.watch<AuthProvider>().user;
    if (user?.fotoPerfil != null && user!.fotoPerfil!.startsWith('http')) {
      return user.fotoPerfil;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            color:
                Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              AppLocalizations.of(context)!.save,
              style: GoogleFonts.plusJakartaSans(
                color: _isLoading
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      ProfileAvatarPicker(
                        localImagePath: _selectedImagePath(context),
                        networkImageUrl: _selectedNetworkImageUrl(context),
                        onPickImage: _pickImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fullName,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.nameRequired;
                    }
                    if (value.trim().length < 2) {
                      return AppLocalizations.of(context)!.nameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    final emailRegex = RegExp(
                      r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return AppLocalizations.of(context)!.emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthDateController,
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                    _BirthDateInputFormatter(),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.birthDate,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    hintText: AppLocalizations.of(context)!.birthDateFormat,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final birthDate = _parseBirthDate(value.trim());
                    if (birthDate == null) {
                      return AppLocalizations.of(context)!.invalidBirthDate;
                    }

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    if (birthDate.isAfter(today)) {
                      return AppLocalizations.of(
                        context,
                      )!.birthDateCannotBeFuture;
                    }

                    int age = today.year - birthDate.year;
                    if (today.month < birthDate.month ||
                        (today.month == birthDate.month &&
                            today.day < birthDate.day)) {
                      age--;
                    }
                    if (age < 14) {
                      return AppLocalizations.of(context)!.birthDateMinAge;
                    }

                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade900),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppLocalizations.of(context)!.save,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: Text(
                      AppLocalizations.of(context)!.changeEmail,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _showChangeEmailDialog,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_outline),
                    label: Text(
                      AppLocalizations.of(context)!.changePassword,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _showChangePasswordDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits = digitsOnly.length > 8
        ? digitsOnly.substring(0, 8)
        : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < limitedDigits.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(limitedDigits[i]);
    }

    final masked = buffer.toString();
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}
