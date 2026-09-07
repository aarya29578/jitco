import 'package:flutter/material.dart';

@immutable
class JlAppGradient extends ThemeExtension<JlAppGradient> {
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;

  const JlAppGradient({
    required this.primaryGradient,
    required this.secondaryGradient,
  });

  @override
  JlAppGradient copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
  }) {
    return JlAppGradient(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
    );
  }

  @override
  JlAppGradient lerp(ThemeExtension<JlAppGradient>? other, double t) {
    if (other is! JlAppGradient) return this;
    return JlAppGradient(
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      secondaryGradient: LinearGradient.lerp(
        secondaryGradient,
        other.secondaryGradient,
        t,
      )!,
    );
  }
}
