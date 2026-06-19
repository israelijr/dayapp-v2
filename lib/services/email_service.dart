import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'smtp_config.dart';

/// Serviço para envio de e-mails via SMTP.
/// Envia e-mails silenciosamente sem abrir nenhum app de e-mail.
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  /// Envia um e-mail de recuperação de senha com o código informado.
  /// Retorna true se o envio foi bem-sucedido.
  Future<bool> sendRecoveryEmail({
    required String toEmail,
    required String recoveryCode,
    int validityMinutes = 15,
  }) async {
    try {
      final smtpServer = SmtpServer(
        SmtpConfig.smtpHost,
        port: SmtpConfig.smtpPort,
        ssl: SmtpConfig.smtpSsl,
        username: SmtpConfig.smtpUsername,
        password: SmtpConfig.smtpPassword,
      );

      final message = Message()
        ..from = const Address(SmtpConfig.smtpUsername, SmtpConfig.senderName)
        ..recipients.add(toEmail)
        ..subject = 'DayApp - Código de Recuperação de Senha'
        ..text = _buildPlainTextBody(recoveryCode, validityMinutes)
        ..html = _buildHtmlBody(recoveryCode, validityMinutes);

      await send(message, smtpServer);
      debugPrint('EMAIL: Enviado com sucesso para $toEmail');
      return true;
    } catch (e) {
      debugPrint('EMAIL: Erro ao enviar e-mail: $e');
      return false;
    }
  }

  /// Envia um e-mail de recuperação de PIN com o código informado.
  /// Retorna true se o envio foi bem-sucedido.
  Future<bool> sendRecoveryPinEmail({
    required String toEmail,
    required String recoveryCode,
    int validityMinutes = 15,
  }) async {
    try {
      final smtpServer = SmtpServer(
        SmtpConfig.smtpHost,
        port: SmtpConfig.smtpPort,
        ssl: SmtpConfig.smtpSsl,
        username: SmtpConfig.smtpUsername,
        password: SmtpConfig.smtpPassword,
      );

      final message = Message()
        ..from = const Address(SmtpConfig.smtpUsername, SmtpConfig.senderName)
        ..recipients.add(toEmail)
        ..subject = 'DayApp - Código de Recuperação de PIN'
        ..text = _buildPlainTextPinBody(recoveryCode, validityMinutes)
        ..html = _buildHtmlPinBody(recoveryCode, validityMinutes);

      await send(message, smtpServer);
      debugPrint(
        'EMAIL: Code de recuperação de PIN enviado com sucesso para $toEmail',
      );
      return true;
    } catch (e) {
      debugPrint('EMAIL: Erro ao enviar e-mail de PIN: $e');
      return false;
    }
  }

  /// Corpo do e-mail em texto plano
  String _buildPlainTextBody(String code, int validityMinutes) {
    return 'Olá,\n\n'
        'Você solicitou a recuperação da sua senha no DayApp.\n\n'
        'Seu código de recuperação é: $code\n\n'
        'Este código expira em $validityMinutes minutos.\n\n'
        'Se você não solicitou este código, ignore este e-mail.\n\n'
        'Atenciosamente,\n'
        'Equipe DayApp';
  }

  /// Corpo do e-mail em HTML (melhor formatação visual)
  String _buildHtmlBody(String code, int validityMinutes) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px;">
  <div style="max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 24px;">
      <h2 style="color: #5E35B1; margin: 0;">DayApp</h2>
      <p style="color: #666; font-size: 14px;">Recuperação de Senha</p>
    </div>
    
    <p style="color: #333; font-size: 15px;">Olá,</p>
    <p style="color: #333; font-size: 15px;">Você solicitou a recuperação da sua senha no DayApp.</p>
    
    <div style="text-align: center; margin: 24px 0;">
      <p style="color: #666; font-size: 14px; margin-bottom: 8px;">Seu código de recuperação:</p>
      <div style="background: #EDE7F6; border-radius: 8px; padding: 16px; display: inline-block;">
        <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #5E35B1;">$code</span>
      </div>
    </div>
    
    <p style="color: #999; font-size: 13px; text-align: center;">
      Este código expira em <strong>$validityMinutes minutos</strong>.
    </p>
    
    <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
    
    <p style="color: #999; font-size: 12px; text-align: center;">
      Se você não solicitou este código, ignore este e-mail.
    </p>
  </div>
</body>
</html>
''';
  }

  /// Corpo do e-mail de recuperação de PIN em texto plano
  String _buildPlainTextPinBody(String code, int validityMinutes) {
    return 'Olá,\n\n'
        'Você solicitou a recuperação do seu PIN de desbloqueio no DayApp.\n\n'
        'Seu código de recuperação é: $code\n\n'
        'Este código expira em $validityMinutes minutos.\n\n'
        'Se você não solicitou este código, ignore este e-mail.\n\n'
        'Atenciosamente,\n'
        'Equipe DayApp';
  }

  /// Corpo do e-mail de recuperação de PIN em HTML
  String _buildHtmlPinBody(String code, int validityMinutes) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px;">
  <div style="max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 24px;">
      <h2 style="color: #5E35B1; margin: 0;">DayApp</h2>
      <p style="color: #666; font-size: 14px;">Recuperação de PIN</p>
    </div>
    
    <p style="color: #333; font-size: 15px;">Olá,</p>
    <p style="color: #333; font-size: 15px;">Você solicitou a recuperação do seu PIN de desbloqueio no DayApp.</p>
    
    <div style="text-align: center; margin: 24px 0;">
      <p style="color: #666; font-size: 14px; margin-bottom: 8px;">Seu código de recuperação:</p>
      <div style="background: #EDE7F6; border-radius: 8px; padding: 16px; display: inline-block;">
        <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #5E35B1;">$code</span>
      </div>
    </div>
    
    <p style="color: #999; font-size: 13px; text-align: center;">
      Este código expira em <strong>$validityMinutes minutos</strong>.
    </p>
    
    <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
    
    <p style="color: #999; font-size: 12px; text-align: center;">
      Se você não solicitou este código, ignore este e-mail.
    </p>
  </div>
</body>
</html>
''';
  }
}
