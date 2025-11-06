import 'package:flutter/material.dart';
import 'package:axle/data/services/app_config_service.dart';
import 'package:axle/data/services/connectivity_service.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';

/// Settings screen for configuring application settings with adaptive layout.
///
/// Adapts to different screen sizes following Material Design 3 principles.
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
            content: Text(
              'Server URL saved. Restart the app for changes to take effect.',
            ),
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
          content: Text(
            'Reset to default. Restart the app for changes to take effect.',
          ),
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
    final isCompact = context.isCompactLayout;
    final isExpandedOrLarger = context.isExpandedOrLarger;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 2),
      body: AdaptiveContainer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: context.adaptiveMargin),
            _buildConnectivityCard(context, isCompact),
            SizedBox(height: context.adaptiveMargin),
            _buildCurrentServerCard(context, currentUrl, isCompact),
            SizedBox(height: context.adaptiveMargin),
            _buildConfigureServerCard(context, isCompact, isExpandedOrLarger),
            SizedBox(height: context.adaptiveMargin),
            _buildOfflineModeCard(context, isCompact),
            SizedBox(height: context.adaptiveMargin),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityCard(BuildContext context, bool isCompact) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: TextStyle(
                fontSize: isCompact ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 16),
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
    );
  }

  Widget _buildCurrentServerCard(
    BuildContext context,
    String currentUrl,
    bool isCompact,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Server',
              style: TextStyle(
                fontSize: isCompact ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 16),
            Row(
              children: [
                Icon(Icons.link, size: isCompact ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentUrl,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: isCompact ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isUsingCustomUrl ? 'Using custom URL' : 'Using default URL',
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigureServerCard(
    BuildContext context,
    bool isCompact,
    bool isExpandedOrLarger,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Server URL',
                style: TextStyle(
                  fontSize: isCompact ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isCompact ? 12 : 16),
              Text(
                'Enter a custom server URL or use the default.',
                style: TextStyle(fontSize: isCompact ? 14 : 16),
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
              if (isExpandedOrLarger)
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
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveCustomUrl,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _resetToDefault,
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset to Default'),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                'Note: You need to restart the app for changes to take effect.',
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineModeCard(BuildContext context, bool isCompact) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: isCompact ? 24 : 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 12 : 16),
            Text(
              'The app can operate in offline mode. When disconnected from the server, '
              'authentication features will be unavailable, but you can still access '
              'cached data and configure settings.',
              style: TextStyle(fontSize: isCompact ? 14 : 16),
            ),
          ],
        ),
      ),
    );
  }
}
