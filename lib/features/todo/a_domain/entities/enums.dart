enum TodoPriority { undefined, low, medium, high, urgent }

extension TodoPriorityX on TodoPriority {
  String toDB() => name; // name trong dart trùng với string db
}

// ignore: constant_identifier_names
enum TodoStatus { pending, in_progress, completed, cancelled }

extension TodoStatusX on TodoStatus {
  String toDB() => name;
}

enum RecurrencePattern { once, daily, weekdays, custom }
