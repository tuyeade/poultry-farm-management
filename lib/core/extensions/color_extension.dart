import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Returns a copy of this color with the provided values applied.
  /// Currently supports `alpha` (0.0 - 1.0).
  Color withValues({double? alpha}) {
    if (alpha != null) {
      final a = alpha.clamp(0.0, 1.0);
      final intA = (a * 255).round().clamp(0, 255);
      final int r = (this.r * 255).round().clamp(0, 255);
      final int g = (this.g * 255).round().clamp(0, 255);
      final int b = (this.b * 255).round().clamp(0, 255);
      return Color.fromARGB(intA, r, g, b);
    }

    return this;
  }
}
