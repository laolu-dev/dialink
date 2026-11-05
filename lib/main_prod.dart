import 'package:dialink/src/app/env/env.dart';
import 'package:dialink/src/bootstrap.dart';

/// flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
void main() => bootstrap(Flavor.prod);
