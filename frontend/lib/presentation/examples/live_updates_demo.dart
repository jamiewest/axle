import 'package:flutter/material.dart';
import 'package:axle/data/services/grpc_update_service.dart';
import 'package:axle/data/services/token_storage_service.dart';
import 'package:axle/generated/updates.pb.dart';

/// Demo widget showing real-time updates via gRPC
class LiveUpdatesDemo extends StatefulWidget {
  const LiveUpdatesDemo({
    super.key,
  });

  @override
  State<LiveUpdatesDemo> createState() => _LiveUpdatesDemoState();
}

class _LiveUpdatesDemoState extends State<LiveUpdatesDemo> {
  final GrpcUpdateService _grpcService = GrpcUpdateService(
    host: 'localhost',
    port: 5103,
  );
  final TokenStorageService _tokenStorage = TokenStorageService();

  final List<UpdateMessage> _updates = [];
  String? _subscriptionId;
  bool _isSubscribed = false;
  String _selectedDataType = 'users';
  int _userCount = 6; // Example starting value

  final List<String> _dataTypes = [
    'users',
    'orders',
    'stats',
    'notifications',
  ];

  @override
  void dispose() {
    _grpcService.close();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Not authenticated. Please log in first.');
      return;
    }

    setState(() {
      _isSubscribed = true;
    });

    try {
      _subscriptionId = await _grpcService.subscribe(
        dataType: _selectedDataType,
        token: accessToken,
        onUpdate: (UpdateMessage message) {
          setState(() {
            _updates.insert(0, message);
            if (_updates.length > 50) {
              _updates.removeLast();
            }

            // Handle specific data types
            if (message.dataType == 'users') {
              _handleUserUpdate(message);
            }
          });
        },
        onError: (error) {
          _showError('Subscription error: $error');
          setState(() {
            _isSubscribed = false;
          });
        },
        onDone: () {
          setState(() {
            _isSubscribed = false;
          });
        },
      );
    } catch (e) {
      _showError('Failed to subscribe: $e');
      setState(() {
        _isSubscribed = false;
      });
    }
  }

  void _handleUserUpdate(UpdateMessage message) {
    // Parse the JSON data and update user count
    // For now, just increment as a demo
    if (message.changeType == ChangeType.CREATED) {
      _userCount++;
    } else if (message.changeType == ChangeType.DELETED) {
      _userCount--;
    }
  }

  Future<void> _unsubscribe() async {
    if (_subscriptionId != null) {
      await _grpcService.unsubscribe(_subscriptionId!);
      setState(() {
        _isSubscribed = false;
        _subscriptionId = null;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Updates Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Control Panel
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'gRPC Stream Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Data Type:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedDataType,
                          isExpanded: true,
                          items: _dataTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: _isSubscribed
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedDataType = value;
                                    });
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubscribed ? null : _subscribe,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Subscribe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubscribed ? _unsubscribe : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Unsubscribe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${_isSubscribed ? 'Connected' : 'Disconnected'}',
                        style: TextStyle(
                          color: _isSubscribed ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Updates: ${_updates.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Display (Example of reactive UI)
          if (_selectedDataType == 'users')
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: _userCount.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Active Now',
                      value: '${(_userCount * 0.3).round()}',
                      icon: Icons.online_prediction,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Updates List
          Expanded(
            child: _updates.isEmpty
                ? const Center(
                    child: Text(
                      'No updates yet.\nSubscribe to start receiving updates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _updates.length,
                    itemBuilder: (context, index) {
                      final update = _updates[index];
                      return _UpdateCard(update: update);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final UpdateMessage update;

  const _UpdateCard({required this.update});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getChangeTypeColor(update.changeType),
          child: Icon(
            _getChangeTypeIcon(update.changeType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${update.dataType} - ${_getChangeTypeText(update.changeType)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          update.data.length > 100
              ? '${update.data.substring(0, 100)}...'
              : update.data,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTimestamp(update.timestamp),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Color _getChangeTypeColor(ChangeType type) {
    switch (type) {
      case ChangeType.CREATED:
        return Colors.green;
      case ChangeType.UPDATED:
        return Colors.blue;
      case ChangeType.DELETED:
        return Colors.red;
      case ChangeType.BATCH_UPDATE:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getChangeTypeIcon(ChangeType type) {
    switch (type) {
      case ChangeType.CREATED:
        return Icons.add_circle;
      case ChangeType.UPDATED:
        return Icons.update;
      case ChangeType.DELETED:
        return Icons.delete;
      case ChangeType.BATCH_UPDATE:
        return Icons.sync;
      default:
        return Icons.help;
    }
  }

  String _getChangeTypeText(ChangeType type) {
    switch (type) {
      case ChangeType.CREATED:
        return 'Created';
      case ChangeType.UPDATED:
        return 'Updated';
      case ChangeType.DELETED:
        return 'Deleted';
      case ChangeType.BATCH_UPDATE:
        return 'Batch Update';
      default:
        return 'Unknown';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    // Handle both int and Int64 types from protobuf
    final timestampInt = timestamp.toInt();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInt);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dateTime.hour}:${dateTime.minute}';
    }
  }
}
