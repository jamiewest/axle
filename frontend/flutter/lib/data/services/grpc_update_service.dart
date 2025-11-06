import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:axle/generated/updates.pbgrpc.dart';

/// Service for receiving real-time updates via gRPC streaming.
class GrpcUpdateService {
  final String host;
  final int port;
  ClientChannel? _channel;
  UpdateStreamClient? _client;
  final Map<String, StreamSubscription<UpdateMessage>> _subscriptions = {};

  GrpcUpdateService({
    required this.host,
    this.port = 5103,
  });

  /// Initialize the gRPC channel
  void _ensureChannel() {
    _channel ??= ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _client ??= UpdateStreamClient(_channel!);
  }

  /// Subscribe to a data type and receive updates via callback
  /// Returns a subscription ID that can be used to unsubscribe
  Future<String> subscribe({
    required String dataType,
    required String token,
    required Function(UpdateMessage) onUpdate,
    Function(dynamic error)? onError,
    Function()? onDone,
    String? filter,
  }) async {
    _ensureChannel();

    final request = SubscribeRequest()
      ..dataType = dataType
      ..token = token;

    if (filter != null && filter.isNotEmpty) {
      request.filter = filter;
    }

    try {
      final responseStream = _client!.subscribe(request);

      final subscriptionId = DateTime.now().millisecondsSinceEpoch.toString();

      final subscription = responseStream.listen(
        (message) {
          print('[gRPC] Received update: ${message.dataType} - ${message.changeType}');
          onUpdate(message);
        },
        onError: (error) {
          print('[gRPC] Error in subscription: $error');
          onError?.call(error);
        },
        onDone: () {
          print('[gRPC] Subscription ended for $dataType');
          _subscriptions.remove(subscriptionId);
          onDone?.call();
        },
      );

      _subscriptions[subscriptionId] = subscription;
      print('[gRPC] Subscribed to $dataType with ID: $subscriptionId');

      return subscriptionId;
    } catch (e) {
      print('[gRPC] Failed to subscribe: $e');
      rethrow;
    }
  }

  /// Unsubscribe from updates
  Future<void> unsubscribe(String subscriptionId) async {
    final subscription = _subscriptions.remove(subscriptionId);
    if (subscription != null) {
      await subscription.cancel();
      print('[gRPC] Unsubscribed: $subscriptionId');
    }
  }

  /// Unsubscribe from all active subscriptions
  Future<void> unsubscribeAll() async {
    for (var subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    print('[gRPC] Unsubscribed from all');
  }

  /// Close the gRPC channel and clean up
  Future<void> close() async {
    await unsubscribeAll();
    await _channel?.shutdown();
    _channel = null;
    _client = null;
    print('[gRPC] Channel closed');
  }

  /// Check if there are active subscriptions
  bool get hasActiveSubscriptions => _subscriptions.isNotEmpty;

  /// Get number of active subscriptions
  int get subscriptionCount => _subscriptions.length;
}
