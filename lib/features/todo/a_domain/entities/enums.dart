enum TodoPriority { undefined, low, medium, high, urgent }

extension TodoPriorityX on TodoPriority {
  String toDB() => name; // name trong dart trùng với string db

  static TodoPriority fromDB(String? value) {
    if (value == null) {
      return TodoPriority.undefined;
    }

    return TodoPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TodoPriority.undefined,
    );
  }
}

// ignore: constant_identifier_names
enum TodoStatus { pending, in_progress, completed, cancelled }

extension TodoStatusX on TodoStatus {
  String toDB() => name;

  static TodoStatus fromDB(String? value) {
    if (value == null) {
      return TodoStatus.pending;
    }

    return TodoStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TodoStatus.pending,
    );
  }
}

enum RecurrencePattern { once, daily, weekdays, custom }

extension RecurrencePatternX on RecurrencePattern {
  String toDB() => name;

  static RecurrencePattern fromDB(String? value) {
    if (value == null) {
      return RecurrencePattern.once;
    }

    return RecurrencePattern.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrencePattern.once,
    );
  }
}
