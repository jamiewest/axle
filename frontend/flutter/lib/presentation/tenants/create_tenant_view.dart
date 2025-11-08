import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/tenant_service.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';

/// View for creating a new tenant.
class CreateTenantView extends StatefulWidget {
  const CreateTenantView({super.key});

  @override
  State<CreateTenantView> createState() => _CreateTenantViewState();
}

class _CreateTenantViewState extends State<CreateTenantView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  bool _isLoading = false;
  bool _autoGenerateSlug = true;
  late final TenantService _tenantService;

  @override
  void initState() {
    super.initState();
    _tenantService = _createTenantService();
    _nameController.addListener(_onNameChanged);
  }

  TenantService _createTenantService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return TenantService(apiConfig: apiConfig);
  }

  void _onNameChanged() {
    if (_autoGenerateSlug) {
      final slug = _generateSlug(_nameController.text);
      _slugController.text = slug;
    }
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _tenantService.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTenant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _tenantService.createTenant(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        _showSuccessDialog(result.tenant?.name ?? 'Tenant');
      } else {
        final errorMessage = result.formattedErrors ??
            result.message ??
            'Tenant creation failed';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String tenantName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('Tenant Created'),
        content: Text(
          'Your tenant "$tenantName" has been created successfully.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        title: const Text('Tenant Creation Failed'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompact = context.isCompactLayout;
    final isExpandedOrLarger = context.isExpandedOrLarger;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Tenant'),
      ),
      body: AdaptiveContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isExpandedOrLarger ? 600 : 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Icon(
                      Icons.business_outlined,
                      size: isCompact ? 64 : 80,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: isCompact ? 16 : 24),
                    Text(
                      'Create New Tenant',
                      style: (isCompact
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineLarge)
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    Text(
                      'Set up a new organization or workspace',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 32 : 48),

                    // Information Card
                    Card(
                      elevation: 0,
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'A tenant represents an organization with isolated data and users.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 24 : 32),

                    // Tenant Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tenant Name',
                        hintText: 'e.g., Acme Corporation',
                        prefixIcon: const Icon(Icons.business),
                        border: const OutlineInputBorder(),
                        helperText: 'The display name of your organization',
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a tenant name';
                        }
                        if (value.length < 3) {
                          return 'Tenant name must be at least 3 characters';
                        }
                        if (value.length > 200) {
                          return 'Tenant name must not exceed 200 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Slug Field
                    TextFormField(
                      controller: _slugController,
                      decoration: InputDecoration(
                        labelText: 'Slug',
                        hintText: 'e.g., acme-corporation',
                        prefixIcon: const Icon(Icons.link),
                        border: const OutlineInputBorder(),
                        helperText: 'URL-friendly identifier (lowercase, no spaces)',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _autoGenerateSlug
                                ? Icons.auto_fix_high
                                : Icons.edit,
                          ),
                          onPressed: () {
                            setState(() {
                              _autoGenerateSlug = !_autoGenerateSlug;
                              if (_autoGenerateSlug) {
                                _onNameChanged();
                              }
                            });
                          },
                          tooltip: _autoGenerateSlug
                              ? 'Auto-generate enabled'
                              : 'Manual editing',
                        ),
                      ),
                      enabled: !_autoGenerateSlug,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleCreateTenant(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a slug';
                        }
                        if (value.length < 3) {
                          return 'Slug must be at least 3 characters';
                        }
                        if (value.length > 100) {
                          return 'Slug must not exceed 100 characters';
                        }
                        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                          return 'Slug can only contain lowercase letters, numbers, and hyphens';
                        }
                        if (value.startsWith('-') || value.endsWith('-')) {
                          return 'Slug cannot start or end with a hyphen';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isCompact ? 32 : 40),

                    // Create Button
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _handleCreateTenant,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_business),
                      label: Text(_isLoading ? 'Creating...' : 'Create Tenant'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 16 : 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 16 : 20,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
