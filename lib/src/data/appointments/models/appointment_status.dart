enum AppointmentStatus {
  requested("Requested"),
  confirmed("Confirmed"),
  cancelled("Cancelled"),
  completed("Completed"),
  noShow("No show"),

  /// A status this version of the app does not know yet. Shown as is and
  /// offers no actions, so one new status cannot break the whole list.
  unknown("Unknown");

  const AppointmentStatus(this.label);
  final String label;

  static AppointmentStatus fromJson(String value) => switch (value) {
    'REQUESTED' => requested,
    'CONFIRMED' => confirmed,
    'CANCELLED' => cancelled,
    'COMPLETED' => completed,
    'NO_SHOW' => noShow,
    _ => unknown,
  };

  /// Whether the patient can still cancel or move it.
  bool get isActive => this == requested || this == confirmed;
}
