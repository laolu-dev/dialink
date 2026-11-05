import 'package:dialink/src/core/utils/time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sends the start time with the provider zone offset', () {
    final instant = DateTime.utc(2026, 11, 3, 9);

    expect(
      AppTime.withOffset(instant, 'Africa/Lagos'),
      '2026-11-03T10:00:00+01:00',
    );
    expect(
      AppTime.withOffset(instant, 'America/New_York'),
      '2026-11-03T04:00:00-05:00',
    );
    expect(
      AppTime.withOffset(instant, 'Asia/Kolkata'),
      '2026-11-03T14:30:00+05:30',
    );
  });

  test('shows times in the provider zone', () {
    final instant = DateTime.utc(2026, 11, 3, 9);

    expect(AppTime.time(instant, 'Africa/Lagos'), '10:00');
    expect(
      AppTime.dateTime(instant, 'Africa/Lagos'),
      'Tue 3 Nov 2026, 10:00 WAT',
    );
  });

  test('falls back to UTC for an unknown zone', () {
    expect(AppTime.time(DateTime.utc(2026, 11, 3, 9), 'Not/AZone'), '09:00');
  });

  test('calendar dates do not shift across daylight saving', () {
    final start = DateTime.utc(2026, 3, 26);
    expect(AppTime.apiDate(start.add(const Duration(days: 7))), '2026-04-02');
  });
}
