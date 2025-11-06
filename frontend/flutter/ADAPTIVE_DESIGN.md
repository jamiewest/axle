# Material Design 3 Adaptive Layout Implementation

## Overview

The Axle Flutter app has been enhanced with comprehensive Material Design 3 adaptive layouts that automatically adjust to different screen sizes and form factors. The implementation follows Material Design 3 guidelines for responsive design across mobile phones, tablets, and desktop devices.

## Key Features

### 1. Adaptive Breakpoints

Based on Material Design 3 window size classes:

| Size Class | Width Range | Target Devices | Layout Behavior |
|------------|-------------|----------------|-----------------|
| **Compact** | 0-599dp | Phones in portrait | Single column, bottom navigation, compact spacing |
| **Medium** | 600-839dp | Tablets in portrait, foldables | Two columns possible, navigation rail appears |
| **Expanded** | 840-1199dp | Tablets in landscape, small desktops | Multi-column layouts, navigation rail with labels |
| **Large** | 1200-1599dp | Large tablets, desktops | Wide layouts, max content width constraints |
| **Extra Large** | 1600dp+ | Ultra-wide displays | Maximum content width, generous spacing |

### 2. Adaptive Navigation

**Compact Screens (< 600dp)**:
- Bottom navigation bar
- App bar with actions
- Drawer for additional navigation (optional)

**Medium+ Screens (≥ 600dp)**:
- Navigation rail on the left side
- Vertical divider
- More screen real estate for content

**Expanded+ Screens (≥ 840dp)**:
- Navigation rail with text labels
- Expanded content area
- Side-by-side layouts where appropriate

### 3. Responsive Components

All major screens adapt automatically:

- **Settings Screen**: Cards resize, buttons stack on mobile/row on desktop
- **Home Screen**: Icon sizes scale, buttons arrange vertically/horizontally
- **Login Screen**: Form width constrained, typography scales
- **All Screens**: Padding, margins, and spacing adjust based on screen size

## Implementation Files

### Core Utilities

#### `/lib/core/ui/adaptive_breakpoints.dart`

Defines breakpoint constants and utility functions:

```dart
// Check screen size
final isCompact = context.isCompactLayout;
final isMediumOrLarger = context.isMediumOrLarger;
final isExpandedOrLarger = context.isExpandedOrLarger;

// Get adaptive values
final padding = context.adaptivePadding;
final margin = context.adaptiveMargin;
final maxWidth = context.contentMaxWidth;
final columns = context.gridColumns;
```

#### `/lib/core/ui/adaptive_scaffold.dart`

Provides adaptive components:

- `AdaptiveScaffold`: Automatic navigation pattern selection
- `AdaptiveContainer`: Centers content with max width on large screens
- `AdaptiveGrid`: Responsive grid that adjusts columns
- `AdaptiveLayout`: Build different layouts per screen size

## Usage Examples

### Basic Adaptive Layout

```dart
import 'package:axle/core/ui/adaptive_breakpoints.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactLayout;

    return Scaffold(
      body: Padding(
        padding: context.adaptivePadding,
        child: Column(
          children: [
            Text(
              'Title',
              style: TextStyle(
                fontSize: isCompact ? 24 : 32,
              ),
            ),
            // Content adapts automatically
          ],
        ),
      ),
    );
  }
}
```

### Adaptive Container with Max Width

```dart
import 'package:axle/core/ui/adaptive_scaffold.dart';

Scaffold(
  body: AdaptiveContainer(
    child: ListView(
      children: [
        // Content automatically centers and constrains width
        // on large screens
      ],
    ),
  ),
)
```

### Conditional Layouts

```dart
// Different layout for mobile vs desktop
if (context.isExpandedOrLarger)
  Row(
    children: [
      Expanded(child: button1),
      SizedBox(width: 16),
      Expanded(child: button2),
    ],
  )
else
  Column(
    children: [
      button1,
      SizedBox(height: 12),
      button2,
    ],
  )
```

### Adaptive Grid

```dart
AdaptiveGrid(
  spacing: 16,
  runSpacing: 16,
  children: [
    Card(child: Text('Item 1')),
    Card(child: Text('Item 2')),
    Card(child: Text('Item 3')),
  ],
)
// Automatically shows 1, 2, 3, or 4 columns based on screen size
```

### Multiple Layout Variants

```dart
AdaptiveLayout(
  compact: (context) => CompactPhoneLayout(),
  medium: (context) => TabletLayout(),
  expanded: (context) => DesktopLayout(),
)
```

## Design Principles

### 1. Progressive Enhancement

Start with mobile-first design, then enhance for larger screens:

```dart
// Base design for mobile
Icon(Icons.home, size: 24)

// Enhanced for larger screens
Icon(
  Icons.home,
  size: isCompact ? 24 : isExpandedOrLarger ? 32 : 28,
)
```

### 2. Content-First Approach

Content determines layout, not device:

```dart
// Max width ensures readability on ultra-wide displays
AdaptiveContainer(
  child: Text(longArticle),
)
```

### 3. Touch Target Sizes

Maintain minimum 48dp touch targets across all sizes:

```dart
IconButton(
  icon: Icon(Icons.settings),
  iconSize: isCompact ? 24 : 28, // Icon scales
  // But touch target remains 48dp minimum
)
```

### 4. Responsive Typography

Text scales with screen size for better readability:

```dart
Text(
  'Headline',
  style: (isCompact
      ? theme.textTheme.headlineMedium
      : theme.textTheme.headlineLarge),
)
```

## Testing Adaptive Layouts

### Chrome DevTools

1. Open app in Chrome
2. Open DevTools (F12)
3. Toggle device toolbar (Ctrl+Shift+M / Cmd+Shift+M)
4. Test different device sizes:
   - iPhone SE (375x667) - Compact
   - iPad (768x1024) - Medium
   - iPad Pro (1024x1366) - Expanded
   - Desktop (1920x1080) - Large

### Flutter DevTools

```bash
flutter run -d chrome
```

Use the device toolbar to test responsive breakpoints in real-time.

### Manual Testing

```dart
// Test specific sizes in your code
MediaQuery(
  data: MediaQueryData(size: Size(1024, 768)),
  child: MyApp(),
)
```

## Screen-by-Screen Breakdown

### Settings Screen

**Compact (Phone)**:
- Single column cards
- Stacked buttons (Save / Reset)
- 16dp padding
- 18px headings

**Medium+ (Tablet/Desktop)**:
- Centered content with max width
- Side-by-side buttons
- 24-32dp padding
- 20px headings
- Larger icons

### Home Screen

**Compact (Phone)**:
- 80dp icon
- Vertical button stack
- Headline Large text
- 24dp spacing

**Expanded+ (Desktop)**:
- 120dp icon
- Horizontal button row
- Display Small text
- 32-64dp spacing
- Content centered with max width

### Login Screen

**All Sizes**:
- Constrained width (400-600dp)
- Centered on screen
- Adaptive padding
- Responsive typography
- Form scales appropriately

## Performance Considerations

### Build Optimization

The adaptive utilities are lightweight:
- No additional dependencies
- Extension methods compile away
- MediaQuery lookups are cached by Flutter
- Minimal runtime overhead

### Layout Recalculation

Layouts rebuild on orientation change or window resize:
```dart
// Automatically handled by MediaQuery
context.isCompactLayout // Recomputes on size change
```

## Migration Guide

### Converting Existing Screens

1. **Add imports**:
```dart
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
```

2. **Replace fixed values with adaptive ones**:
```dart
// Before
padding: const EdgeInsets.all(24.0)

// After
padding: context.adaptivePadding
```

3. **Add size-specific logic**:
```dart
// Check screen size
final isCompact = context.isCompactLayout;

// Use conditional values
fontSize: isCompact ? 18 : 20
```

4. **Wrap content appropriately**:
```dart
// Before
body: ListView(...)

// After
body: AdaptiveContainer(
  child: ListView(...),
)
```

## Best Practices

### DO:

✅ Use extension methods from `AdaptiveContext`
✅ Test on multiple screen sizes
✅ Start with mobile, enhance for desktop
✅ Use `AdaptiveContainer` for content max-width
✅ Provide both compact and expanded layouts
✅ Scale icons and typography
✅ Adjust spacing and padding

### DON'T:

❌ Hardcode pixel values without consideration
❌ Assume screen orientation
❌ Ignore touch target sizes
❌ Over-complicate with too many breakpoints
❌ Forget to test on actual devices
❌ Rely solely on MediaQuery directly

## Future Enhancements

### Planned Features

- **Responsive Images**: Serve different image sizes based on screen
- **Adaptive Animations**: Scale animation durations/distances
- **Platform-Specific Patterns**: iOS vs Android vs Web adaptations
- **Orientation Handling**: Portrait vs landscape optimizations
- **Accessibility Scaling**: Respect user text size preferences

### Possible Improvements

- Add theme variants for different screen sizes
- Implement adaptive card layouts
- Create responsive data tables
- Add split-view for large screens
- Implement master-detail patterns

## Resources

- [Material Design 3 - Layout](https://m3.material.io/foundations/layout)
- [Material Design 3 - Adaptive Design](https://m3.material.io/foundations/adaptive-design)
- [Flutter Adaptive UI](https://docs.flutter.dev/ui/layout/responsive)
- [Material 3 Components](https://m3.material.io/components)

## Support

For issues or questions about adaptive layouts:

1. Check this documentation
2. Review `/lib/core/ui/adaptive_*.dart` files
3. Test in Chrome DevTools with device emulation
4. Refer to Material Design 3 guidelines

---

**Implementation Date**: 2025-11-06
**Flutter Version**: 3.35.7
**Material Design Version**: 3
