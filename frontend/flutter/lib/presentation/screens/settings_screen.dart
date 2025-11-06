import 'package:flutter/material.dart';
import 'package:axle/data/services/app_config_service.dart';
import 'package:axle/data/services/connectivity_service.dart';

/// Settings screen for configuring application settings.
///
/// Allows users to configure the API server URL and view connectivity status.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _configService = AppConfigService();
  final _connectivityService = ConnectivityService();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isUsingCustomUrl = false;
  bool _isCheckingServer = false;
  bool _serverReachable = false;
  ConnectivityStatus _connectivityStatus = ConnectivityStatus.unknown;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _connectivityStatus = _connectivityService.currentStatus;

    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((status) {
      if (mounted) {
        setState(() {
          _connectivityStatus = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isUsingCustomUrl = _configService.isUsingCustomUrl();
      final customUrl = _configService.getStoredCustomUrl();
      _urlController.text = customUrl ?? '';
    });

    // Check server reachability
    await _checkServerReachability();
  }

  Future<void> _checkServerReachability() async {
    setState(() {
      _isCheckingServer = true;
    });

    final url = _configService.getApiUrl();
    final reachable = await _connectivityService.checkServerReachability(url);

    if (mounted) {
      setState(() {
        _serverReachable = reachable;
        _isCheckingServer = false;
      });
    }
  }

  Future<void> _saveCustomUrl() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _configService.setApiUrl(_urlController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server URL saved. Restart the app for changes to take effect.'),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _isUsingCustomUrl = true;
        });
        await _checkServerReachability();
      }
    }
  }

  Future<void> _resetToDefault() async {
    await _configService.resetToDefault();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default. Restart the app for changes to take effect.'),
          duration: Duration(seconds: 4),
        ),
      );
      setState(() {
        _isUsingCustomUrl = false;
      });
      await _checkServerReachability();
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a URL';
    }

    final trimmed = value.trim();

    // Check if it's a valid URL format
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }

    try {
      final uri = Uri.parse(trimmed);
      if (uri.host.isEmpty) {
        return 'Invalid URL format';
      }
    } catch (e) {
      return 'Invalid URL format';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = _configService.getApiUrl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Connectivity Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connection Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _connectivityStatus == ConnectivityStatus.connected
                            ? Icons.wifi
                            : Icons.wifi_off,
                        color: _connectivityStatus == ConnectivityStatus.connected
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _connectivityStatus == ConnectivityStatus.connected
                            ? 'Network Connected'
                            : _connectivityStatus == ConnectivityStatus.disconnected
                                ? 'Network Disconnected'
                                : 'Network Status Unknown',
                        style: TextStyle(
                          color: _connectivityStatus == ConnectivityStatus.connected
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _serverReachable ? Icons.check_circle : Icons.error,
                        color: _serverReachable ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isCheckingServer
                              ? 'Checking server...'
                              : _serverReachable
                                  ? 'Server Reachable'
                                  : 'Server Unreachable',
                          style: TextStyle(
                            color: _serverReachable ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      if (!_isCheckingServer)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _checkServerReachability,
                          tooltip: 'Refresh',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Current Server URL Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Server',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentUrl,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isUsingCustomUrl ? 'Using custom URL' : 'Using default URL',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Configure Server URL Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure Server URL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter a custom server URL or use the default.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Server URL',
                        hintText: 'http://localhost:5103',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dns),
                      ),
                      validator: _validateUrl,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveCustomUrl,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetToDefault,
                            icon: const Icon(Icons.restore),
                            label: const Text('Reset to Default'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: You need to restart the app for changes to take effect.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Offline Mode Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Offline Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The app can operate in offline mode. When disconnected from the server, '
                    'authentication features will be unavailable, but you can still access '
                    'cached data and configure settings.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
