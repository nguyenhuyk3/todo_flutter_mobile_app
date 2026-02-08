import 'package:flutter/widgets.dart';

/// Chuyển hex string (vd: #EF4444) sang [Color].
Color colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(
    0xFF000000 | int.parse(h.length == 6 ? h : h.padRight(6, '0'), radix: 16),
  );
}

/// Chuyển [Color] sang hex string (#rrggbb) để lưu DB.
String colorToHex(Color color) {
  // ignore: deprecated_member_use
  return '#${color.red.toRadixString(16).padLeft(2, '0')}'
      // ignore: deprecated_member_use
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      // ignore: deprecated_member_use
      '${color.blue.toRadixString(16).padLeft(2, '0')}';
}
