using Axle.Grpc;

namespace Axle.Services;

/// <summary>
/// Service for notifying subscribers of data changes.
/// </summary>
public interface IUpdateNotifier
{
    /// <summary>
    /// Notify subscribers of a data change.
    /// </summary>
    Task NotifyAsync(string dataType, ChangeType changeType, string data, Dictionary<string, string>? metadata = null);

    /// <summary>
    /// Register a subscription for a data type.
    /// </summary>
    string Subscribe(string dataType, Func<UpdateMessage, Task> callback);

    /// <summary>
    /// Unregister a subscription.
    /// </summary>
    bool Unsubscribe(string subscriptionId);
}
