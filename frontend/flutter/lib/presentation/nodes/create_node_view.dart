import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axle/core/ui/adaptive_breakpoints.dart';
import 'package:axle/core/ui/adaptive_scaffold.dart';
import 'package:axle/data/services/node_service.dart';
import 'package:axle/core/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:axle/data/services/app_config_service.dart';

/// View for creating a new node.
class CreateNodeView extends StatefulWidget {
  const CreateNodeView({
    required this.tenantId,
    this.workspaceId,
    this.parentId,
    super.key,
  });

  final String tenantId;
  final String? workspaceId;
  final String? parentId;

  @override
  State<CreateNodeView> createState() => _CreateNodeViewState();
}

class _CreateNodeViewState extends State<CreateNodeView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _subtypeController = TextEditingController();
  bool _isSaving = false;
  late final NodeService _nodeService;

  // Common node types
  final List<String> _nodeTypes = [
    'Task',
    'Project',
    'Customer',
    'Issue',
    'Note',
    'Document',
  ];

  @override
  void initState() {
    super.initState();
    _nodeService = _createNodeService();
  }

  NodeService _createNodeService() {
    final configService = AppConfigService();
    final apiBaseUrl = configService.isUsingCustomUrl()
        ? configService.getApiUrl()
        : (dotenv.env['API_URL'] ?? configService.getApiUrl());

    final apiConfig = ApiConfig(baseUrl: apiBaseUrl);
    return NodeService(apiConfig: apiConfig);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _subtypeController.dispose();
    _nodeService.dispose();
    super.dispose();
  }

  Future<void> _handleCreateNode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await _nodeService.createNode(
        type: _typeController.text.trim(),
        name: _nameController.text.trim(),
        tenantId: widget.tenantId,
        workspaceId: widget.workspaceId,
        parentId: widget.parentId,
        subtype: _subtypeController.text.trim().isEmpty
            ? null
            : _subtypeController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        _showSuccessDialog(result.node?.name ?? 'Node');
      } else {
        final errorMessage = result.formattedErrors ??
            result.message ??
            'Node creation failed';
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

  void _showSuccessDialog(String nodeName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('Node Created'),
        content: Text(
          'Your node "$nodeName" has been created successfully.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.pop(true); // Return to previous screen with success flag
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
        title: const Text('Creation Failed'),
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
        title: Text(widget.parentId != null ? 'Create Child Node' : 'Create Node'),
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
                      Icons.add_circle_outline,
                      size: isCompact ? 64 : 80,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: isCompact ? 16 : 24),
                    Text(
                      widget.parentId != null ? 'Create Child Node' : 'Create New Node',
                      style: (isCompact
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineLarge)
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    Text(
                      widget.parentId != null
                          ? 'Add a child node to organize your work'
                          : 'Add a new item to your workspace',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 32 : 48),

                    // Node Type Field
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _typeController.text),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _nodeTypes;
                        }
                        return _nodeTypes.where((String option) {
                          return option.toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        _typeController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _typeController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Node Type',
                            hintText: 'e.g., Task, Project, Customer',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                            helperText: 'Select or enter a node type',
                          ),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a node type';
                            }
                            if (value.length < 2) {
                              return 'Node type must be at least 2 characters';
                            }
                            if (value.length > 100) {
                              return 'Node type must not exceed 100 characters';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Node Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Node Name',
                        hintText: 'e.g., Implement user authentication',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                        helperText: 'The display name of this node',
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a node name';
                        }
                        if (value.length < 3) {
                          return 'Node name must be at least 3 characters';
                        }
                        if (value.length > 500) {
                          return 'Node name must not exceed 500 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subtype Field (Optional)
                    TextFormField(
                      controller: _subtypeController,
                      decoration: const InputDecoration(
                        labelText: 'Subtype (Optional)',
                        hintText: 'e.g., Bug, Feature, Epic',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                        helperText: 'Further categorize this node',
                      ),
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (_) => _handleCreateNode(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length > 100) {
                          return 'Subtype must not exceed 100 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isCompact ? 32 : 40),

                    // Create Button
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _handleCreateNode,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSaving ? 'Creating...' : 'Create Node'),
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
        ),
      ),
    );
  }
}
