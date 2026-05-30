import 'dart:io';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../services/file_utils.dart';
import '../widgets/custom_text_field.dart';

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
  AuthProvider? _authProvider; // Salvar referência

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
    // Acessar context aqui é seguro
    if (_authProvider == null) {
      _authProvider = context.read<AuthProvider>();
      final user = _authProvider!.user!;
      _nameController.text = user.nome;
      _emailController.text = user.email;
      _selectedDate = user.dtNascimento;
      final locale = Localizations.localeOf(context).toString();
      _birthDateController.text = user.dtNascimento != null
          ? DateFormat.yMd(locale).format(user.dtNascimento!)
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
        _birthDateController.text = DateFormat.yMd(
          Localizations.localeOf(context).toString(),
        ).format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateUser(
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dtNascimento: _selectedDate,
      fotoPerfil:
          _pickedImagePath ??
          authProvider.user!.fotoPerfil, // mantém nova foto (ou a atual)
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: newEmailController,
                label: loc.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 8),
                Text(
                  dialogError!,
                  style: TextStyle(
                    color: Theme.of(dialogCtx).colorScheme.error,
                  ),
                ),
              ],
            ],
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
                  r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$',
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
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(loc.changePassword),
          content: SingleChildScrollView(
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
                      obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureCurrent = !obscureCurrent),
                  ),
                ),
                CustomTextField(
                  controller: newPasswordController,
                  label: loc.newPinLabel,
                  obscureText: obscureNew,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureNew = !obscureNew),
                  ),
                ),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: loc.confirmPassword,
                  obscureText: obscureConfirm,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    dialogError!,
                    style: TextStyle(
                      color: Theme.of(dialogCtx).colorScheme.error,
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
                final current = currentPasswordController.text;
                final newPass = newPasswordController.text;
                final confirm = confirmPasswordController.text;

                if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                  setDialogState(() => dialogError = loc.fillAllFields);
                  return;
                }
                if (newPass.length < 4) {
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
        final File tmpFile = File(picked.path);
        final oldPath = _pickedImagePath;
        // copy into app directory
        final savedPath = await FileUtils.copyProfileImageToApp(tmpFile);

        // if oldPath points to a local file inside profile_images, delete it
        if (oldPath != null && oldPath.isNotEmpty && oldPath != savedPath) {
          await FileUtils.deleteFileIfExists(oldPath);
        }

        if (!mounted) return;
        setState(() {
          _pickedImagePath = savedPath;
        });
      }
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      // Mostrar erro apenas se o widget ainda está montado
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.errorSelectImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              AppLocalizations.of(context)!.save,
              style: TextStyle(
                color: _isLoading
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      backgroundImage: _pickedImagePath != null
                          ? (_pickedImagePath!.startsWith('http')
                                ? NetworkImage(_pickedImagePath!)
                                      as ImageProvider
                                : (File(_pickedImagePath!).existsSync()
                                      ? FileImage(File(_pickedImagePath!))
                                      : null))
                          : (context.watch<AuthProvider>().user!.fotoPerfil !=
                                    null
                                ? (context
                                          .watch<AuthProvider>()
                                          .user!
                                          .fotoPerfil!
                                          .startsWith('http')
                                      ? NetworkImage(
                                              context
                                                  .watch<AuthProvider>()
                                                  .user!
                                                  .fotoPerfil!,
                                            )
                                            as ImageProvider
                                      : (File(
                                              context
                                                  .watch<AuthProvider>()
                                                  .user!
                                                  .fotoPerfil!,
                                            ).existsSync()
                                            ? FileImage(
                                                File(
                                                  context
                                                      .watch<AuthProvider>()
                                                      .user!
                                                      .fotoPerfil!,
                                                ),
                                              )
                                            : null))
                                : null),
                      child:
                          (_pickedImagePath == null &&
                              context.watch<AuthProvider>().user!.fotoPerfil ==
                                  null)
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fullName,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.emailRequired;
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
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
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.birthDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                          style: const TextStyle(fontSize: 16),
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
                  label: Text(AppLocalizations.of(context)!.changeEmail),
                  onPressed: _showChangeEmailDialog,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.lock_outline),
                  label: Text(AppLocalizations.of(context)!.changePassword),
                  onPressed: _showChangePasswordDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
