import 'package:flutter/material.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/routing/app_router.dart';
import 'package:axle/data/services/aspnetcore_identity_sign_in_manager.dart';
import 'package:axle/data/services/mock_sign_in_manager.dart';
import 'package:axle/domain/services/sign_in_manager.dart';

void main() {
  runApp(const MainApp());
}

/// Main application widget.
///
/// Configures authentication with either mock or real API implementation.
/// Set [_useMockAuth] to false to use ASP.NET Core Identity API.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// Set to false to use real ASP.NET Core Identity API.
  static const bool _useMockAuth = false;

  /// API configuration for production use.
  static const String _apiBaseUrl = 'http://localhost:5103';

  late final SignInManager _signInManager;
  late final _router = createAppRouter(_signInManager);

  @override
  void initState() {
    super.initState();
    _signInManager = _createSignInManager();
  }

  SignInManager _createSignInManager() {
    if (_useMockAuth) {
      return MockSignInManager();
    } else {
      final apiConfig = ApiConfig(baseUrl: _apiBaseUrl);
      return AspNetCoreIdentitySignInManager(apiConfig: apiConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Axle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
