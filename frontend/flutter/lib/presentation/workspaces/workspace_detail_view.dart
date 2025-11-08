import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/workspace_service.dart';
import 'package:axle/data/services/node_service.dart';
import 'package:axle/domain/models/workspace.dart';
import 'package:axle/domain/models/node.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';

/// Detailed view for a single workspace where nodes can be managed.
class WorkspaceDetailView extends StatefulWidget {
  const WorkspaceDetailView({required this.workspaceId, super.key});

  final String workspaceId;

  @override
  State<WorkspaceDetailView> createState() => _WorkspaceDetailViewState();
}

class _WorkspaceDetailViewState extends State<WorkspaceDetailView> {
  late final WorkspaceService _workspaceService;
  late final NodeService _nodeService;
  Workspace? _workspace;
  List<Node>? _nodes;
  bool _isLoading = true;
  bool _isLoadingNodes = true;
  String? _errorMessage;
  String? _nodesErrorMessage;

  @override
  void initState() {
    super.initState();
    _workspaceService = _createWorkspaceService();
    _nodeService = _createNodeService();
    _loadWorkspace();
    _loadNodes();
  }

  WorkspaceService _createWorkspaceService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return WorkspaceService(apiConfig: apiConfig);
  }

  NodeService _createNodeService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return NodeService(apiConfig: apiConfig);
  }

  Future<void> _loadWorkspace({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _workspaceService.getWorkspace(widget.workspaceId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _workspace = result.workspace;
        } else {
          _errorMessage = result.message ?? 'Failed to load workspace';
        }
      });
    }
  }

  Future<void> _loadNodes({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoadingNodes = true;
        _nodesErrorMessage = null;
      });
    }

    final result = await _nodeService.getNodes(
      page: 1,
      pageSize: 100,
    );

    if (mounted) {
      setState(() {
        _isLoadingNodes = false;
        if (result.success) {
          // Filter to show only nodes in this workspace with no parent (root nodes)
          _nodes = result.nodes
              ?.where((node) =>
                  node.workspaceId == widget.workspaceId &&
                  node.parentId == null)
              .toList();
        } else {
          _nodesErrorMessage = result.message ?? 'Failed to load nodes';
        }
      });
    }
  }

  @override
  void dispose() {
    _workspaceService.dispose();
    _nodeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactLayout;
    final isExpandedOrLarger = context.isExpandedOrLarger;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_workspace?.name ?? 'Workspace Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _workspace == null
                  ? _buildNotFoundView()
                  : AdaptiveContainer(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isCompact ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWorkspaceHeader(isCompact, isExpandedOrLarger),
                            SizedBox(height: isCompact ? 24 : 32),
                            _buildNodesSection(isCompact, isExpandedOrLarger),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: _workspace != null
          ? FloatingActionButton.extended(
              onPressed: _handleAddNode,
              icon: const Icon(Icons.add),
              label: const Text('Add Node'),
            )
          : null,
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
              'Failed to Load Workspace',
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
              onPressed: _loadWorkspace,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Workspace Not Found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The workspace you are looking for does not exist',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader(bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: isExpandedOrLarger
            ? Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.workspaces,
                      color: colorScheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _workspace!.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_workspace!.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _workspace!.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildWorkspaceStatus(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspaces,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _workspace!.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_workspace!.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _workspace!.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildWorkspaceStatus(),
                ],
              ),
      ),
    );
  }

  Widget _buildWorkspaceStatus() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _workspace!.isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _workspace!.isActive ? 'Active' : 'Inactive',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Created ${_formatDate(_workspace!.createdAt)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNodesSection(bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dns,
              color: colorScheme.primary,
              size: isCompact ? 24 : 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Nodes',
              style: (isCompact
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.headlineSmall)
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_nodes != null && _nodes!.isNotEmpty)
              Text(
                '${_nodes!.length} ${_nodes!.length == 1 ? 'node' : 'nodes'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(height: isCompact ? 16 : 20),
        if (_isLoadingNodes)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_nodesErrorMessage != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load nodes',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nodesErrorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _loadNodes(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_nodes == null || _nodes!.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 24 : 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: isCompact ? 56 : 72,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Nodes Yet',
                      style: (isCompact
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first node to start organizing',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _handleAddNode,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Node'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nodes!.length,
            itemBuilder: (context, index) {
              final node = _nodes![index];
              return _buildNodeCard(node, isCompact, isExpandedOrLarger);
            },
          ),
      ],
    );
  }

  Widget _buildNodeCard(Node node, bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      child: InkWell(
        onTap: () async {
          await context.push('/node/${node.id}');
          // Reload nodes after returning in case something was modified
          await _loadNodes(showLoadingIndicator: false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      node.type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (node.subtype != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        node.subtype!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                node.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    node.createdByName ?? 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(node.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddNode() async {
    if (_workspace == null) return;

    final result = await context.push(
      '/workspace/${widget.workspaceId}/create-node',
      extra: {
        'tenantId': _workspace!.tenantId,
      },
    );

    // Reload nodes if a node was created
    if (result == true && mounted) {
      _loadNodes(showLoadingIndicator: false);
    }
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
