import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Emoji {
  final String group;
  final String char;
  final String code;
  final String translation;

  Emoji({
    required this.group,
    required this.char,
    required this.code,
    required this.translation,
  });

  factory Emoji.fromJson(Map<String, dynamic> json) {
    return Emoji(
      group: json['Grupo'] ?? '',
      char: json['Emoji'] ?? '',
      code: json['Código'] ?? '',
      translation: json['Tradução'] ?? '',
    );
  }
}

class EmojiService {
  static final EmojiService _instance = EmojiService._internal();
  factory EmojiService() => _instance;
  EmojiService._internal();

  List<Emoji> _emojis = [];
  Map<String, List<Emoji>> _groupedEmojis = {};

  Future<void> loadEmojis() async {
    if (_emojis.isNotEmpty) return;

    try {
      final String response = await rootBundle.loadString('assets/emojis.json');
      final List<dynamic> data = json.decode(response);
      _emojis = data.map((json) => Emoji.fromJson(json)).toList();

      _groupedEmojis = {};
      for (var emoji in _emojis) {
        if (!_groupedEmojis.containsKey(emoji.group)) {
          _groupedEmojis[emoji.group] = [];
        }
        _groupedEmojis[emoji.group]!.add(emoji);
      }
    } catch (e) {
      // Erro ao carregar emojis - lista ficará vazia
      debugPrint('EmojiService.loadEmojis: erro ao ler assets/emojis.json: $e');
    }
  }

  Map<String, List<Emoji>> get groupedEmojis => _groupedEmojis;

  List<String> get groups => _groupedEmojis.keys.toList();

  Emoji? findByChar(String char) {
    try {
      return _emojis.firstWhere((e) => e.char == char);
    } catch (e) {
      return null;
    }
  }
}
