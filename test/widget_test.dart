import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonora/themes/theme.dart';

void main() {
  test('SONORA theme exposes a Material 3 dark surface', () {
    final theme = AppTheme.dark(primary: Colors.white);
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.surface, Colors.black);
    expect(theme.colorScheme.onSurface, Colors.white);
  });
}
