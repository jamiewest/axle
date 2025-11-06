# gRPC Real-Time Updates - Quick Start

## ✅ Setup Complete!

Your Axle app now has full gRPC streaming for real-time updates between backend and frontend.

## What You Have

### Backend (Running on http://localhost:5103)
- ✅ gRPC server with server-side streaming
- ✅ JWT authentication for all gRPC calls
- ✅ Flexible data type subscriptions
- ✅ Auto-cleanup of disconnected clients
- ✅ Example integration in `/register` endpoint

### Frontend (Flutter)
- ✅ `GrpcUpdateService` - Easy-to-use client
- ✅ Demo widget with live UI
- ✅ Generated protobuf code
- ✅ Multiple subscription support

## Try It Now! (3 Steps)

### 1. Add Demo Route to Your App

Add this to your `app_router.dart`:

```dart
GoRoute(
  path: '/live-updates-demo',
  builder: (context, state) => const LiveUpdatesDemo(),
),
```

### 2. Run Your Flutter App

```bash
cd frontend
flutter run
```

### 3. Test Real-Time Updates

1. Log in to your Flutter app
2. Navigate to "Live Updates Demo"
3. Click **"Subscribe"** to users
4. Register a new user from another window/device
5. Watch the user count update in real-time! 🎉

## How to Use in Your Code

### Backend - Trigger an Update

Anywhere you want to notify clients:

```csharp
// Inject IUpdateNotifier
public async Task MyBusinessLogic(IUpdateNotifier notifier)
{
    // Your code...

    // Notify all subscribed clients
    await notifier.NotifyUserChangeAsync(
        ChangeType.Updated,
        new { totalUsers = 10, activeUsers = 3 }
    );
}
```

### Frontend - Subscribe to Updates

```dart
final grpcService = GrpcUpdateService(
  host: 'localhost',
  port: 5103,
);

await grpcService.subscribe(
  dataType: 'users',
  token: yourAccessToken,
  onUpdate: (UpdateMessage message) {
    // Update your UI!
    setState(() {
      final data = jsonDecode(message.data);
      userCount = data['totalUsers'];
    });
  },
);
```

## Built-In Example

The `/register` endpoint now sends real-time updates:

```bash
# When a new user registers, all subscribed clients
# automatically receive an update with the new user count!
```

## Available Data Types

Use any string as a data type. Built-in helpers for:

- `users` - User-related updates
- `orders` - Order status changes
- `stats` - Statistics updates
- `notifications` - Push notifications

Or create your own:

```csharp
await notifier.NotifyCustomAsync(
    "my-custom-type",
    ChangeType.Updated,
    myData
);
```

## Testing Without the App

Use the test endpoint to trigger updates manually:

```bash
# Get your access token from login
TOKEN="your-jwt-token"

# Trigger a users update
curl -X POST "http://localhost:5103/api/trigger-update?dataType=users&data=%7B%22totalUsers%22%3A99%7D" \
  -H "Authorization: Bearer $TOKEN"
```

## Common Use Cases

### 1. Live Dashboard

Subscribe to `stats` and update charts in real-time.

### 2. Order Tracking

Subscribe to `orders` filtered by user ID, show order status updates.

### 3. Chat/Comments

Subscribe to specific conversation IDs, receive new messages instantly.

### 4. Notifications

Subscribe to `notifications`, show toast/badge when new notification arrives.

### 5. Inventory Updates

Subscribe to product IDs, update "in stock" status in real-time.

## Helper Extensions

I've created helper methods in `UpdateNotifierExtensions.cs`:

```csharp
using Axle.Extensions;

// User updates
await notifier.NotifyUserChangeAsync(ChangeType.Created, userData);

// Order updates
await notifier.NotifyOrderChangeAsync(ChangeType.Updated, orderId, "shipped");

// Stats updates
await notifier.NotifyStatsUpdateAsync("revenue", 50000.00, "USD");

// Notifications
await notifier.SendNotificationAsync("New Order", "You have a new order!", userId);

// Custom types
await notifier.NotifyCustomAsync("my-type", ChangeType.Updated, myData);
```

## Architecture

```
┌─────────────┐                    ┌──────────────┐
│   Flutter   │ ◄──────gRPC───────► │  ASP.NET    │
│             │    Real-time         │  Backend    │
│  Subscribe  │    Streaming         │             │
│  to "users" │                      │  Triggers   │
│             │                      │  NotifyAsync│
└─────────────┘                      └──────────────┘
       │                                     │
       │  UpdateMessage received             │
       ▼                                     ▼
  Update UI                          Data changed
  Automatically                      (register, update, etc.)
```

## Files to Know

### Backend
- `Protos/updates.proto` - Protocol definitions
- `Services/UpdateNotifier.cs` - Notification manager
- `Grpc/UpdateStreamService.cs` - gRPC service
- `Extensions/UpdateNotifierExtensions.cs` - Helper methods
- `Program.cs` - Configuration & example usage

### Frontend
- `lib/data/services/grpc_update_service.dart` - Client service
- `lib/presentation/examples/live_updates_demo.dart` - Demo widget
- `lib/generated/` - Generated gRPC code

## Next Steps

1. **Try the demo** - See it working first!
2. **Add to your endpoints** - Inject `IUpdateNotifier` and call `NotifyAsync()`
3. **Build reactive UI** - Subscribe in your widgets and update on messages
4. **Create custom data types** - Use any string as a data type

## Full Documentation

See [GRPC_SETUP_GUIDE.md](GRPC_SETUP_GUIDE.md) for:
- Detailed examples
- Advanced features (filtering, multiple subscriptions)
- Performance considerations
- Scaling for production
- Security best practices
- Troubleshooting

## Backend Status

Backend is running with gRPC enabled at:
- **HTTP/REST:** `http://localhost:5103`
- **gRPC:** `http://localhost:5103` (same port, different protocol)

Check logs: `tail -f /tmp/axle-backend.log`

## That's It!

You're ready to build real-time features. Happy coding! 🚀
