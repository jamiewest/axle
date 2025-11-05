using Axle.Grpc;
using Axle.Services;
using System.Text.Json;

namespace Axle.Examples;

/// <summary>
/// Example showing how to use IUpdateNotifier in your services.
/// </summary>
public class UserNotificationExample
{
    private readonly IUpdateNotifier _notifier;

    public UserNotificationExample(IUpdateNotifier notifier)
    {
        _notifier = notifier;
    }

    // Example 1: Notify when user count changes
    public async Task NotifyUserCountChange(int totalUsers, int activeUsers)
    {
        var data = JsonSerializer.Serialize(new
        {
            totalUsers,
            activeUsers,
            timestamp = DateTimeOffset.UtcNow
        });

        await _notifier.NotifyAsync(
            dataType: "users",
            changeType: ChangeType.Updated,
            data: data
        );
    }

    // Example 2: Notify when new user is created
    public async Task NotifyNewUser(string userId, string email)
    {
        var data = JsonSerializer.Serialize(new
        {
            userId,
            email,
            action = "created"
        });

        var metadata = new Dictionary<string, string>
        {
            ["source"] = "registration",
            ["priority"] = "normal"
        };

        await _notifier.NotifyAsync(
            dataType: "users",
            changeType: ChangeType.Created,
            data: data,
            metadata: metadata
        );
    }

    // Example 3: Notify order status change
    public async Task NotifyOrderStatus(string orderId, string status, decimal amount)
    {
        var data = JsonSerializer.Serialize(new
        {
            orderId,
            status,
            amount,
            currency = "USD"
        });

        await _notifier.NotifyAsync(
            dataType: "orders",
            changeType: ChangeType.Updated,
            data: data
        );
    }

    // Example 4: Notify dashboard stats
    public async Task NotifyDashboardStats(int revenue, int orders, int customers)
    {
        var data = JsonSerializer.Serialize(new
        {
            revenue,
            orders,
            customers,
            period = "today"
        });

        await _notifier.NotifyAsync(
            dataType: "stats",
            changeType: ChangeType.BatchUpdate,
            data: data
        );
    }

    // Example 5: Notify system message
    public async Task NotifySystemMessage(string message, string severity)
    {
        var data = JsonSerializer.Serialize(new
        {
            message,
            severity, // info, warning, error
            timestamp = DateTimeOffset.UtcNow
        });

        await _notifier.NotifyAsync(
            dataType: "notifications",
            changeType: ChangeType.Created,
            data: data
        );
    }
}

// Usage in your endpoints or services:
//
// app.MapPost("/api/users", async (CreateUserRequest request, IUpdateNotifier notifier) =>
// {
//     // Create user logic...
//     var user = await CreateUser(request);
//
//     // Notify subscribers
//     var example = new UserNotificationExample(notifier);
//     await example.NotifyNewUser(user.Id, user.Email);
//
//     return Results.Ok(user);
// });
