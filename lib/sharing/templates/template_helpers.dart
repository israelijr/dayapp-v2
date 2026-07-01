import 'dart:convert';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:flutter/material.dart';

String normalizedDescription(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return '';
  }

  final trimmed = raw.trim();
  if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) {
    return trimmed;
  }

  try {
    final decoded = json.decode(trimmed);
    final buffer = StringBuffer();

    void extract(dynamic value) {
      if (value is String) {
        buffer.write(value);
      } else if (value is Map) {
        if (value.containsKey('insert')) {
          extract(value['insert']);
        } else {
          for (final item in value.values) {
            extract(item);
          }
        }
      } else if (value is List) {
        for (final item in value) {
          extract(item);
        }
      }
    }

    extract(decoded);
    final text = buffer.toString().trim();
    return text.isEmpty ? trimmed : text;
  } catch (_) {
    return trimmed;
  }
}

String moodLabel(BuildContext context, int value) {
  final l10n = AppLocalizations.of(context)!;
  switch (value) {
    case 1:
      return l10n.moodVeryDifficult;
    case 2:
      return l10n.moodDifficult;
    case 3:
      return l10n.moodNeutral;
    case 4:
      return l10n.moodGood;
    case 5:
      return l10n.moodVeryGood;
    default:
      return l10n.moodNeutral;
  }
}

Widget buildEmptyPhotoBackground(ColorScheme colorScheme) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          colorScheme.surface.withValues(alpha: 0.82),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.photo,
        size: 80,
        color: colorScheme.onSurface.withValues(alpha: 0.22),
      ),
    ),
  );
}

String storyPeopleLine(StoryData story) {
  final names = story.people
      .map((person) => person.name.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
  return names.join(', ');
}

String storyMetadataLine(StoryData story) {
  final location = story.location?.trim();
  final people = storyPeopleLine(story);
  final parts = <String>[];
  if (location != null && location.isNotEmpty) {
    parts.add(location);
  }
  if (people.isNotEmpty) {
    parts.add(people);
  }
  return parts.join(' • ');
}
