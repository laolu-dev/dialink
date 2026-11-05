import 'package:flutter/material.dart';

import 'package:dialink/src/config/theme/app_palette.dart';

/// The onboarding illustrations as SVG, drawn in the active theme's colours
/// so they follow the theme and stay sharp at any size.
abstract final class OnboardingIllustrations {
  static List<String> all(AppPalette p) => [
    _findDoctor(p),
    _book(p),
    _manage(p),
  ];

  static Color _accent(AppPalette p) => p.accent;

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static String _fill(Color c) =>
      'fill="${_hex(c)}" fill-opacity="${c.a.toStringAsFixed(2)}"';

  static String _stroke(Color c, double width) =>
      'stroke="${_hex(c)}" stroke-opacity="${c.a.toStringAsFixed(2)}" stroke-width="$width"';

  static double _line(AppPalette p) => p.borderWidth > 1 ? 2 : 1.2;

  /// The colour on the badge, readable on [_accent].
  static String _onAccent(AppPalette p) =>
      _hex(p.outlinedStatus ? p.background : p.surfaceSolid);

  static String _findDoctor(AppPalette p) {
    final rows = StringBuffer();
    for (var i = 0; i < 3; i++) {
      final x = 44 + i * 4, y = 68 + i * 30, w = 112 - i * 8;
      rows.write(
        '''
<rect x="$x" y="$y" width="$w" height="24" rx="10" ${_fill(p.surface)} ${_stroke(i == 0 ? p.primary : p.border, i == 0 ? 2 : _line(p))}/>
<circle cx="${x + 14}" cy="${y + 12}" r="7" ${_fill(p.tint)} ${_stroke(p.primary, 1.2)}/>
<rect x="${x + 26}" y="${y + 7}" width="${46 - i * 6}" height="5" rx="2.5" ${_fill(p.text)}/>
<rect x="${x + 26}" y="${y + 15}" width="${30 - i * 4}" height="4" rx="2" ${_fill(p.muted)}/>''',
      );
    }
    return '''
<svg viewBox="0 0 200 170" xmlns="http://www.w3.org/2000/svg">
<circle cx="100" cy="88" r="72" ${_fill(p.tint)}/>
<rect x="38" y="30" width="124" height="26" rx="13" ${_fill(p.surface)} ${_stroke(p.border, _line(p))}/>
<circle cx="54" cy="43" r="5" fill="none" ${_stroke(p.muted, 2)}/>
<line x1="58" y1="47" x2="62" y2="51" ${_stroke(p.muted, 2)} stroke-linecap="round"/>
<rect x="70" y="40" width="54" height="6" rx="3" ${_fill(p.border)}/>
$rows
<circle cx="150" cy="122" r="17" fill="none" ${_stroke(_accent(p), 5)}/>
<line x1="162" y1="134" x2="174" y2="146" ${_stroke(_accent(p), 6)} stroke-linecap="round"/>
</svg>''';
  }

  static String _book(AppPalette p) {
    final days = StringBuffer();
    for (var i = 0; i < 5; i++) {
      days.write(
        '<rect x="${50 + i * 21}" y="58" width="16" height="20" rx="5" ${_fill(i == 1 ? p.primary : p.tint)}/>',
      );
    }
    final times = StringBuffer();
    for (var i = 0; i < 6; i++) {
      final picked = i == 2;
      times.write(
        '<rect x="${52 + (i % 3) * 33}" y="${88 + (i ~/ 3) * 22}" width="28" height="16" rx="8" '
        '${_fill(picked ? p.primary : p.surface)} ${_stroke(picked ? p.primary : p.border, _line(p))}/>',
      );
    }
    return '''
<svg viewBox="0 0 200 170" xmlns="http://www.w3.org/2000/svg">
<circle cx="100" cy="88" r="72" ${_fill(p.tint)}/>
<rect x="40" y="26" width="120" height="118" rx="16" ${_fill(p.surface)} ${_stroke(p.border, _line(p))}/>
<path d="M40 44 a16 16 0 0 1 16 -16 h88 a16 16 0 0 1 16 16 v6 h-120z" ${_fill(p.primary)}/>
<rect x="62" y="18" width="6" height="16" rx="3" ${_fill(p.text)}/>
<rect x="132" y="18" width="6" height="16" rx="3" ${_fill(p.text)}/>
$days
$times
<circle cx="152" cy="132" r="15" ${_fill(_accent(p))}/>
<path d="M145 132 l5 5 l9 -10" fill="none" stroke="${_onAccent(p)}" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';
  }

  static String _manage(AppPalette p) =>
      '''
<svg viewBox="0 0 200 170" xmlns="http://www.w3.org/2000/svg">
<circle cx="100" cy="88" r="72" ${_fill(p.tint)}/>
<rect x="36" y="40" width="128" height="86" rx="16" ${_fill(p.surface)} ${_stroke(p.border, _line(p))}/>
<circle cx="56" cy="62" r="10" ${_fill(p.tint)} ${_stroke(p.primary, 1.4)}/>
<rect x="72" y="56" width="52" height="6" rx="3" ${_fill(p.text)}/>
<rect x="72" y="66" width="34" height="5" rx="2.5" ${_fill(p.muted)}/>
<rect x="48" y="82" width="62" height="16" rx="8" ${_fill(p.successBg)} ${_stroke(p.successFg, p.outlinedStatus ? 1.5 : 0)}/>
<path d="M55 90 l3 3 l6 -6" fill="none" ${_stroke(p.successFg, 2.4)} stroke-linecap="round"/>
<rect x="68" y="87" width="34" height="5" rx="2.5" ${_fill(p.successFg)}/>
<rect x="48" y="104" width="50" height="14" rx="7" ${_fill(p.primary)}/>
<rect x="104" y="104" width="48" height="14" rx="7" fill="none" ${_stroke(p.border, _line(p))}/>
<g transform="translate(150 40)">
<circle r="20" ${_fill(_accent(p))}/>
<path d="M-9 -2 a9 9 0 0 1 16 -4 M8 -10 v5 h-5 M9 2 a9 9 0 0 1 -16 4 M-8 10 v-5 h5" fill="none" stroke="${_onAccent(p)}" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
</g>
</svg>''';
}
