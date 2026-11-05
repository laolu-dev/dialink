import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The layer rules in docs/architecture.md. A file may import from its own
/// layer and the ones listed for it; `app/` may import anything.
const _allowed = <String, List<String>>{
  'core/': ['core/'],
  'data/': ['core/', 'data/'],
  'shared/': [
    'core/',
    'data/',
    'shared/',
    'app/theme/',
    'app/router/routes.dart',
  ],
  'features/': [
    'core/',
    'data/',
    'shared/',
    'app/theme/',
    'app/router/routes.dart',
  ],
};

final _import = RegExp(
  r"^import 'package:dialink/src/([^']+)';",
  multiLine: true,
);

void main() {
  final files = Directory('lib/src')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

  test('every layer imports only what it may', () {
    final broken = <String>[];
    for (final file in files) {
      final path = file.path.substring('lib/src/'.length);
      final layer = _allowed.keys.where(path.startsWith).firstOrNull;
      if (layer == null) continue;

      // A feature may also import itself, but no other feature.
      final own = layer == 'features/'
          ? 'features/${path.split('/')[1]}/'
          : null;
      for (final match in _import.allMatches(file.readAsStringSync())) {
        final target = match.group(1)!;
        final ok =
            _allowed[layer]!.any(target.startsWith) ||
            (own != null && target.startsWith(own));
        if (!ok) broken.add('$path imports $target');
      }
    }
    expect(broken, isEmpty, reason: broken.join('\n'));
  });
}
