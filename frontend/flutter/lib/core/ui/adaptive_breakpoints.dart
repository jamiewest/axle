import 'package:flutter/material.dart';

/// Material Design 3 adaptive breakpoints for responsive layouts.
///
/// Based on Material Design 3 guidelines:
/// - Compact: 0-599dp (phones in portrait)
/// - Medium: 600-839dp (tablets in portrait, foldables)
/// - Expanded: 840-1199dp (tablets in landscape, desktops)
/// - Large: 1200-1599dp (large tablets, desktops)
/// - Extra Large: 1600dp+ (ultra-wide displays)
class AdaptiveBreakpoints {
  // Material 3 standard breakpoints
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1600;

  /// Get the current window size class.
  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < compact) {
      return WindowSizeClass.compact;
    } else if (width < medium) {
      return WindowSizeClass.medium;
    } else if (width < expanded) {
      return WindowSizeClass.expanded;
    } else if (width < large) {
      return WindowSizeClass.large;
    } else {
      return WindowSizeClass.extraLarge;
    }
  }

  /// Check if the screen is compact (mobile phone).
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compact;
  }

  /// Check if the screen is medium or larger (tablet+).
  static bool isMediumOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= compact;
  }

  /// Check if the screen is expanded or larger (landscape tablet+).
  static bool isExpandedOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= medium;
  }

  /// Check if the screen is large or extra large (desktop).
  static bool isLargeOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= expanded;
  }

  /// Get adaptive padding based on screen size.
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return const EdgeInsets.all(16.0);
      case WindowSizeClass.medium:
        return const EdgeInsets.all(24.0);
      case WindowSizeClass.expanded:
      case WindowSizeClass.large:
        return const EdgeInsets.all(32.0);
      case WindowSizeClass.extraLarge:
        return const EdgeInsets.all(40.0);
    }
  }

  /// Get adaptive margin based on screen size.
  static double getAdaptiveMargin(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return 16.0;
      case WindowSizeClass.medium:
        return 24.0;
      case WindowSizeClass.expanded:
      case WindowSizeClass.large:
        return 32.0;
      case WindowSizeClass.extraLarge:
        return 48.0;
    }
  }

  /// Get adaptive content max width.
  static double? getContentMaxWidth(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
      case WindowSizeClass.medium:
        return null; // Use full width
      case WindowSizeClass.expanded:
        return 840.0;
      case WindowSizeClass.large:
        return 1024.0;
      case WindowSizeClass.extraLarge:
        return 1200.0;
    }
  }

  /// Get number of columns for grid layouts.
  static int getGridColumns(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return 1;
      case WindowSizeClass.medium:
        return 2;
      case WindowSizeClass.expanded:
      case WindowSizeClass.large:
        return 3;
      case WindowSizeClass.extraLarge:
        return 4;
    }
  }
}

/// Window size classifications based on Material Design 3.
enum WindowSizeClass {
  /// 0-599dp: Phones in portrait
  compact,

  /// 600-839dp: Tablets in portrait, foldables
  medium,

  /// 840-1199dp: Tablets in landscape, desktops
  expanded,

  /// 1200-1599dp: Large tablets, desktops
  large,

  /// 1600dp+: Ultra-wide displays
  extraLarge,
}

/// Extension to get adaptive values based on screen size.
extension AdaptiveContext on BuildContext {
  /// Get the current window size class.
  WindowSizeClass get windowSizeClass =>
      AdaptiveBreakpoints.getWindowSizeClass(this);

  /// Check if compact layout should be used.
  bool get isCompactLayout => AdaptiveBreakpoints.isCompact(this);

  /// Check if medium or larger layout should be used.
  bool get isMediumOrLarger => AdaptiveBreakpoints.isMediumOrLarger(this);

  /// Check if expanded or larger layout should be used.
  bool get isExpandedOrLarger => AdaptiveBreakpoints.isExpandedOrLarger(this);

  /// Check if large or larger layout should be used.
  bool get isLargeOrLarger => AdaptiveBreakpoints.isLargeOrLarger(this);

  /// Get adaptive padding.
  EdgeInsets get adaptivePadding =>
      AdaptiveBreakpoints.getAdaptivePadding(this);

  /// Get adaptive margin.
  double get adaptiveMargin => AdaptiveBreakpoints.getAdaptiveMargin(this);

  /// Get content max width.
  double? get contentMaxWidth => AdaptiveBreakpoints.getContentMaxWidth(this);

  /// Get grid columns.
  int get gridColumns => AdaptiveBreakpoints.getGridColumns(this);
}
