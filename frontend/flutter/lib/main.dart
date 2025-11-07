import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/routing/app_router.dart';
import 'package:axle/data/services/aspnetcore_identity_sign_in_manager.dart';
import 'package:axle/data/services/mock_sign_in_manager.dart';
import 'package:axle/data/services/app_config_service.dart';
import 'package:axle/data/services/connectivity_service.dart';
import 'package:axle/domain/services/sign_in_manager.dart';

/// Application entry point.
///
/// Initializes the app with minimal blocking for fast startup.
void main() async {
  final startTime = DateTime.now();
  developer.log('App startup initiated', name: 'Startup');

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  _logElapsed(startTime, 'Flutter binding initialized');

  // Only initialize critical services synchronously
  try {
    await dotenv.load(fileName: '.env');
    _logElapsed(startTime, '.env loaded');
  } catch (e) {
    developer.log('No .env file found, continuing...', name: 'Startup');
  }

  await AppConfigService().initialize();
  _logElapsed(startTime, 'AppConfig initialized');

  // Run the app
  runApp(const MainApp());
  _logElapsed(startTime, 'App started');

  // Initialize non-critical services after app starts
  ConnectivityService()
      .initialize()
      .then((_) {
        _logElapsed(startTime, 'Connectivity service initialized');
      })
      .catchError((_) {});
}

void _logElapsed(DateTime startTime, String message) {
  final elapsed = DateTime.now().difference(startTime).inMilliseconds;
  developer.log('[$elapsed ms] $message', name: 'Startup');
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
      // Get API URL from stored config, .env, or default
      final configService = AppConfigService();
      final apiBaseUrl = configService.isUsingCustomUrl()
          ? configService.getApiUrl()
          : (dotenv.env['API_URL'] ?? configService.getApiUrl());

      final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
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
