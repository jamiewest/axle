import 'package:flutter/material.dart';
import 'package:axle/domain/services/sign_in_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';

/// Simple home view shown after successful authentication.
class HomeView extends StatelessWidget {
  const HomeView({required this.signInManager, super.key});

  final SignInManager signInManager;

  Future<void> _handleSignOut(BuildContext context) async {
    await signInManager.signOut();
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompact = context.isCompactLayout;
    final isExpandedOrLarger = context.isExpandedOrLarger;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: AdaptiveContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: isCompact
                    ? 80
                    : isExpandedOrLarger
                    ? 120
                    : 100,
                color: colorScheme.primary,
              ),
              SizedBox(height: isCompact ? 24 : 32),
              Text(
                'Welcome!',
                style:
                    (isCompact
                            ? theme.textTheme.headlineLarge
                            : theme.textTheme.displaySmall)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: isCompact ? 8 : 12),
              Text(
                'You are successfully signed in',
                style:
                    (isCompact
                            ? theme.textTheme.bodyLarge
                            : theme.textTheme.titleLarge)
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isCompact ? 48 : 64),
              // Use different layout for compact vs expanded
              if (isExpandedOrLarger)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.push('/grpc-demo'),
                      icon: const Icon(Icons.stream),
                      label: const Text('gRPC Live Updates Demo'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.push('/grpc-demo'),
                      icon: const Icon(Icons.stream),
                      label: const Text('gRPC Live Updates Demo'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
