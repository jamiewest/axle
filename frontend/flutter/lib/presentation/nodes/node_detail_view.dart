import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/node_service.dart';
import 'package:axle/domain/models/node.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';
import 'package:intl/intl.dart';

/// View for displaying node details and managing child nodes.
class NodeDetailView extends StatefulWidget {
  const NodeDetailView({
    required this.nodeId,
    super.key,
  });

  final String nodeId;

  @override
  State<NodeDetailView> createState() => _NodeDetailViewState();
}

class _NodeDetailViewState extends State<NodeDetailView> {
  Node? _node;
  List<Node>? _childNodes;
  bool _isLoading = true;
  bool _isLoadingChildren = true;
  String? _errorMessage;
  String? _childrenErrorMessage;
  late final NodeService _nodeService;

  @override
  void initState() {
    super.initState();
    _nodeService = _createNodeService();
    _loadNode();
    _loadChildNodes();
  }

  NodeService _createNodeService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return NodeService(apiConfig: apiConfig);
  }

  Future<void> _loadNode({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _nodeService.getNode(widget.nodeId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.success) {
          _node = result.node;
        } else {
          _errorMessage = result.message ?? 'Failed to load node';
        }
      });
    }
  }

  Future<void> _loadChildNodes({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoadingChildren = true;
        _childrenErrorMessage = null;
      });
    }

    final result = await _nodeService.getNodes(
      parentId: widget.nodeId,
      pageSize: 100,
    );

    if (mounted) {
      setState(() {
        _isLoadingChildren = false;
        if (result.success) {
          _childNodes = result.nodes;
        } else {
          _childrenErrorMessage = result.message ?? 'Failed to load child nodes';
        }
      });
    }
  }

  Future<void> _handleAddChildNode() async {
    if (_node == null) return;

    final result = await context.push<bool>(
      '/tenant/${_node!.tenantId}/node/${widget.nodeId}/create-node',
    );

    if (result == true) {
      // Reload child nodes after successful creation
      await _loadChildNodes(showLoadingIndicator: false);
    }
  }

  @override
  void dispose() {
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
        title: Text(_node?.name ?? 'Node Details'),
      ),
      floatingActionButton: _node != null
          ? FloatingActionButton.extended(
              onPressed: _handleAddChildNode,
              icon: const Icon(Icons.add),
              label: Text(isCompact ? 'Add' : 'Add Child Node'),
            )
          : null,
      body: AdaptiveContainer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _node == null
                    ? _buildNotFoundState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _loadNode(),
                            _loadChildNodes(),
                          ]);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildNodeInfoCard(isCompact, isExpandedOrLarger),
                              SizedBox(height: isCompact ? 16 : 24),
                              _buildChildNodesSection(isCompact, isExpandedOrLarger),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Loading Node',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _loadNode();
                _loadChildNodes();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Node Not Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested node could not be found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeInfoCard(bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);
    final node = _node!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Node Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTypeBadge(node.type, node.subtype),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Node Name
            _buildInfoRow(
              icon: Icons.title,
              label: 'Name',
              value: node.name,
              isCompact: isCompact,
            ),
            const SizedBox(height: 12),

            // Node Type
            _buildInfoRow(
              icon: Icons.category,
              label: 'Type',
              value: node.type,
              isCompact: isCompact,
            ),
            const SizedBox(height: 12),

            // Node Subtype (if present)
            if (node.subtype != null) ...[
              _buildInfoRow(
                icon: Icons.label_outline,
                label: 'Subtype',
                value: node.subtype!,
                isCompact: isCompact,
              ),
              const SizedBox(height: 12),
            ],

            // Created By
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Created By',
              value: node.createdByName ?? 'Unknown',
              isCompact: isCompact,
            ),
            const SizedBox(height: 12),

            // Created At
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Created',
              value: _formatDateTime(node.createdAt),
              isCompact: isCompact,
            ),
            const SizedBox(height: 12),

            // Modified At (if present)
            if (node.modifiedAt != null) ...[
              _buildInfoRow(
                icon: Icons.update,
                label: 'Last Modified',
                value: _formatDateTime(node.modifiedAt!),
                isCompact: isCompact,
              ),
              const SizedBox(height: 12),
            ],

            // Modified By (if present)
            if (node.modifiedByName != null) ...[
              _buildInfoRow(
                icon: Icons.person,
                label: 'Modified By',
                value: node.modifiedByName!,
                isCompact: isCompact,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isCompact,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type, String? subtype) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtype != null) ...[
            const SizedBox(width: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              subtype,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChildNodesSection(bool isCompact, bool isExpandedOrLarger) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Child Nodes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_childNodes != null && _childNodes!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_childNodes!.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _isLoadingChildren
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _childrenErrorMessage != null
                    ? _buildChildrenErrorState()
                    : _childNodes == null || _childNodes!.isEmpty
                        ? _buildEmptyChildrenState(isCompact)
                        : _buildChildNodesList(isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenErrorState() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load child nodes',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _childrenErrorMessage ?? 'An error occurred',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadChildNodes,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChildrenState(bool isCompact) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(isCompact ? 24.0 : 32.0),
      child: Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: isCompact ? 48 : 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            'No child nodes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a child node to organize your work',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCompact ? 16 : 24),
          FilledButton.icon(
            onPressed: _handleAddChildNode,
            icon: const Icon(Icons.add),
            label: const Text('Add Child Node'),
          ),
        ],
      ),
    );
  }

  Widget _buildChildNodesList(bool isCompact) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _childNodes!.length,
      separatorBuilder: (context, index) => SizedBox(height: isCompact ? 8 : 12),
      itemBuilder: (context, index) {
        return _buildChildNodeCard(_childNodes![index], isCompact);
      },
    );
  }

  Widget _buildChildNodeCard(Node node, bool isCompact) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () async {
          await context.push('/node/${node.id}');
          // Reload after returning in case the child was modified
          await _loadChildNodes(showLoadingIndicator: false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildTypeBadge(node.type, node.subtype),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            node.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    node.createdByName ?? 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(node.createdAt),
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y • h:mm a').format(dateTime.toLocal());
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
