import 'dart:typed_data';

import 'package:dayapp/models/historia.dart';

class StoryPerson {
  final String name;

  const StoryPerson({required this.name});
}

class StoryMediaItem {
  final Uint8List bytes;
  final String? caption;

  const StoryMediaItem({required this.bytes, this.caption});
}

class StoryData {
  final String title;
  final String? subtitle;
  final String? description;
  final String? emoticon;
  final DateTime date;
  final int mood;
  final int energy;
  final List<Uint8List> images;
  final List<StoryMediaItem> mediaItems;
  final List<StoryPerson> people;
  final String? location;
  final List<String> tags;
  final String localeName;

  const StoryData({
    required this.title,
    required this.date,
    required this.localeName,
    this.subtitle,
    this.description,
    this.emoticon,
    this.mood = 3,
    this.energy = 2,
    this.images = const [],
    this.mediaItems = const [],
    this.people = const [],
    this.location,
    this.tags = const [],
  });

  factory StoryData.fromHistoria(
    Historia historia,
    List<Uint8List> images, {
    String localeName = 'en_US',
    List<StoryPerson> people = const [],
    String? location,
  }) {
    final tag = historia.tag;
    final subtitle = (tag != null && tag.isNotEmpty) ? tag : historia.assunto;
    final mediaItems = images
        .map((bytes) => StoryMediaItem(bytes: bytes))
        .toList(growable: false);

    return StoryData(
      title: historia.titulo,
      subtitle: subtitle,
      description: historia.descricao,
      emoticon: historia.emoticon,
      date: historia.data,
      localeName: localeName,
      mood: historia.humor,
      energy: historia.energia,
      images: List<Uint8List>.unmodifiable(images),
      mediaItems: mediaItems,
      people: List<StoryPerson>.unmodifiable(people),
      location: location ?? historia.local,
      tags: (tag != null && tag.isNotEmpty) ? [tag] : const [],
    );
  }
}
