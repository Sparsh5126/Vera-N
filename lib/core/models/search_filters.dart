import 'package:flutter/foundation.dart';

/// The Date filter's choices. Dates are when a note was last changed (the
/// date shown on cards), counted in whole local days.
enum DateFilter {
  today(0),
  last7Days(6),
  last30Days(29),
  thisYear(null);

  const DateFilter(this._daysBeforeToday);

  final int? _daysBeforeToday;

  /// The earliest moment a note may have been changed to match.
  DateTime startFrom(DateTime now) {
    final days = _daysBeforeToday;
    if (days == null) return DateTime(now.year);
    return DateTime(now.year, now.month, now.day - days);
  }
}

/// Folder, Tag and Date filters on Search. Each holds one value or none.
@immutable
class SearchFilters {
  const SearchFilters({this.folder, this.tag, this.date});

  /// A folder path; its subfolders match too.
  final String? folder;
  final String? tag;
  final DateFilter? date;

  bool get isActive => folder != null || tag != null || date != null;

  SearchFilters withFolder(String? value) =>
      SearchFilters(folder: value, tag: tag, date: date);

  SearchFilters withTag(String? value) =>
      SearchFilters(folder: folder, tag: value, date: date);

  SearchFilters withDate(DateFilter? value) =>
      SearchFilters(folder: folder, tag: tag, date: value);

  @override
  bool operator ==(Object other) =>
      other is SearchFilters &&
      other.folder == folder &&
      other.tag == tag &&
      other.date == date;

  @override
  int get hashCode => Object.hash(folder, tag, date);
}
