import 'package:dialink/src/app/env/env.dart';
import 'package:dialink/src/bootstrap.dart';

/// flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
void main() => bootstrap(Flavor.dev);
