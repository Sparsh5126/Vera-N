import 'package:flutter/foundation.dart';

/// Another note shown in a note's Linked or Mentioned in section.
@immutable
class LinkedNote {
  const LinkedNote({required this.ref, required this.title});

  final int ref;
  final String title;
}
