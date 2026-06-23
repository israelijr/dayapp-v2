import 'dart:io';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../providers/auth_provider.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/custom_text_field.dart';

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

class CreateAccountComplementScreen extends StatefulWidget {
  const CreateAccountComplementScreen({super.key});

  @override
  State<CreateAccountComplementScreen> createState() =>
      _CreateAccountComplementScreenState();
}

class _CreateAccountComplementScreenState
    extends State<CreateAccountComplementScreen> {
  final birthDateController = TextEditingController();
  String? profileImagePath;
  String? errorMessage;
  bool loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        if (!mounted) return;
        setState(() {
          profileImagePath = picked.path;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = AppLocalizations.of(
          context,
        )!.errorSelectImages(e.toString());
      });
    }
  }

  Future<void> _saveComplement(BuildContext context) async {
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      loading = true;
      errorMessage = null;
    });
    DateTime? birthDate;
    if (birthDateController.text.isNotEmpty) {
      try {
        birthDate = DateFormat('dd/MM/yyyy').parse(birthDateController.text);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        if (birthDate.isAfter(today)) {
          setState(() {
            errorMessage = 'A data de nascimento não pode ser no futuro.';
            loading = false;
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
            errorMessage = 'Você deve ter pelo menos 14 anos de idade.';
            loading = false;
          });
          return;
        }
      } catch (_) {
        setState(() {
          errorMessage = AppLocalizations.of(context)!.invalidBirthDate;
          loading = false;
        });
        return;
      }
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.userNotFound;
        loading = false;
      });
      return;
    }
    try {
      final db = await DatabaseHelper().database;
      await db.update(
        'users',
        {
          'dt_nascimento': birthDate?.toIso8601String(),
          'foto_perfil': profileImagePath,
        },
        where: 'id = ?',
        whereArgs: [auth.user!.id],
      );

      if (!mounted) return;
      // Navega para uma nova instância da tela de login, removendo toda a
      // pilha de criação de conta. Isso garante que o initState rode novamente
      // e a verificação de biometria reflita o estado real (sem credenciais
      // da conta anterior).
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = l10n.profileUpdateError;
      });
      debugPrint(
        'CreateAccountComplementScreen: erro ao salvar complemento: $e',
      );
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          AppLocalizations.of(context)!.almostReady,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.optionalData,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath!))
                          : null,
                      child: profileImagePath == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: birthDateController,
                  label: AppLocalizations.of(context)!.birthDateFormat,
                  keyboardType: TextInputType.datetime,
                  maxLength: 10,
                  inputFormatters: [_BirthDateInputFormatter()],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : () => _saveComplement(context),
                    child: loading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.create,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
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
