import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  // Spacing
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 999.0;

  // Icon Sizes
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;

  // Common Heights
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 70.0;

  // Card
  static const double cardElevation = 2.0;

  // Common EdgeInsets
  static const EdgeInsets pagePadding = EdgeInsets.all(md);

  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets verticalPadding =
      EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
}