import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/tenant_service.dart';
import 'package:axle/domain/models/tenant.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';

/// View for displaying a list of tenants.
class TenantsListView extends StatefulWidget {
  const TenantsListView({super.key});

  @override
  State<TenantsListView> createState() => _TenantsListViewState();
}

class _TenantsListViewState extends State<TenantsListView> {
  late final TenantService _tenantService;
  List<Tenant>? _tenants;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tenantService = _createTenantService();
    _loadTenants();
  }

  TenantService _createTenantService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return TenantService(apiConfig: apiConfig);
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _tenantService.getTenants();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _tenants = result.tenants;
        } else {
          _errorMessage = result.message ?? 'Failed to load tenants';
        }
      });
    }
  }

  @override
  void dispose() {
    _tenantService.dispose();
    super.dispose();
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
        title: const Text('My Tenants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/create-tenant');
              // Refresh the list when returning from create
              _loadTenants();
            },
            tooltip: 'Create Tenant',
          ),
        ],
      ),
      body: AdaptiveContainer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _tenants == null || _tenants!.isEmpty
                    ? _buildEmptyView()
                    : _buildTenantsList(isCompact, isExpandedOrLarger),
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
              'Failed to Load Tenants',
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
            FilledButton.icon(
              onPressed: _loadTenants,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tenants Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first tenant to get started',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await context.push('/create-tenant');
                _loadTenants();
              },
              icon: const Icon(Icons.add_business),
              label: const Text('Create Tenant'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantsList(bool isCompact, bool isExpandedOrLarger) {
    return RefreshIndicator(
      onRefresh: _loadTenants,
      child: ListView.builder(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        itemCount: _tenants!.length,
        itemBuilder: (context, index) {
          final tenant = _tenants![index];
          return _buildTenantCard(tenant, isCompact, isExpandedOrLarger);
        },
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant, bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 12 : 16),
      child: InkWell(
        onTap: () async {
          await context.push('/tenant/${tenant.id}');
          _loadTenants();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          child: isExpandedOrLarger
              ? Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tenant.slug,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTenantStatus(tenant),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await context.push('/tenant/${tenant.id}');
                        _loadTenants();
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      tenant.slug,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTenantStatus(tenant),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.push('/tenant/${tenant.id}');
                          _loadTenants();
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Tenant'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTenantStatus(Tenant tenant) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: tenant.isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tenant.isActive ? 'Active' : 'Inactive',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.calendar_today,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Created ${_formatDate(tenant.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
