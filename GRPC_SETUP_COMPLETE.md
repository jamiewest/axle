# gRPC Real-Time Updates - Setup Complete!

## Overview

Your Axle app now has full gRPC server-side streaming support for real-time updates! The backend can push updates to the Flutter frontend instantly when data changes.

## Architecture

```
┌─────────────────────────────────────┐
│     Flutter App (Frontend)          │
│  ┌────────────────────────────────┐ │
│  │  GrpcUpdateService             │ │
│  │  - Subscribe to data types     │ │
│  │  - Receive updates in real-time│ │
│  └────────────────────────────────┘ │
└──────────────┬──────────────────────┘
               │ gRPC Stream (HTTP/2)
               │ Bidirectional
               ▼
┌─────────────────────────────────────┐
│     ASP.NET Core (Backend)          │
│  ┌────────────────────────────────┐ │
│  │  UpdateStreamService (gRPC)    │ │
│  │  - Manages subscriptions       │ │
│  │  - Validates JWT tokens        │ │
│  │  - Streams updates to clients  │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │  UpdateNotifier               │ │
│  │  - Tracks subscribers          │ │
│  │  - Broadcasts changes          │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## What Was Built

### Backend (ASP.NET Core)

**Files Created:**
- `Protos/updates.proto` - Protocol Buffers definition
- `Services/IUpdateNotifier.cs` - Notification service interface
- `Services/UpdateNotifier.cs` - In-memory notification broadcaster
- `Grpc/UpdateStreamService.cs` - gRPC streaming service

**Features:**
- ✅ Server-side streaming (backend → Flutter)
- ✅ JWT authentication for gRPC
- ✅ Subscription management
- ✅ Flexible data types (users, orders, stats, etc.)
- ✅ Optional filtering
- ✅ Change type tracking (Created, Updated, Deleted)

### Frontend (Flutter)

**Files Created:**
- `protos/updates.proto` - Copy of backend proto file
- `lib/generated/updates.pb.dart` - Generated Dart gRPC code
- `lib/data/services/grpc_update_service.dart` - gRPC client service
- `lib/presentation/examples/live_updates_demo.dart` - Demo widget

**Features:**
- ✅ Subscribe to multiple data types
- ✅ Real-time UI updates
- ✅ Automatic reconnection handling
- ✅ Error handling and callbacks
- ✅ Clean subscription lifecycle management

## How to Use

### 1. Subscribe to Updates (Flutter)

```dart
import 'package:axle/data/services/grpc_update_service.dart';

final grpcService = GrpcUpdateService(
  host: 'localhost',
  port: 5103,
);

// Subscribe to user updates
final subscriptionId = await grpcService.subscribe(
  dataType: 'users',
  token: accessToken, // Your JWT token
  onUpdate: (UpdateMessage message) {
    // Handle the update
    print('Update received: ${message.data}');

    // Update your UI
    setState(() {
      userCount = parseUserCount(message.data);
    });
  },
  onError: (error) => print('Error: $error'),
  onDone: () => print('Stream ended'),
);

// Later: Unsubscribe
await grpcService.unsubscribe(subscriptionId);
```

### 2. Trigger Updates from Backend

#### Option A: Use the Test Endpoint

```bash
TOKEN="your_jwt_token"

curl -X POST "http://localhost:5103/api/trigger-update?dataType=users&data={\"count\":7}" \
  -H "Authorization: Bearer $TOKEN"
```

#### Option B: Call from Your Code

```csharp
// Inject IUpdateNotifier into your service/controller
public class UserService
{
    private readonly IUpdateNotifier _notifier;

    public UserService(IUpdateNotifier notifier)
    {
        _notifier = notifier;
    }

    public async Task CreateUser(User user)
    {
        // Save user to database
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        // Notify subscribers
        var userData = JsonSerializer.Serialize(new {
            userId = user.Id,
            email = user.Email,
            count = await _context.Users.CountAsync()
        });

        await _notifier.NotifyAsync(
            "users",
            ChangeType.Created,
            userData
        );
    }
}
```

### 3. Use the Demo Widget

```dart
import 'package:axle/presentation/examples/live_updates_demo.dart';

// Add to your router or navigate to it
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LiveUpdatesDemo(
      signInManager: signInManager,
    ),
  ),
);
```

## Available Data Types

The system is flexible - you can subscribe to any data type. Common examples:

| Data Type | Use Case | Example Data |
|-----------|----------|--------------|
| `users` | User count, new registrations | `{"count":7,"new":1}` |
| `orders` | New orders, order status | `{"orderId":"123","status":"paid"}` |
| `stats` | Dashboard statistics | `{"revenue":5000,"orders":42}` |
| `notifications` | System notifications | `{"message":"New feature available"}` |
| `messages` | Chat messages | `{"from":"user1","text":"Hello"}` |

Add your own by simply using a new `dataType` string!

## Message Format

All updates follow this structure:

```protobuf
message UpdateMessage {
  string updateId = 1;        // Unique ID for this update
  string dataType = 2;         // Type of data (users, orders, etc.)
  ChangeType changeType = 3;   // CREATED, UPDATED, DELETED, BATCH_UPDATE
  string data = 4;             // JSON string with the actual data
  int64 timestamp = 5;         // Unix timestamp in milliseconds
  map<string, string> metadata = 6; // Optional metadata
}
```

## Change Types

```dart
enum ChangeType {
  UNKNOWN = 0;
  CREATED = 1;      // New entity created
  UPDATED = 2;      // Existing entity modified
  DELETED = 3;      // Entity removed
  BATCH_UPDATE = 4; // Multiple entities changed
}
```

## Example: Reactive User Counter

### Backend - Trigger on User Creation

```csharp
// In your register endpoint
app.MapPost("/register", async (
    RegisterRequest request,
    UserManager<ApplicationUser> userManager,
    IUpdateNotifier notifier) =>
{
    var user = new ApplicationUser { /* ... */ };
    var result = await userManager.CreateAsync(user, request.Password);

    if (result.Succeeded)
    {
        // Notify all subscribers
        var userCount = await userManager.Users.CountAsync();
        await notifier.NotifyAsync(
            "users",
            ChangeType.Created,
            $"{{\"totalUsers\":{userCount}}}"
        );
    }

    return result.Succeeded
        ? Results.Ok()
        : Results.BadRequest(result.Errors);
});
```

### Flutter - Display Real-Time

```dart
class UserCountWidget extends StatefulWidget {
  @override
  State<UserCountWidget> createState() => _UserCountWidgetState();
}

class _UserCountWidgetState extends State<UserCountWidget> {
  int _userCount = 0;
  final _grpcService = GrpcUpdateService(host: 'localhost');

  @override
  void initState() {
    super.initState();
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() async {
    await _grpcService.subscribe(
      dataType: 'users',
      token: await getAccessToken(),
      onUpdate: (message) {
        final data = jsonDecode(message.data);
        setState(() {
          _userCount = data['totalUsers'] ?? 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total Users', style: TextStyle(fontSize: 16)),
            Text(
              '$_userCount',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _grpcService.close();
    super.dispose();
  }
}
```

## Testing the System

### 1. Start the Backend

```bash
cd backend
dotnet run
```

Backend will start on:
- HTTP: `http://localhost:5103`
- gRPC: `http://localhost:5103` (same port, HTTP/2)

### 2. Run the Flutter App

```bash
cd frontend
flutter run
```

### 3. Navigate to the Demo

- Look for "Live Updates Demo" in your app
- Or add navigation to `LiveUpdatesDemo` widget

### 4. Subscribe to Updates

1. Click "Subscribe" button
2. The app connects to the backend via gRPC

### 5. Trigger an Update

#### Terminal:
```bash
# Get your token from the Flutter app debug console
TOKEN="your_jwt_token_here"

# Trigger a user update
curl -X POST "http://localhost:5103/api/trigger-update?dataType=users&data={\"totalUsers\":7,\"newToday\":2}" \
  -H "Authorization: Bearer $TOKEN"
```

#### Or use any HTTP client (Postman, etc.)

### 6. Watch the Update Appear

The Flutter app should instantly show the update in the list!

## Advanced Features

### 1. Filtering Updates

```dart
await grpcService.subscribe(
  dataType: 'orders',
  token: token,
  filter: 'status:pending', // Only get pending orders
  onUpdate: (message) { /* ... */ },
);
```

### 2. Multiple Subscriptions

```dart
// Subscribe to multiple data types
final usersSub = await grpcService.subscribe(
  dataType: 'users',
  token: token,
  onUpdate: _handleUserUpdate,
);

final ordersSub = await grpcService.subscribe(
  dataType: 'orders',
  token: token,
  onUpdate: _handleOrderUpdate,
);
```

### 3. Metadata

```csharp
await notifier.NotifyAsync(
    "users",
    ChangeType.Updated,
    userData,
    metadata: new Dictionary<string, string>
    {
        ["source"] = "admin-panel",
        ["priority"] = "high"
    }
);
```

## Performance Considerations

### Backend

- **In-Memory Storage:** Current implementation uses in-memory storage for subscriptions
- **Scalability:** For production with multiple servers, use Redis or a message broker
- **Connection Limits:** Each subscription is an open HTTP/2 connection

### Frontend

- **Battery Usage:** Active connections use battery power
- **Unsubscribe:** Always unsubscribe when widget is disposed
- **Reconnection:** Implement reconnection logic for network issues

## Production Improvements

For production use, consider:

1. **Persistent Message Broker**
   - Use Redis Pub/Sub or RabbitMQ
   - Allows horizontal scaling of backend

2. **Message Queuing**
   - Queue updates if client is offline
   - Replay missed messages on reconnect

3. **Connection Management**
   - Implement heartbeat/ping-pong
   - Auto-reconnect on connection loss
   - Exponential backoff for retries

4. **Security**
   - Add authorization checks per data type
   - Validate filter parameters
   - Rate limiting per client

5. **Monitoring**
   - Track active subscriptions
   - Monitor message delivery
   - Alert on connection failures

## Troubleshooting

### "Connection Refused"

- Check backend is running on port 5103
- Verify gRPC is configured in Program.cs
- Check firewall/network settings

### "Unauthenticated"

- Ensure JWT token is valid and not expired
- Token must be passed in `SubscribeRequest.token`
- Check token validation logic in `UpdateStreamService`

### "No Updates Received"

- Verify subscription was successful
- Check backend logs for errors
- Try triggering update via `/api/trigger-update` endpoint
- Ensure `dataType` matches exactly

### Flutter Build Errors

If you get errors about missing generated files:

```bash
cd frontend
# Regenerate proto files
protoc --dart_out=grpc:lib/generated --proto_path=protos protos/updates.proto
flutter pub get
```

## Files Modified/Created

### Backend
- ✅ `Axle.csproj` - Added gRPC package
- ✅ `Protos/updates.proto` - Proto definition
- ✅ `Services/IUpdateNotifier.cs` - New
- ✅ `Services/UpdateNotifier.cs` - New
- ✅ `Grpc/UpdateStreamService.cs` - New
- ✅ `Program.cs` - Added gRPC configuration

### Frontend
- ✅ `pubspec.yaml` - Added gRPC packages
- ✅ `protos/updates.proto` - Copied from backend
- ✅ `lib/generated/updates.pb.dart` - Generated
- ✅ `lib/generated/updates.pbgrpc.dart` - Generated
- ✅ `lib/data/services/grpc_update_service.dart` - New
- ✅ `lib/presentation/examples/live_updates_demo.dart` - New

## Next Steps

1. **Integrate into Your App**
   - Add `GrpcUpdateService` to your services
   - Subscribe to updates in relevant widgets
   - Trigger notifications when data changes

2. **Add More Data Types**
   - Define your own data types
   - Create specific update handlers
   - Build reactive UI components

3. **Enhance the Backend**
   - Add more sophisticated filtering
   - Implement data validation
   - Add logging and monitoring

4. **Test Thoroughly**
   - Test reconnection scenarios
   - Verify memory usage
   - Check battery impact on mobile

## Support

If you run into issues:

1. Check the backend logs: `tail -f /tmp/axle-backend.log`
2. Check Flutter debug console for gRPC errors
3. Verify network connectivity between Flutter and backend
4. Test with the demo widget first before integrating

Your app now has real-time capabilities! 🎉
