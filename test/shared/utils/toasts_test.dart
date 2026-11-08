import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/shared/utils/toasts.dart';

void main() {
  test('short messages stay at least 4 seconds', () {
    expect(Toasts.readingTime('Saved.'), const Duration(seconds: 4));
  });

  test('longer messages get time to read', () {
    // 11 words: 2 + 11 / 3 = 5.67 seconds.
    expect(
      Toasts.readingTime(
        "Account created. We've emailed you a code to confirm your address.",
      ),
      const Duration(milliseconds: 5667),
    );
  });

  test('very long messages stop at 10 seconds', () {
    expect(Toasts.readingTime('word ' * 60), const Duration(seconds: 10));
  });
}
