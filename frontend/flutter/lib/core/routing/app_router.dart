import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/logging/app_logger.dart';
import 'package:axle/domain/services/sign_in_manager.dart';
import 'package:axle/presentation/auth/confirm_account_view.dart';
import 'package:axle/presentation/auth/create_account_view.dart';
import 'package:axle/presentation/auth/forgot_password_view.dart';
import 'package:axle/presentation/auth/login_view.dart';
import 'package:axle/presentation/auth/reset_password_view.dart';
import 'package:axle/presentation/home/home_view.dart';
import 'package:axle/presentation/examples/live_updates_demo.dart';
import 'package:axle/presentation/screens/settings_screen.dart';
import 'package:axle/presentation/tenants/create_tenant_view.dart';
import 'package:axle/presentation/tenants/tenants_list_view.dart';
import 'package:axle/presentation/tenants/edit_tenant_view.dart';
import 'package:axle/presentation/tenants/tenant_detail_view.dart';
import 'package:axle/presentation/workspaces/create_workspace_view.dart';
import 'package:axle/presentation/workspaces/workspace_detail_view.dart';
import 'package:axle/presentation/nodes/create_node_view.dart';
import 'package:axle/presentation/nodes/node_detail_view.dart';

/// Navigation observer for logging route changes.
class _NavigationObserver extends NavigatorObserver {
  _NavigationObserver(this._logger);

  final AppLogger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logger.logInfo(
        'Route replaced: ${_getRouteName(oldRoute)} → ${_getRouteName(newRoute)}',
        attributes: {
          'navigation_type': 'replace',
          'old_route': _getRouteName(oldRoute),
          'new_route': _getRouteName(newRoute),
        },
      );
    }
  }

  void _logNavigation(String type, Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = _getRouteName(route);
    final previousRouteName = _getRouteName(previousRoute);

    _logger.logInfo(
      'Navigation $type: ${previousRouteName ?? '(none)'} → $routeName',
      attributes: {
        'navigation_type': type,
        'from_route': previousRouteName ?? 'none',
        'to_route': routeName,
      },
    );
  }

  String? _getRouteName(Route<dynamic>? route) {
    if (route == null) return null;
    if (route.settings.name != null) return route.settings.name;
    return route.toString();
  }
}

/// Creates and configures the application router.
///
/// The router handles navigation between authentication views and the main
/// application content. It uses [SignInManager] for authentication state.
GoRouter createAppRouter(SignInManager signInManager) {
  final logger = AppLogger('AppRouter');

  return GoRouter(
    initialLocation: '/',
    observers: [_NavigationObserver(logger)],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LoginView(
          signInManager: signInManager,
        ),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => CreateAccountView(
          signInManager: signInManager,
        ),
      ),
      GoRoute(
        path: '/confirm-account',
        builder: (context, state) {
          final extra = state.extra;
          String? email;
          String? userId;

          // Handle both String (legacy) and Map (new) formats
          if (extra is String) {
            email = extra;
          } else if (extra is Map<String, dynamic>) {
            email = extra['email'] as String?;
            userId = extra['userId'] as String?;
          }

          if (email == null) {
            return const _ErrorView(
              message: 'Email address is required',
            );
          }
          return ConfirmAccountView(
            signInManager: signInManager,
            email: email,
            userId: userId,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordView(
          signInManager: signInManager,
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.extra as String?;
          if (email == null) {
            return const _ErrorView(
              message: 'Email address is required',
            );
          }
          return ResetPasswordView(
            signInManager: signInManager,
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeView(
          signInManager: signInManager,
        ),
      ),
      GoRoute(
        path: '/grpc-demo',
        builder: (context, state) => const LiveUpdatesDemo(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/tenants',
        builder: (context, state) => const TenantsListView(),
      ),
      GoRoute(
        path: '/create-tenant',
        builder: (context, state) => const CreateTenantView(),
      ),
      GoRoute(
        path: '/tenant/:id',
        builder: (context, state) {
          final tenantId = state.pathParameters['id'];
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          return TenantDetailView(tenantId: tenantId);
        },
      ),
      GoRoute(
        path: '/edit-tenant/:id',
        builder: (context, state) {
          final tenantId = state.pathParameters['id'];
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          return EditTenantView(tenantId: tenantId);
        },
      ),
      GoRoute(
        path: '/tenant/:tenantId/create-workspace',
        builder: (context, state) {
          final tenantId = state.pathParameters['tenantId'];
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          return CreateWorkspaceView(tenantId: tenantId);
        },
      ),
      GoRoute(
        path: '/tenant/:tenantId/create-node',
        builder: (context, state) {
          final tenantId = state.pathParameters['tenantId'];
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          return CreateNodeView(tenantId: tenantId);
        },
      ),
      GoRoute(
        path: '/workspace/:id',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id'];
          if (workspaceId == null) {
            return const _ErrorView(
              message: 'Workspace ID is required',
            );
          }
          return WorkspaceDetailView(workspaceId: workspaceId);
        },
      ),
      GoRoute(
        path: '/workspace/:workspaceId/create-node',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId'];
          if (workspaceId == null) {
            return const _ErrorView(
              message: 'Workspace ID is required',
            );
          }
          // Get tenantId from extra if available
          final extra = state.extra as Map<String, dynamic>?;
          final tenantId = extra?['tenantId'] as String?;
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          return CreateNodeView(
            tenantId: tenantId,
            workspaceId: workspaceId,
          );
        },
      ),
      GoRoute(
        path: '/node/:id',
        builder: (context, state) {
          final nodeId = state.pathParameters['id'];
          if (nodeId == null) {
            return const _ErrorView(
              message: 'Node ID is required',
            );
          }
          return NodeDetailView(nodeId: nodeId);
        },
      ),
      GoRoute(
        path: '/tenant/:tenantId/node/:parentId/create-node',
        builder: (context, state) {
          final tenantId = state.pathParameters['tenantId'];
          final parentId = state.pathParameters['parentId'];
          if (tenantId == null) {
            return const _ErrorView(
              message: 'Tenant ID is required',
            );
          }
          if (parentId == null) {
            return const _ErrorView(
              message: 'Parent Node ID is required',
            );
          }
          return CreateNodeView(
            tenantId: tenantId,
            parentId: parentId,
          );
        },
      ),
    ],
  );
}

/// Simple error view for routing issues.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
