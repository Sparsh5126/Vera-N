import '../copy/app_copy.dart';

/// The Home greeting for the time of day, with the name if one is set.
abstract final class Greeting {
  static String of(DateTime now, {String? name}) {
    final hour = now.hour;
    final greeting = hour >= 5 && hour < 12
        ? AppCopy.greetingMorning
        : hour >= 12 && hour < 17
        ? AppCopy.greetingAfternoon
        : AppCopy.greetingEvening;
    return AppCopy.greetingWithName(greeting, name);
  }
}
