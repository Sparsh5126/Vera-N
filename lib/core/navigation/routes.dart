/// Route paths. Features navigate by these, never by importing each other.
abstract final class Routes {
  static const home = '/';
  static const search = '/search';
  static const graph = '/graph';
  static const settings = '/settings';
  static const trash = '/trash';
  static const welcome = '/welcome';
  static const newNote = '/note/new';

  /// Query values of a new note shared from another app (Android Share);
  /// must match CaptureIntents.kt.
  static const sharedTextParam = 'text';
  static const sharedSubjectParam = 'subject';
  static const review = '/review';
  static const revisit = '/revisit';
  static const notePattern = '/note/:ref';
  static const noteParam = 'ref';

  static String note(int ref) => '/note/$ref';
}
