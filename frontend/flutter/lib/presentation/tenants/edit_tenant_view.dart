import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/tenant_service.dart';
import 'package:axle/domain/models/tenant.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';

/// View for editing an existing tenant.
class EditTenantView extends StatefulWidget {
  const EditTenantView({
    required this.tenantId,
    super.key,
  });

  final String tenantId;

  @override
  State<EditTenantView> createState() => _EditTenantViewState();
}

class _EditTenantViewState extends State<EditTenantView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSlugManuallyEdited = false;
  Tenant? _tenant;
  String? _errorMessage;
  late final TenantService _tenantService;

  @override
  void initState() {
    super.initState();
    _tenantService = _createTenantService();
    _loadTenant();
  }

  TenantService _createTenantService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return TenantService(apiConfig: apiConfig);
  }

  Future<void> _loadTenant() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _tenantService.getTenant(widget.tenantId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success && result.tenant != null) {
          _tenant = result.tenant;
          _nameController.text = result.tenant!.name;
          _slugController.text = result.tenant!.slug;
        } else {
          _errorMessage = result.message ?? 'Failed to load tenant';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _tenantService.dispose();
    super.dispose();
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void _onNameChanged(String value) {
    if (!_isSlugManuallyEdited) {
      _slugController.text = _generateSlug(value);
    }
  }

  Future<void> _handleUpdateTenant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await _tenantService.updateTenant(
        tenantId: widget.tenantId,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        isActive: _tenant?.isActive ?? true,
        settings: _tenant?.settings,
      );

      if (!mounted) return;

      if (result.success) {
        _showSuccessDialog(result.tenant?.name ?? 'Tenant');
      } else {
        final errorMessage = result.formattedErrors ??
            result.message ??
            'Tenant update failed';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
        title: const Text('Tenant Updated'),
        content: Text(
          'Your tenant "$tenantName" has been updated successfully.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.pop(); // Return to previous screen
            },
            child: const Text('Done'),
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
        title: const Text('Update Failed'),
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
        title: const Text('Edit Tenant'),
      ),
      body: AdaptiveContainer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildEditForm(theme, colorScheme, isCompact, isExpandedOrLarger),
      ),
    );
  }

  Widget _buildErrorView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Tenant',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _loadTenant,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isCompact,
    bool isExpandedOrLarger,
  ) {
    return Center(
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
                  Icons.edit_note,
                  size: isCompact ? 64 : 80,
                  color: colorScheme.primary,
                ),
                SizedBox(height: isCompact ? 16 : 24),
                Text(
                  'Edit Tenant',
                  style: (isCompact
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.headlineLarge)
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 8 : 12),
                Text(
                  'Update your organization details',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 32 : 48),

                // Tenant ID Card (Read-only info)
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tenant Information',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('ID', _tenant?.id ?? '', Icons.key),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Created',
                          _tenant != null
                              ? _formatDate(_tenant!.createdAt)
                              : '',
                          Icons.calendar_today,
                        ),
                        if (_tenant?.updatedAt != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Last Updated',
                            _formatDate(_tenant!.updatedAt!),
                            Icons.update,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 24 : 32),

                // Tenant Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tenant Name',
                    hintText: 'e.g., Acme Corporation',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                    helperText: 'The display name of your organization',
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onChanged: _onNameChanged,
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
                    helperText: 'URL-friendly identifier (auto-generated from name)',
                    suffixIcon: _isSlugManuallyEdited
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                _isSlugManuallyEdited = false;
                                _slugController.text = _generateSlug(_nameController.text);
                              });
                            },
                            tooltip: 'Reset to auto-generated slug',
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    if (!_isSlugManuallyEdited) {
                      setState(() {
                        _isSlugManuallyEdited = true;
                      });
                    }
                  },
                  onFieldSubmitted: (_) => _handleUpdateTenant(),
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

                // Save Button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _handleUpdateTenant,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? 16 : 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
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
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
