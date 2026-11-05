import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'preferences.g.dart';

/// Loaded before the app starts, so the saved theme shows on the first frame.
@Riverpod(keepAlive: true)
SharedPreferences preferences(Ref ref) =>
    throw UnimplementedError('Overridden in main()');
