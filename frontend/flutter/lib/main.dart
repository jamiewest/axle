import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/routing/app_router.dart';
import 'package:axle/data/services/aspnetcore_identity_sign_in_manager.dart';
import 'package:axle/data/services/mock_sign_in_manager.dart';
import 'package:axle/data/services/telemetry_service.dart';
import 'package:axle/data/services/app_config_service.dart';
import 'package:axle/data/services/connectivity_service.dart';
import 'package:axle/domain/models/telemetry_config.dart';
import 'package:axle/domain/services/sign_in_manager.dart';

/// Application entry point.
///
/// Initializes telemetry and runs the app with error handling.
void main() {
  // Run app with zone guarding for error capture
  // All initialization must happen inside the zone to avoid zone mismatch
  runZonedGuarded(
    () async {
      // Ensure Flutter binding is initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables
      await dotenv.load(fileName: '.env');

      // Initialize app configuration service
      await AppConfigService().initialize();

      // Initialize connectivity service
      await ConnectivityService().initialize();

      // Initialize telemetry if enabled
      await _initializeTelemetry();

      // Run the app
      runApp(const MainApp());
    },
    (error, stack) {
      // Capture uncaught async errors
      TelemetryService().logError(
        'Uncaught async error',
        error: error,
        stackTrace: stack,
        attributes: {'error.source': 'runZonedGuarded'},
      );
    },
  );
}

/// Initialize telemetry service based on environment configuration.
Future<void> _initializeTelemetry() async {
  final enabled = dotenv.env['TELEMETRY_ENABLED']?.toLowerCase() == 'true';
  final serviceUrl =
      dotenv.env['TELEMETRY_SERVICE_URL'] ?? 'http://localhost:5200';

  if (enabled) {
    final config = TelemetryConfig.development(
      serviceUrl: serviceUrl,
      appVersion: '0.1.0',
    );

    await TelemetryService().initialize(config: config);
    TelemetryService().setupErrorHandlers();
  } else {
    // Initialize as disabled
    await TelemetryService().initialize(config: TelemetryConfig.disabled());
  }
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
