/// Route paths. Features navigate by these, never by importing each other.
abstract final class Routes {
  static const home = '/';
  static const search = '/search';
  static const onboardingFolder = '/welcome/folder';
  static const newNote = '/note/new';
  static const notePattern = '/note/:ref';
  static const noteParam = 'ref';

  static String note(int ref) => '/note/$ref';
}
