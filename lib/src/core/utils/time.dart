import 'package:intl/intl.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Appointment times are shown in the provider's time zone (an IANA id such as
/// `Africa/Lagos`), which is also what the emails use.
abstract final class AppTime {
  static bool _initialised = false;

  // Built once: a DateFormat parses its pattern when it is created.
  static final _dateTime = DateFormat('EEE d MMM yyyy, HH:mm');
  static final _time = DateFormat.Hm();
  static final _day = DateFormat('EEEE d MMMM');
  static final _apiDate = DateFormat('yyyy-MM-dd');
  static final _local = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Loads the time-zone database. `main` calls it after the first frame, so
  /// the first appointment time shown does not stall a scroll; anything that
  /// needs it earlier loads it on demand.
  static void init() {
    if (_initialised) return;
    tz_data.initializeTimeZones();
    _initialised = true;
  }

  static tz.Location location(String? timeZone) {
    init();
    if (timeZone == null) return tz.UTC;
    try {
      return tz.getLocation(timeZone);
    } catch (_) {
      return tz.UTC;
    }
  }

  /// [instant] in the provider's zone.
  static tz.TZDateTime inZone(DateTime instant, String? timeZone) =>
      tz.TZDateTime.from(instant, location(timeZone));

  /// Today in the provider's zone, as a calendar date.
  ///
  /// Calendar dates are UTC midnights so adding days never crosses a
  /// daylight-saving change.
  static DateTime todayIn(String? timeZone) =>
      dateOf(inZone(DateTime.now(), timeZone));

  /// The calendar date of [t], as a UTC midnight.
  static DateTime dateOf(DateTime t) => DateTime.utc(t.year, t.month, t.day);

  /// `Tue 3 Nov 2026, 10:00 WAT`.
  static String dateTime(DateTime instant, String? timeZone) {
    final t = inZone(instant, timeZone);
    return '${_dateTime.format(t)} ${t.timeZoneName}';
  }

  /// `10:00`.
  static String time(DateTime instant, String? timeZone) =>
      _time.format(inZone(instant, timeZone));

  /// `Tuesday 3 November`.
  static String day(DateTime date) => _day.format(date);

  /// `2026-11-03`, the format the API takes for dates.
  static String apiDate(DateTime date) => _apiDate.format(date);

  /// ISO-8601 with the zone's offset, e.g. `2026-11-03T10:00:00+01:00`.
  static String withOffset(DateTime instant, String? timeZone) {
    final t = inZone(instant, timeZone);
    final offset = t.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${_local.format(t)}$sign$hours:$minutes';
  }
}
