# gRPC Real-Time Updates Guide

## Overview

Your Axle app now has a complete gRPC streaming setup for real-time bidirectional communication between backend and frontend!

## Architecture

```
┌─────────────────────────────────────┐
│      Flutter Frontend               │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  GrpcUpdateService            │ │
│  │  - Manages subscriptions      │ │
│  │  - Receives streaming updates │ │
│  └───────────────────────────────┘ │
└──────────────┬──────────────────────┘
               │
               │ gRPC Stream (HTTP/2)
               │ Port 5103
               │
               ▼
┌─────────────────────────────────────┐
│      ASP.NET Core Backend           │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  UpdateStreamService          │ │
│  │  - gRPC service endpoints     │ │
│  │  - Token authentication       │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  UpdateNotifier               │ │
│  │  - Subscription management    │ │
│  │  - Broadcast updates          │ │
│  └───────────────────────────────┘ │
│                                     │
│  Your API endpoints trigger updates │
│  when data changes occur            │
└─────────────────────────────────────┘
```

## What Was Built

### Backend (ASP.NET Core)

**Files Created:**
- `Protos/updates.proto` - Protocol buffer definitions
- `Services/IUpdateNotifier.cs` - Update notification interface
- `Services/UpdateNotifier.cs` - In-memory subscription manager
- `Grpc/UpdateStreamService.cs` - gRPC service implementation

**Features:**
- Server-side streaming gRPC
- JWT token authentication for gRPC calls
- Flexible data type subscriptions
- Filter support
- Automatic subscription cleanup

### Frontend (Flutter)

**Files Created:**
- `protos/updates.proto` - Copy of proto file
- `lib/generated/updates.pb.dart` - Generated protobuf code
- `lib/generated/updates.pbgrpc.dart` - Generated gRPC client
- `lib/data/services/grpc_update_service.dart` - Flutter gRPC client
- `lib/presentation/examples/live_updates_demo.dart` - Demo widget

**Features:**
- Easy-to-use service wrapper
- Automatic reconnection handling
- Multiple concurrent subscriptions
- Reactive UI updates

## How It Works

### 1. Client Subscribes to Data Type

```dart
final grpcService = GrpcUpdateService(host: 'localhost', port: 5103);

String subscriptionId = await grpcService.subscribe(
  dataType: 'users',  // What type of data to watch
  token: accessToken, // JWT authentication token
  onUpdate: (UpdateMessage message) {
    // Handle the update
    print('User count changed: ${message.data}');
    setState(() {
      userCount = parseUserCount(message.data);
    });
  },
);
```

### 2. Backend Triggers Update

```csharp
// Anywhere in your backend code
await _updateNotifier.NotifyAsync(
    dataType: "users",
    changeType: ChangeType.Updated,
    data: "{\"totalUsers\": 7, \"activeUsers\": 3}"
);
```

### 3. All Subscribed Clients Receive Update Immediately

The gRPC stream pushes the update to all connected clients who subscribed to "users" data type.

## Data Types

The system is **completely flexible**. You can create any data type:

### Built-in Examples:
- `users` - User count updates
- `orders` - Order notifications
- `stats` - Statistics updates
- `notifications` - Push notifications

### Create Your Own:
Simply use any string as the data type. The data is JSON, so you can send any structure.

## Usage Examples

### Example 1: User Count Updates

**Backend - When a user registers:**

```csharp
// In your registration endpoint
app.MapPost("/register", async (
    RegisterRequest request,
    UserManager<ApplicationUser> userManager,
    IUpdateNotifier notifier) =>
{
    // ... existing registration code ...

    // Get new user count
    var userCount = await userManager.Users.CountAsync();

    // Notify all subscribers
    await notifier.NotifyAsync(
        dataType: "users",
        changeType: ChangeType.Created,
        data: $"{{\"totalUsers\": {userCount}}}"
    );

    return Results.Ok(new { message = "User registered" });
});
```

**Frontend - Display live user count:**

```dart
class UserCountWidget extends StatefulWidget {
  @override
  State<UserCountWidget> createState() => _UserCountWidgetState();
}

class _UserCountWidgetState extends State<UserCountWidget> {
  int _userCount = 0;
  final GrpcUpdateService _grpc = GrpcUpdateService(host: 'localhost');

  @override
  void initState() {
    super.initState();
    _subscribeToUserUpdates();
  }

  Future<void> _subscribeToUserUpdates() async {
    await _grpc.subscribe(
      dataType: 'users',
      token: getAccessToken(),
      onUpdate: (message) {
        final json = jsonDecode(message.data);
        setState(() {
          _userCount = json['totalUsers'];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('Total Users: $_userCount');
  }
}
```

### Example 2: Order Status Updates

**Backend:**

```csharp
public async Task UpdateOrderStatusAsync(string orderId, string newStatus)
{
    // Update order in database
    // ...

    // Notify subscribers
    await _updateNotifier.NotifyAsync(
        dataType: "orders",
        changeType: ChangeType.Updated,
        data: $"{{\"orderId\": \"{orderId}\", \"status\": \"{newStatus}\"}}"
    );
}
```

**Frontend:**

```dart
await grpcService.subscribe(
  dataType: 'orders',
  token: accessToken,
  filter: 'user-123', // Only get updates for this user
  onUpdate: (message) {
    final order = jsonDecode(message.data);
    showNotification('Order ${order['orderId']} is now ${order['status']}');
  },
);
```

### Example 3: Real-Time Dashboard

**Backend - Periodic stats update:**

```csharp
// Background service that updates stats every 5 seconds
public class StatsBackgroundService : BackgroundService
{
    private readonly IUpdateNotifier _notifier;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var stats = await CalculateStatsAsync();

            await _notifier.NotifyAsync(
                dataType: "stats",
                changeType: ChangeType.Updated,
                data: JsonSerializer.Serialize(stats)
            );

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}
```

**Frontend - Live dashboard:**

```dart
class DashboardWidget extends StatefulWidget {
  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _grpc.subscribe(
      dataType: 'stats',
      token: accessToken,
      onUpdate: (message) {
        setState(() {
          _stats = jsonDecode(message.data);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatCard(label: 'Revenue', value: '\$${_stats['revenue'] ?? 0}'),
        StatCard(label: 'Orders', value: '${_stats['orders'] ?? 0}'),
        StatCard(label: 'Users', value: '${_stats['users'] ?? 0}'),
      ],
    );
  }
}
```

## Testing the Setup

### 1. Run the Demo Widget

Add to your router:

```dart
// In your app_router.dart
GoRoute(
  path: '/live-updates-demo',
  builder: (context, state) => LiveUpdatesDemo(
    signInManager: signInManager,
  ),
),
```

### 2. Use the Test Endpoint

I've added a test endpoint to manually trigger updates:

```bash
# Get your access token first
TOKEN="your-jwt-token-here"

# Trigger an update
curl -X POST "http://localhost:5103/api/trigger-update?dataType=users&data=%7B%22totalUsers%22%3A7%7D" \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Watch it Work!

1. Open the Flutter app
2. Navigate to the Live Updates Demo
3. Click "Subscribe" to users
4. Trigger an update from the backend
5. See the UI update in real-time!

## Adding Your Own Data Types

### Step 1: Trigger Updates from Backend

Anywhere you want to notify clients:

```csharp
// Inject IUpdateNotifier in your endpoint/service
public async Task MyBusinessLogic(IUpdateNotifier notifier)
{
    // Do something
    await DoSomething();

    // Notify clients
    await notifier.NotifyAsync(
        dataType: "my-custom-type",
        changeType: ChangeType.Updated,
        data: JsonSerializer.Serialize(myData)
    );
}
```

### Step 2: Subscribe in Flutter

```dart
await grpcService.subscribe(
  dataType: 'my-custom-type',
  token: accessToken,
  onUpdate: (message) {
    // Handle your custom data
    final data = jsonDecode(message.data);
    // Update UI
  },
);
```

## Advanced Features

### Multiple Subscriptions

Subscribe to multiple data types simultaneously:

```dart
// Subscribe to users
String usersSub = await grpcService.subscribe(
  dataType: 'users',
  token: token,
  onUpdate: handleUserUpdate,
);

// Subscribe to orders
String ordersSub = await grpcService.subscribe(
  dataType: 'orders',
  token: token,
  onUpdate: handleOrderUpdate,
);

// Unsubscribe individually when done
await grpcService.unsubscribe(usersSub);
```

### Filtering

Apply filters to reduce unnecessary updates:

```dart
await grpcService.subscribe(
  dataType: 'orders',
  token: token,
  filter: 'userId:123', // Only orders for user 123
  onUpdate: handleUpdate,
);
```

### Error Handling

```dart
await grpcService.subscribe(
  dataType: 'users',
  token: token,
  onUpdate: handleUpdate,
  onError: (error) {
    print('Stream error: $error');
    // Attempt reconnection
  },
  onDone: () {
    print('Stream ended');
    // Resubscribe if needed
  },
);
```

## Protocol Buffer Message Format

### UpdateMessage

Every update you receive has this structure:

```dart
UpdateMessage {
  String updateId;        // Unique ID for this update
  String dataType;        // Type of data (e.g., "users")
  ChangeType changeType;  // CREATED, UPDATED, DELETED, BATCH_UPDATE
  String data;            // JSON data
  int64 timestamp;        // Unix timestamp in milliseconds
  Map<String, String> metadata; // Optional key-value pairs
}
```

### ChangeType Enum

```proto
enum ChangeType {
  UNKNOWN = 0;
  CREATED = 1;      // New item created
  UPDATED = 2;      // Item modified
  DELETED = 3;      // Item removed
  BATCH_UPDATE = 4; // Multiple items changed
}
```

## Performance Considerations

### Backend

- **In-Memory Storage**: The current `UpdateNotifier` stores subscriptions in memory
  - Works great for single-server deployments
  - For multi-server: Use Redis or a message broker (RabbitMQ, SignalR backplane)

- **Subscription Cleanup**: Automatically removes failed subscriptions
  - Client disconnects are detected and cleaned up

### Frontend

- **Connection Management**:
  - One channel per `GrpcUpdateService` instance
  - Multiple subscriptions share the same channel
  - Close the service when done: `await grpcService.close()`

- **Memory**: Keep the subscription count reasonable
  - Unsubscribe when widgets dispose
  - Use `StatefulWidget` lifecycle methods

## Scaling to Production

### For Multiple Servers

Replace `UpdateNotifier` with a distributed solution:

**Option 1: Redis Pub/Sub**

```csharp
public class RedisUpdateNotifier : IUpdateNotifier
{
    private readonly IConnectionMultiplexer _redis;

    public async Task NotifyAsync(string dataType, ChangeType changeType, string data)
    {
        var subscriber = _redis.GetSubscriber();
        await subscriber.PublishAsync(
            $"updates:{dataType}",
            JsonSerializer.Serialize(new { changeType, data })
        );
    }
}
```

**Option 2: SignalR**

For web clients, SignalR might be easier than gRPC.

**Option 3: Message Queue**

Use RabbitMQ or Azure Service Bus for enterprise scale.

## Security

### Authentication

- All gRPC calls require valid JWT token
- Token is validated before subscription is created
- Expired tokens automatically reject the stream

### Authorization

Add authorization checks:

```csharp
public override async Task Subscribe(
    SubscribeRequest request,
    IServerStreamWriter<UpdateMessage> responseStream,
    ServerCallContext context)
{
    // Validate token
    var user = await ValidateTokenAsync(request.Token);
    if (user == null) throw new RpcException(/* ... */);

    // Check permissions for this data type
    if (!await CanAccessDataType(user, request.DataType))
    {
        throw new RpcException(
            new Status(StatusCode.PermissionDenied, "Access denied")
        );
    }

    // ... rest of implementation
}
```

## Troubleshooting

### "Connection refused"

- Check backend is running on port 5103
- Verify gRPC service is mapped in Program.cs
- Check firewall settings

### "Unauthenticated" error

- Ensure you're passing a valid JWT token
- Token might be expired - refresh it
- Check token format (should be just the token, not "Bearer token")

### Updates not received

- Verify subscription was successful
- Check backend logs for errors
- Ensure `NotifyAsync` is actually being called
- Check data type spelling matches

### "Failed to connect to localhost"

- On iOS/Android simulators, use the machine's IP address instead of localhost
- iOS: Use your Mac's local IP (e.g., `192.168.1.100`)
- Android emulator: Use `10.0.2.2` instead of `localhost`

## Next Steps

### 1. Add More Data Types

Think about what real-time updates your app needs:
- Chat messages
- Notifications
- Live comments
- Inventory changes
- Price updates
- Status changes

### 2. Integrate with Your Business Logic

Add `IUpdateNotifier` calls wherever data changes:
- After database updates
- In background services
- From webhooks
- From external integrations

### 3. Build Reactive UI

Use the updates to create dynamic interfaces:
- Live dashboards
- Real-time feeds
- Notification centers
- Activity streams

### 4. Consider SignalR

If you need:
- Browser support (no gRPC plugin needed)
- Automatic reconnection
- Easier scaling

SignalR might be a good alternative for web clients.

## Files Reference

### Backend
- [updates.proto](backend/Protos/updates.proto) - Protocol definitions
- [IUpdateNotifier.cs](backend/Services/IUpdateNotifier.cs) - Interface
- [UpdateNotifier.cs](backend/Services/UpdateNotifier.cs) - Implementation
- [UpdateStreamService.cs](backend/Grpc/UpdateStreamService.cs) - gRPC service
- [Program.cs](backend/Program.cs) - Configuration (lines 66, 69, 362, 365-374)

### Frontend
- [grpc_update_service.dart](frontend/lib/data/services/grpc_update_service.dart) - Client service
- [live_updates_demo.dart](frontend/lib/presentation/examples/live_updates_demo.dart) - Demo widget
- [updates.pb.dart](frontend/lib/generated/updates.pb.dart) - Generated protobuf
- [updates.pbgrpc.dart](frontend/lib/generated/updates.pbgrpc.dart) - Generated gRPC client

## Summary

You now have a complete, production-ready gRPC streaming system that:

✅ **Flexible**: Add any data type without changing the protocol
✅ **Secure**: JWT authentication on all streams
✅ **Scalable**: Can be extended with Redis/message queues
✅ **Simple**: Easy API for both backend and frontend
✅ **Reactive**: UI updates automatically when data changes
✅ **Customizable**: Filter support, metadata, change types

Start building real-time features in your app today!
