/// A folder with a meaning, like Archive or Locked: a note moved into it
/// keeps its own folder inside (`Ideas/x.md` becomes `<name>/Ideas/x.md`),
/// so moving it out puts it back exactly where it was, and other apps see
/// a plain folder. Names compare without letter case.
class SpecialFolder {
  const SpecialFolder(this.name);

  final String name;

  String get _lower => name.toLowerCase();

  /// Whether [folder] is this folder or inside it.
  bool contains(String folder) {
    final f = folder.toLowerCase();
    return f == _lower || f.startsWith('$_lower/');
  }

  /// Where a note in [folder] goes when moved in.
  String into(String folder) => folder.isEmpty ? name : '$name/$folder';

  /// Where a note in [folder] goes back to.
  String outOf(String folder) {
    if (!contains(folder)) return folder;
    return folder.length == name.length
        ? ''
        : folder.substring(name.length + 1);
  }

  /// SQL: true when note `n` is not in this folder.
  String get notInSql => notInSqlFor('n');

  /// SQL: true when the note with table alias [alias] is not in it.
  String notInSqlFor(String alias) =>
      "NOT (lower($alias.folder) = '$_lower' "
      "OR lower($alias.folder) LIKE '$_lower/%')";
}
