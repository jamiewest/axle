import 'package:flutter/material.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';

/// Adaptive scaffold that adjusts navigation based on screen size.
///
/// - Compact: Bottom navigation or drawer
/// - Medium+: Navigation rail
/// - Expanded+: Navigation rail with labels or drawer
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.body,
    this.destinations = const [],
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.useDrawer = false,
    this.drawer,
    super.key,
  });

  final Widget body;
  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool useDrawer;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactLayout;
    final isExpandedOrLarger = context.isExpandedOrLarger;

    // For screens with no navigation items, use simple scaffold
    if (destinations.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: title, actions: actions),
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      );
    }

    // Compact: Use bottom navigation or drawer
    if (isCompact) {
      return Scaffold(
        appBar: AppBar(title: title, actions: actions),
        body: body,
        bottomNavigationBar: useDrawer
            ? null
            : NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations
                    .map((dest) => dest.toNavigationDestination())
                    .toList(),
              ),
        drawer: useDrawer ? drawer : null,
        floatingActionButton: floatingActionButton,
      );
    }

    // Medium and larger: Use navigation rail
    return Scaffold(
      appBar: AppBar(title: title, actions: actions),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: isExpandedOrLarger
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.selected,
            destinations: destinations
                .map((dest) => dest.toNavigationRailDestination())
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Navigation destination for adaptive scaffold.
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  /// Convert to Flutter's NavigationDestination for NavigationBar.
  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
    );
  }

  /// Convert to NavigationRailDestination for NavigationRail.
  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: Text(label),
    );
  }
}

/// Adaptive container that centers content on large screens.
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({
    required this.child,
    this.padding,
    this.alignment,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.contentMaxWidth;
    final adaptivePadding = padding ?? context.adaptivePadding;

    return Center(
      child: Container(
        constraints: maxWidth != null
            ? BoxConstraints(maxWidth: maxWidth)
            : null,
        padding: adaptivePadding,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

/// Adaptive grid that adjusts columns based on screen size.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final columns = context.gridColumns;

    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: runSpacing),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children
          .map(
            (child) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width -
                      spacing * (columns - 1) -
                      32) /
                  columns,
              child: child,
            ),
          )
          .toList(),
    );
  }
}

/// Adaptive layout builder for responsive designs.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    super.key,
  });

  final WidgetBuilder? compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;
  final WidgetBuilder? extraLarge;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.windowSizeClass;

    switch (sizeClass) {
      case WindowSizeClass.compact:
        return (compact ?? medium ?? expanded ?? large ?? extraLarge)!(context);
      case WindowSizeClass.medium:
        return (medium ?? compact ?? expanded ?? large ?? extraLarge)!(context);
      case WindowSizeClass.expanded:
        return (expanded ?? large ?? extraLarge ?? medium ?? compact)!(context);
      case WindowSizeClass.large:
        return (large ?? extraLarge ?? expanded ?? medium ?? compact)!(context);
      case WindowSizeClass.extraLarge:
        return (extraLarge ?? large ?? expanded ?? medium ?? compact)!(context);
    }
  }
}
