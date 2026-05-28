import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Helper para gerenciar conversões de Rich Text no app
/// Centraliza toda a lógica de conversão entre formatos:
/// - Delta (formato nativo do Quill)
/// - JSON (para armazenamento no banco)
/// - HTML (para visualização e compatibilidade)
/// - Plain Text (para backup legado e visualização simples)
class RichTextHelper {
  /// Converte um controller do Quill para JSON (para salvar no banco)
  static String controllerToJson(QuillController controller) {
    final delta = controller.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  /// Converte JSON do banco para um QuillController
  static QuillController jsonToController(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return QuillController.basic();
    }

    try {
      final json = jsonDecode(jsonString) as List;
      final document = Document.fromJson(json);
      return QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Se houver erro ao parsear JSON, trata como texto simples
      return QuillController.basic();
    }
  }

  /// Converte JSON do banco para HTML (para visualização)
  static String jsonToHtml(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return '';
    }

    try {
      final json = jsonDecode(jsonString);
      final deltaOps = List<Map<String, dynamic>>.from(json);
      final converter = QuillDeltaToHtmlConverter(deltaOps);
      return converter.convert();
    } catch (e) {
      // Se houver erro, retorna o texto como estava
      return jsonString;
    }
  }

  /// Converte JSON do banco para texto simples (sem formatação)
  static String jsonToPlainText(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return '';
    }

    try {
      final controller = jsonToController(jsonString);
      return controller.document.toPlainText();
    } catch (e) {
      // Se houver erro, retorna o texto original
      return jsonString;
    }
  }

  /// Converte texto simples para JSON (útil para migração de dados antigos)
  static String plainTextToJson(String plainText) {
    if (plainText.isEmpty) {
      return jsonEncode([]);
    }

    final controller = QuillController.basic();
    controller.document.insert(0, plainText);
    return controllerToJson(controller);
  }

  /// Verifica se uma string é JSON válido do Quill
  static bool isValidQuillJson(String? text) {
    if (text == null || text.isEmpty) return false;

    try {
      final json = jsonDecode(text);
      return json is List;
    } catch (e) {
      return false;
    }
  }

  /// Retorna um controller vazio
  static QuillController emptyController() {
    return QuillController.basic();
  }

  /// Cria um controller a partir de texto simples ou JSON
  /// Detecta automaticamente o formato
  static QuillController smartController(String? content) {
    if (content == null || content.isEmpty) {
      return QuillController.basic();
    }

    // Tenta parsear como JSON primeiro
    if (isValidQuillJson(content)) {
      return jsonToController(content);
    }

    // Se não for JSON, trata como texto simples
    final controller = QuillController.basic();
    controller.document.insert(0, content);
    return controller;
  }

  /// Trunca o texto para exibição em cards (retorna texto simples)
  static String truncateForCard(String? jsonString, {int maxLength = 150}) {
    final plainText = jsonToPlainText(jsonString);
    if (plainText.length <= maxLength) {
      return plainText;
    }
    return '${plainText.substring(0, maxLength)}...';
  }

  /// Retorna o texto formatado para exibição em notificações
  static String getPlainTextForNotification(String? jsonString) {
    return jsonToPlainText(jsonString);
  }
}
