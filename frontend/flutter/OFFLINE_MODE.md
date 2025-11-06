# Offline Mode and Server Configuration

The Axle Flutter app now supports offline operation and configurable server URLs.

## Features

### 1. Configurable Server URL

Users can configure the API server URL through the Settings screen, which is accessible from:
- The login screen (settings icon in the app bar)
- The home screen (settings button or icon in the app bar)

#### Configuration Priority

The app determines the server URL in the following order:
1. **Custom URL** (if configured in settings)
2. **Environment Variable** (from `.env` file: `API_URL`)
3. **Default URL** (`http://localhost:5103`)

### 2. Offline Mode Support

The app gracefully handles disconnected states:
- **Network Detection**: Automatically detects network connectivity status
- **Server Reachability**: Checks if the configured server is reachable
- **User-Friendly Error Messages**: Provides clear feedback for connection issues
- **Settings Access**: Users can access settings even when offline to change server configuration

### 3. Settings Screen

The settings screen provides:
- **Connection Status**: Real-time network and server connectivity status
- **Current Server URL**: Display of the active server URL
- **Custom URL Configuration**: Ability to set a custom server URL
- **URL Validation**: Ensures URLs are properly formatted
- **Reset to Default**: Option to revert to default settings
- **Server Health Check**: Button to manually check server reachability

## Usage

### For End Users

1. **Configure Server URL**:
   - Open the Settings screen from the login or home screen
   - Enter your server URL (e.g., `http://192.168.1.100:5103` or `https://api.example.com`)
   - Click "Save"
   - Restart the app for changes to take effect

2. **Check Connection Status**:
   - Open Settings to view network and server connectivity status
   - Use the refresh button to manually check server reachability

3. **Reset to Default**:
   - Open Settings
   - Click "Reset to Default" to use the default server URL
   - Restart the app for changes to take effect

### For Developers

#### Environment Configuration

Create a `.env` file in the Flutter project root:

```env
# Backend API URL
API_URL=http://localhost:5103

# Telemetry configuration
TELEMETRY_ENABLED=true
TELEMETRY_SERVICE_URL=http://localhost:5200
```

#### Services

The following services handle offline functionality:

1. **AppConfigService** (`lib/data/services/app_config_service.dart`)
   - Manages persistent storage of configuration settings
   - Provides API URL configuration with fallbacks

2. **ConnectivityService** (`lib/data/services/connectivity_service.dart`)
   - Monitors network connectivity changes
   - Provides server reachability checks
   - Streams connectivity status updates

3. **NetworkExceptionHelper** (`lib/core/exceptions/network_exception.dart`)
   - Identifies network-related exceptions
   - Provides user-friendly error messages
   - Categorizes different types of network errors

#### Architecture

```
User Input → AppConfigService → SharedPreferences
                ↓
            Main.dart → ApiConfig → SignInManager → HTTP Requests
                                         ↓
                          NetworkExceptionHelper (on error)
```

#### Adding to Existing Screens

To add connectivity status to any screen:

```dart
import 'package:axle/data/services/connectivity_service.dart';

// In your state:
ConnectivityStatus _status = ConnectivityService().currentStatus;

@override
void initState() {
  super.initState();

  // Listen for connectivity changes
  ConnectivityService().connectivityStream.listen((status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  });
}
```

## Technical Details

### Dependencies

- **shared_preferences**: Persistent storage for configuration
- **connectivity_plus**: Network connectivity monitoring
- **http**: HTTP client for API requests

### Error Handling

Network errors are caught and transformed into user-friendly messages:

| Exception Type | User Message |
|----------------|--------------|
| SocketException | "Cannot connect to server. Please check your network connection and server settings." |
| TimeoutException | "Connection timed out. The server is taking too long to respond." |
| Failed host lookup | "Cannot find server. Please check the server URL in settings." |
| Connection refused | "Server connection refused. Please verify the server is running." |

### Offline Capabilities

The app currently supports the following in offline mode:
- Access to Settings screen
- Configuration of server URL
- Viewing cached connection status

### Future Enhancements

Potential improvements:
- Cache authentication tokens for offline access
- Offline data persistence
- Queue network requests for retry when connection is restored
- Background sync when connectivity is restored
