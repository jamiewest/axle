using System.Text.Json;
using Axle.Grpc;
using Axle.Services;

namespace Axle.Extensions;

/// <summary>
/// Extension methods to make it easy to trigger updates from anywhere in your code.
/// </summary>
public static class UpdateNotifierExtensions
{
    /// <summary>
    /// Notify about user-related changes.
    /// </summary>
    public static async Task NotifyUserChangeAsync(
        this IUpdateNotifier notifier,
        ChangeType changeType,
        object userData)
    {
        await notifier.NotifyAsync(
            dataType: "users",
            changeType: changeType,
            data: JsonSerializer.Serialize(userData)
        );
    }

    /// <summary>
    /// Notify about order changes.
    /// </summary>
    public static async Task NotifyOrderChangeAsync(
        this IUpdateNotifier notifier,
        ChangeType changeType,
        string orderId,
        string status)
    {
        await notifier.NotifyAsync(
            dataType: "orders",
            changeType: changeType,
            data: JsonSerializer.Serialize(new { orderId, status })
        );
    }

    /// <summary>
    /// Notify about statistics updates.
    /// </summary>
    public static async Task NotifyStatsUpdateAsync(
        this IUpdateNotifier notifier,
        string statName,
        double value,
        string? unit = null)
    {
        await notifier.NotifyAsync(
            dataType: "stats",
            changeType: ChangeType.Updated,
            data: JsonSerializer.Serialize(new { statName, value, unit })
        );
    }

    /// <summary>
    /// Send a notification to users.
    /// </summary>
    public static async Task SendNotificationAsync(
        this IUpdateNotifier notifier,
        string title,
        string message,
        string? userId = null)
    {
        await notifier.NotifyAsync(
            dataType: "notifications",
            changeType: ChangeType.Created,
            data: JsonSerializer.Serialize(new { title, message, userId })
        );
    }

    /// <summary>
    /// Generic helper for custom data types.
    /// </summary>
    public static async Task NotifyCustomAsync<T>(
        this IUpdateNotifier notifier,
        string dataType,
        ChangeType changeType,
        T data)
    {
        await notifier.NotifyAsync(
            dataType: dataType,
            changeType: changeType,
            data: JsonSerializer.Serialize(data)
        );
    }
}
